import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/field_help_icon.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class ExperimentalStudiesStep extends ConsumerStatefulWidget {
  const ExperimentalStudiesStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<ExperimentalStudiesStep> createState() =>
      _ExperimentalStudiesStepState();
}

class _ExperimentalStudiesStepState
    extends ConsumerState<ExperimentalStudiesStep> with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();
  ConsentOption _consent = ConsentOption.no;
  final _conditionsCtrl = TextEditingController();
  bool _hasAgentSections = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _conditionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final directive = await repo.getDirectiveById(widget.directiveId);
    final pref = await repo.getPreferences(widget.directiveId);

    if (!mounted) return;
    setState(() {
      if (directive != null) {
        final formType = FormType.values.firstWhere(
          (e) => e.name == directive.formType,
          orElse: () => FormType.declaration,
        );
        _hasAgentSections = formType.hasAgentSections;
      }

      if (pref != null) {
        final raw = pref.experimentalConsent;
        if (raw.startsWith('conditional:')) {
          _consent = ConsentOption.conditional;
          _conditionsCtrl.text = raw.substring('conditional:'.length);
        } else {
          _consent = ConsentOption.values.firstWhere(
            (e) => e.name == raw,
            orElse: () => ConsentOption.no,
          );
        }
      }
    });
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate();

    final String consentValue;
    if (_consent == ConsentOption.conditional) {
      consentValue = 'conditional:${_conditionsCtrl.text.trim()}';
    } else {
      consentValue = _consent.name;
    }

    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            experimentalConsent: Value(consentValue),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const helpText =
        'You have the right to consent to or refuse participation in '
        'experimental research. Your preferences here will guide your care '
        'team and agent.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'experimentalStudies'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Experimental Studies',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const FieldHelpIcon(
                tooltip:
                    'Experimental studies are research investigations testing new '
                    'treatments that are not yet standard practice. Participation '
                    'is always voluntary and requires informed consent.',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'State your preferences regarding participation in experimental '
            'research or studies during mental health treatment.',
          ),
          const SizedBox(height: 16),
          RadioGroup<ConsentOption>(
            groupValue: _consent,
            onChanged: (v) => setState(() => _consent = v!),
            child: Column(
              children: [
                RadioListTile<ConsentOption>(
                  title: const Text(
                      'I consent to participation in experimental studies'),
                  value: ConsentOption.yes,
                ),
                RadioListTile<ConsentOption>(
                  title: const Text(
                      'I do not consent to participation in experimental studies'),
                  value: ConsentOption.no,
                ),
                RadioListTile<ConsentOption>(
                  title: const Text('I consent under these conditions:'),
                  value: ConsentOption.conditional,
                ),
                if (_hasAgentSections)
                  RadioListTile<ConsentOption>(
                    title: const Text(
                        'My agent will make decisions about experimental studies'),
                    value: ConsentOption.agentDecides,
                  ),
              ],
            ),
          ),
          if (_consent == ConsentOption.conditional) ...[
            const SizedBox(height: 12),
            TextFormField(
              controller: _conditionsCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Conditions',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
          ],
        ],
      ),
    );
  }
}
