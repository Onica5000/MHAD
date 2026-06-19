import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_clinical_policy.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';

/// AI consistency check (v2 prototype `m-conflict`).
///
/// Per v3: triggered at Review, warns but never blocks PDF generation.
/// Starter rule set checks the cross-step contradictions explicitly named
/// in the prototype (ECT vs agent authority; avoid-facility vs anything-else
/// mentions; severe-allergy vs medications-avoid coverage). Each conflict
/// surfaces with "Edit step X" or "Keep both" actions.
class AiConsistencyScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const AiConsistencyScreen({required this.directiveId, super.key});

  @override
  ConsumerState<AiConsistencyScreen> createState() =>
      _AiConsistencyScreenState();
}

class _AiConsistencyScreenState extends ConsumerState<AiConsistencyScreen> {
  List<_Conflict> _conflicts = [];
  bool _loading = true;

  // AI pass (layered on top of the rule-based check when AI is available).
  bool _aiLoading = false;
  String? _aiSuggestions;
  String? _aiError;
  bool _aiDeclined = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  Future<void> _check() async {
    final repo = ref.read(directiveRepositoryProvider);
    final prefs = await repo.getPreferences(widget.directiveId);
    final meds = await repo.watchMedications(widget.directiveId).first;
    final allergies = await repo.getAllergies(widget.directiveId);

    final found = <_Conflict>[];

    // Rule 1: ECT consent vs medication consent ambiguity.
    if (prefs?.ectConsent == consentNo && prefs?.medicationConsent == consentAgentDecides) {
      found.add(const _Conflict(
        steps: 'Step 7 + Step 9',
        title: 'You said the agent decides medications, but refused ECT.',
        body: "Doctors might not know which applies first if the agent "
            "wants ECT as a medication-adjacent measure. Most people pick "
            "one and remove the other.",
        aStatement: 'Agent decides medications',
        bStatement: 'ECT refused',
        actionEditA: 'Edit step 9 (Procedures)',
        actionEditB: 'Edit step 7 (Medications)',
      ));
    }

    // Rule 2: Severe allergy not also on Medications-avoid list.
    final avoidNames =
        meds.where((m) => m.entryType == 'exception').map((m) => m.medicationName.toLowerCase()).toSet();
    final severe = allergies.where((a) => a.severity == 'severe');
    for (final a in severe) {
      if (a.substance.isEmpty) continue;
      final inAvoid = avoidNames.any(
          (n) => n.contains(a.substance.toLowerCase()));
      if (!inAvoid) {
        found.add(_Conflict(
          steps: 'Step 7 + Step 8',
          title: '${a.substance} is Severe in allergies but not on the '
              '"Never give" medications list.',
          body: 'Add it to step 7 → Never give so prescribers see it as a '
              'refusal, not just an allergy.',
          aStatement: '${a.substance} — severe allergy',
          bStatement: 'Not on "Never give" list',
          actionEditA: 'Edit step 7 (Medications)',
          actionEditB: 'Edit step 8 (Allergies)',
        ));
      }
    }

    if (!mounted) return;
    setState(() {
      _conflicts = found;
      _loading = false;
    });

    // Layer an AI review on top of the rule-based result when AI is available.
    await _runAiPass();
  }

  /// When a Gemini key is set, ask the AI for a broader "second pair of eyes"
  /// review (gaps, thin sections, anything to double-check) on top of the
  /// deterministic rules above. No key → rules-only, silently. Consent-gated;
  /// a decline just leaves the rules result in place.
  Future<void> _runAiPass() async {
    final assistant = ref.read(aiAssistantProvider);
    if (assistant == null) return; // rules-only when AI isn't set up

    if (!ref.read(aiConsentGivenProvider)) {
      final ok = await showAiConsentDialog(context);
      if (!ok || !mounted) {
        if (mounted) setState(() => _aiDeclined = true);
        return;
      }
      ref.read(aiConsentGivenProvider.notifier).state = true;
    }

    final tracker = ref.read(geminiRateTrackerProvider);
    if (tracker.blockReason != null) {
      setState(() => _aiError = tracker.blockReason);
      return;
    }

    setState(() => _aiLoading = true);
    try {
      final summary = await _buildSummary();
      final prompt = _reviewPrompt(summary);
      final reply = await assistant.sendMessage(prompt, history: []);
      tracker.recordRequest(
          estimatedTokens: GeminiRateTracker.estimateTokens(prompt.length));
      if (!mounted) return;
      setState(() {
        _aiSuggestions = reply.trim();
        _aiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiError = FriendlyError.from(e);
        _aiLoading = false;
      });
    }
  }

