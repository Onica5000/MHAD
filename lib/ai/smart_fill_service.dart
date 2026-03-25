import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:mhad/services/certificate_pinning_service.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';

/// The structured input collected from the user via NIH APIs (zero tokens),
/// plus existing wizard data so the AI can supplement rather than duplicate.
class SmartFillInput {
  final List<IcdCondition> conditions;
  final List<String> currentMedications;
  final List<String> medicationsToAvoid;
  final String formType; // 'combined', 'declaration', 'poa'

  // Existing wizard data (non-PII) — AI should not contradict these.
  // ── Directive ──
  final String existingEffectiveCondition;
  // ── Preferences ──
  final String existingFacilityPref; // 'noPreference', 'prefer', 'avoid'
  final String existingPreferredFacility;
  final String existingAvoidFacility;
  final String existingMedicationConsent;
  final String existingEctConsent;
  final String existingExperimentalConsent;
  final String existingDrugTrialConsent;
  final bool existingAgentCanConsentHospitalization;
  final bool existingAgentCanConsentMedication;
  final String existingAgentAuthorityLimitations;
  // ── Additional instructions ──
  final String existingHealthHistory;
  final String existingCrisisIntervention;
  final String existingActivities;
  final String existingDietary;
  final String existingReligious;
  final String existingChildrenCustody;
  final String existingFamilyNotification;
  final String existingRecordsDisclosure;
  final String existingPetCustody;
  final String existingOther;
  // ── Medications already in form ──
  final List<String> existingPreferredMeds;
  final List<String> existingLimitationMeds;
  final List<String> existingAvoidMeds;

  const SmartFillInput({
    required this.conditions,
    required this.currentMedications,
    required this.medicationsToAvoid,
    required this.formType,
    this.existingEffectiveCondition = '',
    this.existingFacilityPref = 'noPreference',
    this.existingPreferredFacility = '',
    this.existingAvoidFacility = '',
    this.existingMedicationConsent = 'yes',
    this.existingEctConsent = 'no',
    this.existingExperimentalConsent = 'no',
    this.existingDrugTrialConsent = 'no',
    this.existingAgentCanConsentHospitalization = true,
    this.existingAgentCanConsentMedication = true,
    this.existingAgentAuthorityLimitations = '',
    this.existingHealthHistory = '',
    this.existingCrisisIntervention = '',
    this.existingActivities = '',
    this.existingDietary = '',
    this.existingReligious = '',
    this.existingChildrenCustody = '',
    this.existingFamilyNotification = '',
    this.existingRecordsDisclosure = '',
    this.existingPetCustody = '',
    this.existingOther = '',
    this.existingPreferredMeds = const [],
    this.existingLimitationMeds = const [],
    this.existingAvoidMeds = const [],
  });

  bool get isEmpty =>
      conditions.isEmpty &&
      currentMedications.isEmpty &&
      medicationsToAvoid.isEmpty;
}

/// Structured output from the AI — one field per directive section.
/// Every field is optional (AI only fills what it can infer).
class SmartFillResult {
  final String? effectiveCondition;
  final String? healthHistory;
  final String? preferredFacilityNote;
  final String? avoidFacilityNote;
  final String? ectPreference;
  final String? crisisIntervention;
  final String? activities;
  final String? dietary;
  final String? agentGuidance;
  final List<MedSuggestion> additionalMedsToConsider;
  final List<MedSuggestion> additionalMedsToAvoid;

  const SmartFillResult({
    this.effectiveCondition,
    this.healthHistory,
    this.preferredFacilityNote,
    this.avoidFacilityNote,
    this.ectPreference,
    this.crisisIntervention,
    this.activities,
    this.dietary,
    this.agentGuidance,
    this.additionalMedsToConsider = const [],
    this.additionalMedsToAvoid = const [],
  });

