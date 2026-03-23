import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/auto_save_mixin.dart';
import 'package:mhad/ui/wizard/widgets/ai_suggest_button.dart';
import 'package:mhad/ui/wizard/widgets/example_text_button.dart';
import 'package:mhad/ui/wizard/widgets/field_help_icon.dart';
import 'package:mhad/ui/wizard/widgets/voice_input_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class EffectiveConditionStep extends ConsumerStatefulWidget {
  const EffectiveConditionStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<EffectiveConditionStep> createState() =>
      _EffectiveConditionStepState();
}

class _EffectiveConditionStepState
    extends ConsumerState<EffectiveConditionStep>
    with WizardStepMixin, AutoSaveMixin {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    registerAutoSave(
      directiveId: widget.directiveId,
      collector: () => {'effectiveCondition': _ctrl.text.trim()},
    );
    _ctrl.addListener(triggerAutoSave);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _ctrl.removeListener(triggerAutoSave);
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final directive = await ref
        .read(directiveRepositoryProvider)
        .getDirectiveById(widget.directiveId);
    if (directive != null && mounted) {
      setState(() {
        _ctrl.text = directive.effectiveCondition;
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return false;

    await ref
        .read(directiveRepositoryProvider)
        .updateEffectiveCondition(widget.directiveId, _ctrl.text.trim());
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const helpText =
        'Describe the circumstances under which you want this directive to take '
        'effect — for example, "when two qualified professionals certify that I '
        'lack capacity to make treatment decisions." Under PA Act 194, the '
        'declaration becomes operative when a psychiatrist and one of the '
        'following certify you lack capacity: another psychiatrist, a licensed '
        'psychologist, your family physician, your attending physician, or '
        'another mental health treatment professional.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'effectiveCondition'),
          const ExampleTextButton(
            fieldName: 'Effective Condition',
            examples: [
              'This directive becomes effective when I am determined to lack '
              'the capacity to make mental health treatment decisions, as '
              'certified by a psychiatrist and one other qualified professional.',
              'This directive takes effect when I am in a mental health crisis '
              'and two qualified professionals certify that I am unable to make '
              'informed decisions about my care.',
              'This directive is effective when my treating psychiatrist and '
              'my family physician both determine that I lack capacity to '
              'consent to or refuse mental health treatment.',
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ctrl,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'When this directive becomes effective',
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VoiceInputButton(controller: _ctrl),
                  const FieldHelpIcon(
                    tooltip:
                        'This describes when your directive activates — typically '
                        'when two professionals certify you lack capacity to make '
                        'treatment decisions. Under PA Act 194, at least one must '
                        'be a psychiatrist.',
                  ),
                  AiSuggestButton(
                    controller: _ctrl,
                    fieldName: 'Effective Condition',
                    fieldGuidance:
                        'the specific circumstances under which this mental health '
                        'advance directive becomes operative',
                  ),
                ],
              ),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
