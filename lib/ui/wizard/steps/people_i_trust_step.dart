import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/steps/agent_authority_step.dart';
import 'package:mhad/ui/wizard/steps/agent_designation_step.dart';
import 'package:mhad/ui/wizard/steps/alternate_agent_step.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

/// Merged wizard step that combines [AgentDesignationStep],
/// [AlternateAgentStep], and [AgentAuthorityStep]. Matches the prototype's
/// step 03 "People I trust" — only shown for Combined / POA form types.
class PeopleITrustStep extends ConsumerStatefulWidget {
  final int directiveId;
  const PeopleITrustStep({required this.directiveId, super.key});

  @override
  ConsumerState<PeopleITrustStep> createState() => _PeopleITrustStepState();
}

class _PeopleITrustStepState extends ConsumerState<PeopleITrustStep>
    with WizardStepMixin {
  final _primaryKey = GlobalKey<State<AgentDesignationStep>>();
  final _alternateKey = GlobalKey<State<AlternateAgentStep>>();
  final _authorityKey = GlobalKey<State<AgentAuthorityStep>>();

  @override
  Future<bool> validateAndSave() async {
    bool ok = true;
    for (final k in [_primaryKey, _alternateKey, _authorityKey]) {
      final s = k.currentState;
      if (s is WizardStepMixin) {
        ok = await (s as WizardStepMixin).validateAndSave() && ok;
      }
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionLabel('Primary agent · required'),
        Text(
          'The person you trust most to speak for you.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: p.textMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 8),
        AgentDesignationStep(
          key: _primaryKey,
          directiveId: widget.directiveId,
          embedded: true,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        const SectionLabel('Alternate agent · optional'),
        Text(
          'Steps in only if your primary agent is unable or unwilling.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: p.textMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 8),
        AlternateAgentStep(
          key: _alternateKey,
          directiveId: widget.directiveId,
          embedded: true,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        // Section label paired with the statute reference, matching the
        // prototype `ScrWizardPeople` L686-689: SectionLabel left, MONO
        // "20 Pa.C.S. § 5836" right. This is the headline citation for
        // PA's enumerated agent powers and the prototype surfaces it
        // above the consent rows so users see the legal anchor.
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Expanded(child: SectionLabel('What can they decide?')),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '20 Pa.C.S. § 5836',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace',
                  ],
                  fontSize: 9.5,
                  color: p.textMuted,
                  letterSpacing: 0.4,
                ),
              ),
            ),
          ],
        ),
        Text(
          'Limit or expand your agent’s authority. Default is broad authority.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: p.textMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 8),
        AgentAuthorityStep(
          key: _authorityKey,
          directiveId: widget.directiveId,
          embedded: true,
        ),
        const SizedBox(height: 14),
        // Plain-language explainer of the three authority answers — matches
        // the prototype's dashed-border info card at the bottom of step 3
        // (mobile.jsx::ScrWizardPeople L709-717).
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(
              color: p.border,
              width: 1,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline, size: 16, color: p.textMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: p.textMuted,
                      height: 1.45,
                    ),
                    children: [
                      TextSpan(
                        text: '"Agent decides"',
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' grants the power; '),
                      TextSpan(
                        text: '"No"',
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: ' withholds it entirely; '),
                      TextSpan(
                        text: '"If…"',
                        style: TextStyle(
                          color: p.text,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(
                          text:
                              ' lets you add a condition in your own words.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
