import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// One Federal Register document relevant to the app's FEDERAL legal facts.
class FederalRegisterDoc {
  final String documentNumber;
  final String title;
  final String abstract;
  final String publicationDate; // YYYY-MM-DD as returned by the API
  final String type; // Rule | Proposed Rule | Notice | …
  final String agencies; // joined agency names
  final String url; // html_url — the citable source link

  const FederalRegisterDoc({
    required this.documentNumber,
    required this.title,
    required this.abstract,
    required this.publicationDate,
    required this.type,
    required this.agencies,
    required this.url,
  });
}

/// Deterministic, KEYLESS watch over the U.S. **Federal Register**
/// (`federalregister.gov`) for the FEDERAL rules this app references — HIPAA,
/// 42 CFR Part 2 (substance-use record confidentiality), CMS advance-directive
/// rules, and the 988 Suicide & Crisis Lifeline.
///
/// This does NOT cover PA Act 194 / 20 Pa.C.S. — that is STATE law and never
/// appears in the Federal Register (state-legislation tracking needs Open
/// States / LegiScan). It feeds the admin updater's **verify tier**: each hit
/// carries an authoritative `html_url` the maintainer can cite as the `source`
/// for a legal/dated change. No API key, no auth — just a public GET.
class FederalRegisterService {
  static const _base =
      'https://www.federalregister.gov/api/v1/documents.json';

  /// Curated search terms covering the federal facts the app references. Each is
  /// run separately and the results merged + de-duplicated, so a change under
  /// any of these surfaces without one broad query burying it.
  static const _terms = <String>[
    'mental health advance directive',
    'advance directive',
    '42 CFR Part 2',
    'HIPAA privacy',
    '988 Suicide and Crisis Lifeline',
  ];

  final http.Client _client;
  FederalRegisterService({http.Client? client})
      : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 12);

  /// Recent relevant documents, newest first, de-duplicated across the curated
  /// terms and capped at [limit]. Best-effort: a term that fails is skipped
  /// rather than aborting the whole watch; returns `[]` only if everything fails.
  Future<List<FederalRegisterDoc>> recentRelevant({int limit = 25}) async {
    final byNumber = <String, FederalRegisterDoc>{};
    for (final term in _terms) {
      try {
        final docs = await _search(term, perTerm: 8);
        for (final d in docs) {
          byNumber.putIfAbsent(d.documentNumber, () => d);
        }
      } catch (e) {
        debugPrint('FederalRegisterService term "$term": $e');
      }
    }
    final all = byNumber.values.toList()
      ..sort((a, b) => b.publicationDate.compareTo(a.publicationDate));
    return all.take(limit).toList();
  }

  /// One term query against the Federal Register, limited to rules / proposed
  /// rules / notices and newest first.
  Future<List<FederalRegisterDoc>> _search(String term,
      {int perTerm = 8}) async {
    // The query has repeated keys (conditions[type][], fields[]), which
    // Uri.replace would collapse — build the query string manually so they all
    // survive.
    final qs = <String>[
      'per_page=$perTerm',
      'order=newest',
      'conditions[term]=${Uri.encodeQueryComponent(term)}',
      'conditions[type][]=RULE',
      'conditions[type][]=PRORULE',
      'conditions[type][]=NOTICE',
      for (final f in const [
        'document_number',
        'title',
        'abstract',
        'publication_date',
        'type',
        'agencies',
        'html_url',
      ])
        'fields[]=$f',
    ];
    final fullUri = Uri.parse('$_base?${qs.join('&')}');
    final resp = await _client.get(fullUri).timeout(_timeout);
    if (resp.statusCode != 200) {
      throw Exception('Federal Register ${resp.statusCode}');
    }
    final json = jsonDecode(resp.body);
    if (json is! Map) return const [];
    final results = json['results'];
    if (results is! List) return const [];
    return results.whereType<Map>().map((r) {
      final agencies = (r['agencies'] as List?)
              ?.whereType<Map>()
              .map((a) => (a['name'] ?? a['raw_name'] ?? '').toString())
              .where((s) => s.isNotEmpty)
              .join(', ') ??
          '';
      return FederalRegisterDoc(
        documentNumber: (r['document_number'] ?? '').toString(),
        title: (r['title'] ?? '').toString(),
        abstract: (r['abstract'] ?? '').toString(),
        publicationDate: (r['publication_date'] ?? '').toString(),
        type: (r['type'] ?? '').toString(),
        agencies: agencies,
        url: (r['html_url'] ?? '').toString(),
      );
    }).where((d) => d.title.isNotEmpty && d.url.isNotEmpty).toList();
  }

  void dispose() => _client.close();
}
