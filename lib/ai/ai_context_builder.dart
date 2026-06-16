import 'package:mhad/data/repository/directive_repository.dart';

/// Builds the "answers so far" context map handed to the AI assistant.
///
/// This is the single chokepoint for what directive data leaves the device as
/// AI context, and it is an explicit ALLOWLIST: it emits only non-identifying,
/// clinically-useful fields (effective condition, diagnoses, medications,
/// treatment-facility preference). It deliberately NEVER reads the user's,
/// agents', or guardian's identity columns — see [AiPiiPolicy] for the pinned
/// contract and `test/unit/ai_context_pii_test.dart` for the lock that fails if
/// any PII value ever reaches this map.
///
/// Best-effort: a read failure yields a smaller map rather than blocking chat.
Future<Map<String, String>> buildAiFilledFields(
    DirectiveRepository repo, int directiveId) async {
  final map = <String, String>{};
  try {
    final d = await repo.getDirectiveById(directiveId);
    if (d != null && d.effectiveCondition.trim().isNotEmpty) {
      map['When it takes effect'] = d.effectiveCondition.trim();
    }
    final diags = await repo.getDiagnoses(directiveId);
    final diagNames =
        diags.map((x) => x.name.trim()).where((x) => x.isNotEmpty).toList();
    if (diagNames.isNotEmpty) map['Diagnoses listed'] = diagNames.join(', ');
    final meds = await repo.watchMedications(directiveId).first;
    final preferred = meds
        .where((m) => m.entryType == 'preferred' || m.entryType == 'current')
        .map((m) => m.medicationName.trim())
        .where((x) => x.isNotEmpty)
        .toList();
    final avoid = meds
        .where((m) => m.entryType == 'exception' || m.entryType == 'limitation')
        .map((m) => m.medicationName.trim())
        .where((x) => x.isNotEmpty)
        .toList();
    if (preferred.isNotEmpty) {
      map['Medications (current/preferred)'] = preferred.join(', ');
    }
    if (avoid.isNotEmpty) map['Medications to avoid'] = avoid.join(', ');
    final prefs = await repo.getPreferences(directiveId);
    if (prefs != null &&
        prefs.treatmentFacilityPref.isNotEmpty &&
        prefs.treatmentFacilityPref != 'noPreference') {
      map['Treatment-facility preference'] = prefs.treatmentFacilityPref;
    }
  } catch (_) {
    // Best-effort context only — never block the chat on a read failure.
  }
  return map;
}
