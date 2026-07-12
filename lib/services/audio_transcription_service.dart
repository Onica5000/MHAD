import 'dart:typed_data';

import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/ai/llm_client.dart';
import 'package:mhad/data/app_data/app_data.dart';

/// Transcribes spoken audio to text — used by the voice-dictation overlay when
/// AI is available. More accurate on clinical terms (medication names,
/// conditions) than the browser/OS speech service, which routinely mis-hears
/// drug names.
///
/// Audio transcription is **Gemini-only** ([AiProvider.supportsAudio]); for any
/// other provider [LlmClient] throws [UnsupportedInputError] *before* sending,
/// so a non-Gemini key is never transmitted to Google. The caller gates this
/// behind consent and falls back to the browser speech service otherwise.
///
/// The audio (including any personal details the user speaks) is sent to the
/// provider, like the autofill upload.
class AudioTranscriptionService {
  final AiProvider provider;
  final String model;
  final String apiKey;

  AudioTranscriptionService({
    required this.apiKey,
    this.provider = AiProvider.gemini,
    String? model,
  }) : model = provider.resolveModel(model);

  Future<String> transcribe(
    Uint8List audioBytes, {
    String mimeType = 'audio/wav',
  }) async {
    final client =
        LlmClient(provider: provider, model: model, apiKey: apiKey);
    try {
      final text = await client.generateMultimodal(
        parts: [LlmText(_prompt), LlmData(mimeType, audioBytes)],
        maxOutputTokens: appData.ai.maxOutputTokens,
        timeout: appData.config.documentExtractionTimeout,
      );
      return text.trim();
    } finally {
      client.dispose();
    }
  }

  static const _prompt = '''
Transcribe this audio recording to text. The speaker is dictating into a field of their Pennsylvania Mental Health Advance Directive.
- Write exactly what they said, as clean readable text with normal punctuation and capitalization.
- Spell MEDICATION names and medical CONDITIONS correctly using clinical context (e.g., lamotrigine, clozapine, quetiapine, bipolar disorder). Do NOT guess a drug or condition you did not clearly hear.
- Do NOT add commentary, headings, labels, quotation marks, or anything the speaker did not say. Return ONLY the transcript text.
- If the audio is silent or unintelligible, return an empty string.''';
}
