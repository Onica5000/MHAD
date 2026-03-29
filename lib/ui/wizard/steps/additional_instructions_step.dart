import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/auto_save_mixin.dart';
import 'package:mhad/ui/wizard/widgets/ai_suggest_button.dart';
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
  final _deescalationCtrl = TextEditingController();
  final _triggersCtrl = TextEditingController();
  final _reproductiveCtrl = TextEditingController();
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
    _deescalationCtrl.dispose();
    _triggersCtrl.dispose();
    _reproductiveCtrl.dispose();
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
        _parseOtherField(data.other);
      });
    }
  }

  // The database has one "other" column. We store de-escalation, triggers,
  // and reproductive health in it with tagged sections, and parse them back.
  static const _deescTag = '[DE-ESCALATION] ';
  static const _trigTag = '[TRIGGERS] ';
  static const _reproTag = '[REPRODUCTIVE] ';

  void _parseOtherField(String raw) {
    final lines = raw.split('\n');
    final otherLines = <String>[];
    for (final line in lines) {
      if (line.startsWith(_deescTag)) {
        _deescalationCtrl.text = line.substring(_deescTag.length);
      } else if (line.startsWith(_trigTag)) {
        _triggersCtrl.text = line.substring(_trigTag.length);
      } else if (line.startsWith(_reproTag)) {
        _reproductiveCtrl.text = line.substring(_reproTag.length);
      } else {
        otherLines.add(line);
      }
    }
    _otherCtrl.text = otherLines.join('\n').trim();
  }

  String _buildOtherField() {
    final parts = <String>[];
    final deesc = _deescalationCtrl.text.trim();
    final trig = _triggersCtrl.text.trim();
    final repro = _reproductiveCtrl.text.trim();
    final other = _otherCtrl.text.trim();
    if (deesc.isNotEmpty) parts.add('$_deescTag$deesc');
    if (trig.isNotEmpty) parts.add('$_trigTag$trig');
    if (repro.isNotEmpty) parts.add('$_reproTag$repro');
    if (other.isNotEmpty) parts.add(other);
    return parts.join('\n');
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
            other: Value(_buildOtherField()),
          ),
        );
    return true;
  }

  static const _maxFieldLength = 2000;

  Widget _buildSection(
      String title,
      TextEditingController ctrl,
      String hint,
      String guidance,
      String description) {
    return ExpansionTile(
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: TextFormField(
            controller: ctrl,
            maxLines: 4,
            maxLength: _maxFieldLength,
            autofillHints: const [],
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
            'Describe activities that help you feel better (e.g., walking, '
            'reading, music) and your preferences about your physical '
            'environment during treatment. You can also state whether you '
            'consent to or refuse the use of restraints or seclusion.',
          ),
          _buildSection(
            'Crisis Intervention',
            _crisisCtrl,
            'What helps or doesn\'t help during a crisis',
            'specific things that help or make things worse during a mental health crisis, based on past experience',
            'Based on your past experience, describe what helps you during '
            'a mental health crisis and what makes things worse. This helps '
            'your treatment team respond in the way that works best for you.',
          ),
          _buildSection(
            'De-escalation Techniques',
            _deescalationCtrl,
            'e.g., music, deep breathing, quiet room, weighted blanket',
            'techniques and strategies that calm you during distress — '
            'for example, listening to music, going for a walk, deep '
            'breathing, speaking with a specific person, being in a '
            'quiet room, or using a weighted blanket',
            'List specific techniques or strategies that help calm you '
            'when you are distressed. Examples include listening to music, '
            'deep breathing, being in a quiet room, using a weighted '
            'blanket, speaking with a specific person, or going for a walk.',
          ),
          _buildSection(
            'Potential Crisis Triggers',
            _triggersCtrl,
            'e.g., loud environments, specific topics, being alone',
            'situations or stimuli that may worsen a crisis — for example, '
            'loud environments, specific conversation topics, being touched '
            'without permission, being alone, or certain people or settings',
            'Identify situations, environments, or topics that may trigger '
            'or worsen a crisis for you. This helps your treatment team '
            'avoid these triggers. Examples: loud environments, being '
            'touched without permission, certain conversation topics, '
            'being left alone, or specific people.',
          ),
          _buildSection(
            'Health History',
            _healthHistoryCtrl,
            'Relevant mental health history, diagnoses, hospitalizations',
            'relevant mental health history including diagnoses, past hospitalizations, and treatments that did or did not work',
            'Summarize your relevant mental health history, including '
            'past diagnoses, hospitalizations, and treatments that worked '
            'well or did not work. This gives your treatment team context '
            'about your care history.',
          ),
          _buildSection(
            'Dietary Preferences',
            _dietaryCtrl,
            'Food restrictions, preferences, religious dietary laws',
            'dietary restrictions, food allergies, religious dietary requirements, and food preferences',
            'List any food allergies, dietary restrictions, or preferences '
            'your treatment team should know about. This includes religious '
            'dietary laws (e.g., kosher, halal, vegetarian), food '
            'intolerances, and any foods to avoid due to medication '
            'interactions.',
          ),
          _buildSection(
            'Religious & Spiritual',
            _religiousCtrl,
            'Religious practices, spiritual needs, clergy contact',
            'religious affiliation, spiritual practices, need for chaplain or clergy access during treatment',
            'Describe any religious or spiritual practices that are '
            'important to you during treatment. This may include prayer '
            'times, clergy or chaplain visits, religious texts or items '
            'you would like to have access to, fasting observances, or '
            'faith-based coping practices.',
          ),
          _buildSection(
            'Children & Custody',
            _childrenCustodyCtrl,
            'Instructions regarding care of your minor children',
            'instructions for the care and custody of minor children if you are hospitalized',
            'If you have minor children or dependents, describe who should '
            'care for them if you are hospitalized. Include contact '
            'information for caregivers, school details, and any custody '
            'arrangements your treatment team should be aware of.',
          ),
          _buildSection(
            'Family Notification',
            _familyNotificationCtrl,
            'Who should be notified and how',
            'who should be notified of your hospitalization, how to contact them, and what information may be shared',
            'Specify who should be notified if you are hospitalized or if '
            'your treatment changes. Include how to reach them and what '
            'information may be shared. You can also specify people who '
            'should NOT be contacted.',
          ),
          _buildSection(
            'Records Disclosure & Limitations',
            _recordsDisclosureCtrl,
            'Who may access your records, and any limitations on disclosure',
            'individuals or organizations authorized to receive copies of your '
                'mental health treatment records, and any limitations on who can '
                'access them',
            'Specify who is authorized to receive copies of your mental '
            'health treatment records and any limitations on disclosure. '
            'For example, you might limit access to your treatment team '
            'only, authorize your agent to access records, or exclude '
            'certain family members from receiving information about '
            'your treatment.',
          ),
          _buildSection(
            'Pet Care',
            _petCustodyCtrl,
            'Instructions for care of your pets',
            'instructions for care and custody of pets if you are hospitalized',
            'If you have pets, describe who should care for them if you '
            'are hospitalized. Include the caregiver\'s contact information, '
            'feeding and medication schedules, veterinary contacts, and any '
            'special care instructions.',
          ),
          _buildSection(
            'Reproductive Health Care',
            _reproductiveCtrl,
            'Pregnancy testing, contraception, etc.',
            'reproductive health care preferences during a mental health '
            'crisis — for example, pregnancy testing before medication '
            'changes, contraception preferences, or reproductive health '
            'conditions your treatment team should be aware of',
            'Describe any reproductive health care preferences your '
            'treatment team should know about. This may include whether '
            'you want pregnancy testing before medication changes, '
            'contraception preferences, or reproductive health conditions '
            'that could affect your treatment.',
          ),
          _buildSection(
            'Other Instructions',
            _otherCtrl,
            'Any other instructions not covered above',
            'any additional instructions for your treatment team or agent not addressed in the sections above',
            'Use this section for any instructions to your treatment team '
            'or agent that are not covered by the sections above. This is '
            'a catch-all for anything else you want to communicate about '
            'your care preferences.',
          ),
        ],
      ),
    );
  }
}
