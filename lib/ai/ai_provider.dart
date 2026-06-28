/// The AI providers the app can talk to. Gemini is the default (free tier,
/// multimodal, web-search grounding); Anthropic Claude, OpenAI, and xAI Grok
/// are bring-your-own-key alternatives.
///
/// This is the single source of truth for provider metadata — used by both the
/// user-facing AI (chat, autofill, smart-fill, suggestions) and the gated admin
/// update tool (`AdminAiProvider` is a typedef onto this enum).
///
/// Per-provider transport lives in [LlmClient] (lib/ai/llm_client.dart).
enum AiProvider {
  // A short, curated set of the most useful models per provider (not the full
  // catalog). First entry is the default. Edit these lists as models change.
  gemini(
    label: 'Google Gemini',
    keyHint: 'Gemini API key (AIza…)',
    host: 'generativelanguage.googleapis.com',
    getKeyUrl: 'https://aistudio.google.com/app/apikey',
    models: ['gemini-3.5-flash', 'gemini-2.5-flash', 'gemini-2.5-pro', 'gemini-2.5-flash-lite'],
  ),
  anthropic(
    label: 'Anthropic Claude',
    keyHint: 'Anthropic key (sk-ant-…)',
    host: 'api.anthropic.com',
    getKeyUrl: 'https://console.anthropic.com/settings/keys',
    models: ['claude-opus-4-8', 'claude-sonnet-4-6', 'claude-haiku-4-5'],
  ),
  openai(
    label: 'OpenAI GPT',
    keyHint: 'OpenAI key (sk-…)',
    host: 'api.openai.com',
    getKeyUrl: 'https://platform.openai.com/api-keys',
    models: ['gpt-4o', 'gpt-4o-mini', 'gpt-4.1', 'o3'],
  ),
  grok(
    label: 'xAI Grok',
    keyHint: 'xAI key (xai-…)',
    host: 'api.x.ai',
    getKeyUrl: 'https://console.x.ai',
    models: ['grok-4', 'grok-3', 'grok-3-mini'],
  );

  const AiProvider({
    required this.label,
    required this.keyHint,
    required this.host,
    required this.getKeyUrl,
    required this.models,
  });

  /// Human-facing provider name (dropdowns).
  final String label;

  /// Placeholder/help shown on the API-key field for this provider.
  final String keyHint;

  /// API hostname — added to the native certificate-pinning allowlist.
  final String host;

  /// Where the user creates a key for this provider.
  final String getKeyUrl;

  /// The curated list of useful models for this provider (first = default).
  final List<String> models;

  /// Default model id (the first curated model). NOTE: the active Gemini model
  /// defaults to `appData.ai.model` at the storage layer so the admin update
  /// flow keeps tracking Google's current model id — this is only the fallback.
  String get defaultModel => models.first;

  /// Only Gemini supports Google-Search grounding ("Verify on the web"). Other
  /// providers degrade to an ungrounded answer with no sources.
  bool get supportsGrounding => this == AiProvider.gemini;

  /// All four offer vision-capable models (image input).
  bool get supportsVision => true;

  /// Native PDF input is supported by Gemini and Claude. OpenAI/Grok chat
  /// completions take images only — a PDF must be converted or pasted as text.
  bool get supportsPdf =>
      this == AiProvider.gemini || this == AiProvider.anthropic;

  /// OpenAI-compatible Chat Completions endpoint (OpenAI and xAI share the wire
  /// format). Throws for non-compatible providers.
  String get chatCompletionsUrl => switch (this) {
        AiProvider.openai => 'https://api.openai.com/v1/chat/completions',
        AiProvider.grok => 'https://api.x.ai/v1/chat/completions',
        _ => throw StateError('$name is not OpenAI-compatible'),
      };

  /// Heuristic key-shape check per provider (a real key always passes; not a
  /// hard gate — just an early "that doesn't look right" warning).
  bool looksLikeKey(String key) {
    final k = key.trim();
    if (k.isEmpty || k.contains(RegExp(r'\s'))) return false;
    return switch (this) {
      AiProvider.gemini => k.startsWith('AIza') && k.length >= 35,
      AiProvider.anthropic => k.startsWith('sk-ant-') && k.length >= 20,
      AiProvider.openai => k.startsWith('sk-') && k.length >= 20,
      AiProvider.grok => k.startsWith('xai-') && k.length >= 20,
    };
  }

  /// Parse a stored provider name back to the enum (defaults to [gemini]).
  static AiProvider fromName(String? name) {
    for (final p in values) {
      if (p.name == name) return p;
    }
    return AiProvider.gemini;
  }
}
