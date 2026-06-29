import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/steps/guardian_nomination_step.dart';
import 'package:mhad/ui/wizard/steps/personal_info_step.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// H1 — validate/save/restore coverage for more consolidated wizard steps
/// (beyond People-I-trust). Each follows the same contract: enter a field, the
/// wizard calls the step's `validateAndSave` through its GlobalKey on navigate,
/// and the value must be persisted to the repository.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;
  late int directiveId;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
    directiveId = await repo.createDirective(FormType.combined);
  });

  tearDown(() => db.close());

  Future<void> pump(WidgetTester tester, Widget step) async {
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: Scaffold(body: step)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> save(GlobalKey key) =>
      (key.currentState! as WizardStepMixin).validateAndSave();

  testWidgets('About-you step persists the full legal name', (tester) async {
    final key = GlobalKey<State<PersonalInfoStep>>();
    await pump(tester, PersonalInfoStep(key: key, directiveId: directiveId));

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full legal name *'),
      'Test Person',
    );
    await save(key);

    final d = await repo.getDirectiveById(directiveId);
    expect(d?.fullName, 'Test Person');
  });

  testWidgets('Guardian step persists the nominee name', (tester) async {
    final key = GlobalKey<State<GuardianNominationStep>>();
    await pump(
        tester, GuardianNominationStep(key: key, directiveId: directiveId));

    // The nominee name field only appears once "Someone different" is chosen.
    await tester.tap(find.text('Someone different'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominee full name'),
      'Guard Ian',
    );
    await save(key);

    final g = await repo.getGuardianNomination(directiveId);
    expect(g?.nomineeFullName, 'Guard Ian');
  });
}
