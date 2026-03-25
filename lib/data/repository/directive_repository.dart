import 'package:drift/drift.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';

class DirectiveRepository {
  final AppDatabase _db;
  DirectiveRepository(this._db);

  Stream<List<Directive>> watchAllDirectives() =>
      _db.select(_db.directives).watch();

  Future<List<Directive>> getAllDirectives() =>
      _db.select(_db.directives).get();

  Future<Directive?> getDirectiveById(int id) =>
      (_db.select(_db.directives)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  Future<int> createDirective(FormType formType) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db.into(_db.directives).insert(DirectivesCompanion.insert(
          formType: formType.name,
          createdAt: now,
          updatedAt: now,
        ));
  }

  Future<void> updatePersonalInfo(int id, {
    required String fullName,
    required String dateOfBirth,
    required String address,
    required String address2,
    required String city,
    required String state,
    required String zip,
    required String phone,
  }) =>
      (_db.update(_db.directives)..where((t) => t.id.equals(id))).write(
        DirectivesCompanion(
          fullName: Value(fullName),
          dateOfBirth: Value(dateOfBirth),
          address: Value(address),
          address2: Value(address2),
          city: Value(city),
          state: Value(state),
          zip: Value(zip),
          phone: Value(phone),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> updateLastStepIndex(int id, int stepIndex) =>
      (_db.update(_db.directives)..where((t) => t.id.equals(id))).write(
        DirectivesCompanion(
          lastStepIndex: Value(stepIndex),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> updateEffectiveCondition(int id, String condition) =>
      (_db.update(_db.directives)..where((t) => t.id.equals(id))).write(
        DirectivesCompanion(
          effectiveCondition: Value(condition),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> updatePreferredDoctor(int id, {
    required String name,
    required String contact,
  }) =>
      (_db.update(_db.directives)..where((t) => t.id.equals(id))).write(
        DirectivesCompanion(
          preferredDoctorName: Value(name),
          preferredDoctorContact: Value(contact),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> updateStatus(int id, DirectiveStatus status) =>
      (_db.update(_db.directives)..where((t) => t.id.equals(id))).write(
        DirectivesCompanion(
          status: Value(status.name),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  Future<void> deleteDirective(int id) =>
      (_db.delete(_db.directives)..where((t) => t.id.equals(id))).go();

  Future<void> deleteAllDirectives() async {
    await _db.transaction(() async {
      await _db.delete(_db.medicationEntries).go();
      await _db.delete(_db.diagnosisEntries).go();
      await _db.delete(_db.agents).go();
      await _db.delete(_db.witnesses).go();
      await _db.delete(_db.directivePrefs).go();
      await _db.delete(_db.additionalInstructionsTable).go();
      await _db.delete(_db.guardianNominations).go();
      await _db.delete(_db.directives).go();
    });
  }

  // ── Agents ────────────────────────────────────────────────────────────────

  Future<List<Agent>> getAgents(int directiveId) =>
      (_db.select(_db.agents)
            ..where((t) => t.directiveId.equals(directiveId)))
          .get();

  Future<int> upsertAgent(AgentsCompanion agent) =>
      _db.into(_db.agents).insertOnConflictUpdate(agent);

  // ── Medications ───────────────────────────────────────────────────────────

  Stream<List<MedicationEntry>> watchMedications(int directiveId) =>
      (_db.select(_db.medicationEntries)
            ..where((t) => t.directiveId.equals(directiveId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<int> insertMedication(MedicationEntriesCompanion entry) =>
      _db.into(_db.medicationEntries).insert(entry);

  Future<void> updateMedication(int id, String name, String reason) =>
      (_db.update(_db.medicationEntries)..where((t) => t.id.equals(id))).write(
        MedicationEntriesCompanion(
          medicationName: Value(name),
          reason: Value(reason),
        ),
      );

  Future<void> deleteMedication(int id) =>
      (_db.delete(_db.medicationEntries)..where((t) => t.id.equals(id))).go();

  Future<void> replaceMedications(int directiveId, List<MedicationEntriesCompanion> newEntries) async {
    await _db.transaction(() async {
      await (_db.delete(_db.medicationEntries)
          ..where((t) => t.directiveId.equals(directiveId))).go();
      for (final entry in newEntries) {
        await _db.into(_db.medicationEntries).insert(entry);
      }
    });
  }

  // ── Preferences ───────────────────────────────────────────────────────────

  Future<DirectivePref?> getPreferences(int directiveId) =>
      (_db.select(_db.directivePrefs)
            ..where((t) => t.directiveId.equals(directiveId)))
          .getSingleOrNull();

  Future<void> upsertPreferences(DirectivePrefsCompanion prefs) =>
      _db.into(_db.directivePrefs).insertOnConflictUpdate(prefs);

  // ── Additional Instructions ───────────────────────────────────────────────

  Future<AdditionalInstructionsTableData?> getAdditionalInstructions(int directiveId) =>
      (_db.select(_db.additionalInstructionsTable)
            ..where((t) => t.directiveId.equals(directiveId)))
          .getSingleOrNull();

  Future<void> upsertAdditionalInstructions(
          AdditionalInstructionsTableCompanion data) =>
      _db
          .into(_db.additionalInstructionsTable)
          .insertOnConflictUpdate(data);

  // ── Witnesses ─────────────────────────────────────────────────────────────

  Future<List<WitnessesData>> getWitnesses(int directiveId) =>
      (_db.select(_db.witnesses)
            ..where((t) => t.directiveId.equals(directiveId))
            ..orderBy([(t) => OrderingTerm.asc(t.witnessNumber)]))
          .get();

  Future<void> upsertWitness(WitnessesCompanion witness) =>
      _db.into(_db.witnesses).insertOnConflictUpdate(witness);

  // ── Guardian Nomination ───────────────────────────────────────────────────

  Future<GuardianNomination?> getGuardianNomination(int directiveId) =>
      (_db.select(_db.guardianNominations)
            ..where((t) => t.directiveId.equals(directiveId)))
          .getSingleOrNull();

  Future<void> upsertGuardianNomination(GuardianNominationsCompanion data) =>
      _db.into(_db.guardianNominations).insertOnConflictUpdate(data);

  // ── Diagnoses ──────────────────────────────────────────────────────────────

  Stream<List<DiagnosisEntry>> watchDiagnoses(int directiveId) =>
      (_db.select(_db.diagnosisEntries)
            ..where((t) => t.directiveId.equals(directiveId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .watch();

  Future<List<DiagnosisEntry>> getDiagnoses(int directiveId) =>
      (_db.select(_db.diagnosisEntries)
            ..where((t) => t.directiveId.equals(directiveId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<int> insertDiagnosis(DiagnosisEntriesCompanion entry) =>
      _db.into(_db.diagnosisEntries).insert(entry);

  Future<void> deleteDiagnosis(int id) =>
      (_db.delete(_db.diagnosisEntries)..where((t) => t.id.equals(id))).go();
}
