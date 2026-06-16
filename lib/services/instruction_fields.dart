import 'package:mhad/data/database/app_database.dart';

/// Ordered (label, value) pairs for the additional-instruction free-text
/// fields. Shared by the FHIR JSON + XML serializers, whose labels are
/// identical. The CSV export uses different label wording ("Children / custody"
/// / "Pet care") by convention and is intentionally left separate.
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
