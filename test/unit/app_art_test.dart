// Keeps the three definitions of the app's imagery in step:
//   - lib/ui/theme/app_art.dart   (AppArt: what the code shows)
//   - tool/art/art_manifest.json  (what the generator makes)
//   - assets/images/** + pubspec  (what actually ships)
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/theme/app_art.dart';

double _ratio(String aspect) {
  final parts = aspect.split(':').map(double.parse).toList();
  return parts[0] / parts[1];
}

void main() {
  final manifest =
      jsonDecode(File('tool/art/art_manifest.json').readAsStringSync())
          as Map<String, dynamic>;
  final shipped = (manifest['images'] as List)
      .cast<Map<String, dynamic>>()
      .where((i) => i['set'] != 'board')
      .toList();
  final byId = {for (final i in shipped) i['id'] as String: i};
  final pubspec = File('pubspec.yaml').readAsStringSync();

  test('every AppArt has a manifest entry with the same group and aspect', () {
    for (final art in AppArt.values) {
      final entry = byId[art.id];
      expect(entry, isNotNull, reason: '${art.id} missing from the manifest');
      expect(entry!['group'], art.group, reason: '${art.id} group');
      expect(_ratio(entry['aspect'] as String), closeTo(art.aspectRatio, 0.01),
          reason: '${art.id} aspect ratio');
    }
  });

  test('every manifest image is used by AppArt (no orphans)', () {
    final ids = AppArt.values.map((a) => a.id).toSet();
    expect(byId.keys.where((id) => !ids.contains(id)), isEmpty);
  });

  test('every AppArt file exists and its folder is declared in pubspec', () {
    for (final art in AppArt.values) {
      expect(File(art.assetPath).existsSync(), isTrue,
          reason: '${art.assetPath} is missing; run tool/art/generate_art.py');
      expect(pubspec.contains('- assets/images/${art.group}/'), isTrue,
          reason: 'assets/images/${art.group}/ is not declared in pubspec.yaml');
    }
  });

  test('every wizard step has its own photo', () {
    final arts = WizardStep.values.map((s) => s.art).toSet();
    expect(arts.length, WizardStep.values.length);
  });
}
