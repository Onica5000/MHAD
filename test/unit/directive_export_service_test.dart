import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/services/directive_export_service.dart';
import 'package:mhad/services/directive_file_codec.dart';

/// Guards the portable directive file: a populated directive must survive
/// export → (encrypted OR plaintext) → import including PII + agents, the
/// encrypted form must not be plaintext-readable, and bad content fails cleanly.
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

  Future<void> expectRoundTrip(int id, int newId) async {
    expect(newId, isNot(id), reason: 'import creates a fresh working copy');
    final restored = await repo.getDirectiveById(newId);
    expect(restored!.fullName, 'Jane Q. Public');
    expect(restored.city, 'Harrisburg');
    expect(restored.effectiveCondition, 'When two professionals agree');
    expect(restored.triggerTwoProfessionals, isTrue);
    final agents = await repo.getAgents(newId);
    expect(agents.single.fullName, 'Alex Trusted');
    expect(agents.single.cellPhone, '555-9999');
  }

  test('plaintext round-trip preserves PII + agents', () async {
    final id = await seedDirective();
    final bytes = await svc.buildFile(id, encrypted: false, nowMillis: 1);
    // Plaintext file is human-readable JSON.
    expect(utf8.decode(bytes), contains('Jane Q. Public'));
    expect(DirectiveFileCodec.isEncrypted(bytes), isFalse);
    final newId = await svc.importFile(bytes);
    await expectRoundTrip(id, newId);
  });

  test('encrypted round-trip preserves PII + agents and hides the plaintext',
      () async {
    final id = await seedDirective();
    final bytes = await svc.buildFile(id, encrypted: true, nowMillis: 2);
    // Obfuscated: starts with the MHAD magic and does NOT leak the name.
    expect(DirectiveFileCodec.isEncrypted(bytes), isTrue);
    expect(utf8.decode(bytes, allowMalformed: true), isNot(contains('Jane')));
    final newId = await svc.importFile(bytes);
    await expectRoundTrip(id, newId);
  });

  test('exportedAt is recoverable from both forms', () async {
    final id = await seedDirective();
    final plain = await svc.buildFile(id, encrypted: false, nowMillis: 111);
    final encd = await svc.buildFile(id, encrypted: true, nowMillis: 222);
    expect(DirectiveExportService.exportedAtOf(plain), 111);
    expect(DirectiveExportService.exportedAtOf(encd), 222);
  });

  test('non-directive content throws a typed import error', () {
    final junk = utf8.encode('not a directive file');
    expect(
      () => DirectiveExportService.parseFile(
          Uint8List.fromList(junk)),
      throwsA(isA<DirectiveImportException>()),
    );
  });
}
