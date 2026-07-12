import 'package:mhad/ai/document_extraction_result.dart';
import 'package:mhad/services/clinical_data_service.dart';

/// Takes raw extracted medical data (free-text from Gemini) and validates
/// each item against the NIH APIs. Medications are matched via RxTerms,
/// conditions are matched via ICD-10-CM. Unmatched items are kept as
/// free-text fallbacks so the user doesn't lose data.
class ClinicalDataValidator {
  /// Validate extracted medications against RxTerms.
  /// Returns a list of validated meds — each with the original name,
  /// the best RxNorm match (if found), and the reason.
  static Future<List<ValidatedMedication>> validateMedications(
      List<ExtractedMedication> rawMeds) async {
    final results = <ValidatedMedication>[];
    for (final med in rawMeds) {
      // If the NIH lookup is unreachable (offline / outage), keep the med as
      // an unvalidated free-text item rather than aborting the whole pipeline.
      List<String> matches;
      try {
        matches = await ClinicalDataService.searchMedications(med.name, count: 3);
      } catch (_) {
        matches = const [];
      }
      // Pick the first match — it's the best fuzzy match from RxNorm
      final bestMatch = matches.isNotEmpty ? matches.first : null;
      results.add(ValidatedMedication(
        originalName: med.name,
        rxNormMatch: bestMatch,
        reason: med.reason,
        dosage: med.dosage,
        isValidated: bestMatch != null,
      ));
    }
    return results;
  }

  /// Validate condition text against ICD-10-CM.
  /// Splits the condition text by common delimiters and searches each term.
  static Future<List<ValidatedCondition>> validateConditions(
      String? conditionText) async {
    if (conditionText == null || conditionText.trim().isEmpty) return [];

    // Split on commas, semicolons, "and", newlines to get individual terms
    final terms = conditionText
        .split(RegExp(r'[,;\n]|\band\b'))
        .map((s) => s.trim())
        .where((s) => s.length >= 3)
        .toList();

    final results = <ValidatedCondition>[];
    final seenCodes = <String>{};

    for (final term in terms) {
      // Degrade gracefully on a network/API failure — keep the term as an
      // unvalidated free-text condition instead of losing the extraction.
      List<IcdCondition> matches;
      try {
        matches = await ClinicalDataService.searchConditions(term, count: 3);
      } catch (_) {
        matches = const [];
      }
      final bestMatch = matches.isNotEmpty ? matches.first : null;
      // Avoid duplicates if multiple terms match the same code
      if (bestMatch != null && seenCodes.contains(bestMatch.code)) continue;
      if (bestMatch != null) seenCodes.add(bestMatch.code);

      results.add(ValidatedCondition(
        originalText: term,
        icdMatch: bestMatch,
        isValidated: bestMatch != null,
      ));
    }
    return results;
  }

  /// Validate DRUG allergies against RxTerms (RxNorm). A recognized drug name
  /// is flagged verified; an unrecognized one is left unverified so the user
  /// double-checks it (usually a spelling slip). The substance text is NEVER
  /// rewritten — for an allergy the ingredient the user named is what matters,
  /// not a specific product/strength RxNorm would return. Non-drug allergies
  /// (food / material / other) pass straight through. Degrades gracefully: on a
  /// network/API failure an item is kept as-is (unverified), never dropped.
  static Future<List<ExtractedAllergy>> validateAllergies(
      List<ExtractedAllergy> rawAllergies) async {
    final results = <ExtractedAllergy>[];
    for (final a in rawAllergies) {
      if (a.kind != 'drug' || a.substance.trim().length < 2) {
        results.add(a);
        continue;
      }
      List<String> matches;
      try {
        matches = await ClinicalDataService.searchMedications(a.substance, count: 1);
      } catch (_) {
        matches = const [];
      }
      results.add(a.withVerified(matches.isNotEmpty));
    }
    return results;
  }

