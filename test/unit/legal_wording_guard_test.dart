import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Legal statements the 2026-11-18 language audit found wrong (checked against
/// the text of 20 Pa.C.S. Chapter 58, the official PA MHAD booklet and forms,
/// and the Mental Health Procedures Act). Each pattern says why. The scan
/// covers everything a user, a printed PDF, or the user's AI can read: Dart
/// code (AI instructions, PDF text), the ARB files, the data files and the
/// hosted privacy page.
const _wrong = <String, String>{
  r"agent['’]s spouse":
      'Nothing bars an agent’s spouse from witnessing (§§ 5822(c), 5832(c)).',
  r'5805\(c\)\(4\)': 'No such paragraph; ECT/research authority is § 5836(c).',
  r'5823\(b\)\(2\)':
      'No such subsection; the dosage rule is in the § 5823 statutory form.',
  r'conscience objection':
      '“Good conscience” is not a separate exception: § 5804(a)(2) has three '
          'grounds (clinical standards, treatment unavailable, provider policy).',
  r'insurance (policy|coverage) precl':
      '§ 5804(a)(2) speaks of the provider’s own policies, not insurance.',
  r'not physically available|physically unavailable':
      '§ 5804(a)(2): the TREATMENT is unavailable, not the provider.',
  r'financial interest in (the|your) estate':
      'No source bars a person with a financial interest from witnessing or '
          'serving as agent.',
  r'physically initial':
      '§ 5836(c) requires specific authorization, not initials; the official '
          'form asks for initials.',
  r'original ink|in ink, in person':
      'Ink is how the app has people sign, not a legal requirement.',
  r'960\.3': 'Wrong citation for the NTI substitution rule.',
  r'nurse practitioner':
      'Incapacity: a psychiatrist plus one of another psychiatrist, '
          'psychologist, family physician, attending physician or MH treatment '
          'professional.',
  r'renewable for additional 90':
      'MHPA § 304 orders are not renewed in 90-day periods (see § 305).',
  r'within 120 hours of the':
      'MHPA § 303: the informal hearing is within 24 hours of the application.',
  r'contemporaneous objection':
      'Superseded state-hospital guidance (now DHS bulletin OMHSAS-25-03).',
  r'automatically revokes any prior':
      '§ 5844: a newer directive prevails only where the two conflict.',
  r'cónyuge de mi agente|iniciales a mano|tinta original|objeción simultánea|interés económico en su patrimonio':
      'Spanish copies of the errors above.',
};

void main() {
  test('no known-wrong legal statement anywhere a user, PDF or AI can read it',
      () {
    final files = <File>[
      ...Directory('lib').listSync(recursive: true).whereType<File>().where(
          (f) =>
              (f.path.endsWith('.dart') &&
                  !f.path.contains('app_localizations')) ||
              f.path.endsWith('.arb')),
      ...Directory('assets/data')
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json')),
      File('web/privacy.html'),
    ];
    final hits = <String>[];
    for (final f in files) {
      final text = f.readAsStringSync();
      for (final e in _wrong.entries) {
        if (RegExp(e.key, caseSensitive: false).hasMatch(text)) {
          hits.add('${f.path}: /${e.key}/ — ${e.value}');
        }
      }
    }
    expect(hits, isEmpty, reason: hits.join('\n'));
  });
}
