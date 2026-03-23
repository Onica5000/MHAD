import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';

void main() {
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

    // Home screen should show the app title text
    expect(find.text('PA Mental Health\nAdvance Directive'), findsOneWidget);

    // FAB should exist for creating new directives
    expect(find.text('New Directive'), findsOneWidget);

    // Learn More card should be present
    expect(find.text('Learn About MHADs'), findsOneWidget);

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

    // Scroll down to make the directives section visible
    await tester.scrollUntilVisible(
      find.text('My Directives'),
      200,
    );
    await tester.pumpAndSettle();

    expect(find.text('No directives yet'), findsOneWidget);

    await db.close();
  });
}
