import 'package:mhad/constants.dart';
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
        .where((m) => m.entryType == 'preferred')
        .map((m) => m.medicationName.trim())
        .where((x) => x.isNotEmpty)
        .toList();
    final current = meds
        .where((m) => m.entryType == 'current')
        .map((m) => m.medicationName.trim())
        .where((x) => x.isNotEmpty)
        .toList();
    final avoid = meds
        .where((m) => m.entryType == 'exception')
        .map((m) => m.medicationName.trim())
        .where((x) => x.isNotEmpty)
        .toList();
    // limitation = consented under restrictions (NOT "to avoid" — these are
    // meds the person accepts in specific circumstances).
    final limited = meds
        .where((m) => m.entryType == 'limitation')
        .map((m) => m.medicationName.trim())
        .where((x) => x.isNotEmpty)
        .toList();
    if (current.isNotEmpty) {
      map['Medications currently taking'] = current.join(', ');
    }
    if (preferred.isNotEmpty) {
      map['Medications preferred'] = preferred.join(', ');
    }
    if (avoid.isNotEmpty) map['Medications to avoid'] = avoid.join(', ');
    if (limited.isNotEmpty) {
      map['Restricted-use medications (consent with conditions)'] =
          limited.join(', ');
    }
    final prefs = await repo.getPreferences(directiveId);
    if (prefs != null &&
        prefs.treatmentFacilityPref.isNotEmpty &&
        prefs.treatmentFacilityPref != 'noPreference') {
      map['Treatment-facility preference'] = prefs.treatmentFacilityPref;
    }
    if (prefs != null) {
      final ectLabel = consentLabelOrNull(prefs.ectConsent);
      if (ectLabel != null) map['ECT (electroconvulsive therapy) consent'] = ectLabel;
      final expLabel = consentLabelOrNull(prefs.experimentalConsent);
      if (expLabel != null) map['Experimental treatment consent'] = expLabel;
      final drugLabel = consentLabelOrNull(prefs.drugTrialConsent);
      if (drugLabel != null) map['Drug trial consent'] = drugLabel;
    }
    final allergies = await repo.getAllergies(directiveId);
    final allergyNames = allergies
        .map((a) => a.substance.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    if (allergyNames.isNotEmpty) {
      map['Known allergies'] = allergyNames.join(', ');
    }
  } catch (_) {
    // Best-effort context only — never block the chat on a read failure.
  }
  return map;
}
