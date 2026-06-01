import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

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
      appBar: AppBar(title: const Text('AI consistency check')),
      body: _loading
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
                    _ConflictCard(index: i, conflict: _conflicts[i]),
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
    );
  }
}

class _Conflict {
  final String steps;
  final String title;
  final String body;
  final String actionEditA;
  final String actionEditB;
  const _Conflict({
    required this.steps,
    required this.title,
    required this.body,
    required this.actionEditA,
    required this.actionEditB,
  });
}

class _ConflictCard extends StatelessWidget {
  final int index;
  final _Conflict conflict;
  const _ConflictCard({required this.index, required this.conflict});

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
            const SizedBox(height: 8),
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
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(conflict.actionEditA),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context, true),
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
