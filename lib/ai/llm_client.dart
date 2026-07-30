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

/// Thrown when the provider rejects the API key itself — HTTP 401/403, or the
/// Gemini SDK's "API key not valid" family.
///
/// This used to fall through to a generic "API error", which the UI rendered as
/// "please try again later" — advice that can never work, since waiting does
/// not repair a bad key. Retrying is futile for this class of failure, so it
/// gets its own type and its own message.
class LlmAuthError implements Exception {
  final String message;
  const LlmAuthError(this.message);
  @override
  String toString() => message;
}

/// Thrown when the provider doesn't recognise the requested model — HTTP 404,
/// or Gemini's "model not found" / "not supported for generateContent". Almost
/// always a retired or mistyped model id, which is fixable in AI setup, so it
/// must not be reported as a transient server problem.
class LlmModelNotFoundError implements Exception {
  final String message;
  const LlmModelNotFoundError(this.message);
  @override
  String toString() => message;
}

/// Thrown when the request never reached the provider: no connectivity, DNS
/// failure, or — on web — a CORS rejection.
///
/// Browsers surface all of these as an opaque `ClientException: Failed to
/// fetch`, with the real reason visible only in the devtools console. The web
/// build is the shipping surface and `SocketException` never fires there, so
/// without this type the app had no network-error path on web at all.
class LlmNetworkError implements Exception {
  final String message;
  const LlmNetworkError(this.message);
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

  /// The underlying HTTP client — exposed for the one call that bypasses this
  /// transport (the assistant's Gemini grounded-search REST call), so it can
  /// share the same pinned connection instead of creating a second client.
  http.Client get httpClient => _http;

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
        return _geminiChat(
          system: system,
          history: history,
          userMessage: userMessage,
          timeout: timeout,
        );
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

  /// Gemini multi-turn chat. Kept separate so it can share [_mapGeminiError]:
  /// this path previously let raw SDK exceptions escape, so a rejected key
  /// surfaced in chat as an unexplained generic failure.
  Future<String> _geminiChat({
    String? system,
    required List<ChatMessage> history,
    required String userMessage,
    Duration? timeout,
  }) async {
    final m = gen.GenerativeModel(
      model: model,
      apiKey: apiKey,
      httpClient: _http,
      systemInstruction: system == null ? null : gen.Content.system(system),
    );
    final chat = m.startChat(
      history: [
        for (final msg in history)
          gen.Content(
            msg.role == MessageRole.user ? 'user' : 'model',
            [gen.TextPart(msg.content)],
          ),
      ],
    );
    try {
      final resp =
          await _await(chat.sendMessage(gen.Content.text(userMessage)), timeout);
      return resp.text ?? '';
    } on gen.GenerativeAIException catch (e) {
      throw _mapGeminiError(e);
    } on http.ClientException catch (e) {
      throw _networkError(e.message);
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
      // HEIC/HEIF is the iPhone default but only Gemini decodes it — Anthropic
      // and the OpenAI-compatible APIs accept jpeg/png/gif/webp only. The app
      // can't transcode it (the Dart `image` package has no HEIC decoder), so
      // say so plainly instead of uploading something the provider will reject.
      if (isImage &&
          (p.mimeType == 'image/heic' || p.mimeType == 'image/heif') &&
          provider != AiProvider.gemini) {
        throw UnsupportedInputError(
          "${provider.label} can't read HEIC/HEIF photos (the iPhone default). "
          'Switch to Gemini, or re-save the photo as JPEG or PNG first.',
        );
      }
      if (isImage) continue; // every provider reads the common image formats
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
      throw _mapGeminiError(e);
    } on http.ClientException catch (e) {
      throw _networkError(e.message);
    }
  }

  /// The Gemini SDK signals every failure class through one exception type with
  /// only a human-readable message, so the class has to be recovered from that
  /// text. Maps onto the same typed errors the REST providers throw, so callers
  /// and [FriendlyError] can treat all four providers identically.
  ///
  /// Returns the original exception when nothing matches — better to surface an
  /// unknown Gemini message verbatim than to mislabel it.
  Exception _mapGeminiError(gen.GenerativeAIException e) {
    final msg = e.message.toLowerCase();
    if (msg.contains('429') ||
        msg.contains('rate limit') ||
        msg.contains('quota') ||
        msg.contains('resource_exhausted')) {
      return LlmRateLimitError(
          'Too many requests to ${provider.label}. Please wait a minute '
          'and try again.');
    }
    // "API key not valid", "API_KEY_INVALID", "permission denied", 401/403.
    if (msg.contains('api key') ||
        msg.contains('api_key') ||
        msg.contains('unauthenticated') ||
        msg.contains('permission denied') ||
        msg.contains('permission_denied') ||
        msg.contains('401') ||
        msg.contains('403')) {
      return LlmAuthError(
          '${provider.label} rejected your API key. Open AI setup and check '
          'the key is correct, still active, and has the Generative Language '
          'API enabled.');
    }
    // "models/x is not found", "not supported for generateContent", 404.
    if (msg.contains('not found') ||
        msg.contains('not_found') ||
        msg.contains('is not supported') ||
        msg.contains('404')) {
      return LlmModelNotFoundError(
          '${provider.label} doesn\'t recognise the model "$model" — it may '
          'have been retired. Pick a different model in AI setup.');
    }
    return e;
  }

  LlmNetworkError _networkError(String detail) => LlmNetworkError(
        "Couldn't reach ${provider.label} ($detail). Check your internet "
        'connection. If you are on the web app, this provider may also be '
        "blocked by your browser's CORS policy — Gemini and Claude both work "
        'in the browser.',
      );

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
    final resp = await _post(
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
      timeout: timeout,
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
    final resp = await _post(
      Uri.parse(provider.chatCompletionsUrl),
      headers: {
        'content-type': 'application/json',
        'authorization': 'Bearer $apiKey',
      },
      body: jsonEncode(body),
      timeout: timeout,
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
    switch (resp.statusCode) {
      case 429:
        return LlmRateLimitError(
            'Too many requests to ${provider.label}. Please wait a minute and '
            'try again.');
      case 401:
      case 403:
        return LlmAuthError(
            '${provider.label} rejected your API key. Open AI setup and check '
            'the key is correct, still active, and belongs to '
            '${provider.label}.');
      case 404:
        return LlmModelNotFoundError(
            '${provider.label} doesn\'t recognise the model "$model". Pick a '
            'different model in AI setup.');
      case 500:
      case 502:
      case 503:
      case 504:
        return Exception(
            '${provider.label} is having server trouble (${resp.statusCode}). '
            'This one usually is temporary — try again shortly.');
      default:
        return Exception('${provider.label} API error (${resp.statusCode}).');
    }
  }

  /// Runs [send] and converts transport-level failures into [LlmNetworkError].
  ///
  /// `http` throws [http.ClientException] for both a dead connection and a
  /// browser CORS rejection; there is no way to tell them apart from Dart, so
  /// the message names both possibilities rather than guessing wrong.
  Future<http.Response> _post(
    Uri url, {
    required Map<String, String> headers,
    required Object body,
    Duration? timeout,
  }) async {
    try {
      return await _await(
        _http.post(url, headers: headers, body: body),
        timeout,
      );
    } on http.ClientException catch (e) {
      throw _networkError(e.message);
    }
  }
}