  bool get isEmpty =>
      effectiveCondition == null &&
      healthHistory == null &&
      preferredFacilityNote == null &&
      avoidFacilityNote == null &&
      ectPreference == null &&
      crisisIntervention == null &&
      activities == null &&
      dietary == null &&
      agentGuidance == null &&
      additionalMedsToConsider.isEmpty &&
      additionalMedsToAvoid.isEmpty;

  /// All non-null fields as label→value for the review UI.
  Map<String, String> toDisplayMap() {
    final m = <String, String>{};
    if (effectiveCondition != null) {
      m['Effective Condition'] = effectiveCondition!;
    }
    if (healthHistory != null) m['Health History'] = healthHistory!;
    if (preferredFacilityNote != null) {
      m['Facility Notes (preferred)'] = preferredFacilityNote!;
    }
    if (avoidFacilityNote != null) {
      m['Facility Notes (avoid)'] = avoidFacilityNote!;
    }
    if (ectPreference != null) m['ECT Guidance'] = ectPreference!;
    if (crisisIntervention != null) {
      m['Crisis Intervention'] = crisisIntervention!;
    }
    if (activities != null) m['Helpful Activities'] = activities!;
    if (dietary != null) m['Dietary Considerations'] = dietary!;
    if (agentGuidance != null) {
      m['Agent Guidance'] = agentGuidance!;
    }
    if (additionalMedsToConsider.isNotEmpty) {
      m['Additional Medications to Consider'] =
          additionalMedsToConsider.map((s) => s.display).join('\n');
    }
    if (additionalMedsToAvoid.isNotEmpty) {
      m['Additional Medications to Avoid'] =
          additionalMedsToAvoid.map((s) => s.display).join('\n');
    }
    return m;
  }

