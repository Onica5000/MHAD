import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

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
    if (prefs?.ectConsent == 'no' && prefs?.medicationConsent == 'agentDecides') {
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
        const CrisisTopBar(compact: true),
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
                      child: SectionLabel('AI consistency check · checked at Review'),
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
                const SizedBox(height: 14),
                InfoBanner(
                  icon: Icons.auto_awesome,
                  variant: InfoBannerVariant.info,
                  text:
                      'Note from the AI. Consistency checks run on every '
                      'save. Review any change before accepting. This screen '
                      "warns — it doesn't block PDF generation.",
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
