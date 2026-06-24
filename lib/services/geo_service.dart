import 'dart:convert';

import 'package:http/http.dart' as http;

/// Result of a ZIP-code lookup.
class ZipLookup {
  final String city;
  final String stateAbbr;
  final String stateName;
  final double? lat;
  final double? lng;
  const ZipLookup({
    required this.city,
    required this.stateAbbr,
    required this.stateName,
    this.lat,
    this.lng,
  });
}

/// Address-completion helpers backed by FREE, KEYLESS, CORS-enabled public
/// APIs (verified browser-callable — the app ships as a static web app):
///   • Zippopotam  — ZIP → city / state (+ lat/lng).   `api.zippopotam.us`
///   • FCC Census  — lat/lng → county (FIPS).           `geo.fcc.gov`
///
/// Only the ZIP code (and the lat/lng derived from it) ever leaves the browser
/// — never the user's street address — so this stays within the app's PII
/// posture. Every call is fail-safe: any error/timeout returns null and the
/// user just keeps typing.
class GeoService {
  final http.Client _client;
  GeoService({http.Client? client}) : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 8);
  static final RegExp _zip5 = RegExp(r'^\d{5}$');

  /// ZIP → city / state (+ lat/lng). Null on bad input or any failure.
  Future<ZipLookup?> lookupZip(String zip) async {
    final z = zip.trim();
    if (!_zip5.hasMatch(z)) return null;
    try {
      final r = await _client
          .get(Uri.parse('https://api.zippopotam.us/us/$z'))
          .timeout(_timeout);
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final places = (j['places'] as List?) ?? const [];
      if (places.isEmpty) return null;
      final p = places.first as Map<String, dynamic>;
      final city = (p['place name'] ?? '').toString();
      if (city.isEmpty) return null;
      return ZipLookup(
        city: city,
        stateAbbr: (p['state abbreviation'] ?? '').toString(),
        stateName: (p['state'] ?? '').toString(),
        lat: double.tryParse((p['latitude'] ?? '').toString()),
        lng: double.tryParse((p['longitude'] ?? '').toString()),
      );
    } catch (_) {
      return null;
    }
  }

  /// lat/lng → county name (e.g. "Philadelphia"). Null on any failure.
  Future<String?> countyForLatLng(double lat, double lng) async {
    try {
      final r = await _client
          .get(Uri.parse(
              'https://geo.fcc.gov/api/census/block/find?latitude=$lat&longitude=$lng&format=json&showall=false'))
          .timeout(_timeout);
      if (r.statusCode != 200) return null;
      final j = jsonDecode(r.body) as Map<String, dynamic>;
      final county = j['County'] as Map<String, dynamic>?;
      final name = county?['name']?.toString() ?? '';
      return name.isEmpty ? null : name;
    } catch (_) {
      return null;
    }
  }

  /// Convenience: ZIP → county, chaining [lookupZip] + [countyForLatLng].
  Future<String?> countyForZip(String zip) async {
    final z = await lookupZip(zip);
    final lat = z?.lat, lng = z?.lng;
    if (lat == null || lng == null) return null;
    return countyForLatLng(lat, lng);
  }

  void dispose() => _client.close();
}
