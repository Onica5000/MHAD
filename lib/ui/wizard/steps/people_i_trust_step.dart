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
        const SectionLabel('What can they decide?'),
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
      ],
    );
  }
}
