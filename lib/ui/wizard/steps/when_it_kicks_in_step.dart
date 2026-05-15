import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/steps/diagnoses_step.dart';
import 'package:mhad/ui/wizard/steps/effective_condition_step.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

/// Merged wizard step that combines [DiagnosesStep] and
/// [EffectiveConditionStep]. Matches the prototype's step 02
/// "When this kicks in".
class WhenItKicksInStep extends ConsumerStatefulWidget {
  final int directiveId;
  const WhenItKicksInStep({required this.directiveId, super.key});

  @override
  ConsumerState<WhenItKicksInStep> createState() => _WhenItKicksInStepState();
}

class _WhenItKicksInStepState extends ConsumerState<WhenItKicksInStep>
    with WizardStepMixin {
  final _diagnosesKey = GlobalKey<State<DiagnosesStep>>();
  final _effectiveKey = GlobalKey<State<EffectiveConditionStep>>();

  @override
  Future<bool> validateAndSave() async {
    bool ok = true;
    final ds = _diagnosesKey.currentState;
    if (ds is WizardStepMixin) {
      ok = await (ds as WizardStepMixin).validateAndSave() && ok;
    }
    final es = _effectiveKey.currentState;
    if (es is WizardStepMixin) {
      ok = await (es as WizardStepMixin).validateAndSave() && ok;
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const SectionLabel('Your diagnoses (optional)'),
        Text(
          'Adding ICD-10 codes helps doctors quickly identify your conditions. '
          'You can search for psychiatric (F-codes) or medical diagnoses.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: p.textMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 8),
        DiagnosesStep(
          key: _diagnosesKey,
          directiveId: widget.directiveId,
          embedded: true,
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 8),
        const SectionLabel('When this directive activates'),
        Text(
          'Describe the conditions that should trigger this directive.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: p.textMuted,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 8),
        EffectiveConditionStep(
          key: _effectiveKey,
          directiveId: widget.directiveId,
          embedded: true,
        ),
      ],
    );
  }
}
