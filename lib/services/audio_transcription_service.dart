import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/services/certificate_pinning_service.dart';

/// Transcribes spoken audio to text with Gemini — used by the voice-dictation
/// overlay when AI is available. More accurate on clinical terms (medication
/// names, conditions) than the browser/OS speech service, which routinely
/// mis-hears drug names.
///
/// The audio (including any personal details the user speaks) is sent to
/// Google, like the autofill upload — the caller gates this behind consent.
class AudioTranscriptionService {
  final String apiKey;
  AudioTranscriptionService(this.apiKey);

  Future<String> transcribe(
    Uint8List audioBytes, {
    String mimeType = 'audio/wav',
  }) async {
    final model = GenerativeModel(
      model: appData.ai.model,
      apiKey: apiKey,
      httpClient: CertificatePinningService.createPinnedClient(),
      generationConfig: GenerationConfig(
        maxOutputTokens: appData.ai.maxOutputTokens,
      ),
    );
    final response = await model.generateContent(
      [
        Content.multi([TextPart(_prompt), DataPart(mimeType, audioBytes)]),
      ],
    ).timeout(appData.config.documentExtractionTimeout);
    return (response.text ?? '').trim();
  }

  static const _prompt = '''
Transcribe this audio recording to text. The speaker is dictating into a field of their Pennsylvania Mental Health Advance Directive.
- Write exactly what they said, as clean readable text with normal punctuation and capitalization.
- Spell MEDICATION names and medical CONDITIONS correctly using clinical context (e.g., lamotrigine, clozapine, quetiapine, bipolar disorder). Do NOT guess a drug or condition you did not clearly hear.
- Do NOT add commentary, headings, labels, quotation marks, or anything the speaker did not say. Return ONLY the transcript text.
- If the audio is silent or unintelligible, return an empty string.''';
}
