import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mhad/services/certificate_pinning_service.dart';

/// Wraps the NIH Clinical Table Search Service for both RxTerms (medications)
/// and ICD-10-CM (diagnoses). All lookups are free, no API key needed, and
/// consume zero Gemini tokens.
///
/// Includes:
/// - In-memory cache (12h TTL) per NLM recommendation to reduce server load
/// - Client-side rate limiter (max 20 req/sec per NLM Terms of Service)
class ClinicalDataService {
  static const _rxTermsBase =
      'https://clinicaltables.nlm.nih.gov/api/rxterms/v3/search';
  static const _icdBase =
      'https://clinicaltables.nlm.nih.gov/api/icd10cm/v3/search';

  static final _client = CertificatePinningService.createPinnedClient();

  // ── Cache (12h TTL per NLM recommendation) ──────────────────────────
  static final _cache = <String, _CacheEntry>{};
  static const _cacheTtl = Duration(hours: 12);
  static const _maxCacheSize = 500;

  static String? _getCached(String key) {
    final entry = _cache[key];
    if (entry == null) return null;
    if (DateTime.now().difference(entry.timestamp) > _cacheTtl) {
      _cache.remove(key);
      return null;
    }
    return entry.body;
  }

  static void _putCache(String key, String body) {
    // Evict oldest entries if cache is too large
    if (_cache.length >= _maxCacheSize) {
      final oldest = _cache.entries.first.key;
      _cache.remove(oldest);
    }
    _cache[key] = _CacheEntry(body: body, timestamp: DateTime.now());
  }

  // ── Rate limiter (20 req/sec per NLM Terms of Service) ─────────────
  // Uses a Completer-based mutex to prevent concurrent requests from
  // bypassing the rate limit.
  static final _requestTimestamps = <DateTime>[];
  static const _maxRequestsPerSecond = 20;
  static Completer<void>? _rateLimitLock;

  static Future<void> _rateLimit() async {
    // Serialize access so concurrent callers can't both slip through
    while (_rateLimitLock != null) {
      await _rateLimitLock!.future;
    }
    _rateLimitLock = Completer<void>();

    try {
      final now = DateTime.now();
      final cutoff = now.subtract(const Duration(seconds: 1));
      _requestTimestamps.removeWhere((t) => t.isBefore(cutoff));
      if (_requestTimestamps.length >= _maxRequestsPerSecond) {
        final waitUntil =
            _requestTimestamps.first.add(const Duration(seconds: 1));
        final delay = waitUntil.difference(now);
        if (delay.inMilliseconds > 0) {
          await Future<void>.delayed(delay);
        }
      }
      _requestTimestamps.add(DateTime.now());
    } finally {
      _rateLimitLock!.complete();
      _rateLimitLock = null;
    }
  }

  static Future<String?> _fetch(Uri uri) async {
    final key = uri.toString();
    final cached = _getCached(key);
    if (cached != null) return cached;

    await _rateLimit();
    final resp = await _client.get(uri).timeout(const Duration(seconds: 5));
    if (resp.statusCode != 200) {
      debugPrint('ClinicalDataService: ${uri.path} returned ${resp.statusCode}');
      return null;
    }
    _putCache(key, resp.body);
    return resp.body;
  }

  /// Search for medication names with strengths/forms.
  /// Returns [MedicationResult] objects containing the drug name and its
  /// available dosage strengths.
  static Future<List<MedicationResult>> searchMedicationsWithStrengths(
      String query,
      {int count = 12}) async {
    if (query.trim().length < 2) return [];
    final uri = Uri.parse(
        '$_rxTermsBase?terms=${Uri.encodeComponent(query)}'
        '&ef=STRENGTHS_AND_FORMS&count=$count');
    final body = await _fetch(uri);
    if (body == null) return [];
    final data = jsonDecode(body) as List;
    if (data.length < 2 || data[1] is! List) return [];

    final names = List<String>.from(data[1] as List);
    // data[2] is {"STRENGTHS_AND_FORMS": [["150 mg Cap",...], ...]}
    final extraFields = data.length >= 3 && data[2] is Map
        ? data[2] as Map<String, dynamic>
        : <String, dynamic>{};
    final strengthsLists = extraFields['STRENGTHS_AND_FORMS'] is List
        ? extraFields['STRENGTHS_AND_FORMS'] as List
        : <List>[];

    return List.generate(names.length, (i) {
      final strengths = i < strengthsLists.length && strengthsLists[i] is List
          ? List<String>.from(strengthsLists[i] as List)
          : <String>[];
      return MedicationResult(name: names[i], strengths: strengths);
    });
  }

  /// Simple search returning just medication names (no strengths).
  static Future<List<String>> searchMedications(String query,
      {int count = 12}) async {
    final results = await searchMedicationsWithStrengths(query, count: count);
    return results.map((r) => r.name).toList();
  }

  /// Search for ICD-10-CM conditions. Returns code+name pairs.
  static Future<List<IcdCondition>> searchConditions(String query,
      {int count = 12}) async {
    if (query.trim().length < 2) return [];
    final uri = Uri.parse('$_icdBase?sf=code,name&df=code,name'
        '&terms=${Uri.encodeComponent(query)}&count=$count');
    final body = await _fetch(uri);
    if (body == null) return [];
    final data = jsonDecode(body) as List;
    if (data.length >= 4 && data[3] is List) {
      return (data[3] as List).map((item) {
        final arr = item as List;
        return IcdCondition(
          code: arr.isNotEmpty ? arr[0].toString() : '',
          name: arr.length > 1 ? arr[1].toString() : '',
        );
      }).toList();
    }
    return [];
  }
}

class _CacheEntry {
  final String body;
  final DateTime timestamp;
  const _CacheEntry({required this.body, required this.timestamp});
}

class IcdCondition {
  final String code;
  final String name;
  const IcdCondition({required this.code, required this.name});

  @override
  String toString() => '$code: $name';
}

class MedicationResult {
  final String name;
  final List<String> strengths;
  const MedicationResult({required this.name, this.strengths = const []});
}
