import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:mhad/ai/document_extraction_result.dart';
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/services/certificate_pinning_service.dart';

/// Sends a document (image, PDF, or text) to Gemini and extracts structured
/// MHAD-relevant fields (medications, conditions, facilities, etc.).
class DocumentExtractor {
  final String apiKey;
  final http.Client _httpClient;

  DocumentExtractor({required this.apiKey})
      : _httpClient = CertificatePinningService.createPinnedClient();

  static const _model = 'gemini-2.5-flash';

  // Gemini tiles images into 768x768 chunks at ~258 tokens each.
  // 1024px max keeps a portrait document to ~2 tiles (~516 tokens).
  static const _maxImageDimension = 1024;
  static const _jpegQuality = 75;

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
      ),
    );

    final parts = <Part>[TextPart(_extractionPrompt)];
    List<String> piiStripped = [];

    if (mimeType.startsWith('text/')) {
      // Text files — strip PII locally before sending
      final rawText = utf8.decode(bytes, allowMalformed: true);
      final stripResult = PiiStripper.stripWithReport(rawText);
      piiStripped = stripResult.removedCategories;
      parts.add(TextPart('--- DOCUMENT CONTENT ---\n${stripResult.sanitizedText}'));
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
      const Duration(seconds: 60),
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

  static const _extractionPrompt = '''
You are analyzing a document provided by a user who is filling out a Pennsylvania Mental Health Advance Directive (PA Act 194 of 2004).

CRITICAL PII RULES — absolute, no exceptions:
- NEVER include any personally identifiable information in your response
- REJECT and IGNORE: patient names, dates of birth, addresses, phone numbers, SSNs, email addresses, insurance IDs, medical record numbers, provider names
- If the document contains PII, extract ONLY the medical data (medications, conditions, preferences) and discard all PII completely
- Your JSON response must contain ZERO names, ZERO dates of birth, ZERO addresses, ZERO identifying numbers

Extract relevant medical information and return it as JSON. Only include fields where you can confidently identify information.

{
  "medications_to_avoid": [
    {"name": "medication name", "reason": "why to avoid (side effects, allergies, etc.)"}
  ],
  "medications_preferred": [
    {"name": "medication name", "reason": "why preferred (currently taking, works well, etc.)"}
  ],
  "preferred_facility": "name of preferred treatment facility",
  "avoid_facility": "name of facility to avoid",
  "effective_condition": "mental health conditions or circumstances mentioned",
  "health_history": "relevant mental health history, diagnoses, hospitalizations",
  "dietary": "dietary restrictions or needs mentioned",
  "religious": "religious or cultural preferences mentioned",
  "activities": "therapeutic activities or coping strategies mentioned",
  "crisis_intervention": "crisis intervention preferences mentioned",
  "other": "any other advance directive-relevant information not fitting above categories"
}

Rules:
- ONLY extract what is explicitly stated in the document
- For medications: classify as "to_avoid" if the document mentions allergies, adverse reactions, side effects, or discontinuation; classify as "preferred" if currently prescribed, recommended, or noted as effective
- If a medication appears with no clear avoid/prefer signal, classify it as "preferred" (assume current medications are desired)
- If the document contains no relevant medical information, return an empty object: {}
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
