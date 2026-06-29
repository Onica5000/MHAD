import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/services/certificate_pinning_service.dart';

/// Live "what models can this key reach" lookup across AI providers — the admin
/// model-availability check, generalized beyond Gemini. Queries each provider's
/// models-list endpoint and returns the model IDs the key can access. Mirrors
/// how [GeminiModelService] refreshes the Gemini list, but for any provider, so
/// the maintainer can verify/refresh the curated lists in `AiProvider.models`.
///
/// All hosts are on the cert-pinning allowlist (see certificate_pinning_native).
class AiModelCatalogService {
  final http.Client _client;

  AiModelCatalogService({http.Client? client})
      : _client = client ?? CertificatePinningService.createPinnedClient();

  /// Model IDs the [apiKey] can access for [provider]. Throws on a non-200.
  Future<List<String>> fetchModelIds(AiProvider provider, String apiKey) {
    switch (provider) {
      case AiProvider.gemini:
        return _gemini(apiKey);
      case AiProvider.anthropic:
        return _anthropic(apiKey);
      case AiProvider.openai:
      case AiProvider.grok:
        return _openAiCompatible(provider, apiKey);
    }
  }

  Future<List<String>> _gemini(String apiKey) async {
    final ids = <String>[];
    String? pageToken;
    do {
      final qp = {'key': apiKey, 'pageSize': '1000'};
      if (pageToken != null && pageToken.isNotEmpty) qp['pageToken'] = pageToken;
      final uri = Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models')
          .replace(queryParameters: qp);
      final resp = await _client.get(uri);
      if (resp.statusCode != 200) {
        throw Exception('Gemini ListModels ${resp.statusCode}');
      }
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      for (final m in (data['models'] as List?) ?? const []) {
        final name = (m is Map ? m['name'] : null)?.toString() ?? '';
        if (name.isNotEmpty) ids.add(name.replaceFirst('models/', ''));
      }
      pageToken = data['nextPageToken']?.toString();
    } while (pageToken != null && pageToken.isNotEmpty);
    return ids;
  }

  Future<List<String>> _anthropic(String apiKey) async {
    final resp = await _client.get(
      Uri.parse('https://api.anthropic.com/v1/models?limit=1000'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'anthropic-dangerous-direct-browser-access': 'true',
      },
    );
    if (resp.statusCode != 200) {
      throw Exception('Anthropic /models ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return _idsFromDataArray(data);
  }

  /// OpenAI and xAI Grok share the `GET /v1/models` shape: `{ data: [{ id }] }`.
  Future<List<String>> _openAiCompatible(
      AiProvider provider, String apiKey) async {
    final resp = await _client.get(
      Uri.parse('https://${provider.host}/v1/models'),
      headers: {'authorization': 'Bearer $apiKey'},
    );
    if (resp.statusCode != 200) {
      throw Exception('${provider.label} /models ${resp.statusCode}');
    }
    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return _idsFromDataArray(data);
  }

  static List<String> _idsFromDataArray(Map<String, dynamic> data) => [
        for (final m in (data['data'] as List?) ?? const [])
          if (m is Map && m['id'] != null) m['id'].toString(),
      ];
}
