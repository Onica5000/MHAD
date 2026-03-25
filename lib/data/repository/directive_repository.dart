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

  // ── Snapshot / Restore (for web reload recovery) ───────────────────────

  /// Export all non-PII data for a directive as a JSON-safe map.
  Future<Map<String, dynamic>> snapshotDirective(int directiveId) async {
    final d = await getDirectiveById(directiveId);
    if (d == null) return {};

    final prefs = await getPreferences(directiveId);
    final instr = await getAdditionalInstructions(directiveId);
    final meds = await watchMedications(directiveId).first;
    final diags = await getDiagnoses(directiveId);

    return {
      'formType': d.formType,
      'lastStepIndex': d.lastStepIndex,
      'effectiveCondition': d.effectiveCondition,
      'preferredDoctorName': d.preferredDoctorName,
      'preferredDoctorContact': d.preferredDoctorContact,
      if (prefs != null) 'prefs': {
        'treatmentFacilityPref': prefs.treatmentFacilityPref,
        'preferredFacilityName': prefs.preferredFacilityName,
        'avoidFacilityName': prefs.avoidFacilityName,
        'medicationConsent': prefs.medicationConsent,
        'ectConsent': prefs.ectConsent,
        'experimentalConsent': prefs.experimentalConsent,
        'drugTrialConsent': prefs.drugTrialConsent,
        'agentCanConsentHospitalization': prefs.agentCanConsentHospitalization,
        'agentCanConsentMedication': prefs.agentCanConsentMedication,
        'agentAuthorityLimitations': prefs.agentAuthorityLimitations,
      },
      if (instr != null) 'instructions': {
        'activities': instr.activities,
        'crisisIntervention': instr.crisisIntervention,
        'healthHistory': instr.healthHistory,
        'dietary': instr.dietary,
        'religious': instr.religious,
        'childrenCustody': instr.childrenCustody,
        'familyNotification': instr.familyNotification,
        'recordsDisclosure': instr.recordsDisclosure,
        'petCustody': instr.petCustody,
        'other': instr.other,
      },
      if (meds.isNotEmpty) 'medications': meds.map((m) => {
        'entryType': m.entryType,
        'medicationName': m.medicationName,
        'reason': m.reason,
        'sortOrder': m.sortOrder,
      }).toList(),
      if (diags.isNotEmpty) 'diagnoses': diags.map((d) => {
        'icdCode': d.icdCode,
        'name': d.name,
        'sortOrder': d.sortOrder,
      }).toList(),
    };
  }

  /// Restore a directive from a snapshot map. Returns the new directive ID.
  Future<int> restoreFromSnapshot(Map<String, dynamic> snap) async {
    final formType = FormType.values.firstWhere(
      (e) => e.name == (snap['formType'] ?? 'combined'),
      orElse: () => FormType.combined,
    );
    final id = await createDirective(formType);

    // Directive fields
    final ec = snap['effectiveCondition']?.toString() ?? '';
    if (ec.isNotEmpty) await updateEffectiveCondition(id, ec);
    final docName = snap['preferredDoctorName']?.toString() ?? '';
    final docContact = snap['preferredDoctorContact']?.toString() ?? '';
    if (docName.isNotEmpty || docContact.isNotEmpty) {
      await updatePreferredDoctor(id, name: docName, contact: docContact);
    }
    final step = snap['lastStepIndex'];
    if (step is int && step > 0) await updateLastStepIndex(id, step);

    // Preferences
    final p = snap['prefs'];
    if (p is Map<String, dynamic>) {
      await upsertPreferences(DirectivePrefsCompanion(
        directiveId: Value(id),
        treatmentFacilityPref: _v(p['treatmentFacilityPref']),
        preferredFacilityName: _v(p['preferredFacilityName']),
        avoidFacilityName: _v(p['avoidFacilityName']),
        medicationConsent: _v(p['medicationConsent']),
        ectConsent: _v(p['ectConsent']),
        experimentalConsent: _v(p['experimentalConsent']),
        drugTrialConsent: _v(p['drugTrialConsent']),
        agentAuthorityLimitations: _v(p['agentAuthorityLimitations']),
      ));
    }

    // Additional instructions
    final i = snap['instructions'];
    if (i is Map<String, dynamic>) {
      await upsertAdditionalInstructions(AdditionalInstructionsTableCompanion(
        directiveId: Value(id),
        activities: _v(i['activities']),
        crisisIntervention: _v(i['crisisIntervention']),
        healthHistory: _v(i['healthHistory']),
        dietary: _v(i['dietary']),
        religious: _v(i['religious']),
        childrenCustody: _v(i['childrenCustody']),
        familyNotification: _v(i['familyNotification']),
        recordsDisclosure: _v(i['recordsDisclosure']),
        petCustody: _v(i['petCustody']),
        other: _v(i['other']),
      ));
    }

    // Medications
    final meds = snap['medications'];
    if (meds is List) {
      for (final m in meds) {
        if (m is Map<String, dynamic>) {
          await insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: m['entryType']?.toString() ?? 'preferred',
            medicationName: Value(m['medicationName']?.toString() ?? ''),
            reason: Value(m['reason']?.toString() ?? ''),
            sortOrder: Value(m['sortOrder'] as int? ?? 0),
          ));
        }
      }
    }

    // Diagnoses
    final diags = snap['diagnoses'];
    if (diags is List) {
      for (final d in diags) {
        if (d is Map<String, dynamic>) {
          await insertDiagnosis(DiagnosisEntriesCompanion.insert(
            directiveId: id,
            icdCode: Value(d['icdCode']?.toString() ?? ''),
            name: Value(d['name']?.toString() ?? ''),
            sortOrder: Value(d['sortOrder'] as int? ?? 0),
          ));
        }
      }
    }

    return id;
  }

  static Value<String> _v(dynamic val) {
    final s = val?.toString() ?? '';
    return s.isNotEmpty ? Value(s) : const Value.absent();
  }
}
