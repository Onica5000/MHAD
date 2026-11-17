import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Typography in every string, English and Spanish: … not "...", ’ not a
/// straight apostrophe, “ ” not straight quotes, “in” for inches (the UI fonts have no ″), and no double
/// spaces between words. Machine-read text keeps straight quotes (the JSON
/// fix-it message the AI must echo exactly); two keyboard-shortcut lines keep
/// their deliberate double spacing.
void main() {
  const machineRead = {'aiHandoffFixItMessage'};
  const layoutSpacing = {'aiSetupShortcutWithMac', 'aiSetupShortcutMacOnly'};

  for (final lang in const ['en', 'es']) {
    test('$lang strings use typographic punctuation', () {
      final arb = jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
          as Map<String, dynamic>;
      final bad = <String>[];
      arb.forEach((key, value) {
        if (key.startsWith('@') || value is! String) return;
        if (machineRead.contains(key)) return;
        if (value.contains('...')) bad.add('$key: "..." → …');
        if (value.contains("'")) bad.add("$key: ' → ’ (or “ ” for a quote)");
        if (value.contains('"')) bad.add('$key: " → “ ” (“in” for inches)');
        if (!layoutSpacing.contains(key) &&
            RegExp(r'\S  \S').hasMatch(value)) {
          bad.add('$key: double space');
        }
      });
      expect(bad, isEmpty, reason: bad.join('\n'));
    });
  }
}
