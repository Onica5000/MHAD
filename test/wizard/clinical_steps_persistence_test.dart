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
import 'package:mhad/ui/wizard/steps/allergies_step.dart';
import 'package:mhad/ui/wizard/steps/procedures_research_step.dart';
import 'package:mhad/ui/wizard/steps/when_it_kicks_in_step.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// V4-H6 — validate/save/restore coverage for the wizard steps not already
/// covered by `wizard_steps_persistence_test.dart`, `people_i_trust_step_test`
/// and `instruction_serialization_test`:
///   - When it kicks in   (statutory triggers + preferred doctor)
///   - Procedures & research (ECT / experimental / drug-trial consent)
///   - Allergies          (add-on-tap persistence + restore)
///
/// Diagnoses / Medications stay at the repository level (see the scope note in
/// `wizard_steps_persistence_test.dart`); Review & sign is read-only.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;

  setUpAll(() => AppData.instance = AppData.fromJson(const {}));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
  });

  tearDown(() => db.close());

  // Bounded settle (see wizard_steps_persistence_test.dart for why not
  // pumpAndSettle): build + post-frame `_loadData` + one rebuild.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> pump(WidgetTester tester, Widget step) async {
    await tester.binding.setSurfaceSize(const Size(1200, 4000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: Scaffold(body: step)),
      ),
    );
    await settle(tester);
  }

  // Replace the tree with a fresh instance of the step, as the wizard does
  // when the user navigates back to it.
  Future<void> remount(WidgetTester tester, Widget step) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await pump(tester, step);
  }

  Future<bool> save(GlobalKey key) =>
      (key.currentState! as WizardStepMixin).validateAndSave();

  // ── When it kicks in ─────────────────────────────────────────────────────

  group('When-it-kicks-in step', () {
    const courtTrigger = 'A court determines I lack capacity';
    const commitTrigger = 'I am involuntarily committed';

    testWidgets('persists the chosen triggers and preferred doctor',
        (tester) async {
      final id = await repo.createDirective(FormType.combined);
      final key = GlobalKey<State<WhenItKicksInStep>>();
      await pump(tester, WhenItKicksInStep(key: key, directiveId: id));

      await tester.tap(find.text(courtTrigger));
      await tester.tap(find.text(commitTrigger));
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Name of Doctor'), 'Dr. Rivera');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Address / Phone Number'),
          '215-555-0100');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'In your own words (optional)'),
          'When I stop sleeping for 3 days.');
      await tester.pump();

      expect(await save(key), isTrue);

      final d = (await repo.getDirectiveById(id))!;
      expect(d.triggerTwoProfessionals, isFalse);
      expect(d.triggerCourtOrder, isTrue);
      expect(d.triggerInvoluntaryCommitment, isTrue);
      expect(d.preferredDoctorName, 'Dr. Rivera');
      expect(d.preferredDoctorContact, '215-555-0100');
      expect(d.effectiveCondition, 'When I stop sleeping for 3 days.');
    });

    testWidgets('restores stored triggers and round-trips them unchanged',
        (tester) async {
      final id = await repo.createDirective(FormType.declaration);
      await repo.updateEffectiveCondition(
        id,
        'Stored condition',
        twoProfessionals: true,
        courtOrder: false,
        involuntaryCommitment: true,
      );
      await repo.updatePreferredDoctor(id,
          name: 'Dr. Stored', contact: 'stored@example.com');

      final key = GlobalKey<State<WhenItKicksInStep>>();
      await pump(tester, WhenItKicksInStep(key: key, directiveId: id));

      final boxes = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .map((c) => c.value)
          .toList();
      expect(boxes, [true, false, true],
          reason: 'two-professionals / court / commitment restored in order');
      expect(find.text('Dr. Stored'), findsOneWidget);
      expect(find.text('Stored condition'), findsOneWidget);

      // Saving an untouched, restored step must not flip anything.
      await save(key);
      final d = (await repo.getDirectiveById(id))!;
      expect(d.triggerTwoProfessionals, isTrue);
      expect(d.triggerCourtOrder, isFalse);
      expect(d.triggerInvoluntaryCommitment, isTrue);
      expect(d.preferredDoctorName, 'Dr. Stored');
      expect(d.effectiveCondition, 'Stored condition');
    });
  });

  // ── Procedures & research ────────────────────────────────────────────────

  group('Procedures & research step', () {
    Future<DirectivePref> prefs(int id) async => (await repo.getPreferences(id))!;

    testWidgets('persists each of the three consent decisions independently',
        (tester) async {
      final id = await repo.createDirective(FormType.combined);
      final key = GlobalKey<State<ProceduresResearchStep>>();
      await pump(tester, ProceduresResearchStep(key: key, directiveId: id));

      // ECT → yes; experimental → conditional w/ text; drug trials → agent.
      await tester.tap(find.text('I consent to ECT'));
      await tester.pump();
      await tester.tap(find.text('I consent under specific conditions').at(1));
      await tester.pump();
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Conditions'), 'Non-invasive only');
      await tester.tap(find.text('My agent will decide').last);
      await tester.pump();

      expect(await save(key), isTrue);

      final p = await prefs(id);
      expect(p.ectConsent, ConsentOption.yes.name);
      expect(p.experimentalConsent, 'conditional:Non-invasive only');
      expect(p.drugTrialConsent, ConsentOption.agentDecides.name);
    });

    testWidgets('restores a conditional consent with its text',
        (tester) async {
      final id = await repo.createDirective(FormType.combined);
      await repo.upsertPreferences(DirectivePrefsCompanion(
        directiveId: Value(id),
        ectConsent: const Value('conditional:Only after two med trials fail'),
        experimentalConsent: Value(ConsentOption.no.name),
        drugTrialConsent: Value(ConsentOption.yes.name),
      ));

      final key = GlobalKey<State<ProceduresResearchStep>>();
      await pump(tester, ProceduresResearchStep(key: key, directiveId: id));

      expect(find.widgetWithText(TextFormField, 'Conditions'), findsOneWidget);
      expect(find.text('Only after two med trials fail'), findsOneWidget);

      // Re-save without touching anything: stored values survive verbatim.
      await save(key);
      final p = await prefs(id);
      expect(p.ectConsent, 'conditional:Only after two med trials fail');
      expect(p.experimentalConsent, ConsentOption.no.name);
      expect(p.drugTrialConsent, ConsentOption.yes.name);
    });

    testWidgets('declaration (no agent) hides every "agent will decide" option',
        (tester) async {
      final id = await repo.createDirective(FormType.declaration);
      await pump(tester, ProceduresResearchStep(directiveId: id));

      expect(find.text('My agent will decide about ECT'), findsNothing);
      expect(find.text('My agent will decide'), findsNothing);
      // The other three choices are still offered for each treatment.
      expect(find.text('I consent under specific conditions'), findsNWidgets(3));
    });

    testWidgets('combined form offers the agent option for all three',
        (tester) async {
      final id = await repo.createDirective(FormType.combined);
      await pump(tester, ProceduresResearchStep(directiveId: id));

      expect(find.text('My agent will decide about ECT'), findsOneWidget);
      expect(find.text('My agent will decide'), findsNWidgets(2));
    });
  });

  // ── Allergies ────────────────────────────────────────────────────────────

  group('Allergies step', () {
    testWidgets('Add allergy persists kind, substance, severity and reaction',
        (tester) async {
      final id = await repo.createDirective(FormType.combined);
      final key = GlobalKey<State<AllergiesStep>>();
      await pump(tester, AllergiesStep(key: key, directiveId: id));

      // Food (not Drug): a drug allergy opens the "never want" cross-add
      // prompt, which is its own flow.
      await tester.tap(find.text('Food'));
      await tester.pump();
      // Set the substance through the controller rather than enterText, so the
      // live NLM autocomplete search (a network call) never fires.
      tester
          .widget<TextField>(find.byType(TextField).first)
          .controller!
          .text = 'Peanuts';
      await tester.tap(find.text('Severe'));
      await tester.enterText(
          find.widgetWithText(TextField, 'e.g. Hives, Swelling, Throat closing'),
          'Throat closing');
      await tester.tap(find.text('Add allergy'));
      await settle(tester);

      final list = await repo.getAllergies(id);
      expect(list, hasLength(1));
      expect(list.single.substance, 'Peanuts');
      expect(list.single.kind, 'food');
      expect(list.single.severity, AllergySeverity.severe.name);
      expect(list.single.reactions, 'Throat closing');

      // The step saves on add; validateAndSave is a no-op that must not block.
      expect(await save(key), isTrue);
      expect(await repo.getAllergies(id), hasLength(1));
    });

    testWidgets('restores stored allergies after the step is remounted',
        (tester) async {
      final id = await repo.createDirective(FormType.combined);
      await repo.addAllergy(DirectiveAllergiesCompanion.insert(
        directiveId: id,
        kind: const Value('drug'),
        substance: const Value('Penicillin'),
        severity: Value(AllergySeverity.moderate.name),
        reactions: const Value('Hives'),
      ));

      await pump(tester, AllergiesStep(directiveId: id));
      expect(find.text('Penicillin'), findsOneWidget);
      // SectionLabel renders upper-case.
      expect(find.text('ADDED · 1 ALLERGY'), findsOneWidget);

      await remount(tester, AllergiesStep(directiveId: id));
      expect(find.text('Penicillin'), findsOneWidget);
    });
  });
}
