// Spacing scale (2026-11 overhaul): every inset and gap in lib/ui sits on the
// DesignTokens scale. The audit found 28 distinct inset values, 18 vertical
// gap sizes and 25 different page paddings; the sweep moved 442 values onto
// the scale and gave page scroll views DesignTokens.pagePadding.
//
// The allowed set is read from DesignTokens itself, so the scale has ONE
// definition. The PDF renderer (lib/ui/export/pdf/**) is excluded: it mirrors
// the official printed form. The theme defines the tokens and is excluded.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ui/theme/app_theme.dart';

void main() {
  final scale = <double>{
    0,
    1, // hairline separators
    DesignTokens.space2,
    DesignTokens.space4,
    DesignTokens.space6,
    DesignTokens.space8,
    DesignTokens.space12,
    DesignTokens.space16,
    DesignTokens.space20,
    DesignTokens.space24,
    DesignTokens.space32,
    DesignTokens.space40,
    DesignTokens.space48,
    DesignTokens.space64,
  };

  test('EdgeInsets and SizedBox gaps use the spacing scale', () {
    final insets = RegExp(
        r'EdgeInsets(?:Directional)?\.(?:all|symmetric|only|fromLTRB|fromSTEB)\(([^()]*)\)');
    final gap = RegExp(r'SizedBox\(\s*(?:height|width):\s*(\d+(?:\.\d+)?)\s*\)');
    final number = RegExp(r'(?<![\w.$])(\d+(?:\.\d+)?)(?![\w.])');
    final hits = <String>[];
    for (final f in Directory('lib/ui').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final path = f.path.replaceAll(r'\', '/');
      if (path.contains('/export/pdf/') || path.contains('/ui/theme/')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final code = lines[i].split('//').first;
        for (final m in insets.allMatches(code)) {
          for (final n in number.allMatches(m.group(1)!)) {
            final v = double.parse(n.group(1)!);
            if (!scale.contains(v) && v <= 200) {
              hits.add('$path:${i + 1}  $v');
            }
          }
        }
        for (final m in gap.allMatches(code)) {
          final v = double.parse(m.group(1)!);
          if (!scale.contains(v) && v <= 200) hits.add('$path:${i + 1}  $v');
        }
      }
    }
    expect(hits, isEmpty,
        reason: 'Use the DesignTokens spacing scale '
            '(0 1 2 4 6 8 12 16 20 24 32 40 48 64):\n${hits.join('\n')}');
  });
}
