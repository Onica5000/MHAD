import 'package:mhad/data/app_data/app_data.dart';

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
  // catalog). First entry is the DEFAULT — chosen as each provider's best
  // efficiency/quality balance for this app (fast chat, vision autofill, JSON),
  // followed by alternatives. Refreshed from each provider's model docs
  // 2026-10-01; edit as models change (or use the admin tool's live refresh).
  gemini(
    label: 'Google Gemini',
    keyHint: 'Gemini API key (AIza…)',
    host: 'generativelanguage.googleapis.com',
    getKeyUrl: 'https://aistudio.google.com/app/apikey',
    // Default is Flash-Lite: on the free tier it allows ~500 requests/day vs
    // ~20 for the Flash models (Oct 2026), and nearly every user is on a free
    // key. The 2.5 models shut down Oct 16-17 2026 and were removed.
    models: [
      'gemini-3.5-flash-lite', // default (also app_data.ai.model)
      'gemini-3.5-flash', // stronger; ~20 free requests/day
      'gemini-3.8-flash', // newest, most capable Flash; ~20 free/day
    ],
  ),
  anthropic(
    label: 'Anthropic Claude',
    keyHint: 'Anthropic key (sk-ant-…)',
    host: 'api.anthropic.com',
    getKeyUrl: 'https://console.anthropic.com/settings/keys',
    models: [
      'claude-sonnet-5-5', // default — current Sonnet: speed + capability
      'claude-haiku-4-5', // fastest + cheapest
      'claude-opus-5-5', // current Opus
      'claude-fable-5-1', // most capable (premium pricing)
    ],
  ),
  openai(
    label: 'OpenAI GPT',
    keyHint: 'OpenAI key (sk-…)',
    host: 'api.openai.com',
    getKeyUrl: 'https://platform.openai.com/api-keys',
    models: [
      'gpt-5.4-mini', // default — low-cost, vision + JSON
      'gpt-5.4-nano', // cheapest
      'gpt-6-luna', // GPT-6 efficient reasoning model
      'gpt-6.1-sol', // GPT-6 flagship
    ],
  ),
  grok(
    label: 'xAI Grok',
    keyHint: 'xAI key (xai-…)',
    host: 'api.x.ai',
    getKeyUrl: 'https://console.x.ai',
    models: [
      'grok-4.7', // default — xAI's current flagship
      'grok-4.3', // cheaper, 1M context
      'grok-4.20-0309-non-reasoning', // no reasoning latency
      'grok-build-0.1', // cheapest
    ],
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

  /// The model-picker options for this provider: the externalized,
  /// admin-updatable list from `appData.ai.providerModels[name]` if present,
  /// else the hardcoded [models] fallback. Use this for the pickers; keep
  /// [defaultModel] (the const first entry) as the canonical storage default.
  List<String> get availableModels => appData.ai.modelsFor(name) ?? models;

  /// The default model the app uses RIGHT NOW: Gemini follows `appData.ai.model`;
  /// the others follow the first entry of the admin-updatable list. So when the
  /// admin model check retires a model, the app moves off it without a code
  /// change.
  String get currentDefault =>
      this == AiProvider.gemini ? appData.ai.model : availableModels.first;

  /// Whether [model] is still offered (a saved pick that was later retired from
  /// the curated list is not — callers fall back to [currentDefault]).
  bool isOffered(String model) =>
      availableModels.contains(model) ||
      (this == AiProvider.gemini && model == appData.ai.model);

  /// Resolves the effective model id for a request: an explicit non-blank
  /// [requested] wins; otherwise Gemini reads the admin-updatable
  /// `appData.ai.model` and every other provider uses its curated
  /// [defaultModel]. The one copy of the rule every AI service shares.
  String resolveModel(String? requested) {
    final trimmed = requested?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return currentDefault;
  }

  /// Only Gemini supports Google-Search grounding ("Verify on the web"). Other
  /// providers degrade to an ungrounded answer with no sources.
  bool get supportsGrounding => this == AiProvider.gemini;

  /// All four offer vision-capable models (image input).
  bool get supportsVision => true;

  /// Native PDF input is supported by Gemini and Claude. OpenAI/Grok chat
  /// completions take images only — a PDF must be converted or pasted as text.
  bool get supportsPdf =>
      this == AiProvider.gemini || this == AiProvider.anthropic;

  /// Audio transcription (voice dictation) is Gemini-only here. Other providers
  /// fall back to the browser/OS speech service.
  bool get supportsAudio => this == AiProvider.gemini;

  /// Whether the provider's API can be called directly from a browser (CORS).
  /// Gemini allows it; Anthropic allows it via the
  /// `anthropic-dangerous-direct-browser-access` header (sent by LlmClient).
  /// OpenAI / xAI generally do NOT send CORS headers, so on web they tend to be
  /// blocked — surfaced as a warning in the setup UI (this is the ship surface).
  bool get worksInBrowser =>
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
