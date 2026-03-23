import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/educational_content.dart';

void main() {
  group('Educational content', () {
    test('allEducationSections is non-empty', () {
      expect(allEducationSections, isNotEmpty);
    });

    test('all sections have unique IDs', () {
      final ids = allEducationSections.map((s) => s.id).toList();
      final uniqueIds = ids.toSet();
      expect(ids.length, uniqueIds.length,
          reason: 'Duplicate section IDs found');
    });

    test('all sections have non-empty titles', () {
      for (final section in allEducationSections) {
        expect(section.title, isNotEmpty,
            reason: 'Section ${section.id} has empty title');
      }
    });

    test('all sections have non-empty content', () {
      for (final section in allEducationSections) {
        expect(section.content, isNotEmpty,
            reason: 'Section ${section.id} has empty content');
        // Glossary entries may be short; other sections should have more content
        final minLength = section.category == EducationCategory.glossary ? 10 : 50;
        expect(section.content.length, greaterThan(minLength),
            reason: 'Section ${section.id} content is too short');
      }
    });

    test('contains all eight categories', () {
      final categories = allEducationSections.map((s) => s.category).toSet();
      for (final cat in EducationCategory.values) {
        expect(categories, contains(cat),
            reason: 'Category ${cat.name} has no sections');
      }
    });

    test('intro category sections are present', () {
      final introSections = allEducationSections
          .where((s) => s.category == EducationCategory.intro)
          .toList();
      expect(introSections, isNotEmpty);
    });

    test('faq category has at least 10 entries', () {
      final faqSections = allEducationSections
          .where((s) => s.category == EducationCategory.faq)
          .toList();
      expect(faqSections.length, greaterThanOrEqualTo(10));
    });

    test('glossary terms are present', () {
      final glossSections = allEducationSections
          .where((s) => s.category == EducationCategory.glossary)
          .toList();
      expect(glossSections, isNotEmpty);

      // Verify key terms are present
      final titles = glossSections.map((s) => s.title).toList();
      expect(titles, contains('Agent'));
      expect(titles, contains('Declaration'));
      expect(titles, contains('Power of Attorney'));
      expect(titles, contains('Revoke'));
    });

    test('key FAQ questions are present', () {
      final faqTitles = allEducationSections
          .where((s) => s.category == EducationCategory.faq)
          .map((s) => s.title)
          .toList();
      expect(
          faqTitles.any((t) => t.contains('valid')), isTrue,
          reason: 'FAQ should include what makes a directive valid');
      expect(
          faqTitles.any((t) => t.contains('revoke')), isTrue,
          reason: 'FAQ should include revocation question');
    });

    test('all category displayNames are non-empty', () {
      for (final cat in EducationCategory.values) {
        expect(cat.displayName, isNotEmpty);
      }
    });

    test('wizardStepEducationMap references valid section IDs', () {
      final validIds = allEducationSections.map((s) => s.id).toSet();
      for (final entry in wizardStepEducationMap.entries) {
        for (final sectionId in entry.value) {
          expect(validIds, contains(sectionId),
              reason:
                  'wizardStepEducationMap["${entry.key}"] references unknown section ID "$sectionId"');
        }
      }
    });
  });
}
