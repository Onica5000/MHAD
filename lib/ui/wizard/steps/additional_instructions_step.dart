import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/widgets/ai_suggest_button.dart';
import 'package:mhad/ui/wizard/widgets/example_text_button.dart';
import 'package:mhad/ui/wizard/widgets/voice_input_button.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

class AdditionalInstructionsStep extends ConsumerStatefulWidget {
  const AdditionalInstructionsStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<AdditionalInstructionsStep> createState() =>
      _AdditionalInstructionsStepState();
}

class _AdditionalInstructionsStepState
    extends ConsumerState<AdditionalInstructionsStep>
    with WizardStepMixin, AutoSaveMixin, WizardStepLoadGuard {
  final _formKey = GlobalKey<FormState>();

  final _activitiesCtrl = TextEditingController();
  final _crisisCtrl = TextEditingController();
  final _healthHistoryCtrl = TextEditingController();
  final _dietaryCtrl = TextEditingController();
  final _religiousCtrl = TextEditingController();
  final _childrenCustodyCtrl = TextEditingController();
  final _familyNotificationCtrl = TextEditingController();
  // Records disclosure is now a structured release/withhold/other control.
  // All three round-trip through the single `recordsDisclosure` text column
  // via labeled blocks (see _buildRecordsDisclosure / _parseRecordsDisclosure),
  // so the PDF, FHIR export and review screen still read clean prose.
  final _recordsReleaseCtrl = TextEditingController();
  final _recordsWithholdCtrl = TextEditingController();
  final _recordsOtherCtrl = TextEditingController();
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
    _recordsReleaseCtrl.dispose();
    _recordsWithholdCtrl.dispose();
    _recordsOtherCtrl.dispose();
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
    markLoaded();
    if (data != null && mounted) {
      setState(() {
        _activitiesCtrl.text = data.activities;
        _crisisCtrl.text = data.crisisIntervention;
        _healthHistoryCtrl.text = data.healthHistory;
        _dietaryCtrl.text = data.dietary;
        _religiousCtrl.text = data.religious;
        _childrenCustodyCtrl.text = data.childrenCustody;
        _familyNotificationCtrl.text = data.familyNotification;
        _parseRecordsDisclosure(data.recordsDisclosure);
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

  // Records disclosure round-trips through the single `recordsDisclosure`
  // column as labeled prose blocks. These exact labels are also what shows in
  // the PDF / FHIR export / review screen, so they are written to read well.
  static const _relTag = 'Authorized to receive my records:';
  static const _witTag = 'Not authorized to receive my records:';
  static const _othTag = 'Other limitations on disclosure:';

  String _buildRecordsDisclosure() {
    final rel = _recordsReleaseCtrl.text.trim();
    final wit = _recordsWithholdCtrl.text.trim();
    final oth = _recordsOtherCtrl.text.trim();
    final parts = <String>[];
    if (rel.isNotEmpty) parts.add('$_relTag $rel');
    if (wit.isNotEmpty) parts.add('$_witTag $wit');
    if (oth.isNotEmpty) parts.add('$_othTag $oth');
    return parts.join('\n\n');
  }

  void _parseRecordsDisclosure(String raw) {
    if (raw.trim().isEmpty) return;
    const tags = {
      'rel': _relTag,
      'wit': _witTag,
      'oth': _othTag,
    };
    final positions = <String, int>{};
    tags.forEach((key, tag) {
      final i = raw.indexOf(tag);
      if (i >= 0) positions[key] = i;
    });
    if (positions.isEmpty) {
      // Legacy free-text records disclosure — preserve it in "other".
      _recordsOtherCtrl.text = raw.trim();
      return;
    }
    final ordered = positions.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    for (var idx = 0; idx < ordered.length; idx++) {
      final key = ordered[idx].key;
      final start = ordered[idx].value + tags[key]!.length;
      final end =
          idx + 1 < ordered.length ? ordered[idx + 1].value : raw.length;
      final val = raw.substring(start, end).trim();
      switch (key) {
        case 'rel':
          _recordsReleaseCtrl.text = val;
        case 'wit':
          _recordsWithholdCtrl.text = val;
        case 'oth':
          _recordsOtherCtrl.text = val;
      }
    }
  }

  @override
  Future<bool> validateAndSave() async {
    if (!isLoaded) return true; // don't overwrite instructions before load
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
            recordsDisclosure: Value(_buildRecordsDisclosure()),
            petCustody: Value(_petCustodyCtrl.text.trim()),
            other: Value(_buildOtherField()),
          ),
        );
    return true;
  }

  static int get _maxFieldLength => appData.config.textFieldMaxChars;

  // [aiName] is the English field name sent to the AI (kept unlocalized);
  // [title] is the localized display label.
  Widget _buildSection(
      String aiName,
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
                    directiveId: widget.directiveId,
                    fieldName: aiName,
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

  // A single structured records-field (release / withhold / other) used inside
  // the Records Disclosure section. Mirrors _buildSection's input styling.
  Widget _recordsField({
    required String aiName,
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required String guidance,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: 3,
        maxLength: _maxFieldLength,
        autofillHints: const [],
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              VoiceInputButton(controller: ctrl),
              AiSuggestButton(
                controller: ctrl,
                directiveId: widget.directiveId,
                fieldName: aiName,
                fieldGuidance: guidance,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Structured Records Disclosure section (F20 / 20 Pa.C.S. § 5836(e)) —
  // replaces the prior single free-text field with explicit release / withhold
  // controls plus the statutory supersession note.
  Widget _buildRecordsDisclosureSection() {
    final cs = Theme.of(context).colorScheme;
    return ExpansionTile(
      title: Text(context.l10n.addlInstrRecordsTitle),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            context.l10n.addlInstrRecordsDescription,
            style: TextStyle(
              fontSize: 12,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
        _recordsField(
          aiName: 'Who may receive my records',
          label: context.l10n.addlInstrRecordsReleaseLabel,
          ctrl: _recordsReleaseCtrl,
          hint: context.l10n.addlInstrRecordsReleaseHint,
          guidance:
              'individuals or organizations the person authorizes to receive '
              'copies of their mental health treatment records',
        ),
        _recordsField(
          aiName: 'Who must NOT receive my records',
          label: context.l10n.addlInstrRecordsWithholdLabel,
          ctrl: _recordsWithholdCtrl,
          hint: context.l10n.addlInstrRecordsWithholdHint,
          guidance:
              'individuals or organizations the person wants excluded from '
              'receiving any of their mental health treatment records',
        ),
        _recordsField(
          aiName: 'Other limitations on disclosure',
          label: context.l10n.addlInstrRecordsOtherLabel,
          ctrl: _recordsOtherCtrl,
          hint: context.l10n.addlInstrRecordsOtherHint,
          guidance:
              'any other limits on how, when, or which mental health records '
              'may be disclosed',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final helpText = l10n.addlInstrHelpText;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'additionalInstructions'),
          ExampleTextButton(
            fieldName: l10n.addlInstrExampleFieldName,
            examples: [
              l10n.addlInstrExample1,
              l10n.addlInstrExample2,
              l10n.addlInstrExample3,
            ],
          ),
          const SizedBox(height: 8),
          _buildSection(
            'Activities & Environment',
            l10n.addlInstrActivitiesTitle,
            _activitiesCtrl,
            l10n.addlInstrActivitiesHint,
            'preferences about daily activities, physical environment, use of restraints or seclusion during treatment',
            l10n.addlInstrActivitiesDescription,
          ),
          _buildSection(
            'Crisis Intervention',
            l10n.addlInstrCrisisTitle,
            _crisisCtrl,
            l10n.addlInstrCrisisHint,
            'specific things that help or make things worse during a mental health crisis, based on past experience',
            l10n.addlInstrCrisisDescription,
          ),
          _buildSection(
            'De-escalation Techniques',
            l10n.addlInstrDeescTitle,
            _deescalationCtrl,
            l10n.addlInstrDeescHint,
            'techniques and strategies that calm you during distress — '
            'for example, listening to music, going for a walk, deep '
            'breathing, speaking with a specific person, being in a '
            'quiet room, or using a weighted blanket',
            l10n.addlInstrDeescDescription,
          ),
          _buildSection(
            'Potential Crisis Triggers',
            l10n.addlInstrTriggersTitle,
            _triggersCtrl,
            l10n.addlInstrTriggersHint,
            'situations or stimuli that may worsen a crisis — for example, '
            'loud environments, specific conversation topics, being touched '
            'without permission, being alone, or certain people or settings',
            l10n.addlInstrTriggersDescription,
          ),
          _buildSection(
            'Health History',
            l10n.addlInstrHealthHistoryTitle,
            _healthHistoryCtrl,
            l10n.addlInstrHealthHistoryHint,
            'relevant mental health history including diagnoses, past hospitalizations, and treatments that did or did not work',
            l10n.addlInstrHealthHistoryDescription,
          ),
          _buildSection(
            'Dietary Preferences',
            l10n.addlInstrDietaryTitle,
            _dietaryCtrl,
            l10n.addlInstrDietaryHint,
            'dietary restrictions, food allergies, religious dietary requirements, and food preferences',
            l10n.addlInstrDietaryDescription,
          ),
          _buildSection(
            'Religious & Spiritual',
            l10n.addlInstrReligiousTitle,
            _religiousCtrl,
            l10n.addlInstrReligiousHint,
            'religious affiliation, spiritual practices, need for chaplain or clergy access during treatment',
            l10n.addlInstrReligiousDescription,
          ),
          _buildSection(
            'Children & Custody',
            l10n.addlInstrChildrenTitle,
            _childrenCustodyCtrl,
            l10n.addlInstrChildrenHint,
            'instructions for the care and custody of minor children if you are hospitalized',
            l10n.addlInstrChildrenDescription,
          ),
          _buildSection(
            'Family Notification',
            l10n.addlInstrFamilyNotifyTitle,
            _familyNotificationCtrl,
            l10n.addlInstrFamilyNotifyHint,
            'who should be notified of your hospitalization, how to contact them, and what information may be shared',
            l10n.addlInstrFamilyNotifyDescription,
          ),
          _buildRecordsDisclosureSection(),
          _buildSection(
            'Pet Care',
            l10n.addlInstrPetCareTitle,
            _petCustodyCtrl,
            l10n.addlInstrPetCareHint,
            'instructions for care and custody of pets if you are hospitalized',
            l10n.addlInstrPetCareDescription,
          ),
          _buildSection(
            'Reproductive Health Care',
            l10n.addlInstrReproTitle,
            _reproductiveCtrl,
            l10n.addlInstrReproHint,
            'reproductive health care preferences during a mental health '
            'crisis — for example, pregnancy testing before medication '
            'changes, contraception preferences, or reproductive health '
            'conditions your treatment team should be aware of',
            l10n.addlInstrReproDescription,
          ),
          _buildSection(
            'Other Instructions',
            l10n.addlInstrOtherTitle,
            _otherCtrl,
            l10n.addlInstrOtherHint,
            'any additional instructions for your treatment team or agent not addressed in the sections above',
            l10n.addlInstrOtherDescription,
          ),

          // Optional add-ons, moved here from Settings (2026-06-13). Each opens
          // its own full screen, which keeps the complete explanation; these
          // cards just carry a short summary and the entry point.
          const SizedBox(height: 8),
          SectionLabel(l10n.addlInstrOptionalAddOns),
          const SizedBox(height: 8),
          _addOnCard(
            icon: Icons.favorite_outline,
            title: l10n.addlInstrCrisisPlanTitle,
            subtitle: l10n.addlInstrCrisisPlanSubtitle,
            onTap: () =>
                context.push(AppRoutes.crisisPlanRoute(widget.directiveId)),
          ),
          const SizedBox(height: 8),
          _addOnCard(
            icon: Icons.anchor_outlined,
            title: l10n.addlInstrUlyssesTitle,
            subtitle: l10n.addlInstrUlyssesSubtitle,
            onTap: () =>
                context.push(AppRoutes.ulyssesRoute(widget.directiveId)),
          ),
        ],
      ),
    );
  }

  /// A tappable card linking to an optional add-on screen (Crisis plan,
  /// Ulysses clause). The destination screen owns the full explanation.
  Widget _addOnCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final p = Theme.of(context).mhadPalette;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: p.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: kSansFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 12,
                        height: 1.4,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: p.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
