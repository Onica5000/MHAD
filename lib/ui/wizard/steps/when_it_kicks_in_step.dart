import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ui/wizard/steps/effective_condition_step.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// Wizard step 2 — "When this kicks in".
///
/// Phase 3 update: the previously-embedded `DiagnosesStep` was PROMOTED to
/// its own dedicated wizard step 6 (Diagnoses), matching the v2 prototype's
/// flow. Step 2 now focuses solely on the activation conditions. The
/// diagnoses data table is unchanged — entering diagnoses in step 6 writes
/// to the same place the embedded version used to.
///
/// This is a surface-only relocation, not a functional removal: any
/// diagnoses entered before the Phase 3 update remain in the database and
/// surface in step 6.
class WhenItKicksInStep extends ConsumerStatefulWidget {
  final int directiveId;
  const WhenItKicksInStep({required this.directiveId, super.key});

  @override
  ConsumerState<WhenItKicksInStep> createState() => _WhenItKicksInStepState();
}

class _WhenItKicksInStepState extends ConsumerState<WhenItKicksInStep>
    with WizardStepMixin {
  final _effectiveKey = GlobalKey<State<EffectiveConditionStep>>();

  @override
  Future<bool> validateAndSave() async {
    final es = _effectiveKey.currentState;
    if (es is WizardStepMixin) {
      return (es as WizardStepMixin).validateAndSave();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return EffectiveConditionStep(
      key: _effectiveKey,
      directiveId: widget.directiveId,
      embedded: false,
    );
  }
}
