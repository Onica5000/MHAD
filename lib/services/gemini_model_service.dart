import 'dart:convert';

import 'package:http/http.dart' as http;

/// One model from the Gemini ListModels API.
class GeminiModel {
  /// Bare id, e.g. `gemini-3.5-flash` (the API returns `models/gemini-3.5-flash`).
  final String id;
  final String displayName;
  final String description;
  final int inputTokenLimit;
  final int outputTokenLimit;
  final List<String> supportedMethods;

  const GeminiModel({
    required this.id,
    required this.displayName,
    required this.description,
    required this.inputTokenLimit,
    required this.outputTokenLimit,
    required this.supportedMethods,
  });

  factory GeminiModel.fromJson(Map<String, dynamic> j) {
    final name = (j['name'] ?? '').toString();
    return GeminiModel(
      id: name.startsWith('models/') ? name.substring('models/'.length) : name,
      displayName: (j['displayName'] ?? '').toString(),
      description: (j['description'] ?? '').toString(),
      inputTokenLimit: (j['inputTokenLimit'] as num?)?.toInt() ?? 0,
      outputTokenLimit: (j['outputTokenLimit'] as num?)?.toInt() ?? 0,
      supportedMethods: ((j['supportedGenerationMethods'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  bool get supportsGenerate => supportedMethods.contains('generateContent');
  bool get isFlash => id.contains('flash');
  bool get isLite => id.contains('lite');
  bool get isPro => id.contains('pro');

  /// Aliases (`gemini-flash-latest`) and experimental/preview builds are not
  /// pinnable stable versions — we pin a concrete release, never a moving alias.
  bool get isAliasOrPreview =>
      id.endsWith('-latest') ||
      id.contains('-exp') ||
      id.contains('preview') ||
      id.contains('thinking');

  /// Non-text models the app can't use for its chat/extraction tasks.
  bool get isNonText =>
      id.contains('embedding') ||
      id.contains('aqa') ||
      id.contains('imagen') ||
      id.contains('image') ||
      id.contains('-tts') ||
      id.contains('learnlm');

  /// A usable, pinnable, text-generation model.
  bool get isCandidate =>
      supportsGenerate && !isAliasOrPreview && !isNonText;

  /// Numeric version (e.g. 3.5 → 305, 2.0 → 200) for ordering. Higher = newer.
  /// Returns -1 when no `gemini-<major>[.<minor>]` version is present.
  int get versionScore {
    final m = RegExp(r'gemini-(\d+)(?:\.(\d+))?').firstMatch(id);
    if (m == null) return -1;
    final major = int.tryParse(m.group(1) ?? '') ?? 0;
    final minor = int.tryParse(m.group(2) ?? '0') ?? 0;
    return major * 100 + minor;
  }
}

/// The outcome of researching the live Gemini catalog: the recommended Flash
/// model (the app's default tier — fast, free-tier-friendly) and the most
/// capable Pro alternative, so a human can choose Pro when accuracy demands it.
class ModelRecommendation {
  final GeminiModel? bestFlash;
  final GeminiModel? bestPro;
  final String currentModel;
  final List<GeminiModel> all;

  const ModelRecommendation({
    required this.bestFlash,
    required this.bestPro,
    required this.currentModel,
    required this.all,
  });

  /// Newer-than-current check for [m] (true when worth switching).
  bool isNewerThanCurrent(GeminiModel? m) {
    if (m == null) return false;
    if (m.id == currentModel) return false;
    final cur = GeminiModel(
      id: currentModel,
      displayName: '',
      description: '',
      inputTokenLimit: 0,
      outputTokenLimit: 0,
      supportedMethods: const [],
    ).versionScore;
    return m.versionScore >= cur;
  }
}

/// Researches the live Gemini model catalog so the admin update tool proposes a
/// switch to the genuinely-best available model instead of relying on a
/// hardcoded id or the drafting AI's (possibly stale) training knowledge.
///
/// Selection policy (per product decision): Flash first — the app's tasks are
/// tuned for the fast, free-tier Flash tier — with the best Pro surfaced as an
/// accuracy alternative for a human to choose. A concrete version is always
/// pinned (never a `-latest` alias). The winner is validated with a real
/// generateContent ping before being proposed.
class GeminiModelService {
  final String apiKey;
  final http.Client _client;

  GeminiModelService(this.apiKey, {http.Client? client})
      : _client = client ?? http.Client();

  static const _base = 'https://generativelanguage.googleapis.com/v1beta';

  /// GET every model the key can see (following pagination).
  Future<List<GeminiModel>> listModels() async {
    final models = <GeminiModel>[];
    String? pageToken;
    do {
      final qp = {'key': apiKey, 'pageSize': '1000'};
      if (pageToken != null && pageToken.isNotEmpty) qp['pageToken'] = pageToken;
      final uri = Uri.parse('$_base/models').replace(queryParameters: qp);
      final resp = await _client.get(uri);
      if (resp.statusCode != 200) {
        throw Exception('ListModels ${resp.statusCode}: ${resp.body}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      for (final raw in (data['models'] as List?) ?? const []) {
        if (raw is Map) {
          models.add(GeminiModel.fromJson(raw.cast<String, dynamic>()));
        }
      }
      pageToken = data['nextPageToken']?.toString();
    } while (pageToken != null && pageToken.isNotEmpty);
    return models;
  }

  /// Confirm [modelId] actually serves generateContent (a tiny, cheap ping).
  /// Returns true on a 200 with any text; false otherwise.
  Future<bool> validate(String modelId) async {
    final uri = Uri.parse('$_base/models/$modelId:generateContent')
        .replace(queryParameters: {'key': apiKey});
    try {
      final resp = await _client.post(
        uri,
        headers: {'content-type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': 'Reply with the single word: ok'}
              ]
            }
          ],
          'generationConfig': {'maxOutputTokens': 5},
        }),
      );
      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Pure ranking: pick the best Flash and best Pro from [models] given the
  /// [currentModel]. Flash excludes the cheaper "lite" variants (accuracy is
  /// prioritised over token cost); ties break toward the canonical (shortest)
  /// id, e.g. `gemini-3.5-flash` over `gemini-3.5-flash-002`.
  static ModelRecommendation rank(List<GeminiModel> models, String currentModel) {
    int better(GeminiModel a, GeminiModel b) {
      if (a.versionScore != b.versionScore) {
        return b.versionScore - a.versionScore; // higher version first
      }
      return a.id.length - b.id.length; // canonical (shorter) id first
    }

    GeminiModel? pick(Iterable<GeminiModel> xs) {
      final list = xs.toList()..sort(better);
      return list.isEmpty ? null : list.first;
    }

    final candidates = models.where((m) => m.isCandidate).toList();
    final bestFlash =
        pick(candidates.where((m) => m.isFlash && !m.isLite)) ??
            pick(candidates.where((m) => m.isFlash)); // fall back to lite
    final bestPro = pick(candidates.where((m) => m.isPro));

    return ModelRecommendation(
      bestFlash: bestFlash,
      bestPro: bestPro,
      currentModel: currentModel,
      all: models,
    );
  }

  /// Research + rank in one call (network).
  Future<ModelRecommendation> recommend(String currentModel) async =>
      rank(await listModels(), currentModel);
}
