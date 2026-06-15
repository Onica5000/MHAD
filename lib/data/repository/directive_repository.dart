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
    String county = '',
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
          county: Value(county),
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

  Future<void> updateEffectiveCondition(
    int id,
    String condition, {
    bool? twoProfessionals,
    bool? courtOrder,
    bool? involuntaryCommitment,
  }) =>
      (_db.update(_db.directives)..where((t) => t.id.equals(id))).write(
        DirectivesCompanion(
          effectiveCondition: Value(condition),
          triggerTwoProfessionals: twoProfessionals == null
              ? const Value.absent()
              : Value(twoProfessionals),
          triggerCourtOrder:
              courtOrder == null ? const Value.absent() : Value(courtOrder),
          triggerInvoluntaryCommitment: involuntaryCommitment == null
              ? const Value.absent()
              : Value(involuntaryCommitment),
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

  Future<void> updatePrimaryDoctor(int id, {
    required String name,
    required String specialty,
    required String phone,
  }) =>
      (_db.update(_db.directives)..where((t) => t.id.equals(id))).write(
        DirectivesCompanion(
          primaryDoctorName: Value(name),
          primaryDoctorSpecialty: Value(specialty),
          primaryDoctorPhone: Value(phone),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Stamps the directive's `executionDate` to [now] (millis-since-epoch).
  /// Called by the wet-ink sign step when the user advances past the
  /// print-and-sign instructions — flips downstream "Signed in effect"
  /// status pills and date columns from draft to complete.
  Future<void> setExecutionDate(int id, int now) =>
      (_db.update(_db.directives)..where((t) => t.id.equals(id))).write(
        DirectivesCompanion(
          executionDate: Value(now),
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

  Future<void> upsertPreferences(DirectivePrefsCompanion prefs) async {
    final directiveId = prefs.directiveId.value;
    final updated = await (_db.update(_db.directivePrefs)
            ..where((t) => t.directiveId.equals(directiveId)))
        .write(prefs);
    if (updated == 0) {
      await _db.into(_db.directivePrefs).insert(prefs);
    }
  }

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

  // ── Allergies (wizard step 8 — Phase 3) ────────────────────────────────

  Future<List<DirectiveAllergy>> getAllergies(int directiveId) =>
      (_db.select(_db.directiveAllergies)
            ..where((t) => t.directiveId.equals(directiveId))
            ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
          .get();

  Future<int> addAllergy(DirectiveAllergiesCompanion entry) =>
      _db.into(_db.directiveAllergies).insert(entry);

  Future<void> removeAllergy(int id) =>
      (_db.delete(_db.directiveAllergies)..where((t) => t.id.equals(id))).go();

  // ── Snapshot / Restore (for web reload recovery) ───────────────────────

  /// Export all non-PII data for a directive as a JSON-safe map.
  /// Serialize a directive to a Map. [full] = true additionally includes the
  /// personal-identity fields and designated agents — used for the user-owned
  /// ENCRYPTED export file (portable, the user holds it). The default
  /// (PII-stripped) form is used for the unencrypted web-reload cache, which
  /// must not persist identity. Round-trips with [restoreFromSnapshot].
  Future<Map<String, dynamic>> snapshotDirective(int directiveId,
      {bool full = false}) async {
    final d = await getDirectiveById(directiveId);
    if (d == null) return {};

    final prefs = await getPreferences(directiveId);
    final instr = await getAdditionalInstructions(directiveId);
    final meds = await watchMedications(directiveId).first;
    final diags = await getDiagnoses(directiveId);
    final allergies = await getAllergies(directiveId);
    final guardian = await getGuardianNomination(directiveId);
    final agents = full ? await getAgents(directiveId) : const <Agent>[];

    return {
      if (full) 'personal': {
        'fullName': d.fullName,
        'dateOfBirth': d.dateOfBirth,
        'address': d.address,
        'address2': d.address2,
        'city': d.city,
        'county': d.county,
        'state': d.state,
        'zip': d.zip,
        'phone': d.phone,
      },
      if (full && agents.isNotEmpty) 'agents': agents
          .map((a) => {
                'agentType': a.agentType,
                'fullName': a.fullName,
                'relationship': a.relationship,
                'address': a.address,
                'homePhone': a.homePhone,
                'workPhone': a.workPhone,
                'cellPhone': a.cellPhone,
              })
          .toList(),
      'formType': d.formType,
      'lastStepIndex': d.lastStepIndex,
      'effectiveCondition': d.effectiveCondition,
      'triggerTwoProfessionals': d.triggerTwoProfessionals,
      'triggerCourtOrder': d.triggerCourtOrder,
      'triggerInvoluntaryCommitment': d.triggerInvoluntaryCommitment,
      'preferredDoctorName': d.preferredDoctorName,
      'preferredDoctorContact': d.preferredDoctorContact,
      'primaryDoctorName': d.primaryDoctorName,
      'primaryDoctorSpecialty': d.primaryDoctorSpecialty,
      'primaryDoctorPhone': d.primaryDoctorPhone,
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
        // Phase 2 + Phase 4 additions — without these the web-reload
        // recovery silently drops room chips, crisis-plan JSON and the
        // Ulysses acknowledgment flag.
        'roomPreferences': prefs.roomPreferences,
        'crisisPlanJson': prefs.crisisPlanJson,
        'selfBindingEnabled': prefs.selfBindingEnabled,
        'sideEffectsJson': prefs.sideEffectsJson,
      },
      if (guardian != null) 'guardian': {
        'nomineeFullName': guardian.nomineeFullName,
        'nomineeAddress': guardian.nomineeAddress,
        'nomineePhone': guardian.nomineePhone,
        'nomineeRelationship': guardian.nomineeRelationship,
        'guardianCanRevoke': guardian.guardianCanRevoke,
        'guardianCanChangeAgent': guardian.guardianCanChangeAgent,
        'guardianMustConsultAgent': guardian.guardianMustConsultAgent,
        'guardianRelation': guardian.guardianRelation,
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
      if (allergies.isNotEmpty) 'allergies': allergies.map((a) => {
        'kind': a.kind,
        'substance': a.substance,
        'code': a.code,
        'codeSource': a.codeSource,
        'severity': a.severity,
        'reactions': a.reactions,
        'notes': a.notes,
        'sortOrder': a.sortOrder,
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
    final tTwo = snap['triggerTwoProfessionals'] == true;
    final tCourt = snap['triggerCourtOrder'] == true;
    final tCommit = snap['triggerInvoluntaryCommitment'] == true;
    if (ec.isNotEmpty || tTwo || tCourt || tCommit) {
      await updateEffectiveCondition(
        id,
        ec,
        twoProfessionals: tTwo,
        courtOrder: tCourt,
        involuntaryCommitment: tCommit,
      );
    }
    final docName = snap['preferredDoctorName']?.toString() ?? '';
    final docContact = snap['preferredDoctorContact']?.toString() ?? '';
    if (docName.isNotEmpty || docContact.isNotEmpty) {
      await updatePreferredDoctor(id, name: docName, contact: docContact);
    }
    final pcpName = snap['primaryDoctorName']?.toString() ?? '';
    final pcpSpec = snap['primaryDoctorSpecialty']?.toString() ?? '';
    final pcpPhone = snap['primaryDoctorPhone']?.toString() ?? '';
    if (pcpName.isNotEmpty || pcpSpec.isNotEmpty || pcpPhone.isNotEmpty) {
      await updatePrimaryDoctor(id,
          name: pcpName, specialty: pcpSpec, phone: pcpPhone);
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
        agentCanConsentHospitalization: _vBool(p['agentCanConsentHospitalization']),
        agentCanConsentMedication: _vBool(p['agentCanConsentMedication']),
        // Phase 2 + Phase 4 additions — round-trip pair to snapshotDirective.
        roomPreferences: _v(p['roomPreferences']),
        crisisPlanJson: _v(p['crisisPlanJson']),
        selfBindingEnabled: _vBool(p['selfBindingEnabled']),
        sideEffectsJson: _v(p['sideEffectsJson']),
      ));
    }

    // Personal identity (only present in a `full` / encrypted-export snapshot).
    final personal = snap['personal'];
    if (personal is Map<String, dynamic>) {
      await updatePersonalInfo(
        id,
        fullName: personal['fullName']?.toString() ?? '',
        dateOfBirth: personal['dateOfBirth']?.toString() ?? '',
        address: personal['address']?.toString() ?? '',
        address2: personal['address2']?.toString() ?? '',
        city: personal['city']?.toString() ?? '',
        county: personal['county']?.toString() ?? '',
        state: personal['state']?.toString() ?? 'PA',
        zip: personal['zip']?.toString() ?? '',
        phone: personal['phone']?.toString() ?? '',
      );
    }

    // Designated agents (only present in a `full` / encrypted-export snapshot).
    final agents = snap['agents'];
    if (agents is List) {
      for (final raw in agents) {
        if (raw is! Map) continue;
        final a = raw.cast<String, dynamic>();
        await upsertAgent(AgentsCompanion(
          directiveId: Value(id),
          agentType: Value(a['agentType']?.toString() ?? 'primary'),
          fullName: _v(a['fullName']),
          relationship: _v(a['relationship']),
          address: _v(a['address']),
          homePhone: _v(a['homePhone']),
          workPhone: _v(a['workPhone']),
          cellPhone: _v(a['cellPhone']),
        ));
      }
    }

    // Guardian (Phase 2 — includes the new `guardianRelation` enum).
    final g = snap['guardian'];
    if (g is Map<String, dynamic>) {
      await upsertGuardianNomination(GuardianNominationsCompanion(
        directiveId: Value(id),
        nomineeFullName: _v(g['nomineeFullName']),
        nomineeAddress: _v(g['nomineeAddress']),
        nomineePhone: _v(g['nomineePhone']),
        nomineeRelationship: _v(g['nomineeRelationship']),
        guardianCanRevoke: _vBool(g['guardianCanRevoke']),
        guardianCanChangeAgent: _vBool(g['guardianCanChangeAgent']),
        guardianMustConsultAgent: _vBool(g['guardianMustConsultAgent']),
        guardianRelation: _v(g['guardianRelation']),
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

    // Allergies (Phase 3) — round-trip pair to snapshotDirective.
    final aller = snap['allergies'];
    if (aller is List) {
      for (final a in aller) {
        if (a is Map<String, dynamic>) {
          await addAllergy(DirectiveAllergiesCompanion.insert(
            directiveId: id,
            kind: Value(a['kind']?.toString() ?? 'drug'),
            substance: Value(a['substance']?.toString() ?? ''),
            code: Value(a['code']?.toString() ?? ''),
            codeSource: Value(a['codeSource']?.toString() ?? 'manual'),
            severity: Value(a['severity']?.toString() ?? 'moderate'),
            reactions: Value(a['reactions']?.toString() ?? ''),
            notes: Value(a['notes']?.toString() ?? ''),
            sortOrder: Value(a['sortOrder'] as int? ?? 0),
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

  static Value<bool> _vBool(dynamic val) {
    if (val is bool) return Value(val);
    if (val is String) return Value(val == 'true' || val == '1');
    return const Value.absent();
  }
}
