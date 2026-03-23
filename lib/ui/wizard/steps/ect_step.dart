import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/field_help_icon.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class EctStep extends ConsumerStatefulWidget {
  const EctStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<EctStep> createState() => _EctStepState();
}

class _EctStepState extends ConsumerState<EctStep> with WizardStepMixin {
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
        final raw = pref.ectConsent;
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
    if (!(_formKey.currentState?.validate() ?? false)) return false;

    final String consentValue;
    if (_consent == ConsentOption.conditional) {
      consentValue = 'conditional:${_conditionsCtrl.text.trim()}';
    } else {
      consentValue = _consent.name;
    }

    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            ectConsent: Value(consentValue),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const helpText =
        'ECT can be an effective treatment for severe depression and other '
        'conditions. Under PA law, you can consent in advance, refuse in '
        'advance, or set conditions.\n\n'
        'Important: Under PA Act 194, your agent is NOT allowed to consent '
        'to ECT on your behalf unless you specifically authorize it here. '
        'This authorization must be explicit in your directive.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'ect'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Electroconvulsive Therapy (ECT)',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const FieldHelpIcon(
                tooltip:
                    'ECT uses brief electrical stimulation of the brain while '
                    'the patient is under anesthesia. It is typically used for '
                    'severe depression, mania, or catatonia when other treatments '
                    'have not worked. You can consent, refuse, or set conditions.',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'ECT is a psychiatric treatment in which seizures are electrically '
            'induced. If you have preferences about ECT, state them here.',
          ),
          const SizedBox(height: 16),
          RadioGroup<ConsentOption>(
            groupValue: _consent,
            onChanged: (v) => setState(() => _consent = v!),
            child: Column(
              children: [
                RadioListTile<ConsentOption>(
                  title: const Text('I consent to ECT'),
                  value: ConsentOption.yes,
                ),
                RadioListTile<ConsentOption>(
                  title: const Text('I do not consent to ECT'),
                  value: ConsentOption.no,
                ),
                RadioListTile<ConsentOption>(
                  title: const Text('I consent to ECT under these conditions:'),
                  value: ConsentOption.conditional,
                ),
                if (_hasAgentSections)
                  RadioListTile<ConsentOption>(
                    title: const Text('My agent will make decisions about ECT'),
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
