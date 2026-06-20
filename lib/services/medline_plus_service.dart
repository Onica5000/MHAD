import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/services/certificate_pinning_service.dart';

/// Plain-language patient education from NLM's **MedlinePlus Connect**, keyed
/// off the codes the app already obtains (ICD-10-CM for conditions). Free, no
/// API key. Returns null on any failure so callers can simply hide the
/// "Learn about this" affordance — it never blocks the form.
///
/// This is reference/education content, NOT medical advice; surface it framed
/// that way (see legal-wording canon).
class MedlinePlusService {
  static const _base = 'https://connect.medlineplus.gov/service';

  /// HL7 OID for the ICD-10-CM code system (MedlinePlus Connect's `v.cs`).
  static const _icd10Cs = '2.16.840.1.113883.6.90';

  static final _client = CertificatePinningService.createPinnedClient();

  // Small in-memory cache (per session). Stores nulls too, so a miss isn't
  // re-fetched on every rebuild.
  static final _cache = <String, MedlinePlusTopic?>{};

  /// Look up plain-language education for an ICD-10-CM [code]
  /// (e.g. `F33.1`). Returns null when MedlinePlus has nothing for the code.
  static Future<MedlinePlusTopic?> forIcd10(String code) async {
    final c = code.trim();
    if (c.isEmpty) return null;
    if (_cache.containsKey(c)) return _cache[c];

    final uri = Uri.parse('$_base?knowledgeResponseType=application/json'
        '&mainSearchCriteria.v.cs=$_icd10Cs'
        '&mainSearchCriteria.v.c=${Uri.encodeComponent(c)}');
    try {
      final resp =
          await _client.get(uri).timeout(appData.config.clinicalApiTimeout);
      if (resp.statusCode != 200) {
        _cache[c] = null;
        return null;
      }
      final topic = _parse(resp.body);
      _cache[c] = topic;
      return topic;
    } catch (e) {
      debugPrint('MedlinePlusService: $e');
      _cache[c] = null;
      return null;
    }
  }

  /// Parse the Atom-as-JSON feed MedlinePlus Connect returns. Defensive: the
  /// shape varies slightly (string vs {_value} objects), so we coerce.
  static MedlinePlusTopic? _parse(String body) {
    final json = jsonDecode(body);
    if (json is! Map) return null;
    final feed = json['feed'];
    if (feed is! Map) return null;
    final entries = feed['entry'];
    if (entries is! List || entries.isEmpty) return null;
    final e = entries.first;
    if (e is! Map) return null;

    String coerce(dynamic v) {
      if (v == null) return '';
      if (v is String) return v;
      if (v is Map && v['_value'] != null) return v['_value'].toString();
      return v.toString();
    }

    final title = _stripHtml(coerce(e['title']));
    final summary = _stripHtml(coerce(e['summary']));
    var url = '';
    final links = e['link'];
    if (links is List && links.isNotEmpty && links.first is Map) {
      url = (links.first as Map)['href']?.toString() ?? '';
    }
    if (title.isEmpty && summary.isEmpty) return null;
    return MedlinePlusTopic(title: title, summary: summary, url: url);
  }

  /// MedlinePlus summaries are HTML; strip tags/entities for plain display.
  static String _stripHtml(String s) {
    final noTags = s.replaceAll(RegExp(r'<[^>]*>'), ' ');
    final decoded = noTags
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ');
    return decoded.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}

/// A single plain-language education topic from MedlinePlus.
class MedlinePlusTopic {
  final String title;
  final String summary;
  final String url;
  const MedlinePlusTopic({
    required this.title,
    required this.summary,
    this.url = '',
  });
}
