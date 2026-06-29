import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/steps/people_i_trust_step.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// H1 — wizard-step validate/save/restore coverage for the "People I trust"
/// (agents) step. This locks the regression fixed this session: collapsing an
/// agent card must NOT discard what was typed, because the wizard saves through
/// the embedded form's GlobalKey on navigate (the form stays mounted via
/// Offstage even when the card is collapsed).
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

  Future<GlobalKey<State<PeopleITrustStep>>> pumpStep(
      WidgetTester tester) async {
    // PeopleITrustStep is itself a ListView; give it a tall, bounded surface so
    // every field lays out and is hittable without scrolling.
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final key = GlobalKey<State<PeopleITrustStep>>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: PeopleITrustStep(key: key, directiveId: directiveId),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return key;
  }

  Future<void> save(GlobalKey<State<PeopleITrustStep>> key) =>
      (key.currentState! as WizardStepMixin).validateAndSave();

  testWidgets('saves the primary agent entered in the (expanded) card',
      (tester) async {
    final key = await pumpStep(tester);

    // The primary card auto-expands when no agent is on file, so the name
    // field is on screen. (`.first` = primary; the alternate card's field
    // also carries the "Full name" label.)
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name').first,
      'Jane Doe',
    );
    await save(key);

    final agents = await repo.getAgents(directiveId);
    final primary = agents.where((a) => a.agentType == 'primary').toList();
    expect(primary, hasLength(1));
    expect(primary.first.fullName, 'Jane Doe');
  });

  testWidgets('keeps the primary agent even after the card is collapsed',
      (tester) async {
    final key = await pumpStep(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Full name').first,
      'Jane Doe',
    );

    // Collapse the primary card — the exact scenario that used to drop the
    // typed data (the form unmounted and validateAndSave skipped it).
    await tester.tap(find.text('PRIMARY AGENT'));
    await tester.pumpAndSettle();

    await save(key);

    final agents = await repo.getAgents(directiveId);
    final primary = agents.where((a) => a.agentType == 'primary').toList();
    expect(primary, hasLength(1));
    expect(primary.first.fullName, 'Jane Doe',
        reason: 'collapsing the card must not discard the entered agent');
  });
}
