import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';

void main() {
  Widget buildApp(AppDatabase db) {
    return ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
      ],
      child: const MhadApp(),
    );
  }

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
}
