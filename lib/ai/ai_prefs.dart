import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/data/app_data/app_data.dart';

/// The user's AI configuration: which provider is active, plus the bring-your-
/// own key and chosen model for each provider (remembered per provider so
/// switching back doesn't require re-pasting). Immutable; the notifiers in
/// `assistant_providers.dart` persist it (secure storage in private mode,
/// in-memory + short-TTL cache in public mode).
class AiPrefs {
  final AiProvider provider;
  final Map<AiProvider, String> keys;
  final Map<AiProvider, String> models;

  const AiPrefs({
    required this.provider,
    this.keys = const {},
    this.models = const {},
  });

  static const AiPrefs initial = AiPrefs(provider: AiProvider.gemini);

  /// Key for the active provider (null/empty → AI is off).
  String? get activeKey => keys[provider];

  /// Chosen model for [p]; the Gemini default tracks `appData.ai.model` (so the
  /// admin update flow keeps controlling it), others use their first curated model.
  String modelFor(AiProvider p) =>
      models[p] ?? (p == AiProvider.gemini ? appData.ai.model : p.defaultModel);

  String get activeModel => modelFor(provider);

  AiPrefs withProvider(AiProvider p) =>
      AiPrefs(provider: p, keys: keys, models: models);

  AiPrefs withKey(AiProvider p, String key) {
    final next = Map<AiProvider, String>.from(keys);
    final trimmed = key.trim();
    if (trimmed.isEmpty) {
      next.remove(p);
    } else {
      next[p] = trimmed;
    }
    return AiPrefs(provider: provider, keys: next, models: models);
  }

  AiPrefs withModel(AiProvider p, String model) {
    final next = Map<AiProvider, String>.from(models)..[p] = model.trim();
    return AiPrefs(provider: provider, keys: keys, models: next);
  }

  Map<String, dynamic> toJson() => {
        'provider': provider.name,
        'keys': {for (final e in keys.entries) e.key.name: e.value},
        'models': {for (final e in models.entries) e.key.name: e.value},
      };

  static AiPrefs fromJson(Map<String, dynamic> json) {
    Map<AiProvider, String> parse(Object? raw) {
      final out = <AiProvider, String>{};
      if (raw is Map) {
        raw.forEach((k, v) {
          final p = AiProvider.values.where((e) => e.name == k);
          if (p.isNotEmpty && v is String && v.isNotEmpty) out[p.first] = v;
        });
      }
      return out;
    }

    return AiPrefs(
      provider: AiProvider.fromName(json['provider'] as String?),
      keys: parse(json['keys']),
      models: parse(json['models']),
    );
  }
}
