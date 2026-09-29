import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/ai_clinical_policy.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/ai_suggest_button.dart';
import 'package:mhad/ui/wizard/widgets/example_text_button.dart';
import 'package:mhad/ui/wizard/widgets/voice_input_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

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
    with WizardStepMixin, AutoSaveMixin, WizardStepLoadGuard {
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
    markLoaded();
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
    if (!isLoaded) return true; // don't overwrite the trigger fields before load
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
    final l10n = context.l10n;
    final helpText = l10n.effCondHelpText;

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
            l10n.effCondTakeEffectWhen,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          _TriggerTile(
            value: _triggerTwo,
            onChanged: (v) => setState(() => _triggerTwo = v),
            title: l10n.effCondTriggerTwoTitle,
            subtitle: l10n.effCondTriggerTwoSubtitle,
          ),
          _TriggerTile(
            value: _triggerCourt,
            onChanged: (v) => setState(() => _triggerCourt = v),
            title: l10n.effCondTriggerCourtTitle,
          ),
          _TriggerTile(
            value: _triggerCommit,
            onChanged: (v) => setState(() => _triggerCommit = v),
            title: l10n.effCondTriggerCommitTitle,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.effCondAnythingElseTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.effCondAnythingElseSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          ExampleTextButton(
            fieldName: l10n.effCondExampleFieldName,
            examples: [
              // Standard — two professionals certify
              l10n.effCondExample1,

              // Broader — any hospitalization or crisis
              l10n.effCondExample2,

              // Specific symptoms
              l10n.effCondExample3,

              // Self-identified trigger
              l10n.effCondExample4,

              // Broad with agent authority
              l10n.effCondExample5,
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _ctrl,
            maxLines: 5,
            maxLength: appData.config.textFieldMaxChars,
            decoration: InputDecoration(
              labelText: l10n.effCondOwnWordsLabel,
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VoiceInputButton(controller: _ctrl),
                  AiSuggestButton(
                    controller: _ctrl,
                    directiveId: widget.directiveId,
                    fieldName: effectiveConditionArea.fieldName,
                    fieldGuidance: effectiveConditionArea.guidance,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.effCondDoctorTitle,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          Text(
            l10n.effCondDoctorSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _doctorNameCtrl,
            decoration: InputDecoration(
              labelText: l10n.effCondDoctorNameLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _doctorContactCtrl,
            decoration: InputDecoration(
              labelText: l10n.effCondDoctorContactLabel,
              border: const OutlineInputBorder(),
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
