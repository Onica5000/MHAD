import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/services/certificate_pinning_service.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';

/// The structured input collected from the user via NIH APIs (zero tokens),
/// plus existing wizard data so the AI can supplement rather than duplicate.
class SmartFillInput {
  static const maxConditions = 30;
  static const maxMedsPerCategory = 50;
  static const maxFieldLength = 2000;
  static const _validFormTypes = {'combined', 'declaration', 'poa'};

  final List<IcdCondition> conditions;
  final List<String> currentMedications;
  final List<String> medicationsToAvoid;
  final String formType;

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

  /// Validates and clamps input to safe bounds.
  SmartFillInput sanitized() {
    final safeFormType =
        _validFormTypes.contains(formType) ? formType : 'combined';
    return SmartFillInput(
      conditions: conditions.take(maxConditions).toList(),
      currentMedications: currentMedications.take(maxMedsPerCategory).toList(),
      medicationsToAvoid: medicationsToAvoid.take(maxMedsPerCategory).toList(),
      formType: safeFormType,
      existingEffectiveCondition:
          _truncate(existingEffectiveCondition),
      existingFacilityPref: existingFacilityPref,
      existingPreferredFacility: _truncate(existingPreferredFacility),
      existingAvoidFacility: _truncate(existingAvoidFacility),
      existingMedicationConsent: existingMedicationConsent,
      existingEctConsent: existingEctConsent,
      existingExperimentalConsent: existingExperimentalConsent,
      existingDrugTrialConsent: existingDrugTrialConsent,
      existingAgentCanConsentHospitalization:
          existingAgentCanConsentHospitalization,
      existingAgentCanConsentMedication: existingAgentCanConsentMedication,
      existingAgentAuthorityLimitations:
          _truncate(existingAgentAuthorityLimitations),
      existingHealthHistory: _truncate(existingHealthHistory),
      existingCrisisIntervention: _truncate(existingCrisisIntervention),
      existingActivities: _truncate(existingActivities),
      existingDietary: _truncate(existingDietary),
      existingReligious: _truncate(existingReligious),
      existingChildrenCustody: _truncate(existingChildrenCustody),
      existingFamilyNotification: _truncate(existingFamilyNotification),
      existingRecordsDisclosure: _truncate(existingRecordsDisclosure),
      existingPetCustody: _truncate(existingPetCustody),
      existingOther: _truncate(existingOther),
      existingPreferredMeds:
          existingPreferredMeds.take(maxMedsPerCategory).toList(),
      existingLimitationMeds:
          existingLimitationMeds.take(maxMedsPerCategory).toList(),
      existingAvoidMeds:
          existingAvoidMeds.take(maxMedsPerCategory).toList(),
    );
  }

  static String _truncate(String s) =>
      s.length > maxFieldLength ? s.substring(0, maxFieldLength) : s;
}

/// Structured output from the AI — one field per directive section.
/// Every field is optional (AI only fills what it can infer).
class SmartFillResult {
  final String? effectiveCondition;
  final String? healthHistory;
  final String? preferredFacilityNote;
  final String? avoidFacilityNote;
  final String? ectPreference;
  final String? experimentalPreference;
  final String? drugTrialPreference;
  final String? crisisIntervention;
  final String? deescalation;
  final String? triggers;
  final String? activities;
  final String? dietary;
  final String? religious;
  final String? childrenCustody;
  final String? familyNotification;
  final String? recordsDisclosure;
  final String? petCustody;
  final String? agentGuidance;
  final List<MedSuggestion> additionalMedsToConsider;
  final List<MedSuggestion> additionalMedsWithLimitations;
  final List<MedSuggestion> additionalMedsToAvoid;

  const SmartFillResult({
    this.effectiveCondition,
    this.healthHistory,
    this.preferredFacilityNote,
    this.avoidFacilityNote,
    this.ectPreference,
    this.experimentalPreference,
    this.drugTrialPreference,
    this.crisisIntervention,
    this.deescalation,
    this.triggers,
    this.activities,
    this.dietary,
    this.religious,
    this.childrenCustody,
    this.familyNotification,
    this.recordsDisclosure,
    this.petCustody,
    this.agentGuidance,
    this.additionalMedsToConsider = const [],
    this.additionalMedsWithLimitations = const [],
    this.additionalMedsToAvoid = const [],
  });