  /// Run full validation on a document extraction result.
  /// Validates medications and conditions in parallel.
  static Future<ValidatedExtractionResult> validate(
      DocumentExtractionResult raw) async {
    final futures = await Future.wait([
      validateMedications(raw.medicationsPreferred),
      validateMedications(raw.medicationsToAvoid),
      validateMedications(raw.medicationsCurrent),
      validateConditions(raw.effectiveCondition),
    ]);

    // Confirm extracted facilities against the NPI organization registry. The
    // extractor may return "Name | Address" — match on the name part only.
    String facilityName(String? s) =>
        (s ?? '').split('|').first.trim();
    final prefFacilityName = facilityName(raw.preferredFacility);
    final avoidFacilityName = facilityName(raw.avoidFacility);

    return ValidatedExtractionResult(
      preferredMeds: futures[0] as List<ValidatedMedication>,
      avoidMeds: futures[1] as List<ValidatedMedication>,
      currentMeds: futures[2] as List<ValidatedMedication>,
      limitedMeds: await validateMedications(raw.medicationsLimited),
      conditions: futures[3] as List<ValidatedCondition>,
      diagnoses: raw.diagnoses,
      allergies: await validateAllergies(raw.allergies),
      preferredFacilityVerified: prefFacilityName.isNotEmpty &&
          await ClinicalDataService.isKnownFacility(prefFacilityName),
      avoidFacilityVerified: avoidFacilityName.isNotEmpty &&
          await ClinicalDataService.isKnownFacility(avoidFacilityName),
      // Health history is free-form narrative (and, per the extractor, where
      // current-medication mentions land) — keep it as verbatim prose for the
      // user to review. Do NOT run it through the condition/ICD splitter,
      // which fragments sentences and drops anything it can't match.
      healthHistory: raw.healthHistory,
      // The person's VERBATIM "when it kicks in" wording. The condition
      // splitter above only feeds the ICD chips — without this passthrough
      // the actual trigger language from the document was dropped and apply
      // wrote a canned sentence instead.
      effectiveCondition: raw.effectiveCondition,
      preferredFacility: raw.preferredFacility,
      avoidFacility: raw.avoidFacility,
      dietary: raw.dietary,
      religious: raw.religious,
      activities: raw.activities,
      crisisIntervention: raw.crisisIntervention,
      agentAuthorityLimitations: raw.agentAuthorityLimitations,
      ectConsent: raw.ectConsent,
      experimentalConsent: raw.experimentalConsent,
      drugTrialConsent: raw.drugTrialConsent,
      medicationConsent: raw.medicationConsent,
      triggerTwoProfessionals: raw.triggerTwoProfessionals,
      triggerCourtOrder: raw.triggerCourtOrder,
      triggerInvoluntaryCommitment: raw.triggerInvoluntaryCommitment,
      roomPreferencesNote: raw.roomPreferencesNote,
      sameGenderRoommate: raw.sameGenderRoommate,
      roomPreferenceChips: raw.roomPreferenceChips,
      roommateGenderMatch: raw.roommateGenderMatch,
      guardianCanRevoke: raw.guardianCanRevoke,
      guardianCanRevokeNote: raw.guardianCanRevokeNote,
      guardianCanChangeAgent: raw.guardianCanChangeAgent,
      guardianCanChangeAgentNote: raw.guardianCanChangeAgentNote,
      guardianMustConsultAgent: raw.guardianMustConsultAgent,
      guardianMustConsultAgentNote: raw.guardianMustConsultAgentNote,
      crisisPlan: raw.crisisPlan,
      agentCanConsentHospitalization: raw.agentCanConsentHospitalization,
      agentCanConsentMedication: raw.agentCanConsentMedication,
      selfBindingUlysses: raw.selfBindingUlysses,
      petCustody: raw.petCustody,
      childrenCustody: raw.childrenCustody,
      familyNotification: raw.familyNotification,
      recordsDisclosure: raw.recordsDisclosure,
      other: raw.other,
      // Personal info (PII) passes straight through — no NIH validation needed.
      personalInfo: raw.personalInfo,
    );
  }
}

class ValidatedMedication {
  final String originalName;
  final String? rxNormMatch;
  final String reason;
  // Dosage — only populated for currently-taking meds (empty otherwise).
  final String dosage;
  final bool isValidated;

  const ValidatedMedication({
    required this.originalName,
    this.rxNormMatch,
    this.reason = '',
    this.dosage = '',
    required this.isValidated,
  });

  /// The name to use — validated RxNorm name if available, otherwise original.
  String get displayName => rxNormMatch ?? originalName;
}

class ValidatedCondition {
  final String originalText;
  final IcdCondition? icdMatch;
  final bool isValidated;

  const ValidatedCondition({
    required this.originalText,
    this.icdMatch,
    required this.isValidated,
  });

  /// Display name — ICD name if matched, otherwise original text.
  String get displayName => icdMatch?.name ?? originalText;

  /// ICD code if matched, empty otherwise.
  String get code => icdMatch?.code ?? '';
}

