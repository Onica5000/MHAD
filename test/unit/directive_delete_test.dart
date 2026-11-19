import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';

/// Deleting really deletes. The schema's `ON DELETE CASCADE` never runs (the
/// database doesn't set `PRAGMA foreign_keys = ON`), so a deleted directive
/// used to leave its agents, medications, allergies and the rest in memory,
/// and "Start over" left every allergy behind — while the privacy policy said
/// deleting removes all of it.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
  });
  tearDown(() => db.close());

  /// One row in every table that belongs to directive [id] (raw SQL: the
  /// other columns take their defaults).
  Future<void> fill(int id) async {
    const extra = {
      'agents': ('agent_type', 'primary'),
      'medication_entries': ('entry_type', 'current'),
      'witnesses': ('witness_number', 1),
    };
    for (final t in repo.directiveChildTables) {
      final e = extra[t.actualTableName];
      await db.customStatement(
          e == null
              ? 'INSERT INTO ${t.actualTableName} (directive_id) VALUES (?)'
              : 'INSERT INTO ${t.actualTableName} (directive_id, ${e.$1}) '
                  'VALUES (?, ?)',
          [id, if (e != null) e.$2]);
    }
  }

  Future<int> rowsFor(int id) async {
    var n = 0;
    for (final t in repo.directiveChildTables) {
      final r = await db.customSelect(
          'SELECT COUNT(*) AS c FROM ${t.actualTableName} WHERE directive_id = ?',
          variables: [Variable<int>(id)]).getSingle();
      n += r.read<int>('c');
    }
    return n;
  }

  test('every table with a directive_id is covered', () {
    final covered = repo.directiveChildTables.map((t) => t.actualTableName);
    final withDirectiveId = db.allTables
        .where((t) => t.$columns.any((c) => c.name == 'directive_id'))
        .map((t) => t.actualTableName);
    expect(covered.toSet(), withDirectiveId.toSet());
  });

  test('deleting a directive removes everything that belongs to it',
      () async {
    final a = await repo.createDirective(FormType.combined);
    final b = await repo.createDirective(FormType.combined);
    await fill(a);
    await fill(b);
    final before = await rowsFor(a);
    expect(before, greaterThanOrEqualTo(repo.directiveChildTables.length));

    await repo.deleteDirective(a);
    expect(await repo.getDirectiveById(a), isNull);
    expect(await rowsFor(a), 0);
    expect(await rowsFor(b), greaterThanOrEqualTo(repo.directiveChildTables.length),
        reason: 'the other directive is untouched');
  });

  test('"Start over" leaves no rows anywhere, allergies included', () async {
    final a = await repo.createDirective(FormType.combined);
    await fill(a);
    await repo.deleteAllDirectives();
    for (final t in [...repo.directiveChildTables, db.directives]) {
      final r = await db
          .customSelect('SELECT COUNT(*) AS c FROM ${t.actualTableName}')
          .getSingle();
      expect(r.read<int>('c'), 0, reason: t.actualTableName);
    }
  });
}