  bool get isEmpty =>
      effectiveCondition == null &&
      healthHistory == null &&
      preferredFacilityNote == null &&
      avoidFacilityNote == null &&
      ectPreference == null &&
      experimentalPreference == null &&
      drugTrialPreference == null &&
      crisisIntervention == null &&
      deescalation == null &&
      triggers == null &&
      activities == null &&
      dietary == null &&
      religious == null &&
      childrenCustody == null &&
      familyNotification == null &&
      recordsDisclosure == null &&
      petCustody == null &&
      agentGuidance == null &&
      additionalMedsToConsider.isEmpty &&
      additionalMedsWithLimitations.isEmpty &&
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
    if (experimentalPreference != null) {
      m['Experimental Studies Guidance'] = experimentalPreference!;
    }
    if (drugTrialPreference != null) {
      m['Drug Trials Guidance'] = drugTrialPreference!;
    }
    if (crisisIntervention != null) {
      m['Crisis Intervention'] = crisisIntervention!;
    }
    if (deescalation != null) {
      m['De-escalation Techniques'] = deescalation!;
    }
    if (triggers != null) m['Crisis Triggers'] = triggers!;
    if (activities != null) m['Helpful Activities'] = activities!;
    if (dietary != null) m['Dietary Considerations'] = dietary!;
    if (religious != null) m['Religious/Spiritual'] = religious!;
    if (childrenCustody != null) {
      m['Children/Dependent Care'] = childrenCustody!;
    }
    if (familyNotification != null) {
      m['Family Notification'] = familyNotification!;
    }
    if (recordsDisclosure != null) {
      m['Records Disclosure'] = recordsDisclosure!;
    }
    if (petCustody != null) m['Pet Care'] = petCustody!;
    if (agentGuidance != null) {
      m['Agent Guidance'] = agentGuidance!;
    }
    if (additionalMedsToConsider.isNotEmpty) {
      m['Additional Medications to Consider'] =
          additionalMedsToConsider.map((s) => s.display).join('\n');
    }
    if (additionalMedsWithLimitations.isNotEmpty) {
      m['Additional Medications with Limitations'] =
          additionalMedsWithLimitations.map((s) => s.display).join('\n');
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
      experimentalPreference: _str(json['experimental_preference']),
      drugTrialPreference: _str(json['drug_trial_preference']),
      crisisIntervention: _str(json['crisis_intervention']),
      deescalation: _str(json['deescalation']),
      triggers: _str(json['triggers']),
      activities: _str(json['activities']),
      dietary: _str(json['dietary']),
      religious: _str(json['religious']),
      childrenCustody: _str(json['children_custody']),
      familyNotification: _str(json['family_notification']),
      recordsDisclosure: _str(json['records_disclosure']),
      petCustody: _str(json['pet_custody']),
      agentGuidance: _str(json['agent_guidance']),
      additionalMedsToConsider: _parseMeds(json['additional_meds_to_consider']),
      additionalMedsWithLimitations:
          _parseMeds(json['additional_meds_with_limitations']),
      additionalMedsToAvoid: _parseMeds(json['additional_meds_to_avoid']),
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static const _maxMedSuggestions = 20;

  static List<MedSuggestion> _parseMeds(dynamic v) {
    if (v is! List) return [];
    return v
        .whereType<Map<String, dynamic>>()
        .map((m) => MedSuggestion(
              name: (m['name']?.toString() ?? '').trim(),
              reason: (m['reason']?.toString() ?? '').trim(),
            ))
        .where((m) => m.name.isNotEmpty)
        .take(_maxMedSuggestions)
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
  Future<SmartFillResponse> generate(SmartFillInput rawInput) async {
    final input = rawInput.sanitized();
    final model = GenerativeModel(
      model: _model,
      apiKey: apiKey,
      httpClient: _httpClient,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.0,
      ),
    );

    final prompt = _buildPrompt(input);
    debugPrint('SmartFill prompt: ${prompt.length} chars '
        '(~${(prompt.length / 4).round()} tokens), '
        '${input.conditions.length} conditions, '
        '${input.currentMedications.length} meds');

    try {
      // Retry once on rate limit (429) with backoff
      GenerateContentResponse? response;
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          response = await model
              .generateContent([Content.text(prompt)]).timeout(
            const Duration(seconds: 45),
          );
          break; // success
        } on GenerativeAIException catch (e) {
          if ((e.message.contains('429') ||
                  e.message.toLowerCase().contains('rate limit')) &&
              attempt == 0) {
            // Wait and retry once
            await Future<void>.delayed(const Duration(seconds: 10));
            continue;
          }
          rethrow;
        }
      }

      final text = response?.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty response from Gemini');
      }

      debugPrint('SmartFill response: ${text.length} chars');

