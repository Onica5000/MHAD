import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/disclaimer_service.dart';
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
      PrivacyModeNotifier()..setPublicMode(),
    );
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(buildApp(db));
    await tester.pumpAndSettle();

    await expectLater(tester, meetsGuideline(textContrastGuideline));

    await db.close();
  });
}
