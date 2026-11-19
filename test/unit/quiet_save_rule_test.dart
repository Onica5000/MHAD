import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The progress autosave saves the open wizard step quietly when the page is
/// hidden (`WizardStepMixin.saveQuietly`). That only stays quiet if every
/// step's `validateAndSave` shows warnings through `showWarnings(...)` and
/// saves its sub-steps through `saveSubStep(...)` — a direct
/// `formKey.currentState?.validate()` would flash warnings at someone who
/// comes back to the page, and a direct `.validateAndSave()` on a sub-step
/// would drop the quiet flag.
void main() {
  test('wizard steps save quietly when asked to', () {
    final problems = <String>[];
    final files = Directory('lib/ui/wizard/steps')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'));
    for (final f in files) {
      final text = f.readAsStringSync();
      final start = text.indexOf('Future<bool> validateAndSave()');
      if (start < 0) continue;
      final open = text.indexOf('{', start);
      var depth = 0;
      var end = open;
      for (var i = open; i < text.length; i++) {
        if (text[i] == '{') depth++;
        if (text[i] == '}' && --depth == 0) {
          end = i;
          break;
        }
      }
      final body = text.substring(open, end);
      if (RegExp(r'currentState[?!]\.validate\(\)').hasMatch(body)) {
        problems.add('${f.path}: use showWarnings(formKey)');
      }
      if (RegExp(r'\)\.validateAndSave\(\)').hasMatch(body)) {
        problems.add('${f.path}: use saveSubStep(step)');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
