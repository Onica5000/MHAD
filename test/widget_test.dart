import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/router.dart';

void main() {
  // Reset the global appRouter to "disclaimer accepted + public mode" before
  // each test so home-screen tests don't inherit gate state from a sibling
  // test file that exercised the redirect logic.
  setUp(() {
    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );
  });

  testWidgets('App renders home screen with correct title', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const MhadApp(),
      ),
    );

    // Wait for async operations
    await tester.pumpAndSettle();

    // The prototype-faithful home (mobile.jsx::ScrHome L235-362) has no
    // brand row — it opens straight with the date SectionLabel + editorial
    // greeting. With an empty database the anonymous editorial fallback
    // "Your voice, / in your words." renders in the greeting slot. The
    // previously-asserted "PA MHAD" brand row was removed 2026-06-03 to
    // match the prototype.
    expect(
      find.textContaining('Your voice', findRichText: true),
      findsWidgets,
    );

    // The "Start my directive" CTA in the editorial empty-state card is
    // the canonical primary CTA on a fresh launch. The legacy duplicate
    // "New Directive" button + Learn-More card were removed per the same
    // restructure (Tools-grid Learn tile + empty-hero CTA cover both).
    final startBtn = find.text('Start my directive');
    await tester.scrollUntilVisible(startBtn, 200);
    expect(startBtn, findsOneWidget);

    await db.close();
  });

  testWidgets('Home screen shows empty directives message initially',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
        ],
        child: const MhadApp(),
      ),
    );

    await tester.pumpAndSettle();

    // The editorial empty-hero card lives in the home ListView. Scroll
    // until it's on screen, then assert. The home screen now uses the
    // prototype's "Your first directive" hero copy + "Start my directive"
    // CTA in place of the prior "No directives yet" line.
    final emptyFinder = find.text('Start my directive');
    await tester.scrollUntilVisible(emptyFinder, 200);
    await tester.pumpAndSettle();

    expect(emptyFinder, findsOneWidget);
    expect(find.text('Your first directive'.toUpperCase()), findsOneWidget);

    await db.close();
  });
}
