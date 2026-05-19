import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/router.dart';

void main() {
  // Reset the global appRouter to "disclaimer accepted + public mode" before
  // each test so home-screen tests don't inherit gate state from a sibling
  // test file that exercised the redirect logic.
  setUp(() {
    initRouter(
      DisclaimerNotifier(initialValue: true),
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

    // App bar shows the brand mark.
    expect(find.text('PA MHAD'), findsOneWidget);

    // Learn More card is high on the home screen.
    final learnCard = find.text('Learn About MHADs');
    await tester.scrollUntilVisible(learnCard, 200);
    expect(learnCard, findsOneWidget);

    // The "New Directive" button sits further down the ListView; scroll to
    // it before asserting so the test viewport doesn't matter.
    final newBtn = find.text('New Directive');
    await tester.scrollUntilVisible(newBtn, 200);
    expect(newBtn, findsOneWidget);

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

    // The "No directives yet" empty state lives in the home ListView. Scroll
    // until it's on screen, then assert. (The home screen redesigned the
    // section label, so we anchor on the empty-state copy itself.)
    final emptyFinder = find.text('No directives yet');
    await tester.scrollUntilVisible(emptyFinder, 200);
    await tester.pumpAndSettle();

    expect(emptyFinder, findsOneWidget);

    await db.close();
  });
}
