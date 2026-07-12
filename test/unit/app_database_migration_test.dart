import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

/// Locks the hand-written schema migrations in [AppDatabase.migration].
///
/// Every migration block is additive and guards on the ORIGINAL `from`
/// version only, so upgrading a v1 database to the current version executes
/// every statement in `onUpgrade` — including the guardian_relation backfill
/// UPDATE and the out-of-order `from < 11` / `from < 9` blocks. The test:
///
///  1. builds the reference schema by letting drift create a fresh database;
///  2. synthesizes a REAL v1 database (reference schema minus every column
///     and table the migrations add — the map below is the review-verified
///     inventory of what each schema version added), seeds it with data,
///     and stamps `PRAGMA user_version = 1`;
///  3. re-opens it through [AppDatabase], which runs `onUpgrade(1, current)`;
///  4. asserts the migrated schema is IDENTICAL to the fresh-create schema
///     (tables, per-table columns incl. type/NOT NULL/default, indexes) and
///     that the seeded data survived with correct defaults + backfills.
///
/// If a future schema version adds columns/tables, this test fails until
/// [_columnsAddedByMigrations] / [_tablesAddedByMigrations] are updated —
/// that is deliberate: it forces the new migration through this harness.

/// Tables that did not exist at v1 (created by later migrations).
const _tablesAddedByMigrations = {
  'diagnosis_entries', // v6
  'directive_allergies', // v9
};

/// Columns added to v1 tables by later migrations (drift snake_case names).
const _columnsAddedByMigrations = <String, Set<String>>{
  'directives': {
    'address2', // v3
    'last_step_index', // v4
    'preferred_doctor_name', 'preferred_doctor_contact', // v5
    'county', 'trigger_two_professionals', 'trigger_court_order',
    'trigger_involuntary_commitment', // v13
    'primary_doctor_name', 'primary_doctor_specialty',
    'primary_doctor_phone', // v15
  },
  'agents': {
    'accepted_at', 'acceptance_notes', // v11
    'address2', 'city', 'state', 'zip', // v19
  },
  'medication_entries': {
    'dosage', // v20
  },
  'directive_prefs': {
    'room_preferences', // v8
    'crisis_plan_json', 'self_binding_enabled', // v10
    'room_preferences_note', // v12
    'roommate_gender_match', // v16
    'side_effects_json', // v18
  },
  'witnesses': {
    'phone', // v7
    'address2', 'city', 'state', 'zip', // v19
  },
  'guardian_nominations': {
    'guardian_can_revoke', // v5
    'guardian_relation', // v8
    'guardian_can_change_agent', 'guardian_must_consult_agent', // v14
    'guardian_can_revoke_note', 'guardian_can_change_agent_note',
    'guardian_must_consult_agent_note', // v17
    'nominee_address2', 'nominee_city', 'nominee_state', 'nominee_zip', // v19
  },
  'additional_instructions': {},
};

/// One column's identity for schema comparison.
String _columnKey(Map<String, Object?> c) =>
    '${c['name']}|${c['type']}|${c['notnull']}|${c['dflt_value']}|${c['pk']}';

/// Schema snapshot: table name → set of column keys, plus the named indexes.
class _Schema {
  final Map<String, Set<String>> tables;
  final Set<String> indexes;
  _Schema(this.tables, this.indexes);
}

Future<_Schema> _snapshot(AppDatabase db) async {
  final tableRows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'")
      .get();
  final tables = <String, Set<String>>{};
  for (final row in tableRows) {
    final name = row.data['name'] as String;
    final cols = await db.customSelect('PRAGMA table_info($name)').get();
    tables[name] = cols.map((c) => _columnKey(c.data)).toSet();
  }
  final indexRows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'index' "
          "AND name NOT LIKE 'sqlite_%'")
      .get();
  final indexes = indexRows.map((r) => r.data['name'] as String).toSet();
  return _Schema(tables, indexes);
}

