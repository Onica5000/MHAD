import 'package:drift/drift.dart';

export 'app_database_stub.dart'
    if (dart.library.io) 'app_database_native.dart'
    if (dart.library.js_interop) 'app_database_web.dart'
    show createAppDatabase, createMemoryDatabase, createEncryptedDatabase;

part 'app_database.g.dart';

// ─── Tables ────────────────────────────────────────────────────────────────

class Directives extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get formType => text()(); // 'combined' | 'declaration' | 'poa'
  TextColumn get status => text().withDefault(const Constant('draft'))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get executionDate => integer().nullable()();
  IntColumn get expirationDate => integer().nullable()();

  // Personal info
  TextColumn get fullName => text().withDefault(const Constant(''))();
  TextColumn get dateOfBirth => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  TextColumn get address2 => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get county => text().withDefault(const Constant(''))();
  TextColumn get state => text().withDefault(const Constant('PA'))();
  TextColumn get zip => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();

  // Effective condition — a free-text note plus the three statutory triggers
  // the artboard "When this kicks in" step offers as checkable options.
  TextColumn get effectiveCondition =>
      text().withDefault(const Constant(''))();
  BoolColumn get triggerTwoProfessionals =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get triggerCourtOrder =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get triggerInvoluntaryCommitment =>
      boolean().withDefault(const Constant(false))();

  // Preferred evaluating doctor (official form field) — the doctor the user
  // prefers to certify their capacity ("when this kicks in" step).
  TextColumn get preferredDoctorName =>
      text().withDefault(const Constant(''))();
  TextColumn get preferredDoctorContact =>
      text().withDefault(const Constant(''))();

  // Primary care doctor (artboard Diagnoses step) — the user's regular doctor,
  // distinct from the evaluating doctor above.
  TextColumn get primaryDoctorName =>
      text().withDefault(const Constant(''))();
  TextColumn get primaryDoctorSpecialty =>
      text().withDefault(const Constant(''))();
  TextColumn get primaryDoctorPhone =>
      text().withDefault(const Constant(''))();

  // Wizard resume — tracks which step the user last visited
  IntColumn get lastStepIndex => integer().withDefault(const Constant(0))();
}

class Agents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId =>
      integer().references(Directives, #id, onDelete: KeyAction.cascade)();
  TextColumn get agentType => text()(); // 'primary' | 'alternate'
  TextColumn get fullName => text().withDefault(const Constant(''))();
  TextColumn get relationship => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  // Address components (schema 19) — `address` is line 1; these split out so
  // every form uses the same Address 1/2 · City · State · ZIP boxes.
  TextColumn get address2 => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get state => text().withDefault(const Constant(''))();
  TextColumn get zip => text().withDefault(const Constant(''))();
  TextColumn get homePhone => text().withDefault(const Constant(''))();
  TextColumn get workPhone => text().withDefault(const Constant(''))();
  TextColumn get cellPhone => text().withDefault(const Constant(''))();

  // Manual agent-acceptance log (m-agentaccept).
  // Per user decision (2026-06-02): the prototype's `ScrAgentAccept`
  // receipt is repurposed as a principal-recorded log that the agent
  // accepted in person. NULL = not yet logged. Schema v11.
  IntColumn get acceptedAt => integer().nullable()();
  TextColumn get acceptanceNotes =>
      text().withDefault(const Constant(''))();
}

class MedicationEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId =>
      integer().references(Directives, #id, onDelete: KeyAction.cascade)();
  TextColumn get entryType =>
      text()(); // 'current' | 'exception' | 'limitation' | 'preferred'
  TextColumn get medicationName => text().withDefault(const Constant(''))();
  TextColumn get reason => text().withDefault(const Constant(''))();
  // Dosage captured only for 'current' (currently-taking) entries — the other
  // categories are preferences, not a record of what the person takes now.
  TextColumn get dosage => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class DirectivePrefs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId => integer()
      .unique()
      .references(Directives, #id, onDelete: KeyAction.cascade)();

  TextColumn get treatmentFacilityPref =>
      text().withDefault(const Constant('noPreference'))();
  TextColumn get preferredFacilityName =>
      text().withDefault(const Constant(''))();
  TextColumn get avoidFacilityName => text().withDefault(const Constant(''))();

  TextColumn get medicationConsent =>
      text().withDefault(const Constant('yes'))();
  TextColumn get ectConsent => text().withDefault(const Constant('no'))();
  TextColumn get experimentalConsent =>
      text().withDefault(const Constant('no'))();
  TextColumn get drugTrialConsent => text().withDefault(const Constant('no'))();

  BoolColumn get agentCanConsentHospitalization =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get agentCanConsentMedication =>
      boolean().withDefault(const Constant(true))();
  TextColumn get agentAuthorityLimitations =>
      text().withDefault(const Constant(''))();
  // Comma-separated room-preference chip ids (e.g. 'singleRoom,windowIfPossible,quietFloor').
  // Schema 8.
  TextColumn get roomPreferences =>
      text().withDefault(const Constant(''))();
  // Free-form room-preference note, in addition to the chips above. Schema 12.
  TextColumn get roomPreferencesNote =>
      text().withDefault(const Constant(''))();
  // Same-gender-roommate match preference (artboard WebWizCare sub-selector,
  // shown only when the 'sameGenderRoommate' room chip is selected). Stores
  // 'women' | 'men' | 'sameAsIdentity', or 'specify:<free text>'. Empty = not
  // set. Schema 16.
  TextColumn get roommateGenderMatch =>
      text().withDefault(const Constant(''))();
  // Phase 4 — Crisis plan / wellness toolbox (optional add-on per v2 prototype).
  // JSON-encoded structure: {earlyWarning: [], triggers: [], helps: [],
  // sayToMe: [], dontDo: []}. Empty string = not yet filled.
  // Schema 10.
  TextColumn get crisisPlanJson =>
      text().withDefault(const Constant(''))();
  // Phase 4 — Self-binding (Ulysses) clause opt-in.
  // Per v3 prototype: PA Act 194 § 5802 makes self-binding structural; this
  // toggle confirms the principal acknowledges the structural effect.
  // Schema 10.
  BoolColumn get selfBindingEnabled =>
      boolean().withDefault(const Constant(false))();
  // "Are you experiencing these side effects?" checklist (Schema 18). JSON:
  // {"items":[{"med":"..","effect":"..","adl":"..","serious":bool,
  // "experiencing":bool}], "generatedForMeds":[".."]}. Empty = not yet used.
  // The AI lists common side effects of the user's CURRENT meds; the user
  // verifies which they experience and notes any daily-activity impact.
  TextColumn get sideEffectsJson =>
      text().withDefault(const Constant(''))();
}

class AdditionalInstructionsTable extends Table {
  @override
  String get tableName => 'additional_instructions';

  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId => integer()
      .unique()
      .references(Directives, #id, onDelete: KeyAction.cascade)();

  TextColumn get activities => text().withDefault(const Constant(''))();
  TextColumn get crisisIntervention =>
      text().withDefault(const Constant(''))();
  TextColumn get healthHistory => text().withDefault(const Constant(''))();
  TextColumn get dietary => text().withDefault(const Constant(''))();
  TextColumn get religious => text().withDefault(const Constant(''))();
  TextColumn get childrenCustody => text().withDefault(const Constant(''))();
  TextColumn get familyNotification =>
      text().withDefault(const Constant(''))();
  TextColumn get recordsDisclosure => text().withDefault(const Constant(''))();
  TextColumn get petCustody => text().withDefault(const Constant(''))();
  TextColumn get other => text().withDefault(const Constant(''))();
}

class Witnesses extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId =>
      integer().references(Directives, #id, onDelete: KeyAction.cascade)();
  IntColumn get witnessNumber => integer()(); // 1 or 2
  TextColumn get fullName => text().withDefault(const Constant(''))();
  TextColumn get address => text().withDefault(const Constant(''))();
  // Address components (schema 19) — `address` is line 1.
  TextColumn get address2 => text().withDefault(const Constant(''))();
  TextColumn get city => text().withDefault(const Constant(''))();
  TextColumn get state => text().withDefault(const Constant(''))();
  TextColumn get zip => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get signatureBase64 => text().nullable()();
  IntColumn get signatureDate => integer().nullable()();
}

class DiagnosisEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId =>
      integer().references(Directives, #id, onDelete: KeyAction.cascade)();
  TextColumn get icdCode => text().withDefault(const Constant(''))();
  TextColumn get name => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// Allergies & reactions captured in wizard step 8 (Phase 3 — schema 9).
///
/// `codeSource` notes where the chosen code came from for provenance
/// (`rxterms` for drug allergies, `icd10` for non-drug status codes,
/// `manual` for free-text). `reactions` is a comma-separated list of chip
/// labels (e.g. `Hives,Swelling,Throat closing`).
class DirectiveAllergies extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId =>
      integer().references(Directives, #id, onDelete: KeyAction.cascade)();
  // 'drug' | 'food' | 'material' | 'environmental' | 'other'
  TextColumn get kind => text().withDefault(const Constant('drug'))();
  TextColumn get substance => text().withDefault(const Constant(''))();
  TextColumn get code => text().withDefault(const Constant(''))();
  // 'rxterms' | 'icd10' | 'manual'
  TextColumn get codeSource => text().withDefault(const Constant('manual'))();
  // 'mild' | 'moderate' | 'severe'
  TextColumn get severity => text().withDefault(const Constant('moderate'))();
  // Comma-separated reaction chip labels.
  TextColumn get reactions => text().withDefault(const Constant(''))();
  TextColumn get notes => text().withDefault(const Constant(''))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

class GuardianNominations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId => integer()
      .unique()
      .references(Directives, #id, onDelete: KeyAction.cascade)();
  TextColumn get nomineeFullName => text().withDefault(const Constant(''))();
  TextColumn get nomineeAddress => text().withDefault(const Constant(''))();
  // Address components (schema 19) — `nomineeAddress` is line 1.
  TextColumn get nomineeAddress2 => text().withDefault(const Constant(''))();
  TextColumn get nomineeCity => text().withDefault(const Constant(''))();
  TextColumn get nomineeState => text().withDefault(const Constant(''))();
  TextColumn get nomineeZip => text().withDefault(const Constant(''))();
  TextColumn get nomineePhone => text().withDefault(const Constant(''))();
  TextColumn get nomineeRelationship =>
      text().withDefault(const Constant(''))();
  // true = guardian authorized to revoke ("can override this directive");
  // false = guardian cannot revoke
  BoolColumn get guardianCanRevoke =>
      boolean().withDefault(const Constant(false))();
  // Artboard guardian "conditions": may the guardian change my agent, and
  // must the guardian consult my agent before acting?
  BoolColumn get guardianCanChangeAgent =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get guardianMustConsultAgent =>
      boolean().withDefault(const Constant(false))();
  // Free-form detail the user can add to qualify each "yes" condition above
  // (shown only when the matching condition is Yes). Schema 17.
  TextColumn get guardianCanRevokeNote =>
      text().withDefault(const Constant(''))();
  TextColumn get guardianCanChangeAgentNote =>
      text().withDefault(const Constant(''))();
  TextColumn get guardianMustConsultAgentNote =>
      text().withDefault(const Constant(''))();
  // Relation to existing agents: 'sameAsPrimary' | 'sameAsAlternate' |
  // 'different' | 'noPreference'. Existing rows with `nomineeFullName`
  // populated migrate to 'different'; empty rows → 'noPreference'.
  // Schema 8.
  TextColumn get guardianRelation =>
      text().withDefault(const Constant('different'))();
}

// ─── Database ──────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  Directives,
  Agents,
  MedicationEntries,
  DirectivePrefs,
  AdditionalInstructionsTable,
  Witnesses,
  GuardianNominations,
  DiagnosisEntries,
  DirectiveAllergies,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 20;

  /// The lookup indexes on every child table's directive_id. Historically
  /// created only by the migrations below, which left *fresh* databases
  /// (every new install / web session) without them; onCreate now creates
  /// them too so fresh and upgraded databases have identical schemas
  /// (locked by test/unit/app_database_migration_test.dart).
  static const _directiveIdIndexes = [
    'CREATE INDEX IF NOT EXISTS idx_agents_directive '
        'ON agents (directive_id)',
    'CREATE INDEX IF NOT EXISTS idx_meds_directive '
        'ON medication_entries (directive_id)',
    'CREATE INDEX IF NOT EXISTS idx_witnesses_directive '
        'ON witnesses (directive_id)',
    'CREATE INDEX IF NOT EXISTS idx_diagnosis_directive '
        'ON diagnosis_entries (directive_id)',
    'CREATE INDEX IF NOT EXISTS idx_allergies_directive '
        'ON directive_allergies (directive_id)',
  ];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          for (final stmt in _directiveIdIndexes) {
            await customStatement(stmt);
          }
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_agents_directive '
                'ON agents (directive_id)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_meds_directive '
                'ON medication_entries (directive_id)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_witnesses_directive '
                'ON witnesses (directive_id)');
          }
          if (from < 3) {
            await customStatement(
                "ALTER TABLE directives ADD COLUMN address2 TEXT NOT NULL DEFAULT ''");
          }
          if (from < 4) {
            await customStatement(
                'ALTER TABLE directives ADD COLUMN last_step_index INTEGER NOT NULL DEFAULT 0');
          }
          if (from < 5) {
            await customStatement(
                "ALTER TABLE directives ADD COLUMN preferred_doctor_name TEXT NOT NULL DEFAULT ''");
            await customStatement(
                "ALTER TABLE directives ADD COLUMN preferred_doctor_contact TEXT NOT NULL DEFAULT ''");
            await customStatement(
                'ALTER TABLE guardian_nominations ADD COLUMN guardian_can_revoke INTEGER NOT NULL DEFAULT 0');
          }
          if (from < 6) {
            await customStatement(
                'CREATE TABLE IF NOT EXISTS diagnosis_entries ('
                // NOT NULL matches drift's generated DDL so migrated and
                // fresh-created databases end up schema-identical (locked by
                // app_database_migration_test.dart). Same below for
                // directive_allergies.
                'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
                'directive_id INTEGER NOT NULL REFERENCES directives(id) ON DELETE CASCADE, '
                "icd_code TEXT NOT NULL DEFAULT '', "
                "name TEXT NOT NULL DEFAULT '', "
                'sort_order INTEGER NOT NULL DEFAULT 0)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_diagnosis_directive '
                'ON diagnosis_entries (directive_id)');
          }
          if (from < 7) {
            await customStatement(
                "ALTER TABLE witnesses ADD COLUMN phone TEXT NOT NULL DEFAULT ''");
          }
          if (from < 8) {
            // Phase 2: room-preference chips + guardian-relation enum.
            await customStatement(
                "ALTER TABLE directive_prefs ADD COLUMN room_preferences "
                "TEXT NOT NULL DEFAULT ''");
            await customStatement(
                "ALTER TABLE guardian_nominations ADD COLUMN "
                "guardian_relation TEXT NOT NULL DEFAULT 'different'");
            // Existing rows with no nominee fall back to 'noPreference' so
            // the prototype's 4-radio default state is honest.
            await customStatement(
                "UPDATE guardian_nominations SET guardian_relation = 'noPreference' "
                "WHERE nominee_full_name = '' AND nominee_address = '' "
                "AND nominee_phone = '' AND nominee_relationship = ''");
          }
          if (from < 10) {
            // Phase 4 — Crisis plan JSON + Ulysses opt-in on directive_prefs.
            await customStatement(
                "ALTER TABLE directive_prefs ADD COLUMN crisis_plan_json "
                "TEXT NOT NULL DEFAULT ''");
            await customStatement(
                'ALTER TABLE directive_prefs ADD COLUMN self_binding_enabled '
                'INTEGER NOT NULL DEFAULT 0');
          }
          if (from < 11) {
            // Batch 5: manual agent-acceptance log fields on agents.
            await customStatement(
                'ALTER TABLE agents ADD COLUMN accepted_at INTEGER NULL');
            await customStatement(
                "ALTER TABLE agents ADD COLUMN acceptance_notes TEXT NOT NULL DEFAULT ''");
          }
          if (from < 9) {
            // Phase 3: new directive_allergies table for wizard step 8.
            await customStatement(
                'CREATE TABLE IF NOT EXISTS directive_allergies ('
                'id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, '
                'directive_id INTEGER NOT NULL REFERENCES directives(id) ON DELETE CASCADE, '
                "kind TEXT NOT NULL DEFAULT 'drug', "
                "substance TEXT NOT NULL DEFAULT '', "
                "code TEXT NOT NULL DEFAULT '', "
                "code_source TEXT NOT NULL DEFAULT 'manual', "
                "severity TEXT NOT NULL DEFAULT 'moderate', "
                "reactions TEXT NOT NULL DEFAULT '', "
                "notes TEXT NOT NULL DEFAULT '', "
                'sort_order INTEGER NOT NULL DEFAULT 0)');
            await customStatement(
                'CREATE INDEX IF NOT EXISTS idx_allergies_directive '
                'ON directive_allergies (directive_id)');
            // Migration of existing Reactions-tab content (entry_type =
            // 'reaction' on medication_entries does not exist — the current
            // Reactions tab still uses the MedicationEntryType.preferred /
            // .limitation / .exception triad, with reactions stored in the
            // `reason` field of `.exception` rows that mention reactions).
            // Rather than guess-migrate, the existing rows stay in
            // medication_entries; users can re-enter allergies in step 8.
            // This preserves data without risking false-positive migration.
          }
          if (from < 12) {
            // Free-form room-preference note alongside the chips.
            await customStatement(
                "ALTER TABLE directive_prefs ADD COLUMN room_preferences_note "
                "TEXT NOT NULL DEFAULT ''");
          }
          if (from < 13) {
            // County (official PA address field) + the three statutory
            // "when this kicks in" triggers as checkable options.
            await customStatement(
                "ALTER TABLE directives ADD COLUMN county TEXT NOT NULL DEFAULT ''");
            await customStatement(
                'ALTER TABLE directives ADD COLUMN trigger_two_professionals '
                'INTEGER NOT NULL DEFAULT 0');
            await customStatement(
                'ALTER TABLE directives ADD COLUMN trigger_court_order '
                'INTEGER NOT NULL DEFAULT 0');
            await customStatement(
                'ALTER TABLE directives ADD COLUMN '
                'trigger_involuntary_commitment INTEGER NOT NULL DEFAULT 0');
          }
          if (from < 14) {
            // Guardian "conditions": can change my agent / must consult my
            // agent first (artboard guardian step).
            await customStatement(
                'ALTER TABLE guardian_nominations ADD COLUMN '
                'guardian_can_change_agent INTEGER NOT NULL DEFAULT 0');
            await customStatement(
                'ALTER TABLE guardian_nominations ADD COLUMN '
                'guardian_must_consult_agent INTEGER NOT NULL DEFAULT 0');
          }
          if (from < 15) {
            // Primary care doctor (artboard Diagnoses step).
            await customStatement(
                "ALTER TABLE directives ADD COLUMN primary_doctor_name "
                "TEXT NOT NULL DEFAULT ''");
            await customStatement(
                "ALTER TABLE directives ADD COLUMN primary_doctor_specialty "
                "TEXT NOT NULL DEFAULT ''");
            await customStatement(
                "ALTER TABLE directives ADD COLUMN primary_doctor_phone "
                "TEXT NOT NULL DEFAULT ''");
          }
          if (from < 16) {
            // Same-gender-roommate match preference (artboard care-step
            // sub-selector).
            await customStatement(
                "ALTER TABLE directive_prefs ADD COLUMN roommate_gender_match "
                "TEXT NOT NULL DEFAULT ''");
          }
          if (from < 17) {
            // Free-form detail per guardianship "condition" (shown when Yes).
            await customStatement(
                "ALTER TABLE guardian_nominations ADD COLUMN "
                "guardian_can_revoke_note TEXT NOT NULL DEFAULT ''");
            await customStatement(
                "ALTER TABLE guardian_nominations ADD COLUMN "
                "guardian_can_change_agent_note TEXT NOT NULL DEFAULT ''");
            await customStatement(
                "ALTER TABLE guardian_nominations ADD COLUMN "
                "guardian_must_consult_agent_note TEXT NOT NULL DEFAULT ''");
          }
          if (from < 18) {
            // "Are you experiencing these side effects?" checklist JSON.
            await customStatement(
                "ALTER TABLE directive_prefs ADD COLUMN "
                "side_effects_json TEXT NOT NULL DEFAULT ''");
          }
          if (from < 19) {
            // Standardized address components for agents, witnesses, and the
            // guardian nominee (Address 1/2 · City · State · ZIP). `address`
            // (and `nominee_address`) remains line 1.
            for (final col in ['address2', 'city', 'state', 'zip']) {
              await customStatement(
                  "ALTER TABLE agents ADD COLUMN $col TEXT NOT NULL DEFAULT ''");
              await customStatement(
                  "ALTER TABLE witnesses ADD COLUMN $col TEXT NOT NULL DEFAULT ''");
            }
            for (final col in [
              'nominee_address2',
              'nominee_city',
              'nominee_state',
              'nominee_zip'
            ]) {
              await customStatement(
                  "ALTER TABLE guardian_nominations ADD COLUMN $col "
                  "TEXT NOT NULL DEFAULT ''");
            }
          }
          if (from < 20) {
            // Dosage for currently-taking medications (informational, for the
            // care team — not binding under 20 Pa.C.S. § 5808).
            await customStatement(
                "ALTER TABLE medication_entries ADD COLUMN dosage "
                "TEXT NOT NULL DEFAULT ''");
          }
        },
      );
}
