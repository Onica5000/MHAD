// Keeps the three definitions of the app's imagery in step:
//   - lib/ui/theme/app_art.dart   (AppArt: what the code shows)
//   - tool/art/art_manifest.json  (what the generator makes)
//   - assets/images/** + pubspec  (what actually ships)
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/theme/app_art.dart';

/// Width × height from a WebP header (lossy VP8, lossless VP8L or VP8X).
(int, int)? _webpSize(List<int> b) {
  final chunk = String.fromCharCodes(b.sublist(12, 16));
  switch (chunk) {
    case 'VP8 ':
      return ((b[26] | (b[27] << 8)) & 0x3fff, (b[28] | (b[29] << 8)) & 0x3fff);
    case 'VP8X':
      return (
        1 + (b[24] | (b[25] << 8) | (b[26] << 16)),
        1 + (b[27] | (b[28] << 8) | (b[29] << 16)),
      );
    case 'VP8L':
      final bits = b[21] | (b[22] << 8) | (b[23] << 16) | (b[24] << 24);
      return ((bits & 0x3fff) + 1, ((bits >> 14) & 0x3fff) + 1);
  }
  return null;
}

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

  test('every file is real WebP at its registered width and within budget',
      () {
    final budgets = (manifest['max_kb'] as Map).cast<String, num>();
    for (final art in AppArt.values) {
      final bytes = File(art.assetPath).readAsBytesSync();
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF',
          reason: '${art.id} is not a RIFF/WebP file');
      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WEBP',
          reason: '${art.id} is not WebP');
      final size = _webpSize(bytes);
      expect(size, isNotNull, reason: '${art.id}: unreadable WebP header');
      expect(size!.$1, art.maxPixelWidth,
          reason: '${art.id} is ${size.$1}px wide; AppArt expects '
              '${art.maxPixelWidth}');
      expect(size.$1 / size.$2, closeTo(art.aspectRatio, 0.02),
          reason: '${art.id} aspect');
      final aspect = byId[art.id]!['aspect'] as String;
      expect(bytes.length, lessThanOrEqualTo(budgets[aspect]! * 1024),
          reason: '${art.id} is ${bytes.length ~/ 1024} KB; budget '
              '${budgets[aspect]} KB');
    }
  });

  test('decode widths snap to buckets and never exceed the file', () {
    expect(AppArt.homeHero.decodeWidthFor(500), 640);
    expect(AppArt.homeHero.decodeWidthFor(5000), AppArt.homeHero.maxPixelWidth);
    expect(AppArt.stepReview.decodeWidthFor(1000), 800); // 1:1 file is 800 wide
    expect(AppArt.stepReview.decodeWidthFor(100), 320);
  });

  test('every wizard step has its own photo', () {
    final arts = WizardStep.values.map((s) => s.art).toSet();
    expect(arts.length, WizardStep.values.length);
  });
}
