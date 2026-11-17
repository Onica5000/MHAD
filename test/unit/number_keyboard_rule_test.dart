// Standing rule (2026-11-16): any field that takes only a number opens the
// number/phone pad, not the letter keyboard. This test scans lib/ for
// TextField/TextFormField constructors whose label or hint names a
// number-only value (ZIP, phone, date of birth) and fails if the constructor
// sets no keyboardType. Mixed free-text fields are allow-listed below.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ui/wizard/widgets/document_pipeline_flow.dart';

/// Label/hint identifiers that name a number-only value.
final _numericLabel =
    RegExp(r'(zip|phone|dob|dateofbirth|birthdate)', caseSensitive: false);

/// Fields whose label mentions a phone but that accept free text on purpose
/// (e.g. "Address / Phone Number" for a doctor's contact line).
const _freeTextAllowList = <String>{
  'effectiveConditionAddressPhone',
  'whenItKicksInAddressPhone',
};

/// Returns the text between the '(' at [open] and its matching ')'.
String _argBlock(String src, int open) {
  var depth = 0;
  for (var i = open; i < src.length; i++) {
    final c = src[i];
    if (c == '(') depth++;
    if (c == ')') {
      depth--;
      if (depth == 0) return src.substring(open + 1, i);
    }
  }
  return src.substring(open + 1);
}

void main() {
  test('number-only fields set a keyboardType (number-pad rule)', () {
    final violations = <String>[];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))
        .where((f) => !f.path.contains('l10n${Platform.pathSeparator}app_localizations'));
    final ctor = RegExp(r'\b(TextFormField|TextField)\(');
    final labelRef =
        RegExp(r'(labelText|hintText)\s*:\s*([^,\n]+)', caseSensitive: false);
    for (final f in files) {
      final src = f.readAsStringSync();
      for (final m in ctor.allMatches(src)) {
        final block = _argBlock(src, m.end - 1);
        final labels = labelRef.allMatches(block).map((l) => l.group(2)!);
        final numeric = labels.where((l) =>
            _numericLabel.hasMatch(l) &&
            !_freeTextAllowList.any((a) => l.contains(a)));
        if (numeric.isEmpty) continue;
        if (!block.contains('keyboardType:')) {
          final line = src.substring(0, m.start).split('\n').length;
          violations.add('${f.path}:$line  ${numeric.first.trim()}');
        }
      }
    }
    expect(violations, isEmpty,
        reason: 'These number-only fields open the letter keyboard; add '
            'keyboardType (number / phone / datetime):\n${violations.join('\n')}');
  });

  test('Autofill review keys map to the right keyboard', () {
    expect(reviewFieldKeyboard('person_zip'), TextInputType.number);
    expect(reviewFieldKeyboard('guardian_zip'), TextInputType.number);
    expect(reviewFieldKeyboard('person_phone'), TextInputType.phone);
    expect(reviewFieldKeyboard('person_doctor_phone'), TextInputType.phone);
    expect(reviewFieldKeyboard('person_dob'), TextInputType.datetime);
    expect(reviewFieldKeyboard('effective_condition'), isNull);
    expect(reviewFieldKeyboard('med_prefer_0'), isNull);
  });
}
