import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/steps/diagnoses_step.dart';
import 'package:mhad/ui/wizard/steps/medications_step.dart';
import 'package:mhad/ui/widgets/design/health_chip.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// V4-H6 — the last two wizard steps without widget-level save/restore
/// coverage. They used to be untestable here: Medications loaded through
/// `watchMedications(...).first` and Diagnoses re-created its Drift watch
/// stream on every build. Both now read/watch once (see the steps), which also
/// makes them deterministic under the test harness.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;
  var closed = false;

  setUpAll(() => AppData.instance = AppData.fromJson(const {}));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
    closed = false;
  });

  tearDown(() async {
    if (!closed) await db.close();
  });

  // Tests that mount a Drift watch-stream must unmount it and let Drift's
  // cancellation timer fire before closing — otherwise close() waits on it
  // forever (the "pending timer at teardown" that kept these steps untested).
  Future<void> unmountAndClose(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await db.close();
    closed = true;
  }

  Future<void> pump(WidgetTester tester, Widget step) async {
    await tester.binding.setSurfaceSize(const Size(1200, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: step),
        ),
      ),
    );
    await tester.pump(); // post-frame _loadData
    await tester.pump(const Duration(milliseconds: 400));
  }

  // Drift delivers watch-stream updates (and coalesces them) on timers; under
  // the widget-test fake clock those only fire when time is advanced.
  Future<void> letDriftDeliver(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> save(GlobalKey key) =>
      (key.currentState! as WizardStepMixin).validateAndSave();

  MedicationEntriesCompanion med(
    int id,
    MedicationEntryType type,
    String name, {
    String reason = '',
    String dosage = '',
    int order = 0,
  }) => MedicationEntriesCompanion.insert(
    directiveId: id,
    entryType: type.name,
    medicationName: Value(name),
    reason: Value(reason),
    dosage: Value(dosage),
    sortOrder: Value(order),
  );

  group('Medications step', () {
    testWidgets('restores every category and saves them back unchanged', (
      tester,
    ) async {
      final id = await repo.createDirective(FormType.combined);
      await repo.replaceMedications(id, [
        med(
          id,
          MedicationEntryType.current,
          'Sertraline',
          dosage: '50 mg daily',
          order: 0,
        ),
        med(
          id,
          MedicationEntryType.exception,
          'Haloperidol',
          reason: 'dystonia',
          order: 1,
        ),
        med(
          id,
          MedicationEntryType.limitation,
          'Lorazepam',
          reason: 'max 1 mg',
          order: 2,
        ),
        med(id, MedicationEntryType.preferred, 'Olanzapine', order: 3),
      ]);

      final key = GlobalKey<State<MedicationsStep>>();
      await pump(
        tester,
        MedicationsStep(key: key, directiveId: id, formType: FormType.combined),
      );

      for (final name in [
        'Sertraline',
        'Haloperidol',
        'Lorazepam',
        'Olanzapine',
      ]) {
        expect(
          find.widgetWithText(TextField, name),
          findsWidgets,
          reason: name,
        );
      }

      await save(key);
      final after = await repo.getMedications(id);
      expect(
        after
            .map((m) => (m.entryType, m.medicationName, m.reason, m.dosage))
            .toList(),
        [
          ('current', 'Sertraline', '', '50 mg daily'),
          ('exception', 'Haloperidol', 'dystonia', ''),
          ('limitation', 'Lorazepam', 'max 1 mg', ''),
          ('preferred', 'Olanzapine', '', ''),
        ],
      );
    });

    testWidgets('an edited name is saved', (tester) async {
      final id = await repo.createDirective(FormType.declaration);
      await repo.replaceMedications(id, [
        med(id, MedicationEntryType.exception, 'Haldol'),
      ]);
      final key = GlobalKey<State<MedicationsStep>>();
      await pump(
        tester,
        MedicationsStep(
          key: key,
          directiveId: id,
          formType: FormType.declaration,
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextField, 'Haldol').first,
        'Haloperidol',
      );
      await tester.pump();
      await save(key);

      expect(
        (await repo.getMedications(id)).single.medicationName,
        'Haloperidol',
      );
    });

    testWidgets('empty rows are not saved', (tester) async {
      final id = await repo.createDirective(FormType.declaration);
      final key = GlobalKey<State<MedicationsStep>>();
      await pump(
        tester,
        MedicationsStep(
          key: key,
          directiveId: id,
          formType: FormType.declaration,
        ),
      );

      final add = find.text('Add medication');
      expect(add, findsWidgets);
      await tester.tap(add.first);
      await tester.pump();
      await save(key);

      expect(await repo.getMedications(id), isEmpty);
    });
  });

  group('Diagnoses step', () {
    testWidgets('shows stored diagnoses and removing one deletes it', (
      tester,
    ) async {
      final id = await repo.createDirective(FormType.combined);
      await repo.insertDiagnosis(
        DiagnosisEntriesCompanion.insert(
          directiveId: id,
          icdCode: const Value('F31.9'),
          name: const Value('Bipolar disorder'),
          sortOrder: const Value(0),
        ),
      );
      await repo.insertDiagnosis(
        DiagnosisEntriesCompanion.insert(
          directiveId: id,
          icdCode: const Value('E11.9'),
          name: const Value('Type 2 diabetes'),
          sortOrder: const Value(1),
        ),
      );

      final key = GlobalKey<State<DiagnosesStep>>();
      await pump(tester, DiagnosesStep(key: key, directiveId: id));
      await letDriftDeliver(tester);

      expect(find.textContaining('Bipolar disorder'), findsWidgets);
      expect(find.textContaining('Type 2 diabetes'), findsWidgets);

      final bipolarChip = find.widgetWithText(HealthChip, 'Bipolar disorder');
      await tester.tap(
        find.descendant(of: bipolarChip, matching: find.byIcon(Icons.close)),
      );
      await letDriftDeliver(tester);

      final left = await repo.getDiagnoses(id);
      expect(left.map((d) => d.name), ['Type 2 diabetes']);
      expect(find.textContaining('Bipolar disorder'), findsNothing);
      await unmountAndClose(tester);
    });

    testWidgets('persists and restores the primary care doctor', (
      tester,
    ) async {
      final id = await repo.createDirective(FormType.combined);
      final key = GlobalKey<State<DiagnosesStep>>();
      await pump(tester, DiagnosesStep(key: key, directiveId: id));
      await letDriftDeliver(tester);

      await tester.enterText(
        find.widgetWithText(TextField, 'Doctor name'),
        'Dr. Rivera',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Phone'),
        '717-555-0100',
      );
      await save(key);

      final d = await repo.getDirectiveById(id);
      expect(d!.primaryDoctorName, 'Dr. Rivera');
      expect(d.primaryDoctorPhone, '717-555-0100');

      // Remount: fields come back.
      await tester.pumpWidget(const SizedBox());
      final key2 = GlobalKey<State<DiagnosesStep>>();
      await pump(tester, DiagnosesStep(key: key2, directiveId: id));
      await letDriftDeliver(tester);
      expect(find.widgetWithText(TextField, 'Dr. Rivera'), findsOneWidget);
      await unmountAndClose(tester);
    });
  });
}
