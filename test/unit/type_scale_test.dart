// Type scale (2026-11 redesign, approved Decision 2): small text uses
// 12 / 14 / 16. The old 11/13/15 steps sat 1px apart and read as accidental
// misalignment. This checker keeps them from creeping back into lib/ui.
//
// The PDF renderer (lib/ui/export/pdf/**) is EXCLUDED on purpose: its sizes
// mirror the official printed form, and the PDF output must not change.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('no 11/13/15 font-size literals outside the PDF code', () {
    final offStep = RegExp(r'fontSize:\s*(11|13|15)(\.0)?(?![\d.])');
    final hits = <String>[];
    for (final f in Directory('lib/ui').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final path = f.path.replaceAll(r'\', '/');
      if (path.contains('/export/pdf/')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        if (offStep.hasMatch(lines[i])) hits.add('$path:${i + 1}');
      }
    }
    expect(hits, isEmpty,
        reason: 'Use the 12/14/16 scale (or a textTheme style):\n'
            '${hits.join('\n')}');
  });
}
