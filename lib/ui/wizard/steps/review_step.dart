import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class ReviewStep extends ConsumerStatefulWidget {
  final int directiveId;
  final FormType formType;
  const ReviewStep(
      {required this.directiveId, required this.formType, super.key});

  @override
  ConsumerState<ReviewStep> createState() => _ReviewStepState();
}

class _ReviewData {
  final Directive directive;
  final List<Agent> agents;
  final DirectivePref? prefs;
  final AdditionalInstructionsTableData? additionalInstructions;
  final GuardianNomination? guardian;
  final List<MedicationEntry> medications;

  const _ReviewData({
    required this.directive,
    required this.agents,
    required this.prefs,
    required this.additionalInstructions,
    required this.guardian,
    required this.medications,
  });
}

class _ReviewStepState extends ConsumerState<ReviewStep>
    with WizardStepMixin {
  _ReviewData? _data;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final directive = await repo.getDirectiveById(widget.directiveId);
    if (directive == null || !mounted) return;

    final agents = await repo.getAgents(widget.directiveId);
    final prefs = await repo.getPreferences(widget.directiveId);
    final additional =
        await repo.getAdditionalInstructions(widget.directiveId);
    final guardian = await repo.getGuardianNomination(widget.directiveId);
    final medications =
        await repo.watchMedications(widget.directiveId).first;

    if (mounted) {
      setState(() {
        _data = _ReviewData(
          directive: directive,
          agents: agents,
          prefs: prefs,
          additionalInstructions: additional,
          guardian: guardian,
          medications: medications,
        );
      });
    }
  }

  @override
  Future<bool> validateAndSave() async => true;

  @override
  Widget build(BuildContext context) {
    if (_data == null) {
      return Center(
        child: Semantics(
          label: 'Loading',
          child: const CircularProgressIndicator(),
        ),
      );
    }
    final d = _data!.directive;
    final agents = _data!.agents;
    final prefs = _data!.prefs;
    final additional = _data!.additionalInstructions;
    final guardian = _data!.guardian;
    final meds = _data!.medications;

    final primaryAgent = agents
        .where((a) => a.agentType == 'primary')
        .firstOrNull;
    final altAgent = agents
        .where((a) => a.agentType == 'alternate')
        .firstOrNull;

    final exceptions =
        meds.where((m) => m.entryType == 'exception').toList();
    final limitations =
        meds.where((m) => m.entryType == 'limitation').toList();
    final preferred =
        meds.where((m) => m.entryType == 'preferred').toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _ReviewSection(title: 'Personal Information', entries: {
          'Name': d.fullName,
          'Date of birth': d.dateOfBirth,
          'Address': [d.address, d.address2, d.city, d.state]
              .where((s) => s.isNotEmpty)
              .join(', '),
          'Phone': d.phone,
        }),
        _ReviewSection(title: 'Effective Condition', entries: {
          'Condition': d.effectiveCondition,
        }),
        if (prefs != null)
          _ReviewSection(title: 'Treatment & Consent', entries: {
            'Treatment facility': prefs.treatmentFacilityPref,
            'Medication consent': prefs.medicationConsent,
            'ECT consent': prefs.ectConsent,
            'Experimental studies': prefs.experimentalConsent,
            'Drug trials': prefs.drugTrialConsent,
          }),
        if (exceptions.isNotEmpty || limitations.isNotEmpty || preferred.isNotEmpty)
          _ReviewSection(title: 'Medications', entries: {
            if (exceptions.isNotEmpty)
              'Never give': exceptions.map((m) => m.medicationName).join(', '),
            if (limitations.isNotEmpty)
              'With limits': limitations.map((m) => m.medicationName).join(', '),
            if (preferred.isNotEmpty)
              'Preferred': preferred.map((m) => m.medicationName).join(', '),
          }),
        if (additional != null)
          _ReviewSection(title: 'Additional Instructions', entries: {
            if (additional.activities.isNotEmpty)
              'Activities': additional.activities,
            if (additional.crisisIntervention.isNotEmpty)
              'Crisis intervention': additional.crisisIntervention,
            if (additional.healthHistory.isNotEmpty)
              'Health history': additional.healthHistory,
            if (additional.dietary.isNotEmpty)
              'Dietary': additional.dietary,
            if (additional.religious.isNotEmpty)
              'Religious': additional.religious,
            if (additional.childrenCustody.isNotEmpty)
              'Children': additional.childrenCustody,
            if (additional.familyNotification.isNotEmpty)
              'Family notification': additional.familyNotification,
            if (additional.recordsDisclosure.isNotEmpty)
              'Records disclosure': additional.recordsDisclosure,
            if (additional.petCustody.isNotEmpty)
              'Pet care': additional.petCustody,
            if (additional.other.isNotEmpty) 'Other': additional.other,
          }),
        if (primaryAgent != null)
          _ReviewSection(title: 'Primary Agent', entries: {
            'Name': primaryAgent.fullName,
            'Relationship': primaryAgent.relationship,
            'Phone': [
              primaryAgent.homePhone,
              primaryAgent.workPhone,
              primaryAgent.cellPhone,
            ].firstWhere((p) => p.isNotEmpty, orElse: () => ''),
          }),
        if (altAgent != null)
          _ReviewSection(title: 'Alternate Agent', entries: {
            'Name': altAgent.fullName,
            'Relationship': altAgent.relationship,
            'Phone': [
              altAgent.homePhone,
              altAgent.workPhone,
              altAgent.cellPhone,
            ].firstWhere((p) => p.isNotEmpty, orElse: () => ''),
          }),
        if (guardian != null && guardian.nomineeFullName.isNotEmpty)
          _ReviewSection(title: 'Guardian Nomination', entries: {
            'Name': guardian.nomineeFullName,
            'Relationship': guardian.nomineeRelationship,
            'Phone': guardian.nomineePhone,
          }),
        const SizedBox(height: 16),
        Card(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ready to sign?',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Review all sections above. When satisfied, tap Next '
                  'to proceed to signing and dating the directive.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final Map<String, String> entries;

  const _ReviewSection({required this.title, required this.entries});

  @override
  Widget build(BuildContext context) {
    final nonEmpty =
        entries.entries.where((e) => e.value.isNotEmpty).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                if (nonEmpty.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .tertiary
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('Empty',
                        style: TextStyle(
                            fontSize: 11,
                            color: Theme.of(context)
                                .colorScheme
                                .tertiary)),
                  ),
              ],
            ),
            if (nonEmpty.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...nonEmpty.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Text(e.key,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant)),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(e.value,
                              style: const TextStyle(fontSize: 12),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  )),
            ] else
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'No information entered',
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
