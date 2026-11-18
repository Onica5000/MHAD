import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/ui/education/learn_links.dart';

/// Learn's cross-links: which glossary words an article uses, and which
/// articles sit nearest it.
void main() {
  EducationSection s(String id, EducationCategory c, String title,
          [String content = '']) =>
      EducationSection(id: id, category: c, title: title, content: content);

  group('glossaryMatchTerms', () {
    test('drops a parenthetical note and quotes; splits at an em dash', () {
      expect(glossaryMatchTerms('Competence (vs. capacity)'), ['Competence']);
      expect(glossaryMatchTerms('"Shall comply" (statutory language)'),
          ['Shall comply']);
      expect(
          glossaryMatchTerms("PMHCA — PA Mental Health Consumers' Association"),
          ['PMHCA', "PA Mental Health Consumers' Association"]);
      expect(glossaryMatchTerms('Agent'), ['Agent']);
    });
  });

  group('glossaryTermsIn', () {
    final agent = s('g_agent', EducationCategory.glossary, 'Agent');
    final revoke = s('g_revoke', EducationCategory.glossary, 'Revoke');
    final amend = s('g_amend', EducationCategory.glossary, 'Amend');
    final all = [agent, revoke, amend];

    test('in order of first use, plurals and past forms count', () {
      final article = s('a', EducationCategory.faq, 'A',
          'You **revoked** it? Your agents can still act.');
      expect(glossaryTermsIn(article, all: all), [revoke, agent]);
    });

    test('whole words only, and never the entry itself', () {
      final article = s('b', EducationCategory.faq, 'B', 'Agency amendments.');
      expect(glossaryTermsIn(article, all: all), isEmpty);
      final entry = s('g_agent', EducationCategory.glossary, 'Agent',
          'An agent may revoke.');
      expect(glossaryTermsIn(entry, all: all), [revoke]);
    });
  });

  group('relatedSections', () {
    final list = [
      for (var i = 0; i < 6; i++) s('c$i', EducationCategory.combined, 'C$i'),
      s('d0', EducationCategory.declaration, 'D0'),
    ];

    test('the nearest in the same category — next first, then previous', () {
      expect(relatedSections(list[2], all: list).map((e) => e.id),
          ['c3', 'c1', 'c4']);
      expect(relatedSections(list[5], all: list).map((e) => e.id),
          ['c4', 'c3', 'c2']);
    });

    test('never itself; nothing when alone in its category', () {
      expect(relatedSections(list[6], all: list), isEmpty);
    });
  });

  test('the real corpus: every glossary title has a match term, and every '
      'article finds a few terms but never itself', () {
    final sections = EducationalContent.sections;
    expect(sections, isNotEmpty);
    for (final g in sections
        .where((e) => e.category == EducationCategory.glossary)) {
      expect(glossaryMatchTerms(g.title), isNotEmpty, reason: g.title);
    }
    var withTerms = 0;
    for (final a in sections) {
      final terms = glossaryTermsIn(a);
      expect(terms.any((t) => t.id == a.id), isFalse, reason: a.id);
      expect(terms.length, lessThanOrEqualTo(8));
      if (terms.isNotEmpty) withTerms++;
      expect(relatedSections(a).any((r) => r.id == a.id), isFalse);
    }
    expect(withTerms, greaterThan(sections.length ~/ 2),
        reason: 'most articles use at least one glossary word');
  });
}
