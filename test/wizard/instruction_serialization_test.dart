import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/steps/additional_instructions_step.dart';
import 'package:mhad/ui/wizard/steps/treatment_facility_step.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// Round-trip locks for the two steps that pack multiple sub-fields into a
/// single DB column with hand-rolled parse/build:
///   - additional instructions: de-escalation/triggers/reproductive → `other`,
///     and release/withhold/other → `recordsDisclosure` (labeled blocks);
///   - treatment facility: `Name | Location` lines + the `specify:<text>`
///     roommate encoding.
/// seed → load(parse) → save(rebuild) must reproduce the stored value exactly;
/// a drift here silently mislabels a user's crisis instructions or facilities.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;
  late int directiveId;

  setUpAll(() => AppData.instance = AppData.fromJson(const {}));

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
    directiveId = await repo.createDirective(FormType.combined);
  });

  tearDown(() => db.close());

  Future<void> pumpAndSave(WidgetTester tester, Widget step, GlobalKey key) async {
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: Scaffold(body: step)),
      ),
    );
    await tester.pump(); // fire post-frame _loadData (parse)
    await tester.pump(const Duration(milliseconds: 400)); // load completes
    await (key.currentState! as WizardStepMixin).validateAndSave(); // rebuild
  }

  testWidgets('additional-instructions packed columns survive a load→save',
      (tester) async {
    const other = '[DE-ESCALATION] deep breathing\n'
        '[TRIGGERS] loud rooms\n'
        'my plain other note';
    const records = 'Authorized to receive my records: my agent\n\n'
        'Not authorized to receive my records: my ex';

    await repo.upsertAdditionalInstructions(AdditionalInstructionsTableCompanion(
      directiveId: Value(directiveId),
      crisisIntervention: const Value('calming music'),
      other: const Value(other),
      recordsDisclosure: const Value(records),
    ));

    final key = GlobalKey<State<AdditionalInstructionsStep>>();
    await pumpAndSave(
        tester, AdditionalInstructionsStep(key: key, directiveId: directiveId), key);

    final data = await repo.getAdditionalInstructions(directiveId);
    expect(data?.other, other, reason: 'de-escalation/triggers/other tags');
    expect(data?.recordsDisclosure, records, reason: 'records blocks');
    expect(data?.crisisIntervention, 'calming music');
  });

  testWidgets('treatment-facility facilities + roommate encoding survive a load→save',
      (tester) async {
    await repo.upsertPreferences(DirectivePrefsCompanion(
      directiveId: Value(directiveId),
      preferredFacilityName: const Value('Hospital A | Philadelphia\nClinic B'),
      avoidFacilityName: const Value('Bad Place'),
      roomPreferences: const Value('singleRoom,sameGenderRoommate'),
      roommateGenderMatch: const Value('specify:women only'),
      roomPreferencesNote: const Value('quiet floor'),
    ));

    final key = GlobalKey<State<TreatmentFacilityStep>>();
    await pumpAndSave(
        tester, TreatmentFacilityStep(key: key, directiveId: directiveId), key);

    final p = await repo.getPreferences(directiveId);
    expect(p?.preferredFacilityName, 'Hospital A | Philadelphia\nClinic B');
    expect(p?.avoidFacilityName, 'Bad Place');
    expect(p?.roomPreferences.split(','), containsAll(['singleRoom', 'sameGenderRoommate']));
    expect(p?.roommateGenderMatch, 'specify:women only');
    expect(p?.roomPreferencesNote, 'quiet floor');
  });
}