/// Full validated extraction result — medications and conditions validated
/// against NIH APIs, with pass-through fields that don't need validation.
class ValidatedExtractionResult {
  final List<ValidatedMedication> preferredMeds;
  final List<ValidatedMedication> avoidMeds;
  final List<ValidatedMedication> currentMeds;
  final List<ValidatedMedication> limitedMeds;
  final List<ValidatedCondition> conditions;
  // Pass-through fields (no NIH validation needed)
  final List<ExtractedDiagnosis> diagnoses;
  final List<ExtractedAllergy> allergies;
  final String? healthHistory;
  /// Verbatim "when this kicks in" text from the document (the ICD-split
  /// [conditions] chips are derived from it, but never replace it).
  final String? effectiveCondition;
  final String? preferredFacility;
  final String? avoidFacility;
  // True when the facility name was matched in the NPI organization registry
  // (an authoritative confirmation, not a rewrite of the user's text).
  final bool preferredFacilityVerified;
  final bool avoidFacilityVerified;
  final String? dietary;
  final String? religious;
  final String? activities;
  final String? crisisIntervention;
  final String? agentAuthorityLimitations;
  final String? ectConsent;
  final String? experimentalConsent;
  final String? drugTrialConsent;
  final String? medicationConsent;
  final bool? triggerTwoProfessionals;
  final bool? triggerCourtOrder;
  final bool? triggerInvoluntaryCommitment;
  final String? roomPreferencesNote;
  final bool? sameGenderRoommate;
  final List<String> roomPreferenceChips;
  final String? roommateGenderMatch;
  final bool? guardianCanRevoke;
  final String? guardianCanRevokeNote;
  final bool? guardianCanChangeAgent;
  final String? guardianCanChangeAgentNote;
  final bool? guardianMustConsultAgent;
  final String? guardianMustConsultAgentNote;
  final ExtractedCrisisPlan? crisisPlan;
  final bool? agentCanConsentHospitalization;
  final bool? agentCanConsentMedication;
  final bool? selfBindingUlysses;
  final String? petCustody;
  final String? childrenCustody;
  final String? familyNotification;
  final String? recordsDisclosure;
  final String? other;
  // Personal info (PII) extracted for autofill — pass-through, no validation.
  final ExtractedPersonalInfo personalInfo;

  const ValidatedExtractionResult({
    this.preferredMeds = const [],
    this.avoidMeds = const [],
    this.currentMeds = const [],
    this.limitedMeds = const [],
    this.conditions = const [],
    this.diagnoses = const [],
    this.allergies = const [],
    this.healthHistory,
    this.effectiveCondition,
    this.preferredFacility,
    this.avoidFacility,
    this.preferredFacilityVerified = false,
    this.avoidFacilityVerified = false,
    this.dietary,
    this.religious,
    this.activities,
    this.crisisIntervention,
    this.agentAuthorityLimitations,
    this.ectConsent,
    this.experimentalConsent,
    this.drugTrialConsent,
    this.medicationConsent,
    this.triggerTwoProfessionals,
    this.triggerCourtOrder,
    this.triggerInvoluntaryCommitment,
    this.roomPreferencesNote,
    this.sameGenderRoommate,
    this.roomPreferenceChips = const [],
    this.roommateGenderMatch,
    this.guardianCanRevoke,
    this.guardianCanRevokeNote,
    this.guardianCanChangeAgent,
    this.guardianCanChangeAgentNote,
    this.guardianMustConsultAgent,
    this.guardianMustConsultAgentNote,
    this.crisisPlan,
    this.agentCanConsentHospitalization,
    this.agentCanConsentMedication,
    this.selfBindingUlysses,
    this.petCustody,
    this.childrenCustody,
    this.familyNotification,
    this.recordsDisclosure,
    this.other,
    this.personalInfo = const ExtractedPersonalInfo(),
  });

  bool get hasValidatedConditions => conditions.any((c) => c.isValidated);

  bool get hasValidatedMeds =>
      preferredMeds.any((m) => m.isValidated) ||
      avoidMeds.any((m) => m.isValidated);

  /// Convert validated conditions to IcdCondition list for Smart Fill input.
  List<IcdCondition> get icdConditions =>
      conditions.where((c) => c.isValidated).map((c) => c.icdMatch!).toList();

  /// Validated preferred medication names for Smart Fill input.
  List<String> get validatedPreferredMedNames =>
      preferredMeds.map((m) => m.displayName).toList();

  /// Validated avoid medication names for Smart Fill input.
  List<String> get validatedAvoidMedNames =>
      avoidMeds.map((m) => m.displayName).toList();
}
