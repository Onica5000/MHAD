import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Standing rule (2026-11-17): widget tests size the VIEW —
/// `tester.view.physicalSize` + `tester.view.devicePixelRatio = 1.0` — never
/// `tester.binding.setSurfaceSize`. setSurfaceSize resizes only the render
/// surface; MediaQuery keeps the 800x600 test default, so every layout that
/// switches on the window width (the 1000px desktop shell, Learn's AI panel,
/// the wizard's rails) silently renders the PHONE layout. That hid the
/// desktop cases of layout_matrix_test and spanish_smoke_test.
void main() {
  test('no test uses binding.setSurfaceSize', () {
    final offenders = <String>[];
    for (final f in Directory('test').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      if (f.path.endsWith('test_view_size_rule_test.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final code = lines[i].split('//').first;
        if (code.contains('setSurfaceSize(')) {
          offenders.add('${f.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'use tester.view.physicalSize + devicePixelRatio instead');
  });
}
