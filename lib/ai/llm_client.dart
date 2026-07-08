import 'dart:convert';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart' as gen;
import 'package:http/http.dart' as http;
import 'package:mhad/ai/ai_assistant.dart' show ChatMessage, MessageRole;
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/services/certificate_pinning_service.dart';

/// One piece of multimodal input for [LlmClient.generateMultimodal].
sealed class LlmPart {
  const LlmPart();
}

class LlmText extends LlmPart {
  final String text;
  const LlmText(this.text);
}

/// Binary input (image / PDF / audio) tagged with its MIME type. Providers
/// branch on the MIME: all four read images; Gemini + Claude read PDFs; only
/// Gemini reads other kinds (e.g. audio).
class LlmData extends LlmPart {
  final String mimeType;
  final Uint8List bytes;
  const LlmData(this.mimeType, this.bytes);
}

/// Thrown when a provider can't handle an input kind (e.g. a PDF sent to a
/// vision-only OpenAI/Grok model). Carries a user-facing [message].
class UnsupportedInputError implements Exception {
  final String message;
  const UnsupportedInputError(this.message);
  @override
  String toString() => message;
}

/// Thrown when the provider rejects a request for rate/quota reasons —
/// HTTP 429 on the REST providers, or the Gemini SDK's quota errors. Typed
/// here at the transport so callers can apply their own retry/backoff policy
/// without string-sniffing exception text. Carries a user-facing [message].
class LlmRateLimitError implements Exception {
  final String message;
  const LlmRateLimitError(this.message);
  @override
  String toString() => message;
}

/// Provider-agnostic transport to a single AI model. The caller picks the
/// provider/model/key (see [AiProvider] and the storage layer); this class only
/// knows how to talk to each provider's wire format.
///
/// PII handling is intentionally NOT done here — callers strip PII before
/// handing text in (the document-autofill path is deliberately exempt). Keeping
/// this layer PII-agnostic preserves that single, auditable chokepoint upstream.
class LlmClient {
  final AiProvider provider;
  final String model;
  final String apiKey;
  final http.Client _http;
  final bool _ownsClient;

  LlmClient({
    required this.provider,
    required this.model,
    required this.apiKey,
    http.Client? httpClient,
  })  : _http = httpClient ?? CertificatePinningService.createPinnedClient(),
        _ownsClient = httpClient == null;

  /// Closes the underlying HTTP client if this instance created it. Injected
  /// clients stay open — whoever passed them in owns their lifecycle.
  void dispose() {
    if (_ownsClient) _http.close();
  }

  // ── Single-turn text ──────────────────────────────────────────────────────