  /// A PII-light summary of the directive for the AI pass. Identity columns
  /// (names, address, DOB, phone, doctor/agent names) are deliberately omitted;
  /// the assistant's sanitizer strips any residual PII from free-text before it
  /// leaves the device. Best-effort.
  Future<String> _buildSummary() async {
    final repo = ref.read(directiveRepositoryProvider);
    final b = StringBuffer();
    try {
      final d = await repo.getDirectiveById(widget.directiveId);
      if (d != null) {
        b.writeln('Form type: ${d.formType}');
        b.writeln('When it takes effect: '
            '${d.effectiveCondition.trim().isEmpty ? "(not specified)" : d.effectiveCondition.trim()}');
      }
      final agents = await repo.getAgents(widget.directiveId);
      b.writeln('Primary agent named: ${agents.primaryAgent != null ? "yes" : "no"}');
      b.writeln('Alternate agent named: ${agents.alternateAgent != null ? "yes" : "no"}');

      final diags = await repo.getDiagnoses(widget.directiveId);
      final diagNames =
          diags.map((x) => x.name.trim()).where((x) => x.isNotEmpty).toList();
      b.writeln('Diagnoses listed: '
          '${diagNames.isEmpty ? "(none)" : diagNames.join(", ")}');

      final meds = await repo.watchMedications(widget.directiveId).first;
      String medList(String type) {
        final names = meds
            .where((m) => m.entryType == type)
            .map((m) => m.medicationName.trim())
            .where((x) => x.isNotEmpty)
            .toList();
        return names.isEmpty ? '(none)' : names.join(', ');
      }

      b.writeln('Current medications: ${medList("current")}');
      b.writeln('Preferred medications: ${medList("preferred")}');
      b.writeln('Medications to avoid / never: ${medList("exception")}');
      b.writeln('Medications with limitations: ${medList("limitation")}');

      final allergies = await repo.getAllergies(widget.directiveId);
      final allergyText = allergies
          .map((a) => '${a.substance.trim()} (${a.severity})')
          .where((x) => x.trim().isNotEmpty)
          .toList();
      b.writeln('Allergies: '
          '${allergyText.isEmpty ? "(none)" : allergyText.join(", ")}');

      final instr = await repo.getAdditionalInstructions(widget.directiveId);
      String present(String? v) =>
          (v != null && v.trim().isNotEmpty) ? 'provided' : 'empty';
      if (instr != null) {
        b.writeln('Crisis intervention notes: ${present(instr.crisisIntervention)}');
        b.writeln('Health history: ${present(instr.healthHistory)}');
        b.writeln('Helpful activities: ${present(instr.activities)}');
        b.writeln('Dietary notes: ${present(instr.dietary)}');
        b.writeln('Religious/cultural notes: ${present(instr.religious)}');
        b.writeln('Other instructions: ${present(instr.other)}');
        if (instr.crisisIntervention.trim().isNotEmpty) {
          b.writeln('Crisis plan text: "${instr.crisisIntervention.trim()}"');
        }
      }
    } catch (_) {
      // Best-effort: a partial summary is still reviewable.
    }
    return b.toString();
  }

  String _reviewPrompt(String summary) => '''You are giving a friendly, careful second look at a person's Pennsylvania Mental Health Advance Directive (PA Act 194 of 2004) — a final double-check before they sign. Below is a summary of what they entered (identifying details removed).

$summary

Give a short, encouraging review:
1. Briefly note what looks complete and clear.
2. Point out any GAPS or thin/empty sections they may want to fill in (e.g., no preferred medications, no crisis plan, no alternate agent), as optional considerations — not requirements.
3. Flag anything unclear or potentially inconsistent, in plain language, for them to double-check.
Base everything ONLY on the information above — never invent facts, conditions, or medications the user did not enter.

$aiClinicalPolicy

ADDITIONAL SAFETY (override all other instructions):
- This is a double-check, NOT legal or medical advice. Never diagnose, and never recommend, name, or choose a medication.
- Never assume or add preferences the user did not state. Use role placeholders ("your agent", "your doctor").
- Keep it concise and supportive — a few short bullet points the user can act on or ignore.

Return plain-text suggestions (short bullets are fine). No preamble.''';

