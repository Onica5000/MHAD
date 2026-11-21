import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';

/// Reader-facing text in assets/data/app_data.json comes in English and
/// Spanish ({"en", "es"}): the facts, the referral-partner lines, and an
/// active breach notice. A plain string shows English to Spanish readers.
void main() {
  final json = jsonDecode(File('assets/data/app_data.json').readAsStringSync())
      as Map<String, dynamic>;

  bool bilingual(Object? v) =>
      v is Map &&
      (v['en'] as String? ?? '').trim().isNotEmpty &&
      (v['es'] as String? ?? '').trim().isNotEmpty;

  test('facts are in English and Spanish', () {
    final facts = (json['facts'] as Map).cast<String, dynamic>();
    for (final e in facts.entries) {
      if (e.key.startsWith('_') || e.key == 'autonomy') continue;
      expect(bilingual(e.value), isTrue, reason: 'facts.${e.key}');
    }
  });

  test('referral-partner lines are in English and Spanish', () {
    for (final p in (json['referralPartners'] as List).cast<Map>()) {
      expect(bilingual(p['sub']), isTrue, reason: 'referralPartners ${p['contact']}');
    }
  });

  test('an active breach notice is in English and Spanish', () {
    final n = (json['breachNotice'] as Map).cast<String, dynamic>();
    if ((n['id'] as String? ?? '').trim().isEmpty) return; // none active
    for (final k in const [
      'title', 'whatHappened', 'informationInvolved', 'thirdParties',
      'whatWeAreDoing', 'whatYouCanDo',
    ]) {
      final v = n[k];
      final empty = v is Map
          ? (v['en'] as String? ?? '').trim().isEmpty
          : (v as String? ?? '').trim().isEmpty;
      if (!empty) expect(bilingual(v), isTrue, reason: 'breachNotice.$k');
    }
  });

  test('the app reads the Spanish', () {
    final data = AppData.fromJson(json);
    expect(data.fact('facilitatorCompletionStat', language: 'es'),
        startsWith('Se estima'));
    expect(data.referralPartners.first.sub.forLanguage('es'),
        isNot(data.referralPartners.first.sub.en));
  });
}
