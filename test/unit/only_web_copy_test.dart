import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// There is only the web app (user, 2026-11-23): nothing a person reads may
/// suggest another app or a feature "coming in a later release". The
/// Permissions page had promised camera / contacts / dictation features and
/// mentioned a "native app".
void main() {
  final pattern = RegExp(
      r'later release|future release|coming soon|coming in a|not yet wired|'
      r'native app|phone app|mobile app|app store|google play|desktop app|'
      r'future version|upcoming (version|release|app)',
      caseSensitive: false);

  // Shown only in the native builds (never shipped; `kIsWeb` picks the web
  // text in permissions_overview_screen.dart).
  const nativeOnly = {
    'permissionsOverviewUnlockingEncryptedOnDeviceStorage',
    'permissionsOverviewSnappingAPhotoOfYour',
    'permissionsOverviewNotYetWiredFeatureIn',
    'permissionsOverviewSpeakingLongFormAnswersE',
    'permissionsOverviewPickingAnAgentOrWitness',
  };

  for (final lang in ['en', 'es']) {
    test('$lang: no copy suggests another app or a future release', () {
      final arb = jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
          as Map<String, dynamic>;
      final hits = [
        for (final e in arb.entries)
          if (!e.key.startsWith('@') &&
              e.value is String &&
              !nativeOnly.contains(e.key) &&
              pattern.hasMatch(e.value as String))
            e.key,
      ];
      expect(hits, isEmpty);
    });
  }

  test('nor do the Learn articles or the app data', () {
    for (final f in [
      'assets/data/educational_content.json',
      'assets/data/educational_content_es.json',
      'assets/data/app_data.json',
    ]) {
      final text = File(f).readAsStringSync();
      expect(pattern.allMatches(text).map((m) => m[0]).toList(), isEmpty,
          reason: f);
    }
  });

  test('every native-only exception still exists (no stale allowlist)', () {
    final arb = jsonDecode(File('lib/l10n/app_en.arb').readAsStringSync())
        as Map<String, dynamic>;
    expect(nativeOnly.where((k) => !arb.containsKey(k)), isEmpty);
  });
}
