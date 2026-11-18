import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Flutter web announces EVERY chip as a checkbox: chip.dart sets
/// `checked: kIsWeb ? selected : null`. Right for FilterChip / ChoiceChip
/// (they are selectable), wrong for a chip that only runs an action or shows
/// an item: screen readers said "What 'Agent' means, checkbox, not checked"
/// (found 2026-11-18 in the web build). Use ActionPill / RemovablePill
/// (lib/ui/widgets/design/pills.dart), which are real buttons.
void main() {
  test('no ActionChip / InputChip / RawChip in lib (the web reads them as '
      'checkboxes)', () {
    final pattern = RegExp(r'\b(ActionChip|InputChip|RawChip)\s*[.(]');
    final offenders = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      if (!f.path.endsWith('.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (line.trimLeft().startsWith('//')) continue;
        if (pattern.hasMatch(line)) {
          offenders.add('${f.path}:${i + 1}: ${line.trim()}');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'Use ActionPill / RemovablePill (widgets/design/pills.dart).');
  });
}
