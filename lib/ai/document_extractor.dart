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
      'preferred_facility': Schema.string(nullable: true),
      'avoid_facility': Schema.string(nullable: true),
      'effective_condition': Schema.string(nullable: true),
      'health_history': Schema.string(nullable: true),
      'dietary': Schema.string(nullable: true),
      'religious': Schema.string(nullable: true),
      'activities': Schema.string(nullable: true),
      'crisis_intervention': Schema.string(nullable: true),
      // Personal-life / dependent-care instructions (real app fields — the AI
      // kept dropping these into "other" or missing them entirely).
      'pet_custody': Schema.string(nullable: true),
      'children_custody': Schema.string(nullable: true),
      'family_notification': Schema.string(nullable: true),
      'records_disclosure': Schema.string(nullable: true),
      'other': Schema.string(nullable: true),
      // Personal information (PII) — extracted ONLY for autofill so the
      // declarant and the people they designate can be filled in. Address is a
      // single line as written on the document.
      'personal_info': Schema.object(nullable: true, properties: {
        'full_name': Schema.string(nullable: true),
        'date_of_birth': Schema.string(nullable: true),
        'address': Schema.string(nullable: true),
        'phone': Schema.string(nullable: true),
        'primary_doctor_name': Schema.string(nullable: true),
        'primary_doctor_phone': Schema.string(nullable: true),
        'agent': _personSchema,
        'alternate_agent': _personSchema,
        'guardian': _personSchema,
      }),
    },
  );

  static final Schema _personSchema = Schema.object(nullable: true, properties: {
    'name': Schema.string(nullable: true),
    'relationship': Schema.string(nullable: true),
    'address': Schema.string(nullable: true),
    'phone': Schema.string(nullable: true),
  });

  static const _extractionPrompt = '''
You are analyzing a document uploaded by a user who is filling out a Pennsylvania Mental Health Advance Directive (PA Act 194 of 2004). This is AUTOFILL — the user uploaded this document so its contents can pre-fill their form. You MUST extract personal information (PII); that is the primary purpose of this step.

═══ STEP 1: EXTRACT PERSONAL INFORMATION FIRST ═══
Before reading anything else, locate and extract personal details into "personal_info":

• full_name — the DECLARANT's full legal name (the person this directive is FOR). Look for labels: patient, principal, declarant, "I" / "me". Format: as written.
• date_of_birth — the declarant's date of birth. Format: MM/DD/YYYY (e.g., 03/15/1975). Convert from any other format.
• address — the declarant's full mailing address on ONE line: street, city, state, ZIP. ZIP code: 5 digits only (e.g., 17101 — drop the +4 suffix if present).
• phone — the declarant's phone number. Format: (xxx) xxx-xxxx (e.g., (215) 555-1234).
• primary_doctor_name — the declarant's treating physician / primary doctor name only.
• primary_doctor_phone — that doctor's phone. Same (xxx) xxx-xxxx format.
• agent — the PRIMARY designated health-care agent / proxy / representative (not the backup). Fields: name, relationship to declarant, address (one line, 5-digit ZIP), phone (xxx) xxx-xxxx.
• alternate_agent — the BACKUP / second / alternate agent. Same fields.
• guardian — any nominated guardian. Same fields.

RULE: NEVER put a person's name, phone number, or address into any care/medical field (health_history, activities, crisis_intervention, family_notification, etc.). Every person goes in personal_info ONLY. family_notification is for notification PREFERENCES (who to call/not call), not for storing contact details as personal_info entries.

═══ STEP 2: EXTRACT CARE INSTRUCTIONS — ONE FIELD PER FACT, NO DUPLICATION ═══
Each piece of information goes in EXACTLY ONE field. Once placed, it must NOT appear in any other field.

FIELD DEFINITIONS (each with its exclusive scope):

medications_to_avoid
  → ONLY if the document EXPLICITLY says: allergy, adverse reaction, avoid, discontinue, do not give, or do not use.
  → NOT for medications merely listed, currently prescribed, or mentioned with no explicit avoid signal.

medications_preferred
  → ONLY if the document EXPLICITLY says: prefers, wants, currently taking and working well, or chooses this medication.
  → NOT for medications merely listed or mentioned with no preference stated.

preferred_facility
  → Name of a hospital or treatment center the person WANTS to be treated at.
  → NOT a doctor's name, clinic, or office unless explicitly stated as a preferred facility.

avoid_facility
  → Name of a hospital or treatment center the person wants to AVOID.
  → NOT a general preference to avoid treatment.

effective_condition
  → The specific mental health condition(s) or circumstances that trigger this directive (e.g., "bipolar episode requiring hospitalization", "loss of capacity to make decisions").
  → NOT treatment preferences. NOT medications. NOT general history.

health_history
  → Relevant mental-health history: past diagnoses, past hospitalizations, what has/has not worked historically. Also: current medications listed with NO explicit avoid/prefer label.
  → NOT crisis management plans. NOT comfort activities. NOT current care preferences.

dietary
  → Dietary restrictions, food allergies, nutrition needs or preferences.
  → NOT medications. NOT general health conditions. NOT religious observances (unless the restriction is purely dietary, e.g., kosher/halal food — then it goes here, not religious).

religious
  → Religious, spiritual, or cultural preferences and practices: clergy to contact, prayer, observances, rituals, sacraments.
  → NOT general comfort activities. NOT food restrictions that are purely nutritional.

activities
  → Therapeutic activities, coping strategies, comfort items, and things that HELP during treatment or hospitalization: music, walks, crafts, grounding techniques, having a pet nearby as comfort.
  → NOT crisis de-escalation plans. NOT dietary restrictions. NOT general health history.

crisis_intervention
  → Instructions specifically for CRISIS situations: de-escalation preferences, early warning signs, what NOT to do, restraint/seclusion preferences, who to call in an emergency.
  → NOT general health history. NOT non-crisis comfort activities. NOT general preferences.

pet_custody
  → Who cares for the person's PET(S) while they are hospitalized: who feeds/houses them, vet contact info. Look for: dog, cat, bird, fish, animal, pet.
  → NOT pets as comfort items during hospitalization (those go in "activities").

children_custody
  → Who cares for the person's CHILDREN or other dependents while they are hospitalized: guardian, school/daycare info.
  → NOT family notification preferences.

family_notification
  → Who SHOULD or SHOULD NOT be notified/contacted if the person is hospitalized — stated as a preference or instruction (e.g., "call my sister Jane first", "do not contact my father").
  → NOT storage of contact details for personal_info people. NOT family relationships in general.

records_disclosure
  → Preferences about sharing, releasing, or withholding medical records and information, and to whom.
  → NOT general privacy statements.

other
  → ANYTHING directive-relevant that does NOT clearly fit a field above: financial matters, home/plant care, mail, work arrangements, specific instructions to named people. NEVER drop an instruction because it lacks a category — put it here.

═══ NO-DUPLICATION RULE ═══
Each fact belongs to EXACTLY ONE field. Do NOT repeat it in another. When a fact could fit two fields, pick the more specific one. Examples:
  • Medication listed with no preference → health_history ONLY (not also medications_preferred)
  • Person's name + phone → personal_info ONLY (not also family_notification)
  • Pet as comfort → activities ONLY (not also pet_custody)
  • Crisis de-escalation → crisis_intervention ONLY (not also activities or health_history)
  • Doctor's name → personal_info.primary_doctor_name ONLY (not also health_history)

═══ GENERAL RULES ═══
1. READ THE ENTIRE DOCUMENT before extracting — do not stop early.
2. EXTRACT ONLY what is explicitly stated. Do not diagnose, infer, fabricate, advise, or add anything not written.
3. BE EXHAUSTIVE — if the document lists 10 medications, return all 10. Do not summarize or omit.
4. OMIT EMPTY FIELDS — if you have nothing confident for a field, leave it null. Do not invent.
5. PERSONAL INFO FIRST — always complete personal_info before filling any other field.

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
