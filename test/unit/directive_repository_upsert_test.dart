import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';

/// Regression coverage for the per-directive "child" upserts that key on the
/// table's UNIQUE `directiveId` (not its autoincrement `id` primary key):
/// additional instructions, guardian nomination, and preferences.
///
/// These are saved by the wizard's `validateAndSave` every time the step is
/// passed through. The bug: `insertOnConflictUpdate` targets the *primary key*,
/// so a second save for the same directive inserted a fresh row and tripped the
/// `UNIQUE(directiveId)` constraint — crashing when a saved draft was reopened
/// and the Additional-Instructions or Guardian step was navigated through again.
/// The fix mirrors the long-standing `upsertPreferences` update-then-insert.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;
  late int directiveId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
    directiveId = await repo.createDirective(FormType.combined);
  });

  tearDown(() => db.close());

  group('upsertAdditionalInstructions', () {
    test('a second save updates in place instead of throwing', () async {
      await repo.upsertAdditionalInstructions(AdditionalInstructionsTableCompanion(
        directiveId: Value(directiveId),
        crisisIntervention: const Value('first'),
      ));
      // Previously threw "UNIQUE constraint failed: additional_instructions.directive_id".
      await repo.upsertAdditionalInstructions(AdditionalInstructionsTableCompanion(
        directiveId: Value(directiveId),
        crisisIntervention: const Value('second'),
      ));

      final rows = await db.select(db.additionalInstructionsTable).get();
      expect(rows, hasLength(1), reason: 'must update the same row, not insert');
      expect(rows.single.crisisIntervention, 'second');
    });
  });

  group('upsertGuardianNomination', () {
    test('a second save updates in place instead of throwing', () async {
      await repo.upsertGuardianNomination(GuardianNominationsCompanion(
        directiveId: Value(directiveId),
        nomineeFullName: const Value('First Nominee'),
      ));
      await repo.upsertGuardianNomination(GuardianNominationsCompanion(
        directiveId: Value(directiveId),
        nomineeFullName: const Value('Second Nominee'),
      ));

      final rows = await db.select(db.guardianNominations).get();
      expect(rows, hasLength(1), reason: 'must update the same row, not insert');
      expect(rows.single.nomineeFullName, 'Second Nominee');
    });
  });

  group('upsertPreferences (already correct — locked here for parity)', () {
    test('a second save updates in place', () async {
      await repo.upsertPreferences(DirectivePrefsCompanion(
        directiveId: Value(directiveId),
        medicationConsent: const Value('yes'),
      ));
      await repo.upsertPreferences(DirectivePrefsCompanion(
        directiveId: Value(directiveId),
        medicationConsent: const Value('agentDecides'),
      ));

      final rows = await db.select(db.directivePrefs).get();
      expect(rows, hasLength(1));
      expect(rows.single.medicationConsent, 'agentDecides');
    });
  });
}
