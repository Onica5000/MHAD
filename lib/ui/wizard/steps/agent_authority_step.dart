import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/example_text_button.dart';
import 'package:mhad/ui/wizard/widgets/voice_input_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class AgentAuthorityStep extends ConsumerStatefulWidget {
  const AgentAuthorityStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<AgentAuthorityStep> createState() => _AgentAuthorityStepState();
}

class _AgentAuthorityStepState
    extends ConsumerState<AgentAuthorityStep> with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();

  bool _canConsentHospitalization = true;
  bool _canConsentMedication = true;
  final _limitationsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _limitationsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final pref = await ref
        .read(directiveRepositoryProvider)
        .getPreferences(widget.directiveId);
    if (pref != null && mounted) {
      setState(() {
        _canConsentHospitalization = pref.agentCanConsentHospitalization;
        _canConsentMedication = pref.agentCanConsentMedication;
        _limitationsCtrl.text = pref.agentAuthorityLimitations;
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate();

    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            agentCanConsentHospitalization: Value(_canConsentHospitalization),
            agentCanConsentMedication: Value(_canConsentMedication),
            agentAuthorityLimitations: Value(_limitationsCtrl.text.trim()),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const helpText =
        'Consider carefully before restricting your agent\'s authority. '
        'Broad authority gives your agent flexibility to respond to '
        'situations you may not anticipate.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'agentAuthority'),
          const SizedBox(height: 8),
          Text(
            'Agent Authority & Limits',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'By default your agent has broad authority to make mental health '
            'treatment decisions. You may restrict this authority here.',
          ),
          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gavel, size: 18,
                          color: Theme.of(context).colorScheme.onTertiaryContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text('Important: Scope of Authority (PA Act 194)',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onTertiaryContainer)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The checkboxes below apply ONLY to:\n'
                    '  \u2022 Voluntary hospitalization (admission to a treatment facility)\n'
                    '  \u2022 General psychiatric medications\n\n'
                    'They do NOT cover:\n'
                    '  \u2022 Electroconvulsive therapy (ECT)\n'
                    '  \u2022 Experimental studies or procedures\n'
                    '  \u2022 Clinical drug trials\n\n'
                    'Your consent choices for ECT, experimental studies, and drug '
                    'trials are set on their dedicated pages earlier in this form. '
                    'Under PA Act 194, your agent CANNOT override those decisions — '
                    'they are binding regardless of agent authority.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          CheckboxListTile(
            title: const Text('Agent may consent to voluntary hospitalization'),
            subtitle: Text('Admission to a psychiatric treatment facility only',
                style: TextStyle(fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            value: _canConsentHospitalization,
            onChanged: (v) =>
                setState(() => _canConsentHospitalization = v ?? true),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Agent may consent to medication'),
            subtitle: Text('General psychiatric medications only — does not include ECT',
                style: TextStyle(fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
            value: _canConsentMedication,
            onChanged: (v) =>
                setState(() => _canConsentMedication = v ?? true),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          const SizedBox(height: 12),
          const ExampleTextButton(
            fieldName: 'Agent Limitations',
            examples: [
              'My agent may not consent to electroconvulsive therapy (ECT) '
              'under any circumstances.',
              'My agent should consult with my therapist, Dr. Smith, before '
              'agreeing to any changes in my medication regimen.',
              'My agent may consent to voluntary inpatient admission for up '
              'to 72 hours, but may not consent to longer stays without '
              'consulting my family.',
            ],
          ),
          TextFormField(
            controller: _limitationsCtrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: 'Additional limitations or instructions (optional)',
              border: const OutlineInputBorder(),
              suffixIcon: VoiceInputButton(controller: _limitationsCtrl),
            ),
          ),
        ],
      ),
    );
  }
}