      final promptTokens = response!.usageMetadata?.promptTokenCount ?? 0;
      final responseTokens =
          response.usageMetadata?.candidatesTokenCount ?? 0;
      final totalTokens = promptTokens + responseTokens;

      final result = _parse(text);
      final display = result.toDisplayMap();
      debugPrint('SmartFill fields returned: ${display.keys.join(', ')} '
          '(${display.length} of 13 possible)');

      return SmartFillResponse(
        result: result,
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
      final psychiatric = input.conditions
          .where((c) => c.code.startsWith('F'))
          .toList();
      final medical = input.conditions
          .where((c) => !c.code.startsWith('F'))
          .toList();
      if (psychiatric.isNotEmpty) {
        buf.writeln('Psychiatric diagnoses (ICD-10):');
        for (final c in psychiatric) {
          buf.writeln('- ${c.code} ${c.name}');
        }
      }
      if (medical.isNotEmpty) {
        buf.writeln('Medical diagnoses (ICD-10):');
        for (final c in medical) {
          buf.writeln('- ${c.code} ${c.name}');
        }
      }
    }

    if (input.currentMedications.isNotEmpty) {
      buf.writeln('Current meds: ${input.currentMedications.join(", ")}');
    }

    if (input.medicationsToAvoid.isNotEmpty) {
      buf.writeln('Avoid meds: ${input.medicationsToAvoid.join(", ")}');
    }

    // Include existing wizard data so AI can supplement, not duplicate.
    // Strip PII from free-text fields — users may have typed names,
    // addresses, or other identifying info into these fields.
    String s(String text) => PiiStripper.strip(text);

