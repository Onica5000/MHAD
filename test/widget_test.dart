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

  testWidgets('Home renders the public-mode guest greeting', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          // Public mode so the home renders the anonymous guest greeting (the
          // screen reads this provider, not the router's notifier from setUp).
          privacyModeNotifierProvider
              .overrideWith((ref) => PrivacyModeNotifier()..setPublicMode()),
        ],
        child: const MhadApp(),
      ),
    );

    // Wait for async operations
    await tester.pumpAndSettle();

    // The home opens with the editorial greeting. In Public mode (set in
    // setUp) the anonymous "Welcome, guest. / Quick draft, no trace."
    // greeting renders regardless of any session name.
    expect(
      find.textContaining('Welcome, guest', findRichText: true),
      findsWidgets,
    );

    await db.close();
  });

  testWidgets('Empty home shows the "Start your directive" form picker',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          // Public mode so the home renders the anonymous guest greeting (the
          // screen reads this provider, not the router's notifier from setUp).
          privacyModeNotifierProvider
              .overrideWith((ref) => PrivacyModeNotifier()..setPublicMode()),
        ],
        child: const MhadApp(),
      ),
    );

    await tester.pumpAndSettle();

    // With an empty database the home surfaces the form-type picker
    // (DirectiveFormChoice) under a "Start your directive" section label,
    // led by the bold "Combined directive" card with its "Start now" CTA.
    // This replaced the old single "Start my directive" empty-hero card.
    final combined = find.text('Combined directive');
    await tester.scrollUntilVisible(combined, 200);
    await tester.pumpAndSettle();

    expect(combined, findsOneWidget);
    expect(find.text('Start your directive'.toUpperCase()), findsOneWidget);
    expect(find.text('Start now'), findsWidgets);

    await db.close();
  });
}