  factory SmartFillResult.fromJson(Map<String, dynamic> json) {
    return SmartFillResult(
      effectiveCondition: _str(json['effective_condition']),
      healthHistory: _str(json['health_history']),
      preferredFacilityNote: _str(json['preferred_facility_note']),
      avoidFacilityNote: _str(json['avoid_facility_note']),
      ectPreference: _str(json['ect_preference']),
      crisisIntervention: _str(json['crisis_intervention']),
      activities: _str(json['activities']),
      dietary: _str(json['dietary']),
      agentGuidance: _str(json['agent_guidance']),
      additionalMedsToConsider: _parseMeds(json['additional_meds_to_consider']),
      additionalMedsToAvoid: _parseMeds(json['additional_meds_to_avoid']),
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static List<MedSuggestion> _parseMeds(dynamic v) {
    if (v is! List) return [];
    return v
        .whereType<Map<String, dynamic>>()
        .map((m) => MedSuggestion(
              name: m['name']?.toString() ?? '',
              reason: m['reason']?.toString() ?? '',
            ))
        .where((m) => m.name.isNotEmpty)
        .toList();
  }
}

class MedSuggestion {
  final String name;
  final String reason;
  const MedSuggestion({required this.name, this.reason = ''});
  String get display => reason.isNotEmpty ? '$name — $reason' : name;
}

/// Wrapper returned by [SmartFillService.generate] containing the parsed
/// result and actual token usage for rate tracking.
class SmartFillResponse {
  final SmartFillResult result;
  final int totalTokens;
  const SmartFillResponse({required this.result, required this.totalTokens});
}

/// Sends a compact, structured prompt to Gemini using pre-validated clinical
/// data from the NIH APIs. This approach minimizes token usage by:
///
/// 1. Using ICD-10 codes instead of free-text descriptions (tokens: ~5 per condition vs ~50)
/// 2. Using validated RxNorm drug names instead of free-text (prevents hallucination)
/// 3. Requesting JSON output (no conversational padding)
/// 4. No system prompt, no educational content, no chat history — single-shot
/// 5. Only sending the structured selections, not the entire form
class SmartFillService {
  final String apiKey;
  final http.Client _httpClient;

  SmartFillService({required this.apiKey})
      : _httpClient = CertificatePinningService.createPinnedClient();

  static const _model = 'gemini-2.5-flash';

  /// Given structured clinical data, ask Gemini to generate directive content.
  /// Returns [SmartFillResponse] containing the parsed result and actual token
  /// usage from the API (for rate tracking).
  Future<SmartFillResponse> generate(SmartFillInput input) async {
    final model = GenerativeModel(
      model: _model,
      apiKey: apiKey,
      httpClient: _httpClient,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.3,
      ),
    );

    final prompt = _buildPrompt(input);

    try {
      final response = await model
          .generateContent([Content.text(prompt)]).timeout(
        const Duration(seconds: 30),
      );

      final text = response.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      final promptTokens = response.usageMetadata?.promptTokenCount ?? 0;
      final responseTokens =
          response.usageMetadata?.candidatesTokenCount ?? 0;
      final totalTokens = promptTokens + responseTokens;

      return SmartFillResponse(
        result: _parse(text),
        totalTokens: totalTokens > 0
            ? totalTokens
            : GeminiRateTracker.estimateTokens(prompt.length + text.length),
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on GenerativeAIException catch (e) {
      if (e.message.contains('429') ||
          e.message.toLowerCase().contains('rate limit')) {
        throw Exception('Rate limited. Please wait a moment and try again.');
      }
      throw Exception('AI error: ${e.message}');
    }
  }

  String _buildPrompt(SmartFillInput input) {
    final buf = StringBuffer();

    buf.writeln('PA Mental Health Advance Directive auto-fill.');
    buf.writeln('Form: ${input.formType}');

    if (input.conditions.isNotEmpty) {
      buf.writeln('ICD-10 diagnoses:');
      for (final c in input.conditions) {
        buf.writeln('- ${c.code} ${c.name}');
      }
    }

    if (input.currentMedications.isNotEmpty) {
      buf.writeln('Current meds: ${input.currentMedications.join(", ")}');
    }

    if (input.medicationsToAvoid.isNotEmpty) {
      buf.writeln('Avoid meds: ${input.medicationsToAvoid.join(", ")}');
    }

    // Include existing wizard data so AI can supplement, not duplicate
    final existing = <String>[];
    // Directive
    if (input.existingEffectiveCondition.isNotEmpty) {
      existing.add('Effective condition: ${input.existingEffectiveCondition}');
    }
    // Preferences
    if (input.existingPreferredFacility.isNotEmpty) {
      existing.add('Preferred facility: ${input.existingPreferredFacility}');
    }
    if (input.existingAvoidFacility.isNotEmpty) {
      existing.add('Avoid facility: ${input.existingAvoidFacility}');
    }
    if (input.existingMedicationConsent != 'yes') {
      existing.add('Medication consent: ${input.existingMedicationConsent}');
    }
    if (input.existingEctConsent != 'no') {
      existing.add('ECT consent: ${input.existingEctConsent}');
    }
    if (input.existingExperimentalConsent != 'no') {
      existing.add('Experimental studies consent: ${input.existingExperimentalConsent}');
    }
    if (input.existingDrugTrialConsent != 'no') {
      existing.add('Drug trial consent: ${input.existingDrugTrialConsent}');
    }
    // Agent authority (POA/combined only)
    if (input.formType != 'declaration') {
      if (!input.existingAgentCanConsentHospitalization) {
        existing.add('Agent CANNOT consent to hospitalization');
      }
      if (!input.existingAgentCanConsentMedication) {
        existing.add('Agent CANNOT consent to medication');
      }
      if (input.existingAgentAuthorityLimitations.isNotEmpty) {
        existing.add('Agent authority limitations: ${input.existingAgentAuthorityLimitations}');
      }
    }
    // Additional instructions
    if (input.existingHealthHistory.isNotEmpty) {
      existing.add('Health history: ${input.existingHealthHistory}');
    }
    if (input.existingCrisisIntervention.isNotEmpty) {
      existing.add('Crisis plan: ${input.existingCrisisIntervention}');
    }
    if (input.existingActivities.isNotEmpty) {
      existing.add('Activities: ${input.existingActivities}');
    }
    if (input.existingDietary.isNotEmpty) {
      existing.add('Dietary: ${input.existingDietary}');
    }
    if (input.existingReligious.isNotEmpty) {
      existing.add('Religious/spiritual: ${input.existingReligious}');
    }
    if (input.existingChildrenCustody.isNotEmpty) {
      existing.add('Children/custody: ${input.existingChildrenCustody}');
    }
    if (input.existingFamilyNotification.isNotEmpty) {
      existing.add('Family notification: ${input.existingFamilyNotification}');
    }
    if (input.existingRecordsDisclosure.isNotEmpty) {
      existing.add('Records disclosure: ${input.existingRecordsDisclosure}');
    }
    if (input.existingPetCustody.isNotEmpty) {
      existing.add('Pet custody: ${input.existingPetCustody}');
    }
    if (input.existingOther.isNotEmpty) {
      existing.add('Other instructions: ${input.existingOther}');
    }
    // Medications already in form
    if (input.existingPreferredMeds.isNotEmpty) {
      existing.add('Already listed preferred meds: ${input.existingPreferredMeds.join(", ")}');
    }
    if (input.existingLimitationMeds.isNotEmpty) {
      existing.add('Already listed medication limitations: ${input.existingLimitationMeds.join(", ")}');
    }
    if (input.existingAvoidMeds.isNotEmpty) {
      existing.add('Already listed avoid meds: ${input.existingAvoidMeds.join(", ")}');
    }

    if (existing.isNotEmpty) {
      buf.writeln();
      buf.writeln('EXISTING DATA (user-entered — do NOT contradict, duplicate, or override):');
      for (final line in existing) {
        buf.writeln('- $line');
      }
    }

    buf.writeln();
    buf.writeln('Generate JSON for a PA MHAD (Act 194 of 2004). '
        'Only include fields you can confidently infer from the diagnoses and medications above. '
        'SUPPLEMENT existing data — do not repeat or contradict what the user already wrote. '
        'For fields the user already filled in, only add NEW information they may have missed. '
        'Use plain language suitable for a legal document. '
        'Do NOT include patient name, DOB, or any PII.');

    buf.writeln();
    buf.writeln('{');
    buf.writeln('  "effective_condition": "when this directive activates",');
    buf.writeln('  "health_history": "brief relevant history from diagnoses",');
    buf.writeln(
        '  "preferred_facility_note": "type of facility that would be appropriate",');
    buf.writeln(
        '  "avoid_facility_note": "type of facility or setting to avoid",');
    buf.writeln('  "ect_preference": "guidance on ECT given these conditions",');
    buf.writeln(
        '  "crisis_intervention": "what helps during crisis for these conditions",');
    buf.writeln(
        '  "activities": "therapeutic activities helpful for these conditions",');
    buf.writeln(
        '  "dietary": "dietary considerations related to these medications",');
    if (input.formType != 'declaration') {
      buf.writeln(
          '  "agent_guidance": "what an agent should know about these conditions/meds",');
    }
    buf.writeln('  "additional_meds_to_consider": [{"name":"..","reason":".."}],');
    buf.writeln('  "additional_meds_to_avoid": [{"name":"..","reason":".."}]');
    buf.writeln('}');

    return buf.toString();
  }

  SmartFillResult _parse(String text) {
    var cleaned = text.trim();
    // Strip markdown code fences (handles \r\n from some API responses)
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```(?:json)?\s*[\r\n]*'), '')
          .replaceFirst(RegExp(r'[\r\n]*```\s*$'), '');
    }
    // Remove trailing commas before } or ] (common AI JSON quirk)
    cleaned = cleaned.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');
    try {
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return SmartFillResult.fromJson(json);
    } catch (e) {
      debugPrint('Smart fill parse error: $e\nResponse: ${cleaned.substring(0, cleaned.length.clamp(0, 200))}');
      if (cleaned.toLowerCase().contains('error')) {
        throw Exception('The AI encountered an error. Please try again.');
      }
      throw Exception('The AI response was not in the expected format. Please try again.');
    }
  }
}
