import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:mhad/ai/document_extraction_result.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/services/certificate_pinning_service.dart';

/// Sends a document (image, PDF, or text) to Gemini and extracts structured
/// MHAD-relevant fields (medications, conditions, facilities, etc.).
class DocumentExtractor {
  final String apiKey;
  final http.Client _httpClient;

  DocumentExtractor({required this.apiKey})
      : _httpClient = CertificatePinningService.createPinnedClient();

  static String get _model => appData.ai.model;

  // Gemini tiles images into 768x768 chunks at ~258 tokens each.
  // 1024px max keeps a portrait document to ~2 tiles (~516 tokens).
  // Read from the dynamic `config` block (`config.aiInput.*`).
  static int get _maxImageDimension => appData.config.maxImageDimension;
  static int get _jpegQuality => appData.config.jpegQuality;

  /// Extract structured data from raw bytes.
  Future<ExtractionWithPiiReport> extractFromBytes(
    Uint8List bytes, {
    required String mimeType,
  }) async {
    final model = GenerativeModel(
      model: _model,
      apiKey: apiKey,
      httpClient: _httpClient,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        // A strict schema forces a complete, consistent shape every run.
        responseSchema: _extractionSchema,
        // NOTE: temperature/top_p/top_k are intentionally NOT set. Google
        // advises removing them for Gemini 3.x models (they degrade output and
        // were a likely cause of the model under-extracting). Determinism now
        // comes from the strict schema + an exhaustive prompt, not temperature.
        // Headroom so a long document (many meds / long notes) is never cut off.
        maxOutputTokens: appData.ai.maxOutputTokens,
      ),
    );

    final parts = <Part>[TextPart(_extractionPrompt)];
    List<String> piiStripped = [];

    if (mimeType.startsWith('text/')) {
      // Text files — sent as-is (no local PII stripping). Autofill is the one
      // place the AI is allowed to read personal details so it can fill the
      // declarant + designated people; consistent with images/PDFs, which are
      // already sent unredacted. (The hardcoded PII rule still applies to every
      // OTHER AI path — suggestions, chat, context.)
      final rawText = utf8.decode(bytes, allowMalformed: true);
      parts.add(TextPart('--- DOCUMENT CONTENT ---\n$rawText'));
    } else if (mimeType.startsWith('image/')) {
      // Images — cannot strip PII client-side, rely on prompt instruction
      final optimized = _optimizeImage(bytes);
      parts.add(DataPart('image/jpeg', optimized));
    } else {
      // PDFs — cannot strip PII client-side, rely on prompt instruction
      parts.add(DataPart(mimeType, bytes));
    }

