/// Appends a dosage to a medication name for display — `"Lisinopril (10 mg
/// daily)"` — or just the name when no dosage was given. Shared by the PDF
/// renderers and the CSV/FHIR machine exports so the "currently taking" dosage
/// shows consistently across every output.
String medicationWithDosage(String name, String dosage) {
  final d = dosage.trim();
  return d.isEmpty ? name : '$name ($d)';
}
