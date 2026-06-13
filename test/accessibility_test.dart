import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
  Widget buildApp(AppDatabase db) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const MhadApp(),
    );
  }

  // Reset to the home-screen state before each test; tests that exercise the
  // disclaimer override this themselves.
  setUp(() {
    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );
  });

  testWidgets('Home screen meets Android tap target guideline',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    await db.close();
  });

  testWidgets('Home screen meets labeled tap target guideline',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await db.close();
  });

  testWidgets('Home screen meets text contrast guideline', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await db.close();
  });

  // V4-H6/M9 — extend a11y coverage beyond home. The disclaimer is the
  // first-launch gate screen and must pass the same guidelines.
  testWidgets('Disclaimer (gate) meets Android tap target guideline',
      (tester) async {
    initRouter(
      DisclaimerNotifier(initialValue: false), // forces /disclaimer
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    await db.close();
  });

  testWidgets('Disclaimer (gate) meets text contrast guideline',
      (tester) async {
    initRouter(
      DisclaimerNotifier(initialValue: false),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await db.close();
  });

  testWidgets('Disclaimer (gate) meets labeled tap target guideline',
      (tester) async {
    initRouter(
      DisclaimerNotifier(initialValue: false),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await db.close();
  });

  // Sweep the rest of the top-level destinations against the three a11y
  // guidelines: Android tap target (≥ 48×48), labeled tap target
  // (≥ 48×48 AND has a label), and text contrast (WCAG-aligned colour
  // contrast for any rendered text).
  Future<void> testScreenLabeled(
    WidgetTester tester, {
    required String route,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();
    appRouter.go(route);
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));

    await db.close();
  }

  Future<void> testScreenAndroid(
    WidgetTester tester, {
    required String route,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();
    appRouter.go(route);
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));

    await db.close();
  }

  Future<void> testScreenContrast(
    WidgetTester tester, {
    required String route,
  }) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();
    appRouter.go(route);
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await db.close();
  }

  testWidgets('Settings meets labeled tap target guideline', (tester) async {
    await testScreenLabeled(tester, route: AppRoutes.settings);
  });

  testWidgets('Education meets labeled tap target guideline', (tester) async {
    await testScreenLabeled(tester, route: AppRoutes.education);
  });

  testWidgets('AI Setup meets labeled tap target guideline', (tester) async {
    await testScreenLabeled(tester, route: AppRoutes.aiSetup);
  });

  testWidgets('Privacy Policy meets labeled tap target guideline',
      (tester) async {
    await testScreenLabeled(tester, route: AppRoutes.privacyPolicy);
  });

  testWidgets('Mode selection meets labeled tap target guideline',
      (tester) async {
    // Force a state where mode hasn't been picked so the redirect lands on
    // /mode rather than bouncing away.
    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier(), // notSelected
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await db.close();
  });

  testWidgets('Assistant screen meets labeled tap target guideline',
      (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();
    appRouter.go(AppRoutes.assistant);
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await db.close();
  });

  // Android tap-target sweep — every top-level destination must have all
  // tap targets ≥ 48×48 even before considering labels.
  testWidgets('Settings meets Android tap target guideline', (tester) async {
    await testScreenAndroid(tester, route: AppRoutes.settings);
  });
  testWidgets('Education meets Android tap target guideline', (tester) async {
    await testScreenAndroid(tester, route: AppRoutes.education);
  });
  testWidgets('AI Setup meets Android tap target guideline', (tester) async {
    await testScreenAndroid(tester, route: AppRoutes.aiSetup);
  });
  testWidgets('Privacy Policy meets Android tap target guideline',
      (tester) async {
    await testScreenAndroid(tester, route: AppRoutes.privacyPolicy);
  });
  testWidgets('Assistant screen meets Android tap target guideline',
      (tester) async {
    await testScreenAndroid(tester, route: AppRoutes.assistant);
  });

  // Text-contrast sweep — every top-level destination must render text
  // with sufficient contrast against its surface.
  testWidgets('Settings meets text contrast guideline', (tester) async {
    await testScreenContrast(tester, route: AppRoutes.settings);
  });
  testWidgets('Education meets text contrast guideline', (tester) async {
    await testScreenContrast(tester, route: AppRoutes.education);
  });
  testWidgets('AI Setup meets text contrast guideline', (tester) async {
    await testScreenContrast(tester, route: AppRoutes.aiSetup);
  });
  testWidgets('Privacy Policy meets text contrast guideline', (tester) async {
    await testScreenContrast(tester, route: AppRoutes.privacyPolicy);
  });
  testWidgets('Assistant screen meets text contrast guideline',
      (tester) async {
    await testScreenContrast(tester, route: AppRoutes.assistant);
  });

  // Mode selection is a redirected route — exercise it with its own setUp.
  testWidgets('Mode selection meets Android tap target guideline',
      (tester) async {
    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier(),
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await db.close();
  });
  testWidgets('Mode selection meets text contrast guideline',
      (tester) async {
    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier(),
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    await db.close();
  });

  // Note on the wizard / wizard-complete / export screens:
  //
  //   We deliberately do not run the labeledTapTargetGuideline against these
  //   inside a widget test. They mount native-only plugins (NFC, biometric,
  //   speech_to_text, file_picker) that throw MissingPluginException in the
  //   Flutter test harness; pumpAndSettle never terminates, and iterating
  //   the widget tree triggers further plugin errors.
  //
  //   The wizard's chrome (Smart Fill, AI chat, Save/Exit) is verified by
  //   code inspection — every IconButton in lib/ui/wizard/wizard_screen.dart
  //   carries a `tooltip:` parameter. The labeled-tap-target sweep above
  //   covers every other top-level destination on which a end user actually
  //   spends the majority of their time.
}
