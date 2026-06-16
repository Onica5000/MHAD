import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/ai_context_builder.dart';
import 'package:mhad/ai/ai_pii_policy.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';

/// LOCK TEST for the hardcoded PII guarantee: the data handed to the external
/// AI as context ([buildAiFilledFields]) must NEVER contain user / agent /
/// guardian identity (see [AiPiiPolicy]). We seed every identity field with a
/// recognizable value plus the clinical fields the assistant IS allowed to see,
/// then assert the identity values are absent and the clinical values present.
/// If anyone later wires a PII field into the AI context, this fails.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
  });

  tearDown(() => db.close());

  test('AI context excludes all user/agent/guardian identity, keeps clinical',
      () async {
    final id = await repo.createDirective(FormType.combined);

    // ── PII that must NEVER reach the AI ──────────────────────────────────
    const piiValues = <String>[
      'Jane Q. Patient', // user fullName
      '1980-01-15', // dateOfBirth
      '742 Evergreen Terrace', // address
      'Apt 4B', // address2
      'Springfield', // city
      'Allegheny', // county
      '15001', // zip
      '412-555-0100', // user phone
      'John Trusted', // agent fullName
      '12 Agent Way', // agent address
      '412-555-0199', // agent cellPhone
      'Mary Guardian', // guardian nomineeFullName
      '99 Guard Street', // guardian nomineeAddress
      '412-555-0188', // guardian nomineePhone
    ];

    await repo.updatePersonalInfo(id,
        fullName: 'Jane Q. Patient',
        dateOfBirth: '1980-01-15',
        address: '742 Evergreen Terrace',
        address2: 'Apt 4B',
        city: 'Springfield',
        county: 'Allegheny',
        state: 'PA',
        zip: '15001',
        phone: '412-555-0100');

    await repo.upsertAgent(AgentsCompanion.insert(
      directiveId: id,
      agentType: 'primary',
      fullName: const Value('John Trusted'),
      relationship: const Value('Spouse'),
      address: const Value('12 Agent Way'),
      cellPhone: const Value('412-555-0199'),
    ));

    await repo.upsertGuardianNomination(GuardianNominationsCompanion.insert(
      directiveId: id,
      nomineeFullName: const Value('Mary Guardian'),
      nomineeAddress: const Value('99 Guard Street'),
      nomineePhone: const Value('412-555-0188'),
      nomineeRelationship: const Value('Sister'),
    ));

    // ── Clinical / preference data the assistant IS allowed to see ────────
    await repo.updateEffectiveCondition(
        id, 'When I cannot recognize my family');
    await repo.insertDiagnosis(DiagnosisEntriesCompanion.insert(
      directiveId: id,
      name: const Value('Bipolar I disorder'),
      icdCode: const Value('F31.9'),
    ));
    await repo.insertMedication(MedicationEntriesCompanion.insert(
      directiveId: id,
      entryType: 'preferred',
      medicationName: const Value('Lithium'),
    ));
    await repo.insertMedication(MedicationEntriesCompanion.insert(
      directiveId: id,
      entryType: 'exception',
      medicationName: const Value('Haloperidol'),
    ));

    final context = await buildAiFilledFields(repo, id);
    final blob = context.values.join('\n');

    // No identity value, anywhere in the context.
    for (final pii in piiValues) {
      expect(blob.contains(pii), isFalse,
          reason: 'PII "$pii" must never reach AI context');
    }
    // Relationship words are identity per policy too.
    expect(blob.contains('Spouse'), isFalse);
    expect(blob.contains('Sister'), isFalse);

    // The clinical context the assistant needs IS present (proves the builder
    // isn't simply returning an empty map).
    expect(blob, contains('Bipolar I disorder'));
    expect(blob, contains('Lithium'));
    expect(blob, contains('Haloperidol'));
    expect(blob, contains('When I cannot recognize my family'));

    // Sanity: the policy registry is non-empty so the contract is real.
    expect(AiPiiPolicy.allIdentityFields, isNotEmpty);
  });
}
