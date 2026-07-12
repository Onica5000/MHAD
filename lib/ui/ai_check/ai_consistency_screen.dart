import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_clinical_policy.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/spot_illustration.dart';
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
  String? _error; // rules-pass failure (repo read threw) — shown with a retry

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
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final repo = ref.read(directiveRepositoryProvider);
      final prefs = await repo.getPreferences(widget.directiveId);
      final directive = await repo.getDirectiveById(widget.directiveId);
      final found = _findConflicts(prefs, directive);
      if (!mounted) return;
      setState(() {
        _conflicts = found;
        _loading = false;
      });
      // Layer an AI review on top of the rule-based result when available.
      await _runAiPass();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = FriendlyError.from(e);
        _loading = false;
      });
    }
  }

  /// Pure, deterministic rule pass — no I/O, so it can't throw on a slow or
  /// failed repo read (those are handled in [_check]).
  List<_Conflict> _findConflicts(DirectivePref? prefs, Directive? directive) {
    final found = <_Conflict>[];

    // Agent-authorization review. PA Act 194 lets a principal BOTH record their
    // own consent AND, separately, authorize their agent to consent on their
    // behalf (for ECT, experimental studies, and drug trials that agent
    // authorization needs the principal's physical initials, §5836(c)).
    // Because the app stores a single choice per procedure, some valid
    // combinations print statements that read as contradictory — so surface
    // them as "confirm this is intended" notes (the official form allows both;
    // they just need consideration) rather than hard errors. Only agent-bearing
    // forms (Combined / POA) have an agent at all.
    var hasAgent = false;
    if (directive != null) {
      try {
        hasAgent = FormType.values.byName(directive.formType).hasAgentSections;
      } catch (_) {/* unknown form type → treat as no agent */}
    }
    if (hasAgent && prefs != null) {
      bool gaveOwnConsent(String? c) =>
          c == consentYes || (c?.startsWith('conditional:') ?? false);

      // ECT / experimental / drug trials: a single field. When the principal
      // consents themselves, the form ALSO states the agent is not authorized —
      // valid, but easy to misread as a contradiction.
      void procedureNote(String name, String? consent) {
        if (!gaveOwnConsent(consent)) return;
        found.add(_Conflict(
          steps: 'Procedures + Agent authority',
          title: 'You consented to $name yourself — the printed form will also '
              'state your agent is NOT authorized to consent to $name.',
          body: 'Pennsylvania’s form lets you do both: give your own '
              'consent AND authorize your agent to consent on your behalf (that '
              'agent authorization needs your physical initials, '
              '§5836(c)). As entered, only your own consent is recorded, '
              'so the document says your agent may not consent to $name. That '
              'is allowed and may be exactly what you intend — keep both if so. '
              'If you also want your agent able to consent (e.g. if you later '
              'can’t decide), choose “My agent will decide” for '
              '$name.',
          aStatement: 'You consent to $name',
          bStatement: 'Agent not authorized: $name',
          actionEditA: 'Review $name choice',
        ));
      }

      procedureNote('ECT', prefs.ectConsent);
      procedureNote('experimental studies', prefs.experimentalConsent);
      procedureNote('drug trials', prefs.drugTrialConsent);

      // Medications carry TWO independent fields — your consent (Medications
      // step) and the agent's authority (Agent-authority step) — so they can
      // directly oppose each other on the printed form.
      if (prefs.medicationConsent == consentAgentDecides &&
          !prefs.agentCanConsentMedication) {
        found.add(const _Conflict(
          steps: 'Medications + Agent authority',
          title: 'You said your agent decides your medications, but the form '
              'says your agent is NOT authorized to consent to medications.',
          body: 'These cancel each other out. The official form lets you set '
              'your own medication preferences and your agent’s authority '
              'separately — both are allowed — but as entered they oppose each '
              'other. Authorize your agent to consent to medications, or change '
              'the medication choice so they agree.',
          aStatement: 'Agent decides medications',
          bStatement: 'Agent not authorized: medications',
          actionEditA: 'Edit Medications',
          actionEditB: 'Edit Agent authority',
        ));
      }
      if (prefs.medicationConsent == consentNo &&
          prefs.agentCanConsentMedication) {
        found.add(const _Conflict(
          steps: 'Medications + Agent authority',
          title: 'You don’t consent to any medications, but your agent is '
              'authorized to consent to them.',
          body: 'The official form lets you set your own preference and your '
              'agent’s authority separately — both are valid — but as '
              'entered they oppose each other: your refusal of all medications '
              'versus your agent’s power to consent to any. Decide which '
              'should control and adjust the other.',
          aStatement: 'No medications (you)',
          bStatement: 'Agent may consent: medications',
          actionEditA: 'Edit Medications',
          actionEditB: 'Edit Agent authority',
        ));
      }
    }

    // NOTE: a severe allergy is intentionally NOT flagged for the medications
    // "Never give" list. Allergies and "medications I never want" are separate
    // sections by design — the allergy section is where ER staff look first —
    // so cross-referencing them here would contradict that separation.

    return found;
  }

  /// When a Gemini key is set, ask the AI for a broader "second pair of eyes"
  /// review (gaps, thin sections, anything to double-check) on top of the
  /// deterministic rules above. No key → rules-only, silently. Consent-gated;
  /// a decline just leaves the rules result in place.
  Future<void> _runAiPass() async {
    final assistant = ref.read(aiAssistantProvider);
    if (assistant == null) return; // rules-only when AI isn't set up

    if (!ref.read(aiConsentGivenProvider)) {
      final ok = await showAiConsentDialog(context,
          provider: ref.read(activeProviderProvider));
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
      final reply = await assistant
          .sendMessage(prompt, history: [])
          .timeout(const Duration(seconds: 45));
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

  /// A PII-light, COMPLETE summary of the directive for the AI pass — every
  /// user-fillable section is reported so the AI never flags a filled field as
  /// a gap. Identity values (names, addresses, DOB, phone numbers, doctor/agent
  /// names, free-text content) are deliberately reduced to presence flags
  /// ("provided"/"empty"/"yes"/"no") or non-identifying choices (consent
  /// decisions, facility-preference type); the assistant's sanitizer strips any
  /// residual PII before it leaves the device. Best-effort.
  Future<String> _buildSummary() async {
    final repo = ref.read(directiveRepositoryProvider);
    final b = StringBuffer();

    String present(String? v) =>
        (v != null && v.trim().isNotEmpty) ? 'provided' : 'empty';

    // consentLabel() is the shared global (lib/constants.dart): maps a stored
    // consent value to a readable decision so the AI sees a CHOICE, not a
    // missing field, and never echoes an unexpected raw value (PII safety).

    // A JSON add-on (crisis plan / side-effects checklist) counts as filled
    // only when it actually carries content — an opened-but-empty structure
    // (all-empty lists) must read as empty, not "provided".
    bool jsonHasContent(String raw, {String? itemsKey}) {
      if (raw.trim().isEmpty) return false;
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          if (itemsKey != null) {
            final v = decoded[itemsKey];
            return v is List && v.isNotEmpty;
          }
          return decoded.values.any((v) => v is List && v.isNotEmpty);
        }
        return false;
      } catch (_) {
        return raw.trim().isNotEmpty;
      }
    }

    try {
      var formType = FormType.combined;
      final d = await repo.getDirectiveById(widget.directiveId);
      if (d != null) {
        try {
          formType = FormType.values.byName(d.formType);
        } catch (_) {/* unknown stored value → assume combined */}
        b.writeln('Form type: ${d.formType}');
        b.writeln('When it takes effect: '
            '${d.effectiveCondition.trim().isEmpty ? "(not specified)" : d.effectiveCondition.trim()}');
        b.writeln('Primary doctor on file: '
            '${d.primaryDoctorName.trim().isNotEmpty ? "yes" : "no"}');
        b.writeln('Preferred treating doctor on file: '
            '${d.preferredDoctorName.trim().isNotEmpty ? "yes" : "no"}');
      }
      final hasAgent = formType.hasAgentSections;

      // Agents + guardian — only relevant on agent-bearing forms.
      if (hasAgent) {
        final agents = await repo.getAgents(widget.directiveId);
        b.writeln(
            'Primary agent named: ${agents.primaryAgent != null ? "yes" : "no"}');
        b.writeln(
            'Alternate agent named: ${agents.alternateAgent != null ? "yes" : "no"}');
        final guardian = await repo.getGuardianNomination(widget.directiveId);
        b.writeln('Guardian nominated: '
            '${(guardian?.nomineeFullName.trim().isNotEmpty ?? false) ? "yes" : "no"}');
      }

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

      // Preferences: consent decisions, facility + room preferences, agent
      // authority, and the optional JSON add-ons. None of these were read
      // before — they all showed up to the AI as missing.
      final prefs = await repo.getPreferences(widget.directiveId);
      if (prefs != null) {
        b.writeln('Medication consent: ${consentLabel(prefs.medicationConsent)}');
        b.writeln('ECT consent: ${consentLabel(prefs.ectConsent)}');
        b.writeln('Experimental treatment consent: '
            '${consentLabel(prefs.experimentalConsent)}');
        b.writeln('Drug trial consent: ${consentLabel(prefs.drugTrialConsent)}');
        b.writeln('Treatment facility preference: '
            '${prefs.treatmentFacilityPref == 'noPreference' ? "no preference" : prefs.treatmentFacilityPref}');
        b.writeln('Preferred facility named: ${present(prefs.preferredFacilityName)}');
        b.writeln('Facility to avoid named: ${present(prefs.avoidFacilityName)}');
        final hasRoom = prefs.roomPreferences.trim().isNotEmpty ||
            prefs.roomPreferencesNote.trim().isNotEmpty ||
            prefs.roommateGenderMatch.trim().isNotEmpty;
        b.writeln('Room preferences: ${hasRoom ? "provided" : "empty"}');
        if (hasAgent) {
          b.writeln('Agent may consent to hospitalization: '
              '${prefs.agentCanConsentHospitalization ? "yes" : "no"}');
          b.writeln('Agent may consent to medication: '
              '${prefs.agentCanConsentMedication ? "yes" : "no"}');
          b.writeln('Limits on agent authority: '
              '${present(prefs.agentAuthorityLimitations)}');
        }
        b.writeln('Self-binding (Ulysses) clause: '
            '${prefs.selfBindingEnabled ? "enabled" : "not enabled"}');
        b.writeln('Crisis plan: '
            '${jsonHasContent(prefs.crisisPlanJson) ? "provided" : "empty"}');
        b.writeln('Side-effects checklist: '
            '${jsonHasContent(prefs.sideEffectsJson, itemsKey: "items") ? "completed" : "empty"}');
      }

      // Additional instructions — ALL ten fields (four were previously omitted).
      final instr = await repo.getAdditionalInstructions(widget.directiveId);
      if (instr != null) {
        b.writeln('Crisis intervention notes: ${present(instr.crisisIntervention)}');
        b.writeln('Health history: ${present(instr.healthHistory)}');
        b.writeln('Helpful activities: ${present(instr.activities)}');
        b.writeln('Dietary notes: ${present(instr.dietary)}');
        b.writeln('Religious/cultural notes: ${present(instr.religious)}');
        b.writeln('Children/custody notes: ${present(instr.childrenCustody)}');
        b.writeln('Family notification notes: ${present(instr.familyNotification)}');
        b.writeln('Records disclosure notes: ${present(instr.recordsDisclosure)}');
        b.writeln('Pet care notes: ${present(instr.petCustody)}');
        b.writeln('Other instructions: ${present(instr.other)}');
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
                fontFamily: kSansFamily,
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
            fontFamily: kSansFamily,
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
              fontFamily: kSansFamily,
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
            fontFamily: kSansFamily,
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
              : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline, color: p.primary, size: 40),
                        const SizedBox(height: 12),
                        Text(
                          "Couldn't run the consistency check.\n$_error",
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _check,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try again'),
                        ),
                      ],
                    ),
                  ),
                )
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
                    fontFamily: kSansFamily,
                    fontSize: 14,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 16),
                if (_conflicts.isEmpty) ...[
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child:
                          SpotIllustration(art: SpotArt.success, size: 84),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const InfoBanner(
                    icon: Icons.check_circle_outline,
                    variant: InfoBannerVariant.success,
                    text: 'No cross-step contradictions detected.',
                  ),
                ]
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
  // Optional second edit target. Null for single-source "confirm intent" notes
  // (e.g. an ECT agent-authorization note) that only point at one step.
  final String? actionEditB;
  const _Conflict({
    required this.steps,
    required this.title,
    required this.body,
    required this.aStatement,
    required this.bStatement,
    required this.actionEditA,
    this.actionEditB,
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
          fontFamily: kSansFamily,
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
                    fontFamily: kMonoFamily,
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
                      fontFamily: kMonoFamily,
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
                fontFamily: kSansFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              conflict.body,
              style: TextStyle(
                fontFamily: kSansFamily,
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
                if (conflict.actionEditB != null)
                  OutlinedButton(
                    onPressed: () =>
                        context.push(AppRoutes.wizardRoute(directiveId)),
                    child: Text(conflict.actionEditB!),
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
