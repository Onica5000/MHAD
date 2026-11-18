import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/educational_content.dart';

/// The Spanish Learn articles (assets/data/educational_content_es.json) must
/// mirror the English booklet text section for section: same ids, order and
/// categories, the same lists and bold spans, and every number that matters
/// (phones, URLs, citations, codes) carried over unchanged. Shown only once
/// app_data.json learn.spanishArticles is true (after a fluent review).
void main() {
  Map<String, dynamic> sectionsOf(String path) =>
      (jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>)['sections']
          as Map<String, dynamic>;
  final en = sectionsOf('assets/data/educational_content.json');
  final es = sectionsOf('assets/data/educational_content_es.json');

  test('same sections, same order, same categories', () {
    expect(es.keys.toList(), en.keys.toList());
    for (final id in en.keys) {
      expect(es[id]['category'], en[id]['category'], reason: id);
      expect((es[id]['title'] as String).trim(), isNotEmpty, reason: id);
      expect((es[id]['content'] as String).trim(), isNotEmpty, reason: id);
    }
  });

  final listLine = RegExp(r'^\s*(•|-|\d{1,2}[.)])\s+', multiLine: true);
  final protected = <RegExp>[
    RegExp(r'https?://[^\s)\]>]+'), // URLs
    RegExp(r'[\w.+-]+@[\w-]+\.[a-z]{2,}'), // emails
    RegExp(r'\b(?:1-)?(?:\(\d{3}\)\s?|\d{3}[-.])\d{3}[-.]\d{4}\b'), // phones
    RegExp(r'§+\s?\d+[a-z]?(?:\.\d+)?(?:\([a-z0-9]+\))*'), // statute citations
    RegExp(r'\b[A-Z]\d{2}\.\d{1,2}\b'), // ICD-10 codes
  ];
  String trimEnd(String s) => s.replaceAll(RegExp(r'[.,;:]+$'), '');

  test('formatting and protected tokens carried over, section by section', () {
    final problems = <String>[];
    for (final id in en.keys) {
      final e = en[id]['content'] as String;
      final s = es[id]['content'] as String;
      final le = listLine.allMatches(e).length, ls = listLine.allMatches(s).length;
      if (le != ls) problems.add('$id: $le list lines in English, $ls in Spanish');
      final be = '**'.allMatches(e).length, bs = '**'.allMatches(s).length;
      if (be != bs) problems.add('$id: $be bold markers in English, $bs in Spanish');
      for (final p in protected) {
        for (final m in p.allMatches(e)) {
          final token = trimEnd(m[0]!);
          if (!s.contains(token)) problems.add('$id: "$token" missing');
        }
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('Spanish typography and required terms', () {
    final problems = <String>[];
    for (final id in es.keys) {
      final text = '${es[id]['title']}\n${es[id]['content']}';
      if (text.contains('"')) problems.add('$id: straight " quote (use “ ”)');
      if (text.contains('«') || text.contains('»')) {
        problems.add('$id: « » quotes (the app uses “ ”: docs/SPANISH_STYLE.md)');
      }
      if (text.contains('...')) problems.add('$id: "..." (use …)');
      if (RegExp('poder notarial', caseSensitive: false).hasMatch(text)) {
        problems.add('$id: "poder notarial" (no notary; use Poder de Salud Mental)');
      }
    }
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('no stale section: each translation matches the English it came from',
      () {
    final stale = <String>[];
    for (final id in en.keys) {
      final source = '${en[id]['title']}\n${en[id]['content']}';
      final hash = sha256.convert(utf8.encode(source)).toString().substring(0, 12);
      if (es[id]['sourceHash'] != hash) stale.add(id);
    }
    expect(stale, isEmpty,
        reason: 'The English changed since these were translated; update the '
            'Spanish, then set sourceHash (see _meta.note): ${stale.join(', ')}');
  });

  test('loader: Spanish when loaded, English otherwise', () async {
    expect(EducationalContent.sectionsFor('es'), same(EducationalContent.sections));
    await EducationalContent.loadLanguage('es');
    final spanish = EducationalContent.sectionsFor('es');
    expect(spanish.map((s) => s.id), EducationalContent.sections.map((s) => s.id));
    expect(spanish.first.title, es.values.first['title']);
    expect(EducationalContent.sectionsFor('en'), same(EducationalContent.sections));
    EducationalContent.debugClearTranslations();
    expect(EducationalContent.sectionsFor('es'), same(EducationalContent.sections));
  });
}
