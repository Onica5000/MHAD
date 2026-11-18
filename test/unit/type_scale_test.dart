// Typography rules for lib/ui. The ramp lives in ONE place — MhadType in
// lib/ui/theme/app_theme.dart, which builds the theme's TextTheme — and these
// checkers keep hand-typed values from creeping back.
//
// - 2026-11 refresh (approved Decision 2): small text uses 12 / 14 / 16; the
//   old 11/13/15 steps sat 1px apart and read as accidental misalignment.
// - 2026-11 overhaul: no hard-coded sans family (it silently overrode the
//   dyslexia-friendly font setting in ~300 places), and letter-spacing / line
//   height use the MhadType tokens (the audit found 23 and 14 distinct values).
//
// The PDF renderer (lib/ui/export/pdf/**) is EXCLUDED on purpose: its styles
// mirror the official printed form, and the PDF output must not change. The
// theme folder defines the tokens, so it is excluded too.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// (path, 1-based line, text) for every .dart line in lib/ui outside the PDF
/// renderer and the theme.
Iterable<(String, int, String)> _uiLines() sync* {
  for (final f in Directory('lib/ui').listSync(recursive: true)) {
    if (f is! File || !f.path.endsWith('.dart')) continue;
    final path = f.path.replaceAll(r'\', '/');
    if (path.contains('/export/pdf/') || path.contains('/ui/theme/')) continue;
    final lines = f.readAsLinesSync();
    for (var i = 0; i < lines.length; i++) {
      // Ignore comments: the rule is about code.
      final code = lines[i].split('//').first;
      yield (path, i + 1, code);
    }
  }
}

void main() {
  test('no 11/13/15 font-size literals outside the PDF code', () {
    final offStep = RegExp(r'fontSize:\s*(11|13|15)(\.0)?(?![\d.])');
    final hits = [
      for (final (p, n, code) in _uiLines())
        if (offStep.hasMatch(code)) '$p:$n',
    ];
    expect(hits, isEmpty,
        reason: 'Use the 12/14/16 scale (or a textTheme style):\n'
            '${hits.join('\n')}');
  });

  test('no hard-coded sans family (keeps the dyslexia-friendly font working)',
      () {
    final sans = RegExp(r"kSansFamily|'DM Sans'");
    final hits = [
      for (final (p, n, code) in _uiLines())
        if (sans.hasMatch(code)) '$p:$n',
    ];
    expect(hits, isEmpty,
        reason: 'Text inherits the theme family; setting DM Sans by hand '
            'overrides the dyslexia-friendly font:\n${hits.join('\n')}');
  });

  test('letter-spacing and line height use the MhadType tokens', () {
    // A numeric literal after letterSpacing:, or a decimal line height
    // (`height: 1.45`) — box heights are whole numbers and not matched.
    // Spacing of 3 or more is a deliberate effect (spaced PIN digits) and
    // is allowed.
    final tracking = RegExp(r'letterSpacing:\s*(-?\d*\.?\d+)');
    final leading = RegExp(r'\bheight:\s*(\d\.\d+)\b');
    final hits = <String>[];
    for (final (p, n, code) in _uiLines()) {
      final t = tracking.firstMatch(code);
      if (t != null && double.parse(t.group(1)!).abs() < 3) hits.add('$p:$n');
      if (leading.hasMatch(code)) hits.add('$p:$n');
    }
    expect(hits, isEmpty,
        reason: 'Use MhadType.tracking* / MhadType.leading*:\n'
            '${hits.join('\n')}');
  });
}
