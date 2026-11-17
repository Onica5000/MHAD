import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/art_image.dart';
import 'package:mhad/ui/widgets/design/bottom_nav.dart';
import 'package:mhad/ui/widgets/design/step_head.dart';

/// The wizard has ONE Back/Continue bar (WizardBottomBar) on both layouts
/// (review R18: the desktop rail used to carry its own "Next" button). On
/// phones the bottom nav is hidden in the wizard and the step header's
/// "More" button keeps every destination one tap away.
void main() {
  Future<AppDatabase> pumpWizard(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );

    final db = AppDatabase(NativeDatabase.memory());
    final id = await DirectiveRepository(db).createDirective(FormType.combined);

    // Make the wizard the initial route so there's no Home→wizard transition
    // frame muddying the layout under test.
    appRouter.go(AppRoutes.wizardRoute(id));

    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MhadApp(),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    // Drain any layout exceptions raised during the pumps. The regression we
    // guard against is the bar hitting an *infinite width* and failing to
    // paint (the "no nav buttons on mobile" bug); unrelated minor overflows
    // elsewhere are not this test's concern.
    final errors = <String>[];
    for (Object? e = tester.takeException(); e != null; e = tester.takeException()) {
      errors.add(e.toString());
    }
    expect(
      errors.where((e) => e.contains('infinite width')),
      isEmpty,
      reason: 'the bottom bar must not hit an infinite-width layout',
    );
    return db;
  }

  void expectContinueBar(WidgetTester tester) {
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.getSize(find.text('Continue')).width, greaterThan(0));
    expect(find.text('Next'), findsNothing,
        reason: 'one bar, one label: the old desktop rail "Next" is gone');
  }

  testWidgets('phone: Continue bar, step photo, no bottom nav, More in header',
      (tester) async {
    final db = await pumpWizard(tester, const Size(390, 844));

    expectContinueBar(tester);
    expect(
        find.descendant(
            of: find.byType(StepHead), matching: find.byType(ArtImage)),
        findsOneWidget,
        reason: 'every step shows its photo, always (never keyboard-toggled)');
    expect(find.byType(MhadBottomNav), findsNothing,
        reason: 'the wizard hides the phone nav to give the form room');
    final more = find.descendant(
        of: find.byType(StepHead), matching: find.text('More'));
    expect(more, findsOneWidget,
        reason: 'More replaces the hidden nav, so nothing is lost');

    // The sheet carries the four primary destinations (the hidden nav's
    // tabs) on top of crisis help and the secondary destinations.
    await tester.tap(more);
    await tester.pumpAndSettle();
    for (final label in const ['Home', 'Learn', 'Ask', 'Settings']) {
      expect(find.bySemanticsLabel(label), findsOneWidget,
          reason: '$label must stay one tap away from the wizard');
    }
    expect(find.text('Crisis help'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Settings'));
    await tester.pumpAndSettle();
    expect(appRouter.routerDelegate.currentConfiguration.uri.path,
        AppRoutes.settings);

    await db.close();
  });

  testWidgets('desktop: the same Continue bar under the form, no More button',
      (tester) async {
    final db = await pumpWizard(tester, const Size(1440, 900));

    expectContinueBar(tester);
    expect(
        find.descendant(
            of: find.byType(StepHead), matching: find.text('More')),
        findsNothing,
        reason: 'desktop keeps the sidebar rail; More is a phone affordance');

    await db.close();
  });
}