    final existing = <String>[];
    // Directive
    if (input.existingEffectiveCondition.isNotEmpty) {
      existing.add('Effective condition: ${s(input.existingEffectiveCondition)}');
    }
    // Preferences
    if (input.existingPreferredFacility.isNotEmpty) {
      existing.add('Preferred facility: ${s(input.existingPreferredFacility)}');
    }
    if (input.existingAvoidFacility.isNotEmpty) {
      existing.add('Avoid facility: ${s(input.existingAvoidFacility)}');
    }
    // ALWAYS send ALL consent values — consent is the core of this directive.
    // The AI MUST respect these decisions and never suggest overriding them.
    existing.add('');
    existing.add('=== CONSENT DECISIONS (BINDING — do NOT contradict) ===');
    existing.add('Medication consent: ${s(_describeConsent(input.existingMedicationConsent))}');
    existing.add('ECT consent: ${s(_describeConsent(input.existingEctConsent))}');
    existing.add('Experimental studies consent: ${s(_describeConsent(input.existingExperimentalConsent))}');
    existing.add('Drug trial consent: ${s(_describeConsent(input.existingDrugTrialConsent))}');
    // Agent authority (POA/combined only) — always send full picture
    if (input.formType != 'declaration') {
      existing.add('Agent consent to hospitalization: ${input.existingAgentCanConsentHospitalization ? "YES — agent authorized" : "NO — agent NOT authorized"}');
      existing.add('Agent consent to medication: ${input.existingAgentCanConsentMedication ? "YES — agent authorized" : "NO — agent NOT authorized"}');
      if (input.existingAgentAuthorityLimitations.isNotEmpty) {
        existing.add('Agent authority limitations: ${s(input.existingAgentAuthorityLimitations)}');
      }
    }
    existing.add('');
    existing.add('SCOPE RULE: Agent hospitalization/medication authority covers ONLY '
        'voluntary admission and general psychiatric medications. It does NOT '
        'extend to ECT, experimental studies, or drug trials — those are '
        'governed by the separate consent fields above and the agent CANNOT '
        'override the patient\'s choices on those matters under PA Act 194.');
    existing.add('=== END CONSENT DECISIONS ===');
    existing.add('');
    // Additional instructions — all free-text, PII-strip each one
    if (input.existingHealthHistory.isNotEmpty) {
      existing.add('Health history: ${s(input.existingHealthHistory)}');
    }
    if (input.existingCrisisIntervention.isNotEmpty) {
      existing.add('Crisis plan: ${s(input.existingCrisisIntervention)}');
    }
    if (input.existingActivities.isNotEmpty) {
      existing.add('Activities: ${s(input.existingActivities)}');
    }
    if (input.existingDietary.isNotEmpty) {
      existing.add('Dietary: ${s(input.existingDietary)}');
    }
    if (input.existingReligious.isNotEmpty) {
      existing.add('Religious/spiritual: ${s(input.existingReligious)}');
    }
    if (input.existingChildrenCustody.isNotEmpty) {
      existing.add('Children/custody: ${s(input.existingChildrenCustody)}');
    }
    if (input.existingFamilyNotification.isNotEmpty) {
      existing.add('Family notification: ${s(input.existingFamilyNotification)}');
    }
    if (input.existingRecordsDisclosure.isNotEmpty) {
      existing.add('Records disclosure: ${s(input.existingRecordsDisclosure)}');
    }
    if (input.existingPetCustody.isNotEmpty) {
      existing.add('Pet custody: ${s(input.existingPetCustody)}');
    }
    if (input.existingOther.isNotEmpty) {
      existing.add('Other instructions: ${s(input.existingOther)}');
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

    buf.writeln();
    buf.writeln('EXISTING DATA (user-entered — do NOT contradict, duplicate, or override).');
    buf.writeln('CRITICAL CONSENT RULES:');
    buf.writeln('- This is a CONSENT document. Every consent decision below is BINDING.');
    buf.writeln('- "NO" means HARD REFUSAL. Your guidance must RESPECT the refusal. '
        'Explain why someone with these conditions might refuse, do NOT suggest reconsideration.');
    buf.writeln('- "YES" means the user consents. Your guidance should note relevant '
        'considerations for informed consent (risks, benefits, what to expect).');
    buf.writeln('- "CONDITIONAL" means consent with specific restrictions. Honor those restrictions exactly.');
    buf.writeln('- "AGENT DECIDES" means delegated. Your guidance should help the agent make informed decisions.');
    buf.writeln('- Medication suggestions MUST respect medication consent. If consent is NO, '
        'do not suggest additional medications.');
    buf.writeln('- ECT/experimental/drug trial guidance MUST align with the user\'s consent choice.');
    for (final line in existing) {
      buf.writeln('- $line');
    }

    buf.writeln();
    buf.writeln('Generate JSON for a PA MHAD (Act 194 of 2004).');
    buf.writeln();
    buf.writeln('PRIORITY HIERARCHY for each field:');
    buf.writeln('1. USER INPUT FIRST: If the user already wrote something for a field, '
        'use their input as the foundation. Improve wording for clarity and legal '
        'appropriateness, but preserve their specific preferences and intent verbatim '
        'where possible.');
    buf.writeln('2. SUPPLEMENT: Add important details the user may not have considered '
        'based on their diagnoses, medications, and what they wrote in other fields. '
        'Suggest practical considerations, common scenarios, and relevant PA Act 194 provisions.');
    buf.writeln('3. GENERAL KNOWLEDGE: For fields the user left empty, generate suggestions '
        'based on the user\'s diagnoses and medications first, then general clinical best '
        'practices for those conditions.');
    buf.writeln();
    buf.writeln('SAFETY — ABSOLUTE RULES:');
    buf.writeln('- NEVER suggest anything that could endanger the user\'s physical or mental health.');
    buf.writeln('- NEVER contradict the user\'s stated treatment preferences or consent decisions.');
    buf.writeln('- NEVER suggest stopping or changing medications the user is currently taking.');
    buf.writeln('- NEVER suggest treatments that are contraindicated for the user\'s diagnoses.');
    buf.writeln('- Flag known dangerous drug interactions in medication suggestions.');
    buf.writeln('- When suggesting medications, note common side effects and monitoring requirements.');
    buf.writeln();
    buf.writeln('QUALITY RULES:');
    buf.writeln('- You MUST provide a value for EVERY field listed below — do NOT skip any.');
    buf.writeln('- Cross-reference ALL user data: diagnoses inform crisis plans, medications '
        'inform dietary needs, conditions inform activity suggestions, etc.');
    buf.writeln('- Be specific and practical — include concrete examples, names of techniques, '
        'and actionable instructions rather than generic advice.');
    buf.writeln('- Use plain language suitable for a legal document.');
    buf.writeln('- Do NOT include patient name, DOB, or any PII.');
    buf.writeln('- PA NTI drug rule: Narrow Therapeutic Index drugs (lithium, carbamazepine, '
        'valproic acid, phenytoin, clonazepam) CANNOT have generics substituted under '
        'PA law (35 P.S. §960.3). Note monitoring requirements in the reason field.');

    buf.writeln();
    buf.writeln('{');

    // Helper to build field descriptions that reference user input when present
    String fieldDesc(String base, String existingData) {
      if (existingData.isEmpty) return base;
      return 'Build on user\'s input and add what they may have missed. $base';
    }

    buf.writeln('  "effective_condition": "${fieldDesc(
        'When this directive activates — describe the mental health conditions or '
        'circumstances under which this directive should take effect',
        input.existingEffectiveCondition)}",');
    buf.writeln('  "health_history": "${fieldDesc(
        'Relevant health history based on diagnoses and medications — '
        'include condition timeline, past treatments, hospitalizations',
        input.existingHealthHistory)}",');
    buf.writeln('  "preferred_facility_note": "${fieldDesc(
        'Type of facility that would be appropriate and why, '
        'based on the user\'s conditions',
        input.existingPreferredFacility)}",');
    buf.writeln('  "avoid_facility_note": "${fieldDesc(
        'Type of facility or setting to avoid and why',
        input.existingAvoidFacility)}",');
    buf.writeln('  "ect_preference": "${fieldDesc(
        'Guidance on ECT for these specific conditions — risks, benefits, what to expect',
        '')}",');
    buf.writeln('  "experimental_preference": "${fieldDesc(
        'Guidance on experimental studies/research for these conditions',
        '')}",');
    buf.writeln('  "drug_trial_preference": "${fieldDesc(
        'Guidance on clinical drug trials for these conditions',
        '')}",');
    buf.writeln('  "crisis_intervention": "${fieldDesc(
        'Specific interventions that help during a mental health crisis '
        'for these conditions — include concrete steps, not generic advice',
        input.existingCrisisIntervention)}",');
    buf.writeln('  "deescalation": "${fieldDesc(
        'Specific de-escalation techniques (e.g., music, quiet room, '
        'grounding exercises, breathing techniques, sensory tools)',
        '')}",');
    buf.writeln('  "triggers": "${fieldDesc(
        'Known and common crisis triggers to avoid for these conditions',
        '')}",');
    buf.writeln('  "activities": "${fieldDesc(
        'Therapeutic activities helpful for these conditions — '
        'include both structured and informal activities',
        input.existingActivities)}",');
    buf.writeln('  "dietary": "${fieldDesc(
        'Dietary considerations related to these specific medications '
        '(e.g., grapefruit interactions, caffeine limits, hydration needs, '
        'foods that affect drug levels)',
        input.existingDietary)}",');
    buf.writeln('  "religious": "${fieldDesc(
        'Religious/spiritual preferences relevant to treatment '
        '(e.g., medication timing around prayer, fasting accommodations, '
        'clergy contact, faith-based coping)',
        input.existingReligious)}",');
    buf.writeln('  "children_custody": "${fieldDesc(
        'Arrangements for children/dependents during treatment — '
        'who should care for them, school contacts, custody considerations, '
        'what to tell them',
        input.existingChildrenCustody)}",');
    buf.writeln('  "family_notification": "${fieldDesc(
        'Who should and should not be notified about hospitalization '
        'or treatment changes — use role placeholders (e.g., spouse, parent) '
        'not real names',
        input.existingFamilyNotification)}",');
    buf.writeln('  "records_disclosure": "${fieldDesc(
        'Preferences about sharing medical records — who may access them, '
        'what information to share or restrict, HIPAA considerations',
        input.existingRecordsDisclosure)}",');
    buf.writeln('  "pet_custody": "${fieldDesc(
        'Arrangements for pets during treatment — who should care for them, '
        'feeding/medication schedules, veterinary contacts',
        input.existingPetCustody)}",');
    if (input.formType != 'declaration') {
      buf.writeln('  "agent_guidance": "${fieldDesc(
          'What the agent should know about these conditions and medications — '
          'warning signs, when to seek emergency help, treatment preferences '
          'the agent should advocate for',
          '')}",');
    }
    buf.writeln('  "additional_meds_to_consider": [{"name":"..","reason":"why this med is beneficial"}],');
    buf.writeln('  "additional_meds_with_limitations": [{"name":"..","reason":"specific limitation/restriction for this med"}],');
    buf.writeln('  "additional_meds_to_avoid": [{"name":"..","reason":"why to avoid this med"}]');
    buf.writeln('}');

    return buf.toString();
  }

  /// Translate stored consent values into clear human-readable descriptions
  /// so the AI understands the user's hard decisions.
  static String _describeConsent(String value) {
    if (value == 'yes') return 'YES — user consents';
    if (value == 'no') return 'NO — user refuses (hard no, do NOT suggest otherwise)';
    if (value == 'agentDecides') return 'AGENT DECIDES — user delegated to agent';
    if (value.startsWith('conditional:')) {
      return 'CONDITIONAL — user consents only if: ${value.substring('conditional:'.length)}';
    }
    return value;
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
