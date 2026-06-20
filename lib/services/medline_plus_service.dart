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

  /// RxNav endpoint to resolve a drug NAME → RxCUI (MedlinePlus Connect keys
  /// medications off RxNorm codes, not free-text names).
  static const _rxNavBase = 'https://rxnav.nlm.nih.gov/REST/rxcui.json';

  /// RxNav base for concept-relationship lookups (e.g. a strength/brand → its
  /// ingredient), used for the ingredient fallback below.
  static const _rxNavConceptBase = 'https://rxnav.nlm.nih.gov/REST/rxcui';

  /// HL7 OIDs for the code systems MedlinePlus Connect accepts (`v.cs`).
  static const _icd10Cs = '2.16.840.1.113883.6.90'; // ICD-10-CM
  static const _rxNormCs = '2.16.840.1.113883.6.88'; // RxNorm

  static final _client = CertificatePinningService.createPinnedClient();

  // Small in-memory cache (per session). Stores nulls too, so a miss isn't
  // re-fetched on every rebuild.
  static final _cache = <String, MedlinePlusTopic?>{};

  /// Look up plain-language education for an ICD-10-CM [code]
  /// (e.g. `F33.1`). Returns null when MedlinePlus has nothing for the code.
  static Future<MedlinePlusTopic?> forIcd10(String code) async {
    final c = code.trim();
    if (c.isEmpty) return null;
    final key = 'icd:$c';
    if (_cache.containsKey(key)) return _cache[key];
    final topic = await _forCode(_icd10Cs, c);
    _cache[key] = topic;
    return topic;
  }

  /// Look up plain-language education for a medication by NAME. Resolves the
  /// name → RxCUI via RxNav first (MedlinePlus keys meds off RxNorm codes),
  /// then fetches the topic. Returns null when the drug can't be resolved or
  /// MedlinePlus has nothing for it.
  static Future<MedlinePlusTopic?> forMedication(String medName) async {
    final base = _drugBaseName(medName);
    if (base.length < 2) return null;
    final key = 'med:$base';
    if (_cache.containsKey(key)) return _cache[key];
    MedlinePlusTopic? topic;
    final rxcui = await _rxcuiForName(base);
    if (rxcui != null) {
      // 1) Try the concept the name resolved to directly.
      topic = await _forCode(_rxNormCs, rxcui);
      // 2) Fallback: MedlinePlus often carries consumer content only at the
      //    INGREDIENT (generic) level, not for a specific strength or brand.
      //    If the exact concept has no topic, retry with its ingredient RxCUI.
      if (topic == null) {
        final ingredient = await _ingredientRxcui(rxcui);
        if (ingredient != null && ingredient != rxcui) {
          topic = await _forCode(_rxNormCs, ingredient);
        }
      }
    }
    _cache[key] = topic;
    return topic;
  }

  /// Fetch + parse a MedlinePlus Connect topic for a code in code-system [cs].
  static Future<MedlinePlusTopic?> _forCode(String cs, String code) async {
    final uri = Uri.parse('$_base?knowledgeResponseType=application/json'
        '&mainSearchCriteria.v.cs=$cs'
        '&mainSearchCriteria.v.c=${Uri.encodeComponent(code)}');
    try {
      final resp =
          await _client.get(uri).timeout(appData.config.clinicalApiTimeout);
      if (resp.statusCode != 200) return null;
      return _parse(resp.body);
    } catch (e) {
      debugPrint('MedlinePlusService: $e');
      return null;
    }
  }

  /// Resolve a drug name to its RxNorm RxCUI via RxNav. `search=1` allows a
  /// normalized/approximate match so common spellings still resolve.
  static Future<String?> _rxcuiForName(String name) async {
    final uri = Uri.parse(
        '$_rxNavBase?name=${Uri.encodeComponent(name)}&search=1');
    try {
      final resp =
          await _client.get(uri).timeout(appData.config.clinicalApiTimeout);
      if (resp.statusCode != 200) return null;
      final json = jsonDecode(resp.body);
      if (json is Map) {
        final idGroup = json['idGroup'];
        if (idGroup is Map) {
          final ids = idGroup['rxnormId'];
          if (ids is List && ids.isNotEmpty) return ids.first.toString();
        }
      }
    } catch (e) {
      debugPrint('MedlinePlusService rxcui: $e');
    }
    return null;
  }

  /// The ingredient (TTY=IN) RxCUI related to [rxcui], or null. Lets a specific
  /// strength/brand fall back to its generic, which MedlinePlus is far more
  /// likely to have plain-language content for. Sends only the code to RxNav.
  static Future<String?> _ingredientRxcui(String rxcui) async {
    final uri =
        Uri.parse('$_rxNavConceptBase/$rxcui/related.json?tty=IN');
    try {
      final resp =
          await _client.get(uri).timeout(appData.config.clinicalApiTimeout);
      if (resp.statusCode != 200) return null;
      final json = jsonDecode(resp.body);
      if (json is Map) {
        final group = json['relatedGroup'];
        if (group is Map && group['conceptGroup'] is List) {
          for (final g in group['conceptGroup'] as List) {
            if (g is Map && g['tty'] == 'IN') {
              final props = g['conceptProperties'];
              if (props is List && props.isNotEmpty && props.first is Map) {
                final id = (props.first as Map)['rxcui'];
                if (id != null && id.toString().isNotEmpty) {
                  return id.toString();
                }
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('MedlinePlusService ingredient: $e');
    }
    return null;
  }

  /// Strip a strength/form suffix so "Sertraline 50 MG Tab" → "sertraline",
  /// which resolves cleanly through RxNav.
  static String _drugBaseName(String medName) {
    var s = medName.trim().toLowerCase();
    final firstDigit = s.indexOf(RegExp(r'\d'));
    if (firstDigit > 0) s = s.substring(0, firstDigit);
    s = s.replaceAll(
        RegExp(r'\b(tab|tablet|tablets|cap|capsule|capsules|oral|solution|'
            r'suspension|injection|er|xr|sr|hcl|hydrochloride)\b'),
        ' ');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
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
