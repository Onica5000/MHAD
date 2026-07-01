import 'dart:async';

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
import 'package:mhad/ui/wizard/steps/treatment_facility_step.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

/// H1 (V4-H6) — validate/save coverage for consolidated wizard steps beyond
/// People-I-trust. Each drives the step's local inputs, calls the step's
/// `validateAndSave` through its GlobalKey (the wizard does this on navigate),
/// and asserts the value reached the repository.
///
/// Scope note: only steps with a clean, deterministic save path are covered at
/// the widget level here. Steps whose `_loadData` awaits a Drift watch-stream
/// (Medications) or whose build subscribes to one (Diagnoses) entangle with
/// Drift's async stream machinery in the widget-test harness (a never-firing
/// `.first`, or a pending coalescing timer at teardown). Their *persistence*
/// contracts — including the unique-`directiveId` upsert behavior — are covered
/// deterministically at the repository level in
/// `test/unit/directive_repository_upsert_test.dart` instead.
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

  // Bounded settle: a couple of fixed frames instead of `pumpAndSettle()`. Some
  // steps mount widgets that animate or schedule timers indefinitely;
  // pumpAndSettle would wait on them for its full 10-minute default timeout.
  // Fixed pumps let initState's post-frame `_loadData` (a synchronous in-memory
  // DB read on this isolate) and one rebuild flush, which is all these need.
  Future<void> settle(WidgetTester tester) async {
    await tester.pump(); // build + fire post-frame callbacks
    await tester.pump(const Duration(milliseconds: 400)); // _loadData + rebuild
  }

  Future<void> pump(WidgetTester tester, Widget step) async {
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(home: Scaffold(body: step)),
      ),
    );
    await settle(tester);
  }

  Future<void> save(GlobalKey key) =>
      (key.currentState! as WizardStepMixin).validateAndSave();

  // ── About you ──────────────────────────────────────────────────────────────

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

  // ── Guardian ─────────────────────────────────────────────────────────────

  testWidgets('Guardian step persists the nominee name', (tester) async {
    final key = GlobalKey<State<GuardianNominationStep>>();
    await pump(
        tester, GuardianNominationStep(key: key, directiveId: directiveId));

    // The nominee name field only appears once "Someone different" is chosen.
    await tester.tap(find.text('Someone different'));
    await settle(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nominee full name'),
      'Guard Ian',
    );
    await save(key);

    final g = await repo.getGuardianNomination(directiveId);
    expect(g?.nomineeFullName, 'Guard Ian');
  });

  // ── Treatment facility (room preferences) ────────────────────────────────

  testWidgets('Treatment-facility step persists a room chip + free-text note',
      (tester) async {
    final key = GlobalKey<State<TreatmentFacilityStep>>();
    await pump(
        tester, TreatmentFacilityStep(key: key, directiveId: directiveId));

    await tester.tap(find.text('Single room'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Other room preferences'),
      'Near a window, away from loud areas',
    );
    await tester.pump();

    await save(key);

    final prefs = await repo.getPreferences(directiveId);
    // Chips persist as a comma-separated id list in `roomPreferences`.
    expect(prefs?.roomPreferences.split(','), contains('singleRoom'));
    expect(prefs?.roomPreferencesNote, 'Near a window, away from loud areas');
  });

  // ── Save-before-load race guard (WizardStepLoadGuard) ────────────────────

  // The persistent wizard nav bar can trigger validateAndSave before a freshly
  // navigated step's post-frame `_loadData` has read the DB. Without the guard,
  // the step's destructive save (here `updatePersonalInfo`) would overwrite
  // persisted data with its still-empty controllers. We force that window
  // deterministically with a repository whose read never completes, so the
  // step's `isLoaded` stays false when we save.
  testWidgets('a destructive save before load does not overwrite stored data',
      (tester) async {
    // Seed an existing identity on the directive.
    await repo.updatePersonalInfo(
      directiveId,
      fullName: 'Existing Name',
      dateOfBirth: '01/01/1980',
      address: '1 Main St',
      address2: '',
      city: 'Philadelphia',
      county: 'Philadelphia',
      state: 'PA',
      zip: '19103',
      phone: '215-555-0000',
    );

    final hangingRepo = _HangingReadRepo(db);
    final key = GlobalKey<State<PersonalInfoStep>>();
    await tester.binding.setSurfaceSize(const Size(1200, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          directiveRepositoryProvider.overrideWithValue(hangingRepo),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: PersonalInfoStep(key: key, directiveId: directiveId),
          ),
        ),
      ),
    );
    await tester.pump(); // fire post-frame → _loadData starts and hangs

    // Save while the load is still pending (isLoaded == false).
    final ok = await (key.currentState! as WizardStepMixin).validateAndSave();
    expect(ok, isTrue, reason: 'guard reports valid so the wizard still advances');

    // The seeded identity must be untouched — the guard skipped the save.
    final d = await repo.getDirectiveById(directiveId);
    expect(d?.fullName, 'Existing Name');
    expect(d?.zip, '19103');

    // Release the load so teardown settles cleanly.
    hangingRepo.release();
    await tester.pumpAndSettle();
  });
}

/// A repository whose reads block on a gate until [release] is called — lets a
/// test hold a wizard step in its "not yet loaded" state deterministically.
class _HangingReadRepo extends DirectiveRepository {
  // Not a super parameter: DirectiveRepository's constructor field is private
  // (`this._db`), so `super.db` can't reference it from this library.
  // ignore: use_super_parameters
  _HangingReadRepo(AppDatabase db) : super(db);

  final Completer<void> _gate = Completer<void>();
  void release() => _gate.complete();

  @override
  Future<Directive?> getDirectiveById(int id) async {
    await _gate.future;
    return super.getDirectiveById(id);
  }
}
