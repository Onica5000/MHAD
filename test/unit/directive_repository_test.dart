import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';

void main() {
  late AppDatabase db;
  late DirectiveRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
  });

  tearDown(() => db.close());

  group('DirectiveRepository', () {
    test('watchAllDirectives emits empty list initially', () async {
      final directives = await repo.watchAllDirectives().first;
      expect(directives, isEmpty);
    });

    test('createDirective creates a directive with correct formType', () async {
      final id = await repo.createDirective(FormType.combined);
      expect(id, isPositive);

      final directive = await repo.getDirectiveById(id);
      expect(directive, isNotNull);
      expect(directive!.formType, 'combined');
      expect(directive.status, 'draft');
    });

    test('createDirective sets correct status for declaration form', () async {
      final id = await repo.createDirective(FormType.declaration);
      final directive = await repo.getDirectiveById(id);
      expect(directive!.formType, 'declaration');
      expect(directive.status, 'draft');
    });

    test('watchAllDirectives emits all created directives', () async {
      await repo.createDirective(FormType.combined);
      await repo.createDirective(FormType.declaration);
      await repo.createDirective(FormType.poa);

      final directives = await repo.watchAllDirectives().first;
      expect(directives, hasLength(3));
    });

    test('getDirectiveById returns null for non-existent ID', () async {
      final directive = await repo.getDirectiveById(9999);
      expect(directive, isNull);
    });

    test('deleteDirective removes the directive', () async {
      final id = await repo.createDirective(FormType.combined);
      await repo.deleteDirective(id);

      final directive = await repo.getDirectiveById(id);
      expect(directive, isNull);
    });

    test('watchAllDirectives updates after delete', () async {
      final id = await repo.createDirective(FormType.combined);
      await repo.createDirective(FormType.declaration);

      var directives = await repo.watchAllDirectives().first;
      expect(directives, hasLength(2));

      await repo.deleteDirective(id);

      directives = await repo.watchAllDirectives().first;
      expect(directives, hasLength(1));
    });

    test('updatePersonalInfo persists all fields', () async {
      final id = await repo.createDirective(FormType.combined);
      await repo.updatePersonalInfo(id,
          fullName: 'Jane Doe',
          dateOfBirth: '01/15/1980',
          address: '123 Main St',
          city: 'Philadelphia',
          state: 'PA',
          zip: '19103',
          phone: '215-555-1234');

      final directive = await repo.getDirectiveById(id);
      expect(directive!.fullName, 'Jane Doe');
      expect(directive.dateOfBirth, '01/15/1980');
      expect(directive.city, 'Philadelphia');
      expect(directive.state, 'PA');
    });

    test('getAgents returns empty list for new directive', () async {
      final id = await repo.createDirective(FormType.combined);
      final agents = await repo.getAgents(id);
      expect(agents, isEmpty);
    });

    test('upsertAgent creates and can be retrieved', () async {
      final id = await repo.createDirective(FormType.combined);
      await repo.upsertAgent(AgentsCompanion.insert(
        directiveId: id,
        agentType: 'primary',
        fullName: const Value('Mary Agent'),
        relationship: const Value('Sister'),
        address: const Value('99 Agent Ave'),
        homePhone: const Value('570-555-3333'),
        workPhone: const Value(''),
        cellPhone: const Value(''),
      ));

      final agents = await repo.getAgents(id);
      expect(agents, hasLength(1));
      expect(agents.first.fullName, 'Mary Agent');
      expect(agents.first.agentType, 'primary');
    });

    test('watchMedications emits empty list initially', () async {
      final id = await repo.createDirective(FormType.combined);
      final meds = await repo.watchMedications(id).first;
      expect(meds, isEmpty);
    });

    test('insertMedication and watchMedications returns correct entry', () async {
      final id = await repo.createDirective(FormType.combined);
      await repo.insertMedication(MedicationEntriesCompanion.insert(
        directiveId: id,
        entryType: 'exception',
        medicationName: const Value('Medication A'),
        reason: const Value('Causes adverse reaction'),
      ));

      final meds = await repo.watchMedications(id).first;
      expect(meds, hasLength(1));
      expect(meds.first.medicationName, 'Medication A');
      expect(meds.first.entryType, 'exception');
    });

    test('getGuardianNomination returns null for new directive', () async {
      final id = await repo.createDirective(FormType.combined);
      final guardian = await repo.getGuardianNomination(id);
      expect(guardian, isNull);
    });

    test('upsertGuardianNomination creates nomination', () async {
      final id = await repo.createDirective(FormType.combined);
      await repo.upsertGuardianNomination(GuardianNominationsCompanion.insert(
        directiveId: id,
        nomineeFullName: const Value('Bob Guardian'),
        nomineeRelationship: const Value('Brother'),
        nomineeAddress: const Value('50 Guardian Rd'),
        nomineePhone: const Value('717-555-9999'),
      ));

      final guardian = await repo.getGuardianNomination(id);
      expect(guardian, isNotNull);
      expect(guardian!.nomineeFullName, 'Bob Guardian');
    });

    test('getWitnesses returns empty list for new directive', () async {
      final id = await repo.createDirective(FormType.combined);
      final witnesses = await repo.getWitnesses(id);
      expect(witnesses, isEmpty);
    });

    test('upsertWitness creates witness record', () async {
      final id = await repo.createDirective(FormType.combined);
      await repo.upsertWitness(WitnessesCompanion.insert(
        directiveId: id,
        witnessNumber: 1,
        fullName: const Value('Witness One'),
        address: const Value('1 Witness Way'),
      ));

      final witnesses = await repo.getWitnesses(id);
      expect(witnesses, hasLength(1));
      expect(witnesses.first.fullName, 'Witness One');
      expect(witnesses.first.witnessNumber, 1);
    });
  });
}
