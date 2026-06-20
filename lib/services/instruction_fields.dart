import 'package:mhad/data/database/app_database.dart';

/// Ordered (label, value) pairs for the additional-instruction free-text
/// fields. Shared by the FHIR JSON + XML serializers, whose labels are
/// identical. The CSV export uses different label wording — see
/// [additionalInstructionNotesCsv].
List<({String label, String value})> additionalInstructionNotes(
    AdditionalInstructionsTableData a) {
  return [
    (label: 'Health History', value: a.healthHistory),
    (label: 'Crisis Intervention', value: a.crisisIntervention),
    (label: 'Activities', value: a.activities),
    (label: 'Dietary', value: a.dietary),
    (label: 'Religious', value: a.religious),
    (label: 'Children/Custody', value: a.childrenCustody),
    (label: 'Family Notification', value: a.familyNotification),
    (label: 'Records Disclosure', value: a.recordsDisclosure),
    (label: 'Pet Custody', value: a.petCustody),
    (label: 'Other', value: a.other),
  ];
}

/// CSV-flavoured labels (different wording by convention). Kept here so the
/// field SET stays in sync with [additionalInstructionNotes].
List<({String label, String value})> additionalInstructionNotesCsv(
    AdditionalInstructionsTableData a) {
  return [
    (label: 'Health history', value: a.healthHistory),
    (label: 'Crisis intervention', value: a.crisisIntervention),
    (label: 'Activities', value: a.activities),
    (label: 'Dietary', value: a.dietary),
    (label: 'Religious', value: a.religious),
    (label: 'Children / custody', value: a.childrenCustody),
    (label: 'Family notification', value: a.familyNotification),
    (label: 'Records disclosure', value: a.recordsDisclosure),
    (label: 'Pet care', value: a.petCustody),
    (label: 'Other', value: a.other),
  ];
}