/// Raw column metadata of a fresh (current-version) database, used to derive
/// the v1 DDL.
Future<Map<String, List<Map<String, Object?>>>> _referenceColumns(
    AppDatabase db) async {
  final tableRows = await db
      .customSelect("SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%'")
      .get();
  final result = <String, List<Map<String, Object?>>>{};
  for (final row in tableRows) {
    final name = row.data['name'] as String;
    final cols = await db.customSelect('PRAGMA table_info($name)').get();
    result[name] = cols.map((c) => Map<String, Object?>.from(c.data)).toList();
  }
  return result;
}

/// Builds `CREATE TABLE` DDL for the v1 version of [table]: the current
/// columns minus everything the migrations added.
String _v1CreateTable(String table, List<Map<String, Object?>> columns) {
  final removed = _columnsAddedByMigrations[table] ?? const <String>{};
  final defs = <String>[];
  for (final c in columns) {
    final name = c['name'] as String;
    if (removed.contains(name)) continue;
    final type = c['type'] as String;
    if (c['pk'] == 1) {
      // Match drift's generated DDL exactly (incl. explicit NOT NULL) so the
      // schema-parity check compares like for like.
      defs.add('$name $type NOT NULL PRIMARY KEY AUTOINCREMENT');
      continue;
    }
    final notNull = c['notnull'] == 1 ? ' NOT NULL' : '';
    final dflt = c['dflt_value'] != null ? ' DEFAULT ${c['dflt_value']}' : '';
    defs.add('$name $type$notNull$dflt');
  }
  return 'CREATE TABLE $table (${defs.join(', ')})';
}