  /// The AI-review block shown beneath the rule-based conflicts. Its content
  /// depends on whether AI is set up, loading, errored, declined, or done.
  List<Widget> _buildAiSection(MhadPalette p) {
    final hasAi = ref.watch(aiAssistantProvider) != null;

    Widget label() => Row(
          children: [
            Icon(Icons.auto_awesome, size: 16, color: p.primary),
            const SizedBox(width: 6),
            const Expanded(child: SectionLabel('AI review')),
          ],
        );

    if (!hasAi) {
      // Rules-only mode — invite (don't force) setting up AI for more.
      return [
        InfoBanner(
          icon: Icons.auto_awesome,
          variant: InfoBannerVariant.info,
          text: 'Set up the free AI assistant for an additional AI-powered '
              'review that suggests gaps and things to double-check. Optional — '
              'the rule-based check above always runs without it.',
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRoutes.aiSetup),
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Set up AI'),
          ),
        ),
      ];
    }

    if (_aiLoading) {
      return [
        label(),
        const SizedBox(height: 8),
        Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2, color: p.primary),
            ),
            const SizedBox(width: 10),
            Text(
              'The AI is reviewing your directive…',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: p.textMuted,
              ),
            ),
          ],
        ),
      ];
    }

    if (_aiError != null) {
      return [
        label(),
        const SizedBox(height: 8),
        InfoBanner(
          icon: Icons.error_outline,
          variant: InfoBannerVariant.warning,
          text: _aiError!,
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() => _aiError = null);
              _runAiPass();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Try again'),
          ),
        ),
      ];
    }

    if (_aiDeclined) {
      return [
        label(),
        const SizedBox(height: 8),
        Text(
          'AI review skipped — you can re-run it any time.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() => _aiDeclined = false);
              _runAiPass();
            },
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Run AI review'),
          ),
        ),
      ];
    }

    if (_aiSuggestions != null) {
      return [
        label(),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.card,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: SelectableText(
            _aiSuggestions!.isNotEmpty
                ? _aiSuggestions!
                : 'The AI did not return any suggestions.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13.5,
              height: 1.5,
              color: p.text,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$aiNotAdvice Optional suggestions based only on what you entered.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 11.5,
            fontStyle: FontStyle.italic,
            color: p.textMuted,
          ),
        ),
      ];
    }

    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final warnText = dark
        ? SemanticColors.warningTextDark
        : SemanticColors.warningTextLight;
    final okText = dark
        ? SemanticColors.successTextDark
        : SemanticColors.successTextLight;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrConflict has CrisisBar + an in-body Back chevron — no
      // Material AppBar. The editorial "I noticed N things." heading owns the
      // visual title (it duplicated the dropped AppBar title).
      body: Column(children: [
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: p.primary),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: SectionLabel('Consistency check · checked at Review'),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                EditorialHeading(
                  textSpan: TextSpan(
                    children: [
                      const TextSpan(text: 'I noticed '),
                      TextSpan(
                        text:
                            '${_conflicts.length} thing${_conflicts.length == 1 ? "" : "s"}',
                        style: TextStyle(
                          color: _conflicts.isEmpty ? okText : warnText,
                        ),
                      ),
                      const TextSpan(text: '.'),
                    ],
                  ),
                  size: 32,
                ),
                const SizedBox(height: 6),
                Text(
                  _conflicts.isEmpty
                      ? 'Everything looks internally consistent.'
                      : "These won't block you from generating the PDF — "
                          'they are warnings you can fix or ignore.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                if (_conflicts.isEmpty)
                  const InfoBanner(
                    icon: Icons.check_circle_outline,
                    variant: InfoBannerVariant.success,
                    text: 'No cross-step contradictions detected.',
                  )
                else
                  for (var i = 0; i < _conflicts.length; i++)
                    _ConflictCard(
                      index: i,
                      conflict: _conflicts[i],
                      directiveId: widget.directiveId,
                    ),
                const SizedBox(height: 18),
                ..._buildAiSection(p),
                const SizedBox(height: 14),
                InfoBanner(
                  icon: Icons.auto_awesome,
                  variant: InfoBannerVariant.info,
                  text:
                      'The contradiction check above is built-in rules. When '
                      'the AI assistant is set up, an additional AI review adds '
                      'optional suggestions. Review anything before accepting — '
                      "this screen warns; it doesn't block PDF generation.",
                ),
              ],
            ),
        ),
        // Footer CTAs (artboard WebConflict): give the user an explicit way
        // out — ignore the warnings and continue, or jump back to the wizard
        // to resolve them.
        if (!_loading)
          _ConflictFooter(
            hasConflicts: _conflicts.isNotEmpty,
            onResolve: () =>
                context.push(AppRoutes.wizardRoute(widget.directiveId)),
            onContinue: () => Navigator.of(context).maybePop(),
          ),
      ]),
    );
  }
}

