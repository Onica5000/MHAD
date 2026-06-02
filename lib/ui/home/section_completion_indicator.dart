import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';

/// Shows a compact row of section completion dots for a draft directive.
/// Each dot represents a wizard section — filled if data exists, empty if not.
class SectionCompletionIndicator extends ConsumerWidget {
  final Directive directive;

  const SectionCompletionIndicator({required this.directive, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formType = FormType.values.firstWhere(
      (e) => e.name == directive.formType,
      orElse: () => FormType.combined,
    );
    final sections = _getSections(formType);

    return FutureBuilder<Map<String, bool>>(
      future: _checkCompletion(ref, directive.id, formType),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final completion = snapshot.data!;
        final filled = completion.values.where((v) => v).length;
        final total = completion.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '$filled of $total sections',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    children: sections.map((s) {
                      final done = completion[s] ?? false;
                      return Tooltip(
                        message: '${_sectionName(s)}: ${done ? "done" : "empty"}',
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context)
                                    .colorScheme
                                    .surfaceContainerHighest,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Derive the section list from FormType.steps so new wizard steps
  /// (e.g. Phase 3 diagnoses + allergies) appear automatically without
  /// further edits here. Multi-substep wizard steps (peopleITrust →
  /// agent / altAgent / agentAuth; proceduresResearch → ect / experimental
  /// / drugTrials) are expanded into per-section keys so completion is
  /// reflected at finer granularity than the wizard step.
  List<String> _getSections(FormType formType) {
    final out = <String>[];
    for (final step in formType.steps) {
      switch (step) {
        case WizardStep.aboutYou:
          out.add('personal');
        case WizardStep.whenItKicksIn:
          out.add('condition');
        case WizardStep.peopleITrust:
          out.addAll(['agent', 'altAgent', 'agentAuth']);
        case WizardStep.guardianNomination:
          out.add('guardian');
        case WizardStep.whereIWantCare:
          out.add('facility');
        case WizardStep.diagnoses:
          out.add('diagnoses');
        case WizardStep.medications:
          out.add('medications');
        case WizardStep.allergies:
          out.add('allergies');
        case WizardStep.proceduresResearch:
          out.addAll(['ect', 'experimental', 'drugTrials']);
        case WizardStep.anythingElse:
          out.add('additional');
        case WizardStep.reviewAndSign:
          // Reviewing/signing is not a "section" in the completion sense.
          break;
      }
    }
    return out;
  }

  String _sectionName(String key) => switch (key) {
        'personal' => 'Personal Info',
        'condition' => 'Effective Condition',
        'facility' => 'Treatment Facility',
        'diagnoses' => 'Diagnoses',
        'medications' => 'Medications',
        'allergies' => 'Allergies',
        'ect' => 'ECT',
        'experimental' => 'Experimental Studies',
        'drugTrials' => 'Drug Trials',
        'additional' => 'Additional Instructions',
        'agent' => 'Agent',
        'altAgent' => 'Alternate Agent',
        'agentAuth' => 'Agent Authority',
        'guardian' => 'Guardian',
        _ => key,
      };

  Future<Map<String, bool>> _checkCompletion(
      WidgetRef ref, int id, FormType formType) async {
    final repo = ref.read(directiveRepositoryProvider);
    final directive = await repo.getDirectiveById(id);
    if (directive == null) return {};

    final result = <String, bool>{};

    // Personal info — check if name is filled
    result['personal'] = directive.fullName.isNotEmpty;

    // Effective condition
    result['condition'] = directive.effectiveCondition.isNotEmpty;

    // Treatment facility
    final prefs = await repo.getPreferences(id);
    result['facility'] = prefs != null &&
        (prefs.preferredFacilityName.isNotEmpty ||
            prefs.avoidFacilityName.isNotEmpty ||
            prefs.treatmentFacilityPref != 'noPreference');

    // Medications
    final meds = await repo.watchMedications(id).first;
    result['medications'] = meds.isNotEmpty;

    // Diagnoses (Phase 3)
    final diags = await repo.getDiagnoses(id);
    result['diagnoses'] = diags.isNotEmpty;

    // Allergies (Phase 3)
    final allergies = await repo.getAllergies(id);
    result['allergies'] = allergies.isNotEmpty;

    // ECT / experimental / drug trials — complete if prefs row exists
    // (user has visited the step and saved, even if they chose the default "no")
    result['ect'] = prefs != null;
    result['experimental'] = prefs != null;
    result['drugTrials'] = prefs != null;

    // Additional instructions
    final instr = await repo.getAdditionalInstructions(id);
    result['additional'] = instr != null &&
        (instr.activities.isNotEmpty ||
            instr.crisisIntervention.isNotEmpty ||
            instr.healthHistory.isNotEmpty ||
            instr.dietary.isNotEmpty ||
            instr.religious.isNotEmpty ||
            instr.childrenCustody.isNotEmpty ||
            instr.familyNotification.isNotEmpty ||
            instr.recordsDisclosure.isNotEmpty ||
            instr.petCustody.isNotEmpty ||
            instr.other.isNotEmpty);

    // Agent sections
    if (formType.hasAgentSections) {
      final agents = await repo.getAgents(id);
      result['agent'] =
          agents.any((a) => a.agentType == 'primary' && a.fullName.isNotEmpty);
      result['altAgent'] = agents
          .any((a) => a.agentType == 'alternate' && a.fullName.isNotEmpty);
      result['agentAuth'] = prefs != null &&
          (prefs.agentAuthorityLimitations.isNotEmpty ||
              !prefs.agentCanConsentHospitalization ||
              !prefs.agentCanConsentMedication);
    }

    // Guardian — complete if the user made ANY explicit choice
    // (sameAsPrimary / sameAsAlternate / different-with-name / noPreference).
    // The previous gate (`nomineeFullName.isNotEmpty`) incorrectly counted
    // the three non-'different' radios as incomplete after the Phase 2
    // restructure of GuardianNominationStep.
    final guardian = await repo.getGuardianNomination(id);
    result['guardian'] = guardian != null &&
        (() {
          switch (guardian.guardianRelation) {
            case 'sameAsPrimary':
            case 'sameAsAlternate':
            case 'noPreference':
              return true;
            case 'different':
              return guardian.nomineeFullName.isNotEmpty;
            default:
              // Legacy rows pre-Phase-2 default to 'different'; treat them
              // as before — complete only when a name was typed.
              return guardian.nomineeFullName.isNotEmpty;
          }
        })();

    return result;
  }
}
