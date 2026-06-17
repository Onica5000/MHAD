import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/auto_save_mixin.dart';
import 'package:mhad/ui/wizard/widgets/example_text_button.dart';
import 'package:mhad/ui/wizard/widgets/voice_input_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class EffectiveConditionStep extends ConsumerStatefulWidget {
  const EffectiveConditionStep({
    required this.directiveId,
    this.embedded = false,
    super.key,
  });

  final int directiveId;
  final bool embedded;

  @override
  ConsumerState<EffectiveConditionStep> createState() =>
      _EffectiveConditionStepState();
}

class _EffectiveConditionStepState
    extends ConsumerState<EffectiveConditionStep>
    with WizardStepMixin, AutoSaveMixin {
  final _formKey = GlobalKey<FormState>();
  final _ctrl = TextEditingController();
  final _doctorNameCtrl = TextEditingController();
  final _doctorContactCtrl = TextEditingController();

  // The three statutory "when this kicks in" triggers (artboard checkable
  // options). The free-text field below is now an optional "anything else".
  bool _triggerTwo = false;
  bool _triggerCourt = false;
  bool _triggerCommit = false;

  @override
  void initState() {
    super.initState();
    registerAutoSave(
      directiveId: widget.directiveId,
      collector: () => {'effectiveCondition': _ctrl.text.trim()},
    );
    _ctrl.addListener(triggerAutoSave);
    _doctorNameCtrl.addListener(triggerAutoSave);
    _doctorContactCtrl.addListener(triggerAutoSave);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _ctrl.removeListener(triggerAutoSave);
    _doctorNameCtrl.removeListener(triggerAutoSave);
    _doctorContactCtrl.removeListener(triggerAutoSave);
    _ctrl.dispose();
    _doctorNameCtrl.dispose();
    _doctorContactCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final directive = await ref
        .read(directiveRepositoryProvider)
        .getDirectiveById(widget.directiveId);
    if (directive != null && mounted) {
      setState(() {
        _ctrl.text = directive.effectiveCondition;
        _doctorNameCtrl.text = directive.preferredDoctorName;
        _doctorContactCtrl.text = directive.preferredDoctorContact;
        _triggerTwo = directive.triggerTwoProfessionals;
        _triggerCourt = directive.triggerCourtOrder;
        _triggerCommit = directive.triggerInvoluntaryCommitment;
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate(); // Show warnings but don't block
    final repo = ref.read(directiveRepositoryProvider);
    await repo.updateEffectiveCondition(
      widget.directiveId,
      _ctrl.text.trim(),
      twoProfessionals: _triggerTwo,
      courtOrder: _triggerCourt,
      involuntaryCommitment: _triggerCommit,
    );
    await repo.updatePreferredDoctor(
      widget.directiveId,
      name: _doctorNameCtrl.text.trim(),
      contact: _doctorContactCtrl.text.trim(),
    );
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
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: ListView(
        shrinkWrap: widget.embedded,
        physics:
            widget.embedded ? const NeverScrollableScrollPhysics() : null,
        padding: widget.embedded
            ? const EdgeInsets.symmetric(horizontal: 4)
            : const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'effectiveCondition'),
          Text(
            'This directive should take effect when…',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _TriggerTile(
            value: _triggerTwo,
            onChanged: (v) => setState(() => _triggerTwo = v),
            title: 'A psychiatrist + one other professional find I lack '
                'capacity',
            subtitle:
                'The standard PA Act 194 trigger — two qualified professionals '
                'certify you can\'t make mental-health treatment decisions.',
          ),
          _TriggerTile(
            value: _triggerCourt,
            onChanged: (v) => setState(() => _triggerCourt = v),
            title: 'A court determines I lack capacity',
          ),
          _TriggerTile(
            value: _triggerCommit,
            onChanged: (v) => setState(() => _triggerCommit = v),
            title: 'I am involuntarily committed',
          ),
          const SizedBox(height: 16),
          Text(
            'Anything else about timing (optional)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'Add your own words, or pick an example to start from.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
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
            maxLength: appData.config.textFieldMaxChars,
            decoration: InputDecoration(
              labelText: 'In your own words (optional)',
              border: const OutlineInputBorder(),
              suffixIcon: VoiceInputButton(controller: _ctrl),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Preferred evaluating doctor (optional)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            'If you have a preferred doctor to evaluate your capacity, '
            'enter their information below.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _doctorNameCtrl,
            decoration: const InputDecoration(
              labelText: 'Name of Doctor',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _doctorContactCtrl,
            decoration: const InputDecoration(
              labelText: 'Address / Phone Number',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

/// A checkable statutory "effective condition" trigger (artboard option card).
class _TriggerTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String title;
  final String? subtitle;
  const _TriggerTile({
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 14, 10),
          decoration: BoxDecoration(
            color: value ? cs.primaryContainer.withValues(alpha: 0.4) : null,
            border: Border.all(
              color: value ? cs.primary : theme.dividerColor,
              width: value ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 9),
                      child: Text(
                        title,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
