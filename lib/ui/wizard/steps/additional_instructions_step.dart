import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/auto_save_mixin.dart';
import 'package:mhad/ui/wizard/widgets/ai_suggest_button.dart';
import 'package:mhad/ui/wizard/widgets/condition_autocomplete_field.dart';
import 'package:mhad/ui/wizard/widgets/example_text_button.dart';
import 'package:mhad/ui/wizard/widgets/voice_input_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class AdditionalInstructionsStep extends ConsumerStatefulWidget {
  const AdditionalInstructionsStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<AdditionalInstructionsStep> createState() =>
      _AdditionalInstructionsStepState();
}

class _AdditionalInstructionsStepState
    extends ConsumerState<AdditionalInstructionsStep>
    with WizardStepMixin, AutoSaveMixin {
  final _formKey = GlobalKey<FormState>();

  final _activitiesCtrl = TextEditingController();
  final _crisisCtrl = TextEditingController();
  final _healthHistoryCtrl = TextEditingController();
  final _dietaryCtrl = TextEditingController();
  final _religiousCtrl = TextEditingController();
  final _childrenCustodyCtrl = TextEditingController();
  final _familyNotificationCtrl = TextEditingController();
  final _recordsDisclosureCtrl = TextEditingController();
  final _petCustodyCtrl = TextEditingController();
  final _otherCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    registerAutoSave(
      directiveId: widget.directiveId,
      collector: () => {
        'activities': _activitiesCtrl.text.trim(),
        'crisisIntervention': _crisisCtrl.text.trim(),
        'healthHistory': _healthHistoryCtrl.text.trim(),
        'dietary': _dietaryCtrl.text.trim(),
        'religious': _religiousCtrl.text.trim(),
        'other': _otherCtrl.text.trim(),
      },
    );
    for (final c in [
      _activitiesCtrl, _crisisCtrl, _healthHistoryCtrl,
      _dietaryCtrl, _religiousCtrl, _otherCtrl,
    ]) {
      c.addListener(triggerAutoSave);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _activitiesCtrl.dispose();
    _crisisCtrl.dispose();
    _healthHistoryCtrl.dispose();
    _dietaryCtrl.dispose();
    _religiousCtrl.dispose();
    _childrenCustodyCtrl.dispose();
    _familyNotificationCtrl.dispose();
    _recordsDisclosureCtrl.dispose();
    _petCustodyCtrl.dispose();
    _otherCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final data = await ref
        .read(directiveRepositoryProvider)
        .getAdditionalInstructions(widget.directiveId);
    if (data != null && mounted) {
      setState(() {
        _activitiesCtrl.text = data.activities;
        _crisisCtrl.text = data.crisisIntervention;
        _healthHistoryCtrl.text = data.healthHistory;
        _dietaryCtrl.text = data.dietary;
        _religiousCtrl.text = data.religious;
        _childrenCustodyCtrl.text = data.childrenCustody;
        _familyNotificationCtrl.text = data.familyNotification;
        _recordsDisclosureCtrl.text = data.recordsDisclosure;
        _petCustodyCtrl.text = data.petCustody;
        _otherCtrl.text = data.other;
      });
    }
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate();

    await ref.read(directiveRepositoryProvider).upsertAdditionalInstructions(
          AdditionalInstructionsTableCompanion(
            directiveId: Value(widget.directiveId),
            activities: Value(_activitiesCtrl.text.trim()),
            crisisIntervention: Value(_crisisCtrl.text.trim()),
            healthHistory: Value(_healthHistoryCtrl.text.trim()),
            dietary: Value(_dietaryCtrl.text.trim()),
            religious: Value(_religiousCtrl.text.trim()),
            childrenCustody: Value(_childrenCustodyCtrl.text.trim()),
            familyNotification: Value(_familyNotificationCtrl.text.trim()),
            recordsDisclosure: Value(_recordsDisclosureCtrl.text.trim()),
            petCustody: Value(_petCustodyCtrl.text.trim()),
            other: Value(_otherCtrl.text.trim()),
          ),
        );
    return true;
  }

  Widget _buildSection(
      String title, TextEditingController ctrl, String hint, String guidance) {
    return ExpansionTile(
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextFormField(
            controller: ctrl,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: title,
              hintText: hint,
              border: const OutlineInputBorder(),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  VoiceInputButton(controller: ctrl),
                  AiSuggestButton(
                    controller: ctrl,
                    fieldName: title,
                    fieldGuidance: guidance,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const helpText =
        'These sections are all optional. Use them to give guidance to your '
        'agent and treatment team beyond the basic preferences above.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'additionalInstructions'),
          const ExampleTextButton(
            fieldName: 'Additional Instructions',
            examples: [
              'I find listening to calming music and going for walks '
              'helpful during periods of distress. Please allow me access '
              'to my personal music player.',
              'I am vegetarian for religious reasons. Please ensure my dietary '
              'needs are respected during any inpatient stay. I would also '
              'like access to a chaplain or spiritual advisor.',
              'Please notify my sister, Jane Doe, if I am admitted. Do not '
              'contact my ex-spouse under any circumstances. My therapist, '
              'Dr. Smith, should be informed of any treatment changes.',
            ],
          ),
          const SizedBox(height: 8),
          _buildSection(
            'Activities & Environment',
            _activitiesCtrl,
            'Preferences about daily activities, environment, restraints, seclusion',
            'preferences about daily activities, physical environment, use of restraints or seclusion during treatment',
          ),
          _buildSection(
            'Crisis Intervention',
            _crisisCtrl,
            'What helps or doesn\'t help during a crisis',
            'specific things that help or make things worse during a mental health crisis, based on past experience',
          ),
          ExpansionTile(
            title: const Text('De-escalation Techniques'),
            subtitle: Text(
              'What calms you during distress',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Examples: listening to music, going for a walk, '
                  'deep breathing, speaking with a specific person, '
                  'being in a quiet room, using a weighted blanket.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Potential Crisis Triggers'),
            subtitle: Text(
              'Situations that may worsen a crisis',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Examples: loud environments, specific topics, '
                  'being touched without permission, being alone, '
                  'certain people or settings.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: const Text('Health History'),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: ConditionAutocompleteField(
                  controller: _healthHistoryCtrl,
                  labelText: 'Health History',
                  hintText: 'Relevant mental health history, diagnoses, hospitalizations',
                  maxLines: 4,
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VoiceInputButton(controller: _healthHistoryCtrl),
                      AiSuggestButton(
                        controller: _healthHistoryCtrl,
                        fieldName: 'Health History',
                        fieldGuidance:
                            'relevant mental health history including diagnoses, past hospitalizations, and treatments that did or did not work',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildSection(
            'Dietary Preferences',
            _dietaryCtrl,
            'Food restrictions, preferences, religious dietary laws',
            'dietary restrictions, food allergies, religious dietary requirements, and food preferences',
          ),
          _buildSection(
            'Religious & Spiritual',
            _religiousCtrl,
            'Religious practices, spiritual needs, clergy contact',
            'religious affiliation, spiritual practices, need for chaplain or clergy access during treatment',
          ),
          _buildSection(
            'Children & Custody',
            _childrenCustodyCtrl,
            'Instructions regarding care of your minor children',
            'instructions for the care and custody of minor children if you are hospitalized',
          ),
          _buildSection(
            'Family Notification',
            _familyNotificationCtrl,
            'Who should be notified and how',
            'who should be notified of your hospitalization, how to contact them, and what information may be shared',
          ),
          _buildSection(
            'Records Disclosure & Limitations',
            _recordsDisclosureCtrl,
            'Who may access your records, and any limitations on disclosure',
            'individuals or organizations authorized to receive copies of your '
                'mental health treatment records, and any limitations on who can '
                'access them',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              'You may specify limitations on who can access your mental health '
              'records. For example, you might limit access to your treatment '
              'team only, or exclude certain family members from receiving '
              'information about your treatment.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
          _buildSection(
            'Pet Care',
            _petCustodyCtrl,
            'Instructions for care of your pets',
            'instructions for care and custody of pets if you are hospitalized',
          ),
          ExpansionTile(
            title: const Text('Reproductive Health Care'),
            subtitle: Text(
              'Optional — preferences during a mental health crisis',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            children: const [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'You may document preferences about reproductive health '
                  'care during a mental health crisis — for example, '
                  'pregnancy testing before medication changes, '
                  'contraception preferences, or any reproductive health '
                  'conditions your treatment team should be aware of.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          _buildSection(
            'Other Instructions',
            _otherCtrl,
            'Any other instructions not covered above',
            'any additional instructions for your treatment team or agent not addressed in the sections above',
          ),
        ],
      ),
    );
  }
}
