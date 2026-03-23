import 'package:drift/drift.dart';

import 'app_database_stub.dart'
    if (dart.library.io) 'app_database_native.dart'
    if (dart.library.js_interop) 'app_database_web.dart';

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
  TextColumn get state => text().withDefault(const Constant('PA'))();
  TextColumn get zip => text().withDefault(const Constant(''))();
  TextColumn get phone => text().withDefault(const Constant(''))();

  // Effective condition
  TextColumn get effectiveCondition =>
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
  TextColumn get homePhone => text().withDefault(const Constant(''))();
  TextColumn get workPhone => text().withDefault(const Constant(''))();
  TextColumn get cellPhone => text().withDefault(const Constant(''))();
}

class MedicationEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId =>
      integer().references(Directives, #id, onDelete: KeyAction.cascade)();
  TextColumn get entryType =>
      text()(); // 'exception' | 'limitation' | 'preferred'
  TextColumn get medicationName => text().withDefault(const Constant(''))();
  TextColumn get reason => text().withDefault(const Constant(''))();
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
  TextColumn get signatureBase64 => text().nullable()();
  IntColumn get signatureDate => integer().nullable()();
}

class GuardianNominations extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get directiveId => integer()
      .unique()
      .references(Directives, #id, onDelete: KeyAction.cascade)();
  TextColumn get nomineeFullName => text().withDefault(const Constant(''))();
  TextColumn get nomineeAddress => text().withDefault(const Constant(''))();
  TextColumn get nomineePhone => text().withDefault(const Constant(''))();
  TextColumn get nomineeRelationship =>
      text().withDefault(const Constant(''))();
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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
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
        },
      );
}
