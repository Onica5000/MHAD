import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every wizard step's own list uses ONE page padding, so the form's left
/// edge lines up with the step header (20px) on every step (visual review
/// 2026-11-22: steps mixed 16 and 20). A step's stand-alone padding is the
/// branch after `widget.embedded ? const EdgeInsets.symmetric(horizontal: 4)`.
void main() {
  test('wizard steps pad their list with DesignTokens.pagePadding', () {
    final branch = RegExp(
        r'\? const EdgeInsets\.symmetric\(horizontal: 4\)\s*:\s*([^,]+),');
    // Sign: its side margin is computed to cap the reading width.
    const exempt = {'execution_step.dart'};
    final offenders = <String>[];
    var seen = 0;
    for (final f in Directory('lib/ui/wizard/steps').listSync().whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      for (final m in branch.allMatches(f.readAsStringSync())) {
        seen++;
        if (m.group(1)!.trim() != 'DesignTokens.pagePadding' &&
            !exempt.contains(f.uri.pathSegments.last)) {
          offenders.add('${f.uri.pathSegments.last}: ${m.group(1)!.trim()}');
        }
      }
    }
    expect(seen, greaterThan(5), reason: 'the pattern should still find the steps');
    expect(offenders, isEmpty);
  });
}
