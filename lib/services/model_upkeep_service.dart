import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/services/ai_model_catalog_service.dart';
import 'package:mhad/services/gemini_model_service.dart';

/// The result of checking ONE provider's curated model list
/// (`app_data.ai.providerModels.<provider>`) against its live catalog.
class ModelAudit {
  final AiProvider provider;

  /// The curated list as it is today (first = the app's default).
  final List<String> current;

  /// Curated models the provider no longer serves to this key — retired or
  /// renamed. These are what silently break the app if left in place.
  final List<String> retired;

  /// Relevant chat models the provider offers that aren't curated yet,
  /// newest first (capped at [maxNewcomers]).
  final List<String> newcomers;

  /// Why this provider couldn't be checked (null when it was).
  final String? problem;

  const ModelAudit({
    required this.provider,
    required this.current,
    this.retired = const [],
    this.newcomers = const [],
    this.problem,
  });

  bool get checked => problem == null;

  static const maxNewcomers = 8;
}

/// Model upkeep for EVERY provider (the admin "Check models — all providers"
/// action). Lists each provider's live catalog with the app's saved key for
/// that provider, flags curated models that disappeared, and offers new ones.
/// The maintainer picks; the result is an ordinary reviewed `ai.*` change.
///
/// Catalog presence is the availability test for Claude/OpenAI/Grok — no paid
/// test call is made. Gemini's list is restricted to free-tier text models,
/// matching the app's free-for-users model.
class ModelUpkeepService {
  /// Is [id] a chat/text model worth offering for [p]? Filters out embeddings,
  /// audio/realtime/image/video models, moderation, dated snapshots and
  /// previews — none of which the app can use as its assistant model.
  static bool isRelevant(AiProvider p, String id) {
    final s = id.toLowerCase();
    const junk = [
      'embedding', 'embed', 'audio', 'realtime', 'tts', 'transcribe',
      'whisper', 'dall-e', 'image', 'imagine', 'video', 'moderation',
      'search', 'instruct', 'codex', 'computer-use', 'preview', '-exp',
      'deprecated', 'chat-latest',
    ];
    if (junk.any(s.contains)) return false;
    return switch (p) {
      // Gemini relevance is decided from ListModels metadata instead.
      AiProvider.gemini => s.startsWith('gemini-'),
      AiProvider.anthropic => s.startsWith('claude-'),
      // Pinned snapshots (gpt-x-2026-05-01) duplicate their alias.
      AiProvider.openai => (s.startsWith('gpt-') || RegExp(r'^o\d').hasMatch(s)) &&
          !RegExp(r'-\d{4}-\d{2}-\d{2}$').hasMatch(s),
      AiProvider.grok => s.startsWith('grok-'),
    };
  }

  /// Pure comparison. [liveIds] = every model the key can reach (availability);
  /// [offerable] = the relevant subset, newest first (what may be added).
  static ModelAudit audit(
    AiProvider p,
    List<String> current,
    Iterable<String> liveIds,
    List<String> offerable,
  ) {
    final live = liveIds.toSet();
    if (live.isEmpty) {
      // An empty catalog is an API hiccup, not proof that everything retired.
      return ModelAudit(
          provider: p, current: current, problem: 'The API returned no models.');
    }
    final newcomers = <String>[];
    for (final id in offerable) {
      if (current.contains(id) || newcomers.contains(id)) continue;
      newcomers.add(id);
      if (newcomers.length == ModelAudit.maxNewcomers) break;
    }
    return ModelAudit(
      provider: p,
      current: current,
      retired: [for (final id in current) if (!live.contains(id)) id],
      newcomers: newcomers,
    );
  }

  /// The curated list after the maintainer's picks: retired models removed
  /// (order kept, so the default stays first unless it was retired), [added]
  /// appended. Null when nothing would change or the list would end up empty.
  static List<String>? proposedList(ModelAudit a, Iterable<String> added) {
    final next = <String>[
      for (final id in a.current) if (!a.retired.contains(id)) id,
      for (final id in added) if (!a.current.contains(id)) id,
    ];
    if (next.isEmpty) return null;
    if (next.length == a.current.length &&
        Iterable.generate(next.length).every((i) => next[i] == a.current[i])) {
      return null;
    }
    return next;
  }

  final AiModelCatalogService _catalog;

  ModelUpkeepService({AiModelCatalogService? catalog})
      : _catalog = catalog ?? AiModelCatalogService();

  /// Check [p] with [apiKey] (network). Never throws — failures (bad key,
  /// browser CORS block on OpenAI/xAI, offline) come back as [ModelAudit.problem].
  Future<ModelAudit> check(
      AiProvider p, String apiKey, List<String> current) async {
    if (apiKey.trim().isEmpty) {
      return ModelAudit(
          provider: p,
          current: current,
          problem: 'No ${p.label} key saved — skipped.');
    }
    try {
      if (p == AiProvider.gemini) {
        final models = await GeminiModelService(apiKey).listModels();
        return audit(p, current, models.map((m) => m.id),
            GeminiModelService.curatedFreeModelIds(models));
      }
      final ids = await _catalog.fetchModelIds(p, apiKey);
      return audit(p, current, ids, [for (final id in ids) if (isRelevant(p, id)) id]);
    } catch (e) {
      final msg = e.toString();
      final cors = msg.contains('XMLHttpRequest') || msg.contains('Failed to fetch');
      return ModelAudit(
        provider: p,
        current: current,
        problem: cors
            ? '${p.label} blocks this check from a browser (CORS). Compare the '
                'list against the ${p.label} console/docs, or run the desktop '
                'build.'
            : 'Could not check ${p.label}: $msg',
      );
    }
  }
}
