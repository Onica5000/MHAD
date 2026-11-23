import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/document_extraction_result.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';

/// Audit O7: the same medication with a different dose — from another file
/// in one upload, or already on the person's list — was silently dropped.
/// It is now kept and offered as a choice in the review.
void main() {
  DocumentExtractionResult current(String dose) =>
      DocumentExtractionResult.fromJson({
        'document_relevant': true,
        'medications_current': [
          {'name': 'lithium', 'dosage': dose},
        ],
      });

  group('merging uploads', () {
    test('a different dose from another file is kept as a choice', () {
      final m = current('300 mg twice daily')
          .merge(current('300 mg daily'))
          .medicationsCurrent
          .single;
      expect(m.dosage, '300 mg twice daily');
      expect(m.otherDosages, ['300 mg daily']);
    });

    test('the same dose written differently is not a second choice', () {
      final m = current('300 mg twice daily')
          .merge(current(' 300 MG  twice  daily'))
          .medicationsCurrent
          .single;
      expect(m.otherDosages, isEmpty);
    });

    test('a dose the first file lacked is taken, not offered', () {
      final m = current('').merge(current('300 mg daily')).medicationsCurrent.single;
      expect(m.dosage, '300 mg daily');
      expect(m.otherDosages, isEmpty);
    });

    test('three files, two other doses, no repeats', () {
      final m = current('300 mg twice daily')
          .merge(current('300 mg daily'))
          .merge(current('600 mg daily'))
          .merge(current('300 mg Daily'))
          .medicationsCurrent
          .single;
      expect(m.otherDosages, ['300 mg daily', '600 mg daily']);
    });
  });

  test('sameMedicationDose ignores case and spacing only', () {
    expect(sameMedicationDose('20 mg  at night', '20 MG at night'), isTrue);
    expect(sameMedicationDose('20 mg at night', '40 mg at night'), isFalse);
  });

  test('a dose on the list can be replaced in place', () async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DirectiveRepository(db);
    final id = await repo.createDirective(FormType.combined);
    final medId = await repo.insertMedication(MedicationEntriesCompanion.insert(
      directiveId: id,
      entryType: MedicationEntryType.current.name,
      medicationName: const Value('Lithium carbonate'),
      dosage: const Value('300 mg twice daily'),
    ));
    await repo.updateMedicationDosage(medId, '300 mg daily');
    final meds = await repo.getMedications(id);
    expect(meds.single.dosage, '300 mg daily');
    expect(meds.single.medicationName, 'Lithium carbonate');
  });
}