void main() {
  // This test deliberately opens several AppDatabase instances (reference +
  // migrated), each over its own executor — silence drift's multi-instance
  // warning so real failures stay readable.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('v1 database upgrades to the current schema with data intact',
      () async {
    // 1. Reference: what a fresh install looks like today.
    final freshDb = AppDatabase(NativeDatabase.memory());
    await freshDb.customSelect('SELECT 1').get(); // force create
    final reference = await _snapshot(freshDb);
    final referenceColumns = await _referenceColumns(freshDb);
    await freshDb.close();

    // Guard: if a migration adds a table/column this test doesn't know
    // about, fail with a pointed message instead of a confusing DDL error.
    expect(
      reference.tables.keys.toSet(),
      _tablesAddedByMigrations.union(_columnsAddedByMigrations.keys.toSet()),
      reason: 'New table detected — update _tablesAddedByMigrations / '
          '_columnsAddedByMigrations in this test to cover its migration.',
    );

    // 2. Synthesize a real v1 database and seed it.
    final rawDb = raw.sqlite3.openInMemory();
    for (final entry in referenceColumns.entries) {
      if (_tablesAddedByMigrations.contains(entry.key)) continue;
      rawDb.execute(_v1CreateTable(entry.key, entry.value));
    }
    rawDb.execute(
        "INSERT INTO directives (form_type, created_at, updated_at, full_name)"
        " VALUES ('combined', 111, 222, 'Test Person')");
    rawDb.execute(
        "INSERT INTO directives (form_type, created_at, updated_at) "
        "VALUES ('declaration', 333, 444)");
    rawDb.execute(
        "INSERT INTO agents (directive_id, agent_type, full_name) "
        "VALUES (1, 'primary', 'Agent Smith')");
    rawDb.execute(
        "INSERT INTO medication_entries (directive_id, entry_type, "
        "medication_name) VALUES (1, 'current', 'Lamotrigine')");
    rawDb.execute('INSERT INTO directive_prefs (directive_id) VALUES (1)');
    rawDb.execute(
        "INSERT INTO additional_instructions (directive_id, activities) "
        "VALUES (1, 'Morning walks')");
    rawDb.execute(
        "INSERT INTO witnesses (directive_id, witness_number, full_name) "
        "VALUES (1, 1, 'Witness One')");
    // Guardian rows exercise the v8 guardian_relation backfill: a named
    // nominee must become 'different', an empty row 'noPreference'.
    rawDb.execute(
        "INSERT INTO guardian_nominations (directive_id, nominee_full_name) "
        "VALUES (1, 'Guard Ian')");
    rawDb.execute('INSERT INTO guardian_nominations (directive_id) VALUES (2)');
    rawDb.execute('PRAGMA user_version = 1');

    // 3. Re-open through drift → runs onUpgrade(1, current).
    final upgradedDb = AppDatabase(NativeDatabase.opened(rawDb));
    await upgradedDb.customSelect('SELECT 1').get();

    // 4a. Schema parity with a fresh create.
    final migrated = await _snapshot(upgradedDb);
    expect(migrated.tables.keys.toSet(), reference.tables.keys.toSet(),
        reason: 'migrated table set must match a fresh create');
    for (final table in reference.tables.keys) {
      expect(migrated.tables[table], reference.tables[table],
          reason: 'columns of $table after migration must match a fresh '
              'create (name/type/notnull/default/pk)');
    }
    expect(migrated.indexes, reference.indexes,
        reason: 'indexes after migration must match a fresh create');

    final version =
        await upgradedDb.customSelect('PRAGMA user_version').getSingle();
    expect(version.data.values.single, upgradedDb.schemaVersion);

    // 4b. Seeded data survived with correct defaults + backfills.
    final directive = await upgradedDb
        .customSelect('SELECT * FROM directives WHERE id = 1')
        .getSingle();
    expect(directive.data['full_name'], 'Test Person');
    expect(directive.data['created_at'], 111);
    expect(directive.data['state'], 'PA');
    expect(directive.data['last_step_index'], 0); // v4 default
    expect(directive.data['county'], ''); // v13 default

    final med = await upgradedDb
        .customSelect('SELECT * FROM medication_entries WHERE id = 1')
        .getSingle();
    expect(med.data['medication_name'], 'Lamotrigine');
    expect(med.data['dosage'], ''); // v20 default

    final agent = await upgradedDb
        .customSelect('SELECT * FROM agents WHERE id = 1')
        .getSingle();
    expect(agent.data['full_name'], 'Agent Smith');
    expect(agent.data['accepted_at'], isNull); // v11 nullable default

    final namedGuardian = await upgradedDb
        .customSelect('SELECT * FROM guardian_nominations WHERE id = 1')
        .getSingle();
    expect(namedGuardian.data['guardian_relation'], 'different',
        reason: 'v8 backfill: a named nominee keeps relation=different');
    final emptyGuardian = await upgradedDb
        .customSelect('SELECT * FROM guardian_nominations WHERE id = 2')
        .getSingle();
    expect(emptyGuardian.data['guardian_relation'], 'noPreference',
        reason: 'v8 backfill: an empty nomination becomes noPreference');

    final instructions = await upgradedDb
        .customSelect('SELECT * FROM additional_instructions WHERE id = 1')
        .getSingle();
    expect(instructions.data['activities'], 'Morning walks');

    final witness = await upgradedDb
        .customSelect('SELECT * FROM witnesses WHERE id = 1')
        .getSingle();
    expect(witness.data['full_name'], 'Witness One');
    expect(witness.data['phone'], ''); // v7 default

    await upgradedDb.close();
  });

  test('intermediate-version upgrades succeed (v10 and v19 snapshots)',
      () async {
    // The blocks are independent (each guards on the original `from` and no
    // block reads a column another block adds), so the v1 run above executes
    // the superset. This test additionally replays two representative
    // intermediate starts — v10 (inside the out-of-order from<11/from<9
    // neighborhood) and v19 (only the newest block runs) — by synthesizing
    // the vN schema (v1 + everything added at or before vN) and upgrading.
    final freshDb = AppDatabase(NativeDatabase.memory());
    await freshDb.customSelect('SELECT 1').get();
    final reference = await _snapshot(freshDb);
    final referenceColumns = await _referenceColumns(freshDb);
    await freshDb.close();

    // What each table gained AFTER version N (to subtract from current).
    Set<String> addedAfter(String table, int n) {
      const byVersion = <String, Map<String, int>>{
        'directives': {
          'address2': 3, 'last_step_index': 4, 'preferred_doctor_name': 5,
          'preferred_doctor_contact': 5, 'county': 13,
          'trigger_two_professionals': 13, 'trigger_court_order': 13,
          'trigger_involuntary_commitment': 13, 'primary_doctor_name': 15,
          'primary_doctor_specialty': 15, 'primary_doctor_phone': 15,
        },
        'agents': {
          'accepted_at': 11, 'acceptance_notes': 11,
          'address2': 19, 'city': 19, 'state': 19, 'zip': 19,
        },
        'medication_entries': {'dosage': 20},
        'directive_prefs': {
          'room_preferences': 8, 'crisis_plan_json': 10,
          'self_binding_enabled': 10, 'room_preferences_note': 12,
          'roommate_gender_match': 16, 'side_effects_json': 18,
        },
        'witnesses': {
          'phone': 7, 'address2': 19, 'city': 19, 'state': 19, 'zip': 19,
        },
        'guardian_nominations': {
          'guardian_can_revoke': 5, 'guardian_relation': 8,
          'guardian_can_change_agent': 14, 'guardian_must_consult_agent': 14,
          'guardian_can_revoke_note': 17, 'guardian_can_change_agent_note': 17,
          'guardian_must_consult_agent_note': 17, 'nominee_address2': 19,
          'nominee_city': 19, 'nominee_state': 19, 'nominee_zip': 19,
        },
      };
      final versions = byVersion[table] ?? const {};
      return {
        for (final e in versions.entries)
          if (e.value > n) e.key
      };
    }

    const tableCreatedIn = {'diagnosis_entries': 6, 'directive_allergies': 9};

    for (final startVersion in [10, 19]) {
      final rawDb = raw.sqlite3.openInMemory();
      for (final entry in referenceColumns.entries) {
        final createdIn = tableCreatedIn[entry.key] ?? 1;
        if (createdIn > startVersion) continue;
        final removed = addedAfter(entry.key, startVersion);
        final defs = <String>[];
        for (final c in entry.value) {
          final name = c['name'] as String;
          if (removed.contains(name)) continue;
          if (c['pk'] == 1) {
            defs.add('$name ${c['type']} NOT NULL PRIMARY KEY AUTOINCREMENT');
            continue;
          }
          defs.add('$name ${c['type']}'
              '${c['notnull'] == 1 ? ' NOT NULL' : ''}'
              '${c['dflt_value'] != null ? ' DEFAULT ${c['dflt_value']}' : ''}');
        }
        rawDb.execute('CREATE TABLE ${entry.key} (${defs.join(', ')})');
      }
      rawDb.execute(
          "INSERT INTO directives (form_type, created_at, updated_at, "
          "full_name) VALUES ('poa', 1, 2, 'Interim Person')");
      rawDb.execute('PRAGMA user_version = $startVersion');

      final upgradedDb = AppDatabase(NativeDatabase.opened(rawDb));
      await upgradedDb.customSelect('SELECT 1').get();

      final migrated = await _snapshot(upgradedDb);
      for (final table in reference.tables.keys) {
        expect(migrated.tables[table], reference.tables[table],
            reason: 'v$startVersion → current: columns of $table must match '
                'a fresh create');
      }
      final person = await upgradedDb
          .customSelect('SELECT full_name FROM directives WHERE id = 1')
          .getSingle();
      expect(person.data['full_name'], 'Interim Person');
      await upgradedDb.close();
    }
  });
}
