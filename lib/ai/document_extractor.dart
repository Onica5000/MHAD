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
  /// Medication lists are arrays of {name, reason}. Pairs with temperature 0
  /// for repeatable extractions.
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
You are analyzing a document provided by a user who is filling out a Pennsylvania Mental Health Advance Directive (PA Act 194 of 2004). This is AUTOFILL: the user uploaded this document so its details can pre-fill their form, so you SHOULD extract their personal information when present.

Extract the relevant information and return it as JSON. Only include fields where you can confidently identify information.

{
  "medications_to_avoid": [
    {"name": "medication name", "reason": "why to avoid (side effects, allergies, etc.)"}
  ],
  "medications_preferred": [
    {"name": "medication name", "reason": "why preferred (currently taking, works well, etc.)"}
  ],
  "preferred_facility": "name of a hospital/treatment facility the person PREFERS to be treated at",
  "avoid_facility": "name of a hospital/treatment facility the person wants to AVOID",
  "effective_condition": "the conditions/circumstances under which this directive takes effect, or the mental-health condition(s) it concerns",
  "health_history": "relevant mental-health history: diagnoses, past hospitalizations, what has/hasn't worked, current medications listed without an explicit preference",
  "dietary": "dietary restrictions, allergies-to-food, or nutrition needs/preferences",
  "religious": "religious, spiritual, or cultural preferences and practices (e.g., clergy to call, observances, prayer)",
  "activities": "therapeutic activities, coping strategies, comfort items, or things that help (music, walks, grounding techniques, etc.)",
  "crisis_intervention": "what helps or harms during a crisis: de-escalation preferences, early warning signs, what NOT to do, restraint/seclusion preferences, who to contact",
  "pet_custody": "instructions for the care of the person's PET(S) while they are hospitalized — who feeds/houses them, vet info, etc. (look for any mention of pets, dogs, cats, animals)",
  "children_custody": "instructions for the care of the person's CHILDREN or other dependents while they are hospitalized — who looks after them",
  "family_notification": "who should be notified/contacted (or NOT notified) if the person is hospitalized — names and how to reach them",
  "records_disclosure": "preferences about releasing or withholding medical records / information, and to whom",
  "other": "any other directive-relevant instruction that does not fit a field above — financial/work matters to handle, plants/home to care for, anything important. NEVER drop an instruction just because it lacks a category.",
  "personal_info": {
    "full_name": "the declarant's / patient's full name (the person the directive is FOR)",
    "date_of_birth": "the declarant's date of birth, as written",
    "address": "the declarant's full mailing address on one line (street, city, state, ZIP)",
    "phone": "the declarant's phone number",
    "primary_doctor_name": "the declarant's primary doctor / treating physician name",
    "primary_doctor_phone": "that doctor's phone number",
    "agent": {"name": "...", "relationship": "relationship to the declarant", "address": "full address on one line", "phone": "..."},
    "alternate_agent": {"name": "...", "relationship": "...", "address": "...", "phone": "..."},
    "guardian": {"name": "...", "relationship": "...", "address": "...", "phone": "..."}
  }
}

Rules:
- BE EXHAUSTIVE AND PRECISE. Read the ENTIRE document carefully and extract EVERY relevant item that is explicitly stated — every medication, every condition, every preference, every note. If the document lists multiple medications, return ALL of them, not a subset. Do not summarize, group, shorten, or omit anything relevant. Work methodically through the whole document so nothing is missed.
- BE COMPLETE, NOT BRIEF. This is data extraction, not summarization — favor capturing more over less. Do not shorten, skip, or judge something as unimportant; if it is an instruction or preference in the document, capture it. A missed instruction (for example, who will care for the person's pet or children) is a serious error.
- USE EVERY APPLICABLE FIELD and place each piece of information where it most logically belongs. The fields map directly to the app's form: medications → the medication lists; conditions/circumstances → "effective_condition"; history/diagnoses/hospitalizations → "health_history"; food needs → "dietary"; religious/spiritual/cultural → "religious"; coping strategies/comfort items → "activities"; crisis/de-escalation preferences → "crisis_intervention"; **pet care → "pet_custody"; child/dependent care → "children_custody"; who to notify → "family_notification"; record-release preferences → "records_disclosure"**; facilities → the facility fields; people/identity → "personal_info". Anything important that does NOT clearly fit a specific field MUST go in "other" — never drop it. Do not duplicate the same item across multiple fields; pick the single best-fitting field.
- ONLY extract what is explicitly stated in the document. Do NOT diagnose, infer, or add any condition, medication, or preference that is not written in the document. Extract only — never advise, recommend, or suggest.
- PERSONAL INFO: Extract personal details (names, date of birth, addresses, phone numbers) ONLY into the "personal_info" block, and ONLY when they are clearly present. The "full_name"/"date_of_birth"/"address"/"phone" fields are for the DECLARANT — the person this directive is FOR (often labelled patient, principal, declarant, or "I/me"). Put a designated health-care agent / proxy / representative under "agent", a backup/second one under "alternate_agent", and any nominated guardian under "guardian". Never put a person's name, address, or phone into any medical field. Omit any personal field you are not confident about.
- For medications: classify as "to_avoid" ONLY if the document explicitly states an allergy, adverse reaction, or that the medication should be avoided or discontinued; classify as "preferred" ONLY if the document explicitly states the user wants, prefers, or chooses it.
- Do NOT assume intent. If a medication is merely listed or currently prescribed with no explicit avoid-or-prefer statement, do NOT place it in either list — the user will decide. You may mention it neutrally under "health_history" as a current medication, without implying any preference.
- If the document contains no relevant information, return an empty object: {}
- Return ONLY valid JSON, no explanation or commentary
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