    final response = await model
        .generateContent([Content.multi(parts)]).timeout(
      appData.config.documentExtractionTimeout,
    );

    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Empty response from Gemini');
    }

    return ExtractionWithPiiReport(
      result: _parseResponse(text),
      strippedPiiCategories: piiStripped,
    );
  }

  /// Decodes an image, resizes so the longest side is ≤ [_maxImageDimension],
  /// and re-encodes as JPEG. This minimizes Gemini token usage while keeping
  /// text readable. Falls back to the original bytes if decoding fails.
  Uint8List _optimizeImage(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return bytes;

    img.Image image = decoded;

    // Resize if either dimension exceeds the cap
    final longest =
        image.width > image.height ? image.width : image.height;
    if (longest > _maxImageDimension) {
      if (image.width > image.height) {
        image = img.copyResize(image, width: _maxImageDimension);
      } else {
        image = img.copyResize(image, height: _maxImageDimension);
      }
    }

    return Uint8List.fromList(img.encodeJpg(image, quality: _jpegQuality));
  }

  DocumentExtractionResult _parseResponse(String text) {
    // Strip markdown code fences (handles \r\n from some API responses)
    var cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned
          .replaceFirst(RegExp(r'^```(?:json)?\s*[\r\n]*'), '')
          .replaceFirst(RegExp(r'[\r\n]*```\s*$'), '');
    }
    // Remove trailing commas before } or ] (common AI JSON quirk)
    cleaned = cleaned.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');

    try {
      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return DocumentExtractionResult.fromJson(json);
    } catch (e) {
      debugPrint('Document extraction parse error: $e');
      throw Exception(
          'Could not parse AI response as structured data. '
          'The document may not contain recognizable medical information.');
    }
  }

  /// Strict response schema — every field optional (the model omits what it
  /// can't find), so the JSON shape is consistent without forcing fabrication.
  /// Medication lists are arrays of {name, reason}.
  static final Schema _extractionSchema = Schema.object(
    properties: {
      'medications_to_avoid': Schema.array(
        nullable: true,
        items: Schema.object(properties: {
          'name': Schema.string(),
          'reason': Schema.string(nullable: true),
        }),
      ),
      'medications_preferred': Schema.array(
        nullable: true,
        items: Schema.object(properties: {
          'name': Schema.string(),
          'reason': Schema.string(nullable: true),
        }),
      ),
      // Medications with restricted-use conditions — the 'limitation' type.
      'medications_limited': Schema.array(
        nullable: true,
        items: Schema.object(properties: {
          'name': Schema.string(),
          'reason': Schema.string(nullable: true),
        }),
      ),
      // Distinct from effectiveCondition — these are the person's mental-health
      // diagnoses, written to the Diagnoses step (DiagnosisEntries table).
      'diagnoses': Schema.array(
        nullable: true,
        items: Schema.object(properties: {
          'name': Schema.string(),
          'icd_code': Schema.string(nullable: true),
        }),
      ),
      // Drug, food, material, and other allergies — step 8 (DirectiveAllergies).
      'allergies': Schema.array(
        nullable: true,
        items: Schema.object(properties: {
          'substance': Schema.string(),
          'kind': Schema.string(nullable: true),
          'severity': Schema.string(nullable: true),
          'reactions': Schema.string(nullable: true),
          'notes': Schema.string(nullable: true),
        }),
      ),
      'preferred_facility': Schema.string(nullable: true),
      'avoid_facility': Schema.string(nullable: true),
      'effective_condition': Schema.string(nullable: true),
      'agent_authority_limitations': Schema.string(nullable: true),
      'health_history': Schema.string(nullable: true),
      'dietary': Schema.string(nullable: true),
      'religious': Schema.string(nullable: true),
      'activities': Schema.string(nullable: true),
      'crisis_intervention': Schema.string(nullable: true),
      'pet_custody': Schema.string(nullable: true),
      'children_custody': Schema.string(nullable: true),
      'family_notification': Schema.string(nullable: true),
      'records_disclosure': Schema.string(nullable: true),
      'other': Schema.string(nullable: true),
      // Personal information (PII) — extracted ONLY for autofill.
      // Address is split into components so every form field is populated.
      'personal_info': Schema.object(nullable: true, properties: {
        'full_name': Schema.string(nullable: true),
        'date_of_birth': Schema.string(nullable: true),
        'address_line1': Schema.string(nullable: true),
        'address_line2': Schema.string(nullable: true),
        'city': Schema.string(nullable: true),
        'county': Schema.string(nullable: true),
        'state': Schema.string(nullable: true),
        'zip': Schema.string(nullable: true),
        'phone': Schema.string(nullable: true),
        'primary_doctor_name': Schema.string(nullable: true),
        'primary_doctor_phone': Schema.string(nullable: true),
        'preferred_evaluating_doctor_name': Schema.string(nullable: true),
        'preferred_evaluating_doctor_contact': Schema.string(nullable: true),
        'agent': _personSchema,
        'alternate_agent': _personSchema,
        'guardian': _personSchema,
      }),
    },
  );

  static final Schema _personSchema = Schema.object(nullable: true, properties: {
    'name': Schema.string(nullable: true),
    'relationship': Schema.string(nullable: true),
    'address_line1': Schema.string(nullable: true),
    'address_line2': Schema.string(nullable: true),
    'city': Schema.string(nullable: true),
    'state': Schema.string(nullable: true),
    'zip': Schema.string(nullable: true),
    'phone': Schema.string(nullable: true),
  });

  static const _extractionPrompt = '''
You are analyzing a document uploaded by a user who is filling out a Pennsylvania Mental Health Advance Directive (PA Act 194 of 2004). This is AUTOFILL — the user uploaded this document so its contents can pre-fill their form. You MUST extract personal information (PII); that is the primary purpose of this step.

═══ STEP 1: EXTRACT PERSONAL INFORMATION FIRST ═══
Before reading anything else, locate and extract all personal details into "personal_info":

DECLARANT (the person this directive is FOR — look for labels: patient, principal, declarant, "I" / "me"):
• full_name — full legal name. Format: as written.
• date_of_birth — Format: MM/DD/YYYY (e.g., 03/15/1975). Convert from any other format.
• address_line1 — street number and street name only (e.g., "123 Main St" or "123 Main St Apt 4B").
• address_line2 — apartment, suite, unit, floor — ONLY if it is a SEPARATE line from line 1. Leave null if it is already in line 1.
• city — city name only.
• county — county name only (PA form includes county). Leave null if not stated.
• state — 2-letter state abbreviation (e.g., PA). Default to PA if in a Pennsylvania document and not stated.
• zip — 5-digit ZIP code only (e.g., 17101 — drop the +4 suffix if present).
• phone — Format: (xxx) xxx-xxxx (e.g., (215) 555-1234).
• primary_doctor_name — the declarant's primary care doctor / treating physician name.
• primary_doctor_phone — that doctor's phone. Same (xxx) xxx-xxxx format.
• preferred_evaluating_doctor_name — if the document names a SPECIFIC doctor preferred to certify the declarant's incapacity (different from the primary care doctor, e.g., "I prefer Dr. Smith to evaluate my capacity").
• preferred_evaluating_doctor_contact — that evaluating doctor's phone or address.

DESIGNATED PEOPLE — use these sub-objects:
• agent — the PRIMARY health-care agent / proxy / representative (the FIRST-named, not the backup).
  Fields: name, relationship, address_line1, address_line2 (apt/unit if separate), city, state, zip (5-digit), phone (xxx) xxx-xxxx.
• alternate_agent — the BACKUP / second / alternate agent. Same fields.
• guardian — any nominated guardian. Same fields.

ADDRESS FORMAT FOR ALL PERSONS — always split into components:
  ✓ address_line1: "456 Oak Ave"  city: "Pittsburgh"  state: "PA"  zip: "15213"
  ✗ Do NOT put "456 Oak Ave, Pittsburgh, PA 15213" all in address_line1.

RULE: NEVER put any person's name, phone, or address into any care/medical field (health_history, activities, crisis_intervention, family_notification, etc.). ALL persons go in personal_info ONLY.

═══ STEP 2: EXTRACT ALL CARE INSTRUCTIONS — ONE FIELD PER FACT, NO DUPLICATION ═══
Each piece of information goes in EXACTLY ONE field. Once placed, it must NOT appear in any other field.

medications_to_avoid
  → ONLY if the document EXPLICITLY says: allergy, adverse reaction, avoid, discontinue, do not give, do not use, never give.
  → NOT for medications merely listed, currently prescribed, or mentioned with no explicit avoid signal.
  → Drug allergies go BOTH here AND in "allergies" (kind: drug, severity: severe) when explicitly marked as allergic.

medications_preferred
  → ONLY if the document EXPLICITLY says: prefers, wants, currently taking and working well, or chooses.
  → NOT for medications merely listed with no stated preference.

medications_limited
  → Medications the person accepts ONLY under specific conditions or restrictions (e.g., "only as last resort", "only in inpatient setting", "only if no alternative").
  → NOT for fully-preferred or fully-avoided meds. Captures the middle ground.

diagnoses
  → The person's mental health diagnoses (e.g., bipolar disorder, schizophrenia, PTSD, MDD).
  → Each as {name: "Diagnosis Name", icd_code: "F31.0"} — include ICD code if stated, otherwise omit.
  → NOT the effective condition text. NOT symptoms. NOT hospitalization history.
  → Goes to the Diagnoses step in the app.

allergies
  → All allergies: drug, food, material/latex, and other.
  → Each as {substance: "...", kind: "drug"|"food"|"material"|"other", severity: "mild"|"moderate"|"severe", reactions: "comma-separated symptoms", notes: "..."}.
  → Severity guidance: mild = rash/GI; moderate = hives/swelling; severe = anaphylaxis/ER.
  → Extract even if the allergy is already in medications_to_avoid — both fields get it.

preferred_facility
  → Name of a hospital or treatment center the person WANTS to be treated at.
  → NOT a doctor's name or clinic.

avoid_facility
  → Name of a hospital or treatment center the person wants to AVOID.

effective_condition
  → The specific circumstances that TRIGGER this directive (e.g., "when two professionals certify I lack capacity", "during involuntary commitment").
  → This is the "when it kicks in" language — NOT diagnoses, NOT treatment preferences.

agent_authority_limitations
  → Any limitations or conditions on what the agent is or is NOT authorized to do (e.g., "my agent cannot consent to ECT", "my agent must consult my sister before deciding").
  → Goes to the Agent Authority step.

health_history
  → Relevant mental-health history: past diagnoses (as prose), past hospitalizations, what treatments have/have not worked. Also: current medications mentioned without an explicit avoid/prefer label.
  → NOT crisis plans. NOT comfort activities. NOT current preferences.

dietary
  → Dietary restrictions, food allergies (as prose), nutrition needs or preferences.
  → NOT medications. NOT religious observances unless purely food-related (kosher/halal food → dietary).

religious
  → Religious, spiritual, or cultural preferences: clergy to contact, prayer, observances, rituals, sacraments.
  → NOT comfort activities. NOT food rules unless religiously motivated.

activities
  → Coping strategies, therapeutic activities, comfort items, things that HELP during hospitalization: music, walks, crafts, grounding techniques, pet as comfort.
  → NOT crisis de-escalation plans. NOT dietary. NOT health history.

crisis_intervention
  → Instructions specifically for CRISIS situations: de-escalation preferences, early warning signs, what NOT to do, restraint/seclusion preferences, who to call in a crisis (not as contact storage — as a preference like "call my sister first").
  → NOT general history. NOT general comfort activities.

pet_custody
  → Who cares for PETS while the person is hospitalized: who feeds/houses them, vet info.
  → Look for: dog, cat, bird, fish, animal, pet. NOT pets as in-hospital comfort items (→ activities).

children_custody
  → Who cares for CHILDREN or other dependents while the person is hospitalized.
  → NOT general family info.

family_notification
  → Explicit preferences about who SHOULD or SHOULD NOT be contacted if hospitalized (e.g., "call my sister Jane", "do not contact my estranged father").
  → Stated as a PREFERENCE, NOT as contact-info storage for personal_info people.

records_disclosure
  → Preferences about sharing, releasing, or withholding medical records — to whom and under what conditions.

other
  → ANYTHING important that does NOT fit a field above: financial matters, home/plant care, mail, work coverage, specific named-person instructions. NEVER drop an instruction — put it here rather than omitting it.

═══ NO-DUPLICATION RULE ═══
Each fact belongs to EXACTLY ONE field. Examples:
  • Medication listed with no preference → health_history ONLY
  • Person's name + phone → personal_info ONLY (not family_notification)
  • Pet as in-hospital comfort → activities ONLY (not pet_custody)
  • Crisis de-escalation → crisis_intervention ONLY
  • Doctor's name → personal_info.primary_doctor_name ONLY
  • Diagnosis name → diagnoses list ONLY (not also effective_condition)
  • Drug allergy → both medications_to_avoid AND allergies (this is the only allowed exception)

═══ GENERAL RULES ═══
1. READ THE ENTIRE DOCUMENT before extracting — do not stop early.
2. EXTRACT ONLY what is explicitly stated. Do not diagnose, infer, fabricate, advise, or add anything not written.
3. BE EXHAUSTIVE — if the document lists 10 medications, return all 10. Do not summarize or omit.
4. OMIT EMPTY FIELDS — if you have nothing confident for a field, leave it null. Do not invent.
5. PERSONAL INFO FIRST — always complete personal_info before processing any other field.

Return ONLY valid JSON matching the schema. No explanation, commentary, or markdown.
''';
}

/// Result of document extraction with a PII detection report.
class ExtractionWithPiiReport {
  final DocumentExtractionResult result;
  final List<String> strippedPiiCategories;

  const ExtractionWithPiiReport({
    required this.result,
    required this.strippedPiiCategories,
  });

  bool get hadPii => strippedPiiCategories.isNotEmpty;

  String get piiSummary => strippedPiiCategories.toSet().join(', ');
}