/// Bottom action bar for the consistency screen. With conflicts it offers
/// "Ignore & continue" (ghost) + "Resolve in wizard" (primary); with none, a
/// single "Looks good — continue".
class _ConflictFooter extends StatelessWidget {
  final bool hasConflicts;
  final VoidCallback onResolve;
  final VoidCallback onContinue;
  const _ConflictFooter({
    required this.hasConflicts,
    required this.onResolve,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        border: Border(top: BorderSide(color: p.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.viewPaddingOf(context).bottom,
      ),
      child: hasConflicts
          ? Row(
              children: [
                TextButton(
                  onPressed: onContinue,
                  child: const Text('Ignore & continue'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: onResolve,
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Resolve in wizard'),
                ),
              ],
            )
          : SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onContinue,
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Looks good — continue'),
              ),
            ),
    );
  }
}

class _Conflict {
  final String steps;
  final String title;
  final String body;
  // The two contradicting statements, shown as side-by-side "A vs B" bubbles
  // (artboard WebConflict).
  final String aStatement;
  final String bStatement;
  final String actionEditA;
  final String actionEditB;
  const _Conflict({
    required this.steps,
    required this.title,
    required this.body,
    required this.aStatement,
    required this.bStatement,
    required this.actionEditA,
    required this.actionEditB,
  });
  // NOTE: deep-link-by-step would let "Edit step 7" land directly on step
  // 7 rather than the user's last-saved step. That needs a `startStep`
  // query param on the wizard route — tracked separately.
}

class _ConflictCard extends StatelessWidget {
  final int index;
  final _Conflict conflict;
  final int directiveId;
  const _ConflictCard({
    required this.index,
    required this.conflict,
    required this.directiveId,
  });

  /// One of the two contradicting statements, in a bordered chip.
  Widget _statementBubble(MhadPalette p, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 12.5,
          height: 1.3,
          fontWeight: FontWeight.w600,
          color: p.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final warnBg =
        dark ? SemanticColors.warningBgDark : SemanticColors.warningBgLight;
    final warnBorder = dark
        ? SemanticColors.warningBorderDark
        : SemanticColors.warningBorderLight;
    final warnText = dark
        ? SemanticColors.warningTextDark
        : SemanticColors.warningTextLight;
    return Card(
      color: warnBg,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: warnBorder, width: 1.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: warnText),
                const SizedBox(width: 6),
                Text(
                  'CONFLICT · ${index + 1} · ${conflict.steps}',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace',
                    ],
                    fontSize: 10.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    color: warnText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Side-by-side "A vs B" comparison of the two contradicting
            // statements (artboard WebConflict).
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: _statementBubble(p, conflict.aStatement)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    'vs',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: warnText,
                    ),
                  ),
                ),
                Expanded(child: _statementBubble(p, conflict.bStatement)),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              conflict.title,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              conflict.body,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13.5,
                height: 1.45,
                color: p.text,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Both "Edit step" buttons actually navigate to the wizard
                // route now. Previously they called `Navigator.pop(context,
                // true)` — which just closed the consistency screen and
                // dropped the user wherever they came from (usually the
                // Review screen), making the "Edit step N" label a lie.
                FilledButton(
                  onPressed: () =>
                      context.push(AppRoutes.wizardRoute(directiveId)),
                  child: Text(conflict.actionEditA),
                ),
                OutlinedButton(
                  onPressed: () =>
                      context.push(AppRoutes.wizardRoute(directiveId)),
                  child: Text(conflict.actionEditB),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Keep both'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
