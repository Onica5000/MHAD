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

/// V4-H6 — router redirect gating + bottom-nav navigation.
///
/// These tests pin the navigation contract that was easy to silently break
/// during the nav rewrite this session:
///  1. If the disclaimer is not accepted, every route redirects to /disclaimer.
///  2. If the disclaimer is accepted but no privacy mode is selected (mobile),
///     every route redirects to /mode.
///  3. If both are satisfied, the app lands on /.
///  4. The bottom nav's "Learn" button actually changes the active route.
void main() {
  Widget buildApp(AppDatabase db) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const MhadApp(),
    );
  }

  String currentPath() =>
      appRouter.routerDelegate.currentConfiguration.uri.path;

  testWidgets('not-accepted disclaimer redirects to /disclaimer',
      (tester) async {
    initRouter(
      DisclaimerNotifier(initialValue: false),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    expect(currentPath(), '/disclaimer');
    await db.close();
  });

  testWidgets('accepted disclaimer + no mode redirects to /mode (mobile)',
      (tester) async {
    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier(), // notSelected
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    // kIsWeb is false in this VM test — the router only auto-selects
    // public mode on web. On non-web with no mode selected, expect /mode.
    expect(currentPath(), '/mode');
    await db.close();
  });

  testWidgets('accepted disclaimer + public mode lands on /', (tester) async {
    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    expect(currentPath(), '/');
    await db.close();
  });

  testWidgets('bottom nav "Learn" tab navigates to /education',
      (tester) async {
    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();
    expect(currentPath(), '/');

    // The bottom nav uses Semantics labels — "Learn" is the inactive label.
    // (On the home screen Learn is inactive; only the active item shows its
    // visible text label, so we find by semantics rather than by text.)
    final learn = find.bySemanticsLabel('Learn');
    expect(learn, findsOneWidget,
        reason: 'Learn destination must be present in the bottom nav');
    await tester.tap(learn);
    await tester.pumpAndSettle();

    expect(currentPath(), '/education');
    await db.close();
  });
}
