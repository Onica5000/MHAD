import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/field_help_icon.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class DrugTrialsStep extends ConsumerStatefulWidget {
  const DrugTrialsStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<DrugTrialsStep> createState() => _DrugTrialsStepState();
}

class _DrugTrialsStepState extends ConsumerState<DrugTrialsStep>
    with WizardStepMixin {
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
        final raw = pref.drugTrialConsent;
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
            drugTrialConsent: Value(consentValue),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const helpText =
        'Clinical drug trials test new medications. You can consent, refuse, '
        'or set conditions for your participation.\n\n'
        'Note: Under PA Act 194, your agent cannot consent to your '
        'participation in drug trials unless you specifically authorize '
        'it in this section.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'drugTrials'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Drug Trials',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const FieldHelpIcon(
                tooltip:
                    'Drug trials (clinical trials) test new medications or new '
                    'uses of existing medications. They may involve placebos. '
                    'You can consent, refuse, or set conditions for participation.',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'State your preferences regarding participation in clinical drug '
            'trials during mental health treatment.',
          ),
          const SizedBox(height: 16),
          RadioGroup<ConsentOption>(
            groupValue: _consent,
            onChanged: (v) => setState(() => _consent = v!),
            child: Column(
              children: [
                RadioListTile<ConsentOption>(
                  title: const Text('I consent to participation in drug trials'),
                  value: ConsentOption.yes,
                ),
                RadioListTile<ConsentOption>(
                  title:
                      const Text('I do not consent to participation in drug trials'),
                  value: ConsentOption.no,
                ),
                RadioListTile<ConsentOption>(
                  title: const Text('I consent under these conditions:'),
                  value: ConsentOption.conditional,
                ),
                if (_hasAgentSections)
                  RadioListTile<ConsentOption>(
                    title: const Text(
                        'My agent will make decisions about drug trials'),
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
