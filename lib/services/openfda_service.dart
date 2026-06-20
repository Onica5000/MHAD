import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/services/certificate_pinning_service.dart';

/// FDA drug-labeling lookups via **openFDA** (`api.fda.gov`). Free, no key for
/// low volume. Used to GROUND the AI side-effects list in the official FDA
/// label's "Adverse Reactions" text instead of relying on the model's own
/// knowledge — turning an AI guess into an AI paraphrase of a real source.
///
/// Returns null on any failure so the caller falls back to the previous
/// (ungrounded) behavior — it never blocks the feature.
class OpenFdaService {
  static const _labelBase = 'https://api.fda.gov/drug/label.json';

  static final _client = CertificatePinningService.createPinnedClient();
  static final _cache = <String, String?>{};

  /// The FDA label's adverse-reactions text for [medName] (brand or generic),
  /// capped to a prompt-friendly length. Falls back to the label "warnings"
  /// section when adverse_reactions is absent. Returns null if nothing matches.
  static Future<String?> adverseReactions(String medName) async {
    final base = _baseName(medName);
    if (base.length < 2) return null;
    if (_cache.containsKey(base)) return _cache[base];

    // Match either the generic or brand name exactly (quoted phrase).
    final search =
        'openfda.generic_name:"$base"+OR+openfda.brand_name:"$base"';
    final uri = Uri.parse('$_labelBase?search=$search&limit=1');
    try {
      final resp =
          await _client.get(uri).timeout(appData.config.clinicalApiTimeout);
      if (resp.statusCode != 200) {
        // 404 = no match for this drug; cache the miss.
        _cache[base] = null;
        return null;
      }
      final json = jsonDecode(resp.body);
      if (json is! Map) {
        _cache[base] = null;
        return null;
      }
      final results = json['results'];
      if (results is! List || results.isEmpty || results.first is! Map) {
        _cache[base] = null;
        return null;
      }
      final r0 = results.first as Map;
      var text = _section(r0['adverse_reactions']);
      if (text.isEmpty) text = _section(r0['warnings']);
      text = text.trim();
      if (text.length > 4000) text = '${text.substring(0, 4000)}…';
      _cache[base] = text.isEmpty ? null : text;
      return _cache[base];
    } catch (e) {
      debugPrint('OpenFdaService: $e');
      _cache[base] = null;
      return null;
    }
  }

  static String _section(dynamic v) {
    if (v is List) return v.join('\n');
    if (v == null) return '';
    return v.toString();
  }

  /// Strip a strength/form suffix so "Sertraline 50 MG Tab" → "sertraline".
  /// openFDA matches on the drug name, not the full strength string.
  static String _baseName(String medName) {
    var s = medName.trim().toLowerCase();
    // Cut at the first digit (start of a strength like "50 mg").
    final firstDigit = s.indexOf(RegExp(r'\d'));
    if (firstDigit > 0) s = s.substring(0, firstDigit);
    // Drop trailing dosage-form words.
    s = s.replaceAll(
        RegExp(
            r'\b(tab|tablet|tablets|cap|capsule|capsules|oral|solution|'
            r'suspension|injection|er|xr|sr|hcl|hydrochloride)\b'),
        ' ');
    return s.replaceAll(RegExp(r'\s+'), ' ').trim();
  }
}