  /// Generate a single response to [prompt]. Set [json] to nudge providers
  /// toward a raw JSON object (Gemini/OpenAI have a real JSON mode; Anthropic/
  /// Grok rely on the prompt — callers already parse tolerantly).
  Future<String> generateText(
    String prompt, {
    String? systemPrompt,
    bool json = false,
    Duration? timeout,
    int? maxOutputTokens,
  }) {
    switch (provider) {
      case AiProvider.gemini:
        return _gemini(
          contents: [gen.Content.text(prompt)],
          systemPrompt: systemPrompt,
          json: json,
          timeout: timeout,
          maxOutputTokens: maxOutputTokens,
        );
      case AiProvider.anthropic:
        return _anthropic(
          system: systemPrompt,
          messages: [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          json: json,
          timeout: timeout,
          maxTokens: maxOutputTokens,
        );
      case AiProvider.openai:
      case AiProvider.grok:
        return _chatCompletions(
          messages: [
            if (systemPrompt != null)
              {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          json: json,
          timeout: timeout,
          maxTokens: maxOutputTokens,
        );
    }
  }

  // ── Multi-turn chat ───────────────────────────────────────────────────────

  Future<String> chat({
    String? system,
    required List<ChatMessage> history,
    required String userMessage,
    Duration? timeout,
  }) {
    switch (provider) {
      case AiProvider.gemini:
        final model = gen.GenerativeModel(
          model: this.model,
          apiKey: apiKey,
          httpClient: _http,
          systemInstruction:
              system == null ? null : gen.Content.system(system),
        );
        final chat = model.startChat(
          history: [
            for (final m in history)
              gen.Content(
                m.role == MessageRole.user ? 'user' : 'model',
                [gen.TextPart(m.content)],
              ),
          ],
        );
        return _await(
          chat.sendMessage(gen.Content.text(userMessage)),
          timeout,
        ).then((r) => r.text ?? '');
      case AiProvider.anthropic:
        return _anthropic(
          system: system,
          messages: [
            for (final m in history)
              {
                'role': m.role == MessageRole.user ? 'user' : 'assistant',
                'content': m.content,
              },
            {'role': 'user', 'content': userMessage},
          ],
          timeout: timeout,
        );
      case AiProvider.openai:
      case AiProvider.grok:
        return _chatCompletions(
          messages: [
            if (system != null) {'role': 'system', 'content': system},
            for (final m in history)
              {
                'role': m.role == MessageRole.user ? 'user' : 'assistant',
                'content': m.content,
              },
            {'role': 'user', 'content': userMessage},
          ],
          timeout: timeout,
        );
    }
  }

  // ── Multimodal (text + image/PDF) ─────────────────────────────────────────

  Future<String> generateMultimodal({
    required List<LlmPart> parts,
    String? systemPrompt,
    bool json = false,
    gen.Schema? geminiSchema,
    Duration? timeout,
    int? maxOutputTokens,
  }) {
    // Capability guard: surface a clear, switchable error rather than a raw API
    // failure when a provider can't read an input kind.
    for (final p in parts) {
      if (p is! LlmData) continue;
      final isImage = p.mimeType.startsWith('image/');
      final isPdf = p.mimeType == 'application/pdf';
      if (isImage) continue; // every provider reads images
      if (isPdf && !provider.supportsPdf) {
        throw UnsupportedInputError(
          "${provider.label} can't read PDFs here — switch to Gemini or "
          'Claude, or paste the document text instead.',
        );
      }
      if (!isPdf && provider != AiProvider.gemini) {
        throw UnsupportedInputError(
          "${provider.label} can't read ${p.mimeType} files here — switch to "
          'Gemini, or paste the text instead.',
        );
      }
    }
    switch (provider) {
      case AiProvider.gemini:
        return _gemini(
          contents: [
            gen.Content.multi([
              for (final p in parts)
                switch (p) {
                  LlmText() => gen.TextPart(p.text),
                  LlmData() => gen.DataPart(p.mimeType, p.bytes),
                },
            ]),
          ],
          systemPrompt: systemPrompt,
          json: json,
          responseSchema: geminiSchema,
          timeout: timeout,
          maxOutputTokens: maxOutputTokens,
        );
      case AiProvider.anthropic:
        return _anthropic(
          system: systemPrompt,
          messages: [
            {
              'role': 'user',
              'content': [
                for (final p in parts)
                  switch (p) {
                    LlmText() => {'type': 'text', 'text': p.text},
                    LlmData() => p.mimeType == 'application/pdf'
                        ? {
                            'type': 'document',
                            'source': {
                              'type': 'base64',
                              'media_type': 'application/pdf',
                              'data': base64Encode(p.bytes),
                            },
                          }
                        : {
                            'type': 'image',
                            'source': {
                              'type': 'base64',
                              'media_type': p.mimeType,
                              'data': base64Encode(p.bytes),
                            },
                          },
                  },
              ],
            }
          ],
          json: json,
          timeout: timeout,
          maxTokens: maxOutputTokens,
        );
      case AiProvider.openai:
      case AiProvider.grok:
        return _chatCompletions(
          messages: [
            if (systemPrompt != null)
              {'role': 'system', 'content': systemPrompt},
            {
              'role': 'user',
              'content': [
                for (final p in parts)
                  switch (p) {
                    LlmText() => {'type': 'text', 'text': p.text},
                    LlmData() => {
                        'type': 'image_url',
                        'image_url': {
                          'url':
                              'data:${p.mimeType};base64,${base64Encode(p.bytes)}',
                        },
                      },
                  },
              ],
            },
          ],
          json: json,
          timeout: timeout,
          maxTokens: maxOutputTokens,
        );
    }
  }

  // ── Provider implementations ──────────────────────────────────────────────

  Future<String> _gemini({
    required List<gen.Content> contents,
    String? systemPrompt,
    bool json = false,
    gen.Schema? responseSchema,
    Duration? timeout,
    int? maxOutputTokens,
  }) async {
    final model = gen.GenerativeModel(
      model: this.model,
      apiKey: apiKey,
      httpClient: _http,
      systemInstruction:
          systemPrompt == null ? null : gen.Content.system(systemPrompt),
      generationConfig: gen.GenerationConfig(
        responseMimeType: (json || responseSchema != null)
            ? 'application/json'
            : null,
        responseSchema: responseSchema,
        maxOutputTokens: maxOutputTokens,
      ),
    );
    try {
      final resp = await _await(model.generateContent(contents), timeout);
      return resp.text ?? '';
    } on gen.GenerativeAIException catch (e) {
      // The Gemini SDK reports quota/rate failures only via message text —
      // normalize them to the typed error the REST providers already throw.
      final msg = e.message.toLowerCase();
      if (msg.contains('429') ||
          msg.contains('rate limit') ||
          msg.contains('quota')) {
        throw LlmRateLimitError(
            'Too many requests to ${provider.label}. Please wait a minute '
            'and try again.');
      }
      rethrow;
    }
  }

  /// Anthropic Messages API. [messages] content may be a plain string or an
  /// array of content blocks (text/image/document).
  Future<String> _anthropic({
    String? system,
    required List<Map<String, dynamic>> messages,
    bool json = false,
    Duration? timeout,
    int? maxTokens,
  }) async {
    // Anthropic has no JSON response_format; steer it via the system prompt.
    final effectiveSystem = json
        ? '${system ?? ''}\n\nRespond with ONLY a valid JSON object — no prose, '
            'no markdown code fences.'
            .trim()
        : system;
    final body = <String, dynamic>{
      'model': model,
      'max_tokens': maxTokens ?? 4096,
      if (effectiveSystem != null && effectiveSystem.isNotEmpty)
        'system': effectiveSystem,
      'messages': messages,
    };
    final resp = await _await(
      _http.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: {
          'content-type': 'application/json',
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
          // Required for Anthropic to allow direct browser (CORS) calls — the
          // app is a BYO-key client, so the user's own key is used from their
          // own browser (same trust model as the Gemini path).
          'anthropic-dangerous-direct-browser-access': 'true',
        },
        body: jsonEncode(body),
      ),
      timeout,
    );
    if (resp.statusCode != 200) throw _httpError(resp);
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final blocks = (data['content'] as List?) ?? const [];
    final buf = StringBuffer();
    for (final b in blocks) {
      if (b is Map && b['type'] == 'text') buf.write(b['text'] ?? '');
    }
    return buf.toString();
  }

  /// OpenAI-compatible Chat Completions (OpenAI + xAI Grok).
  Future<String> _chatCompletions({
    required List<Map<String, dynamic>> messages,
    bool json = false,
    Duration? timeout,
    int? maxTokens,
  }) async {
    final body = <String, dynamic>{
      'model': model,
      'messages': messages,
      if (json) 'response_format': {'type': 'json_object'},
    };
    if (maxTokens != null) body['max_tokens'] = maxTokens;
    final resp = await _await(
      _http.post(
        Uri.parse(provider.chatCompletionsUrl),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $apiKey',
        },
        body: jsonEncode(body),
      ),
      timeout,
    );
    if (resp.statusCode != 200) throw _httpError(resp);
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final choices = (data['choices'] as List?) ?? const [];
    if (choices.isEmpty) return '';
    final content = ((choices.first as Map)['message'] as Map?)?['content'];
    if (content is String) return content;
    if (content is List) {
      return content
          .whereType<Map>()
          .map((m) => (m['text'] ?? '').toString())
          .join();
    }
    return content?.toString() ?? '';
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Future<T> _await<T>(Future<T> future, Duration? timeout) =>
      timeout == null ? future : future.timeout(timeout);

  Exception _httpError(http.Response resp) {
    if (resp.statusCode == 429) {
      return LlmRateLimitError(
          'Too many requests to ${provider.label}. Please wait a minute and '
          'try again.');
    }
    return Exception('${provider.label} API error (${resp.statusCode}).');
  }
}
