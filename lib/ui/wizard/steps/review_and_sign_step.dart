import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/wizard/steps/review_step.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

/// Wizard's last step — pure Review.
///
/// Previously this screen bundled Review + Sign in a 2-tab layout. Per
/// user direction 2026-06-03, the prototype splits these into two
/// screens: ScrReview (this step, ending with "Generate signing packet")
/// and ScrSign (a separate post-wizard route — [SignScreen]).
///
/// `validateAndSave` now forwards to ReviewStep only. ExecutionDate
/// stamping has moved to the standalone SignScreen, which fires when
/// the user actually downloads the signing packet.
class ReviewAndSignStep extends ConsumerStatefulWidget {
  final int directiveId;
  final FormType formType;
  const ReviewAndSignStep({
    required this.directiveId,
    required this.formType,
    super.key,
  });

  @override
  ConsumerState<ReviewAndSignStep> createState() => _ReviewAndSignStepState();
}

class _ReviewAndSignStepState extends ConsumerState<ReviewAndSignStep>
    with WizardStepMixin {
  final _reviewKey = GlobalKey<State<ReviewStep>>();

  @override
  Future<bool> validateAndSave() async {
    final s = _reviewKey.currentState;
    if (s is WizardStepMixin) {
      return await (s as WizardStepMixin).validateAndSave();
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return ReviewStep(
      key: _reviewKey,
      directiveId: widget.directiveId,
      formType: widget.formType,
    );
  }
}
