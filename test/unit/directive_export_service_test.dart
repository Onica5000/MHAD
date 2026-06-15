import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/services/directive_export_service.dart';

/// Guards the portable directive file: a populated directive must survive
/// export → encrypt → import (round-trip) including PII + agents, and bad
/// passphrase / bad format must fail with a clear, typed error.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;
  late DirectiveExportService svc;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
    svc = DirectiveExportService(repo);
  });

  tearDown(() => db.close());

  Future<int> seedDirective() async {
    final id = await repo.createDirective(FormType.combined);
    await repo.updatePersonalInfo(
      id,
      fullName: 'Jane Q. Public',
      dateOfBirth: '1990-01-02',
      address: '123 Main St',
      address2: 'Apt 4',
      city: 'Harrisburg',
      county: 'Dauphin',
      state: 'PA',
      zip: '17101',
      phone: '555-1212',
    );
    await repo.upsertAgent(AgentsCompanion(
      directiveId: Value(id),
      agentType: const Value('primary'),
      fullName: const Value('Alex Trusted'),
      relationship: const Value('Sibling'),
      cellPhone: const Value('555-9999'),
    ));
    await repo.updateEffectiveCondition(id, 'When two professionals agree',
        twoProfessionals: true);
    return id;
  }

  test('full round-trip preserves PII, agents, and clinical fields', () async {
    final id = await seedDirective();

    final file =
        await svc.buildEncryptedFile(id, 'correct horse battery', nowMillis: 42);
    final newId = await svc.importEncryptedFile(file, 'correct horse battery');

    expect(newId, isNot(id), reason: 'import creates a fresh working copy');

    final restored = await repo.getDirectiveById(newId);
    expect(restored!.fullName, 'Jane Q. Public');
    expect(restored.dateOfBirth, '1990-01-02');
    expect(restored.city, 'Harrisburg');
    expect(restored.county, 'Dauphin');
    expect(restored.effectiveCondition, 'When two professionals agree');
    expect(restored.triggerTwoProfessionals, isTrue);

    final agents = await repo.getAgents(newId);
    expect(agents.length, 1);
    expect(agents.first.fullName, 'Alex Trusted');
    expect(agents.first.relationship, 'Sibling');
    expect(agents.first.cellPhone, '555-9999');
  });

  test('exportedAt is recoverable from the file', () async {
    final id = await seedDirective();
    final file = await svc.buildEncryptedFile(id, 'pw', nowMillis: 1234567);
    expect(DirectiveExportService.exportedAtOf(file, 'pw'), 1234567);
  });

  test('wrong passphrase throws a typed import error', () async {
    final id = await seedDirective();
    final file = await svc.buildEncryptedFile(id, 'right', nowMillis: 1);
    expect(
      () => DirectiveExportService.parseEncryptedFile(file, 'wrong'),
      throwsA(isA<DirectiveImportException>()),
    );
  });

  test('non-directive content throws a typed import error', () {
    expect(
      () => DirectiveExportService.parseEncryptedFile('not an envelope', 'pw'),
      throwsA(isA<DirectiveImportException>()),
    );
  });
}
