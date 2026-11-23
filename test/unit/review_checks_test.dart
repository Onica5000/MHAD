import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extraction_result.dart';
import 'package:mhad/ai/document_extractor.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/services/clinical_data_validator.dart';
import 'package:mhad/ui/wizard/widgets/document_pipeline_flow.dart';
import 'package:mhad/utils/input_formatters.dart';

/// Field audit O2 + O3: the autofill review flags a bad date of birth / ZIP /
/// phone with the SAME checks the wizard runs, and shows the AI's own
/// "please check" notes — filtered, because the AI read an untrusted document.
void main() {
  final l = lookupAppLocalizations(const Locale('en'));
  final asOf = DateTime(2026, 11, 22);

  group('dateOfBirthValidator (one definition: About you + the review)', () {
    test('a real adult date passes', () {
      expect(dateOfBirthValidator('07/22/1985', l, asOf), isNull);
    });
    test('impossible dates fail', () {
      expect(dateOfBirthValidator('02/30/1985', l, asOf), l.personalInfoStepInvalidDate);
      expect(dateOfBirthValidator('04/31/1966', l, asOf), l.personalInfoStepInvalidDate);
      expect(dateOfBirthValidator('13/15/1966', l, asOf), l.personalInfoStepInvalidDate);
    });
    test('a 2-digit year is a format problem, not a 1st-century birth', () {
      expect(dateOfBirthValidator('07/22/85', l, asOf), l.personalInfoStepDateFormat);
    });
    test('future and under-18 fail', () {
      expect(dateOfBirthValidator('01/01/2027', l, asOf), l.personalInfoStepDobFuture);
      expect(dateOfBirthValidator('01/01/2015', l, asOf), l.personalInfoStepMustBeAdult);
    });
    test('empty is required', () {
      expect(dateOfBirthValidator('', l, asOf), l.required);
    });
  });

  group('reviewFormatProblem', () {
    test('flags the wizard-rejected values by key', () {
      expect(reviewFormatProblem('person_dob', '02/30/1985', l), isNotNull);
      expect(reviewFormatProblem('person_zip', '1810', l), l.inputZipInvalid);
      expect(reviewFormatProblem('agent_phone', '(484) 555-012', l),
          l.personalInfoStepPhoneInvalid);
      expect(reviewFormatProblem('person_doctor_phone', '(610) 555-0170', l), isNull);
      expect(reviewFormatProblem('guardian_zip', '18015', l), isNull);
    });
    test('other keys are never format-checked', () {
      expect(reviewFormatProblem('person_name', '02/30/1985', l), isNull);
      expect(reviewFormatProblem('other', '1810', l), isNull);
    });
  });

  group('parseCheckNotes', () {
    test('keeps plain notes, trims, dedupes, caps at 8', () {
      final notes = parseCheckNotes([
        '  Date of birth   02/30/1985 is not a real date.  ',
        'Date of birth 02/30/1985 is not a real date.',
        for (var i = 0; i < 12; i++) 'Note $i',
      ]);
      expect(notes.first, 'Date of birth 02/30/1985 is not a real date.');
      expect(notes, hasLength(kMaxCheckNotes));
    });
    test('masks phone and ID numbers, keeps dates', () {
      final notes = parseCheckNotes([
        'Your agent’s phone (484) 555-012 is missing a digit.',
        'Left out a Social Security number 123-45-6789.',
      ]);
      expect(notes[0], isNot(contains('555')));
      expect(notes[1], isNot(contains('6789')));
      expect(notes[1], contains('…'));
    });
    test('drops notes with links or email addresses', () {
      expect(
          parseCheckNotes([
            'Verify your identity at https://example.test',
            'Email records@example.org to confirm.',
            'Medication “Zentravex” could not be matched.',
          ]),
          ['Medication “Zentravex” could not be matched.']);
    });
    test('one note sent as a plain string counts; other types are ignored', () {
      expect(parseCheckNotes('just a string'), ['just a string']);
      expect(parseCheckNotes([1, null, true]), isEmpty);
    });
    test('notes come through the reply and merge across documents', () {
      final a = DocumentExtractionResult.fromJson({
        'document_relevant': true,
        'check_notes': ['A'],
      });
      final b = DocumentExtractionResult.fromJson({
        'document_relevant': true,
        'check_notes': ['A', 'B'],
      });
      expect(a.merge(b).checkNotes, ['A', 'B']);
    });
  });

  test('the autofill prompt asks for check notes and forbids echoing numbers', () {
    final p = DocumentExtractor.promptFor('combined');
    expect(p, contains('check_notes is a list of short notes'));
    expect(p, contains('never repeat a date of birth, an ID or phone number, or an address'));
  });

  // From the mock simulation (2026-11-22): review edits to diagnoses and
  // allergies were silently dropped, and a made-up ICD code went unflagged.
  group('review rows read back (edits are kept)', () {
    const d = ExtractedDiagnosis(name: 'nerve attacks', icdCode: 'F45.99');
    test('an unchanged diagnosis keeps the AI values, badge ignored', () {
      final shown = '${d.display} [${l.reviewBadgeNoIcdMatch}]';
      expect(diagnosisFromReview(shown, d), (name: 'nerve attacks', code: 'F45.99'));
    });
    test('an edited code is saved', () {
      expect(diagnosisFromReview('panic attacks [f41.0] [${l.reviewBadgeNoIcdMatch}]', d),
          (name: 'panic attacks', code: 'F41.0'));
    });
    test('a deleted code is honored', () {
      expect(diagnosisFromReview('nerve attacks', d), (name: 'nerve attacks', code: ''));
    });

    const a = ExtractedAllergy(
        substance: 'penicillin', kind: 'drug', severity: 'moderate', reactions: 'hives');
    test("allergy rows speak the reader's language", () {
      final es = lookupAppLocalizations(const Locale('es'));
      expect(allergyReviewText(a, l), 'penicillin (Moderate) — hives');
      expect(allergyReviewText(a, es), 'penicillin (Moderada) — hives');
    });
    test('an unchanged allergy keeps the AI values', () {
      expect(allergyFromReview('${allergyReviewText(a, l)} [${l.reviewBadgeRxNormVerified}]', a, l),
          (substance: 'penicillin', severity: 'moderate', reactions: 'hives'));
    });
    test('edited severity (any language), substance and reaction are saved', () {
      expect(allergyFromReview('amoxicillin (Severe) — swelling', a, l),
          (substance: 'amoxicillin', severity: 'severe', reactions: 'swelling'));
      expect(allergyFromReview('penicilina (Grave) — urticaria', a, l),
          (substance: 'penicilina', severity: 'severe', reactions: 'urticaria'));
    });
    test('a removed reaction is honored; an unknown word stays in the name', () {
      expect(allergyFromReview('penicillin (Moderate)', a, l),
          (substance: 'penicillin', severity: 'moderate', reactions: ''));
      expect(allergyFromReview('sulfa (sulfonamide) — rash', a, l),
          (substance: 'sulfa (sulfonamide)', severity: 'moderate', reactions: 'rash'));
    });
    test('every badge, in every language, is stripped before saving', () {
      final es = lookupAppLocalizations(const Locale('es'));
      expect(stripReviewBadge('F45.99 thing [${es.reviewBadgeNoIcdMatch}]'), 'F45.99 thing');
      expect(stripReviewBadge('x [${l.reviewBadgeUnverified}] '), 'x');
    });
  });

  group('ICD code check (exact match only)', () {
    const m = [IcdCondition(code: 'F31.81', name: 'Bipolar II disorder')];
    test('an exact code is found; case and dot ignored', () {
      expect(ClinicalDataValidator.icdCodeFound('F31.81', m), isTrue);
      expect(ClinicalDataValidator.icdCodeFound('f3181', m), isTrue);
    });
    test('a prefix or a made-up code is not', () {
      expect(ClinicalDataValidator.icdCodeFound('F31.8', m), isFalse);
      expect(ClinicalDataValidator.icdCodeFound('F45.99', const []), isFalse);
      expect(ClinicalDataValidator.icdCodeFound('', m), isFalse);
    });
  });
}
