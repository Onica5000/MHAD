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
      final matches = await ClinicalDataService.searchMedications(
        med.name,
        count: 3,
      );
      // Pick the first match — it's the best fuzzy match from RxNorm
      final bestMatch = matches.isNotEmpty ? matches.first : null;
      results.add(ValidatedMedication(
        originalName: med.name,
        rxNormMatch: bestMatch,
        reason: med.reason,
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
      final matches = await ClinicalDataService.searchConditions(
        term,
        count: 3,
      );
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

  /// Run full validation on a document extraction result.
  /// Validates medications and conditions in parallel.
  static Future<ValidatedExtractionResult> validate(
      DocumentExtractionResult raw) async {
    final futures = await Future.wait([
      validateMedications(raw.medicationsPreferred),
      validateMedications(raw.medicationsToAvoid),
      validateConditions(raw.effectiveCondition),
      validateConditions(raw.healthHistory),
    ]);

    return ValidatedExtractionResult(
      preferredMeds: futures[0] as List<ValidatedMedication>,
      avoidMeds: futures[1] as List<ValidatedMedication>,
      conditions: futures[2] as List<ValidatedCondition>,
      healthHistoryConditions: futures[3] as List<ValidatedCondition>,
      preferredFacility: raw.preferredFacility,
      avoidFacility: raw.avoidFacility,
      dietary: raw.dietary,
      religious: raw.religious,
      activities: raw.activities,
      crisisIntervention: raw.crisisIntervention,
      other: raw.other,
    );
  }
}

class ValidatedMedication {
  final String originalName;
  final String? rxNormMatch;
  final String reason;
  final bool isValidated;

  const ValidatedMedication({
    required this.originalName,
    this.rxNormMatch,
    this.reason = '',
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
  final List<ValidatedCondition> conditions;
  final List<ValidatedCondition> healthHistoryConditions;
  // Pass-through fields (no validation needed)
  final String? preferredFacility;
  final String? avoidFacility;
  final String? dietary;
  final String? religious;
  final String? activities;
  final String? crisisIntervention;
  final String? other;

  const ValidatedExtractionResult({
    this.preferredMeds = const [],
    this.avoidMeds = const [],
    this.conditions = const [],
    this.healthHistoryConditions = const [],
    this.preferredFacility,
    this.avoidFacility,
    this.dietary,
    this.religious,
    this.activities,
    this.crisisIntervention,
    this.other,
  });

  bool get hasValidatedConditions =>
      conditions.any((c) => c.isValidated) ||
      healthHistoryConditions.any((c) => c.isValidated);

  bool get hasValidatedMeds =>
      preferredMeds.any((m) => m.isValidated) ||
      avoidMeds.any((m) => m.isValidated);

  /// Convert validated conditions to IcdCondition list for Smart Fill input.
  List<IcdCondition> get icdConditions => [
        ...conditions.where((c) => c.isValidated).map((c) => c.icdMatch!),
        ...healthHistoryConditions
            .where((c) => c.isValidated)
            .map((c) => c.icdMatch!),
      ];

  /// Validated preferred medication names for Smart Fill input.
  List<String> get validatedPreferredMedNames =>
      preferredMeds.map((m) => m.displayName).toList();

  /// Validated avoid medication names for Smart Fill input.
  List<String> get validatedAvoidMedNames =>
      avoidMeds.map((m) => m.displayName).toList();
}
