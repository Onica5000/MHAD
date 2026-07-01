import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';

/// Locks the `snapshotDirective` → `restoreFromSnapshot` round-trip used by
/// web-reload crash recovery and encrypted export/import. A field the wizard
/// saves but the snapshot omits is silently lost on that round-trip — exactly
/// how `roomPreferencesNote` / `roommateGenderMatch` (schema v16) got dropped
/// until this test + the snapshot fix landed. Extend the assertions whenever a
/// new persisted column is added.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;
  late int id;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
    id = await repo.createDirective(FormType.combined);
  });

  tearDown(() => db.close());

  test('full snapshot → restore preserves the prefs block + identity', () async {
    await repo.updatePersonalInfo(
      id,
      fullName: 'Jane Doe',
      dateOfBirth: '01/15/1980',
      address: '1 Main St',
      address2: '',
      city: 'Philadelphia',
      county: 'Philadelphia',
      state: 'PA',
      zip: '19103',
      phone: '215-555-0000',
    );
    await repo.upsertPreferences(DirectivePrefsCompanion(
      directiveId: Value(id),
      treatmentFacilityPref: const Value('prefer'),
      preferredFacilityName: const Value('Hospital A'),
      medicationConsent: const Value('agentDecides'),
      roomPreferences: const Value('singleRoom,sameGenderRoommate'),
      // The two fields that used to drop on the round-trip.
      roomPreferencesNote: const Value('quiet floor, near a window'),
      roommateGenderMatch: const Value('specify:women only'),
      crisisPlanJson: const Value('{"warn":["x"]}'),
      selfBindingEnabled: const Value(true),
      sideEffectsJson: const Value('{"items":[]}'),
    ));
    await repo.upsertGuardianNomination(GuardianNominationsCompanion(
      directiveId: Value(id),
      nomineeFullName: const Value('Bob Guardian'),
      guardianCanRevoke: const Value(true),
      guardianCanRevokeNote: const Value('with court approval'),
      guardianCanChangeAgent: const Value(true),
      guardianCanChangeAgentNote: const Value('only for medications'),
      guardianMustConsultAgent: const Value(true),
      guardianMustConsultAgentNote: const Value('by phone first'),
      guardianRelation: const Value('different'),
    ));
    await repo.insertMedication(MedicationEntriesCompanion.insert(
      directiveId: id,
      entryType: 'current',
      medicationName: const Value('Lithium'),
      dosage: const Value('300 mg twice daily'),
      sortOrder: const Value(0),
    ));
    await repo.upsertAgent(AgentsCompanion(
      directiveId: Value(id),
      agentType: const Value('primary'),
      fullName: const Value('Mary Agent'),
      acceptedAt: const Value(1700000000000),
      acceptanceNotes: const Value('accepted in person'),
    ));

    final snap = await repo.snapshotDirective(id, full: true);
    final newId = await repo.restoreFromSnapshot(snap);
    expect(newId, isNot(id), reason: 'restore creates a fresh directive');

    final p = await repo.getPreferences(newId);
    expect(p, isNotNull);
    // Regression guards for the previously-dropped fields:
    expect(p!.roomPreferencesNote, 'quiet floor, near a window');
    expect(p.roommateGenderMatch, 'specify:women only');
    // Broad prefs coverage:
    expect(p.roomPreferences, 'singleRoom,sameGenderRoommate');
    expect(p.treatmentFacilityPref, 'prefer');
    expect(p.preferredFacilityName, 'Hospital A');
    expect(p.medicationConsent, 'agentDecides');
    expect(p.crisisPlanJson, '{"warn":["x"]}');
    expect(p.selfBindingEnabled, isTrue);
    expect(p.sideEffectsJson, '{"items":[]}');

    // Identity round-trips in a `full` snapshot.
    final d = await repo.getDirectiveById(newId);
    expect(d!.fullName, 'Jane Doe');
    expect(d.zip, '19103');

    // Guardian condition notes (previously dropped).
    final guardian = await repo.getGuardianNomination(newId);
    expect(guardian!.guardianCanRevokeNote, 'with court approval');
    expect(guardian.guardianCanChangeAgentNote, 'only for medications');
    expect(guardian.guardianMustConsultAgentNote, 'by phone first');

    // Medication dosage (previously dropped).
    final meds = await repo.watchMedications(newId).first;
    expect(meds, hasLength(1));
    expect(meds.single.dosage, '300 mg twice daily');

    // Agent acceptance log (now carried per approval).
    final agents = await repo.getAgents(newId);
    final primary = agents.firstWhere((a) => a.agentType == 'primary');
    expect(primary.acceptedAt, 1700000000000);
    expect(primary.acceptanceNotes, 'accepted in person');
  });
}
