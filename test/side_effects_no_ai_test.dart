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
import 'package:mhad/ui/side_effects/side_effects_screen.dart';
import 'package:mhad/ui/widgets/fda_label_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Side effects work without AI: every current medication gets its official
/// FDA label card (current + limited), and the AI checklist is optional.
void main() {
  setUpAll(() => AppData.instance = AppData.fromJson(const {}));

  testWidgets('no AI key: FDA label cards per current med; AI is optional', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DirectiveRepository(db);
    final id = (await tester.runAsync(() async {
      final id = await repo.createDirective(FormType.combined);
      MedicationEntriesCompanion med(MedicationEntryType t, String n, int o) =>
          MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: t.name,
            medicationName: Value(n),
            sortOrder: Value(o),
          );
      await repo.replaceMedications(id, [
        med(MedicationEntryType.current, 'Sertraline', 0),
        med(MedicationEntryType.current, 'Lithium', 1),
        // Accepted with limits: gets a card too.
        med(MedicationEntryType.limitation, 'Olanzapine', 2),
        // Refused / preferred-if-treated: no card.
        med(MedicationEntryType.exception, 'Haloperidol', 3),
        med(MedicationEntryType.preferred, 'Quetiapine', 4),
      ]);
      return id;
    }))!;

    await tester.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SideEffectsScreen(directiveId: id),
        ),
      ),
    );
    // _load runs real DB futures.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Want a short checklist? (optional)'), findsOneWidget);
    expect(
      find.text('Official FDA labels'.toUpperCase()).evaluate().isNotEmpty ||
          find.text('Official FDA labels').evaluate().isNotEmpty,
      isTrue,
    );
    final cards = tester.widgetList<FdaLabelCard>(find.byType(FdaLabelCard));
    expect(cards.map((c) => c.medName), [
      'Sertraline',
      'Lithium',
      'Olanzapine',
    ]);
    // The old "set up AI to check side effects" gate is gone.
    expect(find.textContaining('Set up AI to check'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await db.close();
  });

  testWidgets('only limited medications: label cards, no AI checklist box', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    final repo = DirectiveRepository(db);
    final id = (await tester.runAsync(() async {
      final id = await repo.createDirective(FormType.combined);
      await repo.replaceMedications(id, [
        MedicationEntriesCompanion.insert(
          directiveId: id,
          entryType: MedicationEntryType.limitation.name,
          medicationName: const Value('Olanzapine'),
          sortOrder: const Value(0),
        ),
      ]);
      return id;
    }))!;
    await tester.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SideEffectsScreen(directiveId: id),
        ),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 200)),
    );
    await tester.pumpAndSettle();

    final cards = tester.widgetList<FdaLabelCard>(find.byType(FdaLabelCard));
    expect(cards.map((c) => c.medName), ['Olanzapine']);
    expect(find.text('Want a short checklist? (optional)'), findsNothing);
    expect(find.textContaining('Add the medications you'), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await db.close();
  });
}
