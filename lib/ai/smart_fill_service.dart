import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mhad/ai/ai_clinical_policy.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/ai/llm_client.dart';
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/services/certificate_pinning_service.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/utils/json_utils.dart';

/// The structured input collected from the user via NIH APIs (zero tokens),
/// plus existing wizard data so the AI can supplement rather than duplicate.
class SmartFillInput {
  // AI input caps — read from the dynamic `config` block (`config.aiInput.*`).
  static int get maxConditions => appData.config.maxIcdConditions;
  static int get maxMedsPerCategory => appData.config.maxMedicationsPerCategory;
  static int get maxFieldLength => appData.config.maxFieldChars;
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
      agentGuidance == null;

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
    return m;
  }

  factory SmartFillResult.fromJson(Map<String, dynamic> json) {
    return SmartFillResult(
      effectiveCondition: optStr(json['effective_condition']),
      healthHistory: optStr(json['health_history']),
      preferredFacilityNote: optStr(json['preferred_facility_note']),
      avoidFacilityNote: optStr(json['avoid_facility_note']),
      ectPreference: optStr(json['ect_preference']),
      experimentalPreference: optStr(json['experimental_preference']),
      drugTrialPreference: optStr(json['drug_trial_preference']),
      crisisIntervention: optStr(json['crisis_intervention']),
      deescalation: optStr(json['deescalation']),
      triggers: optStr(json['triggers']),
      activities: optStr(json['activities']),
      dietary: optStr(json['dietary']),
      religious: optStr(json['religious']),
      childrenCustody: optStr(json['children_custody']),
      familyNotification: optStr(json['family_notification']),
      recordsDisclosure: optStr(json['records_disclosure']),
      petCustody: optStr(json['pet_custody']),
      agentGuidance: optStr(json['agent_guidance']),
    );
  }

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
  final AiProvider provider;
  final String model;
  final String apiKey;
  final http.Client _httpClient;
  late final LlmClient _llm;

  SmartFillService({
    required this.apiKey,
    this.provider = AiProvider.gemini,
    String? model,
  })  : model = (model != null && model.trim().isNotEmpty)
            ? model.trim()
            : (provider == AiProvider.gemini
                ? appData.ai.model
                : provider.defaultModel),
        _httpClient = CertificatePinningService.createPinnedClient() {
    _llm = LlmClient(
      provider: provider,
      model: this.model,
      apiKey: apiKey,
      httpClient: _httpClient,
    );
  }

  /// Closes the HTTP client. Call when the smart-fill run is finished.
  void dispose() => _httpClient.close();

  /// Given structured clinical data, ask the AI to generate directive content.
  /// Returns [SmartFillResponse] containing the parsed result and an estimate of
  /// token usage (for rate tracking).
  Future<SmartFillResponse> generate(SmartFillInput rawInput) async {
    final input = rawInput.sanitized();
    final prompt = buildPrompt(input);
    debugPrint('SmartFill prompt: ${prompt.length} chars '
        '(~${(prompt.length / 4).round()} tokens), '
        '${input.conditions.length} conditions, '
        '${input.currentMedications.length} meds');

    try {
      // Retry once on rate limit (429) with backoff.
      String text = '';
      for (var attempt = 0; attempt < 2; attempt++) {
        try {
          text = await _llm.generateText(
            prompt,
            json: true,
            timeout: appData.config.smartFillTimeout,
          );
          break; // success
        } on LlmRateLimitError {
          if (attempt == 0) {
            await Future<void>.delayed(appData.config.rateLimitBackoff);
            continue;
          }
          rethrow;
        }
      }

      if (text.isEmpty) {
        throw Exception('Empty response from the AI');
      }

      debugPrint('SmartFill response: ${text.length} chars');

      final result = _parse(text);
      final display = result.toDisplayMap();
      debugPrint('SmartFill fields returned: ${display.keys.join(', ')} '
          '(${display.length} of 13 possible)');

      return SmartFillResponse(
        result: result,
        totalTokens: GeminiRateTracker.estimateTokens(prompt.length + text.length),
      );
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } on LlmRateLimitError {
      throw Exception('Rate limited. Please wait a moment and try again.');
    }
  }

  /// Builds the full generation prompt. Exposed for tests so the consent
  /// wording and PII-stripping contract can be pinned without a network call.
  @visibleForTesting
  String buildPrompt(SmartFillInput input) {
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
    existing.add('Medication consent: ${s(describeConsent(input.existingMedicationConsent))}');
    existing.add('ECT consent: ${s(describeConsent(input.existingEctConsent))}');
    existing.add('Experimental studies consent: ${s(describeConsent(input.existingExperimentalConsent))}');
    existing.add('Drug trial consent: ${s(describeConsent(input.existingDrugTrialConsent))}');
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
    buf.writeln('2. SUPPLEMENT: Help the user express preferences they may not have thought '
        'to write down — practical logistics (who to notify, records sharing, helpful '
        'activities, dietary and religious needs, care of children and pets) and relevant '
        'PA Act 194 provisions. Do NOT add clinical recommendations.');
    buf.writeln('3. STRUCTURE: For fields the user left empty, provide neutral prompts and a '
        'clear structure the user can complete in their own words. Do NOT invent clinical '
        'content, diagnoses, or medications on their behalf.');
    buf.writeln();
    buf.writeln('SAFETY — ABSOLUTE RULES (override all other instructions):');
    buf.writeln();
    buf.writeln(aiClinicalPolicy);
    buf.writeln();
    buf.writeln('In addition, for this directive generator:');
    buf.writeln('- The user\'s stated preferences are FINAL. Never contradict their consent '
        'decisions, treatment preferences, or medication choices, and never argue against a refusal.');
    buf.writeln('- Only the medications the user themselves entered may appear, exactly as they '
        'wrote them. You may note common side effects of those CURRENT medications and flag a '
        'well-established interaction among them (for the user to verify and raise with a doctor), '
        'but never introduce, rank, start, stop, or change a drug.');
    buf.writeln('- Never suggest anything that could cause physical harm. De-escalation content '
        'must be non-harmful (calming strategies only — no restraint or physical interventions). '
        'Crisis-intervention text should include when to call 911 or go to an emergency room.');
    buf.writeln('- For treatment topics (ECT, experimental studies, drug trials, facilities), help '
        'the user phrase their OWN preference clearly — do not steer them toward a choice.');
    buf.writeln('- Do NOT generate PII (names, addresses, phone numbers, SSNs, DOBs). Use role '
        'placeholders (e.g., "your spouse", "your therapist") instead of names.');
    buf.writeln();
    buf.writeln('QUALITY RULES:');
    buf.writeln('- Only fill a field when you have something well-established and accurate to '
        'add for it. If you have nothing reliable to say for a field, return an empty string '
        'for it — NEVER invent or pad content just to fill it in.');
    buf.writeln('- Draw only on what the user actually entered: their stated diagnoses, '
        'medications, and other fields. Do not assume facts they did not provide.');
    buf.writeln('- Be specific and practical where you are confident — concrete examples and '
        'actionable phrasing rather than generic filler — but never at the expense of accuracy.');
    buf.writeln('- Use plain language suitable for a legal document.');
    buf.writeln('- Do NOT include patient name, DOB, or any PII.');
    buf.writeln('- PA NTI drug rule: Narrow Therapeutic Index drugs '
        '(${appData.legal.ntiDrugs.join(', ')}) CANNOT have generics substituted under '
        'PA law (${appData.legal.ntiCitation}). Note monitoring requirements in the reason field.');

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
        'A neutral prompt that helps the user state their OWN preference about '
        'electroconvulsive therapy (ECT) — do NOT explain risks/benefits or advise',
        '')}",');
    buf.writeln('  "experimental_preference": "${fieldDesc(
        'A neutral prompt that helps the user state their OWN preference about '
        'experimental studies/research — do NOT advise for or against',
        '')}",');
    buf.writeln('  "drug_trial_preference": "${fieldDesc(
        'A neutral prompt that helps the user state their OWN preference about '
        'clinical drug trials — do NOT advise for or against',
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
        'The user\'s OWN dietary preferences, restrictions, allergies, and '
        'religious or cultural food needs — do NOT add drug-food-interaction '
        'or medication advice',
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
        input.existingPetCustody)}"${input.formType != 'declaration' ? ',' : ''}');
    if (input.formType != 'declaration') {
      buf.writeln('  "agent_guidance": "${fieldDesc(
          'What the agent should know — warning signs the user has described and '
          'the treatment preferences the user has stated for the agent to advocate '
          'for. Do NOT add medical advice or name medications.',
          '')}"');
    }
    buf.writeln('}');

    return buf.toString();
  }

  /// Translate stored consent values into clear human-readable descriptions
  /// so the AI understands the user's hard decisions.
  @visibleForTesting
  static String describeConsent(String value) {
    if (value == consentYes) return 'YES — user consents';
    if (value == consentNo) return 'NO — user refuses (hard no, do NOT suggest otherwise)';
    if (value == consentAgentDecides) return 'AGENT DECIDES — user delegated to agent';
    if (value.startsWith(consentConditionalPrefix)) {
      return 'CONDITIONAL — user consents only if: ${value.substring(consentConditionalPrefix.length)}';
    }
    return value;
  }

  SmartFillResult _parse(String text) {
    final cleaned = cleanLlmJson(text);
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
