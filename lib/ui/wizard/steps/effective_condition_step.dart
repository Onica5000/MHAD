import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/auto_save_mixin.dart';
import 'package:mhad/ui/wizard/widgets/example_text_button.dart';
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
              // Standard — two professionals certify
              'This directive takes effect when I am unable to make mental '
              'health treatment decisions for myself, as determined by two '
              'qualified professionals.',

              // Broader — any hospitalization or crisis
              'This directive becomes effective any time I am admitted to a '
              'psychiatric facility or crisis unit, whether voluntary or '
              'involuntary, and I am unable to clearly communicate my wishes.',

              // Specific symptoms
              'This directive takes effect when I am experiencing a severe '
              'episode of psychosis, mania, or dissociation that prevents me '
              'from understanding my treatment options or communicating my '
              'preferences.',

              // Self-identified trigger
              'This directive becomes effective when I tell my agent or '
              'treatment provider that I want it activated, or when I am '
              'unable to make consistent and informed decisions about my '
              'mental health care.',

              // Broad with agent authority
              'This directive is effective when my designated agent, in '
              'consultation with any treating professional, determines that '
              'I would benefit from having my pre-stated treatment '
              'preferences followed.',
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ctrl,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: 'When this directive becomes effective',
              border: const OutlineInputBorder(),
              suffixIcon: VoiceInputButton(controller: _ctrl),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
        ],
      ),
    );
  }
}
