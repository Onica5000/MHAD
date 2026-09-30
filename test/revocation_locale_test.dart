import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/revocation/revocation_screen.dart';

/// The typed confirmation word is localized (REVOCAR in Spanish). The screen
/// used to accept only the English literal, so revocation was impossible in
/// any other language even though the prompt asked for the translated word.
void main() {
  late AppDatabase db;
  late DirectiveRepository repo;

  setUpAll(() => AppData.instance = AppData.fromJson(const {}));

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = DirectiveRepository(db);
  });

  tearDown(() => db.close());

  Future<int> pump(WidgetTester tester, Locale locale) async {
    final id = await tester.runAsync(
      () => repo.createDirective(FormType.combined),
    );
    await tester.binding.setSurfaceSize(const Size(1000, 3000));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: RevocationScreen(directiveId: id!),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return id!;
  }

  FilledButton revokeButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byWidgetPredicate(
        (w) => w is FilledButton,
      ));

  Future<String?> statusOf(WidgetTester tester, int id) async =>
      (await tester.runAsync(() => repo.getDirectiveById(id)))?.status;

  testWidgets('Spanish: typing REVOCAR enables and performs revocation',
      (tester) async {
    final id = await pump(tester, const Locale('es'));
    expect(find.text('Escriba REVOCAR para confirmar'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'revok');
    await tester.pump();
    expect(revokeButton(tester).onPressed, isNull);

    await tester.enterText(find.byType(TextField), ' revocar ');
    await tester.pump();
    expect(revokeButton(tester).onPressed, isNotNull);

    await tester.ensureVisible(find.text('Revocar ahora'));
    await tester.runAsync(() async {
      await tester.tap(find.text('Revocar ahora'));
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();
    expect(await statusOf(tester, id), DirectiveStatus.revoked.name);
  });

  testWidgets('Spanish: the English REVOKE is still accepted',
      (tester) async {
    await pump(tester, const Locale('es'));
    await tester.enterText(find.byType(TextField), 'REVOKE');
    await tester.pump();
    expect(revokeButton(tester).onPressed, isNotNull);
  });

  testWidgets('English: REVOKE enables the button', (tester) async {
    await pump(tester, const Locale('en'));
    expect(find.text('Type REVOKE to confirm'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'REVOKE');
    await tester.pump();
    expect(revokeButton(tester).onPressed, isNotNull);
  });
}
