import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/steps/allergies_step.dart';

/// The Allergies step's two pickers put ONE word in a narrow tile. On a phone
/// in Spanish at the app's default 1.2× text, "Moderada" broke as
/// "Moderad|a" (and "Medicamento" split). Each label must stay one line —
/// it shrinks a little instead (FittedBox, the bottom nav's pattern).
void main() {
  late AppDatabase db;

  setUpAll(() => AppData.instance = AppData.fromJson(const {}));
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  for (final (locale, labels) in [
    (const Locale('es'),
        ['Medicamento', 'Alimento', 'Material', 'Otro', 'Leve', 'Moderada', 'Grave']),
    (const Locale('en'), ['Drug', 'Food', 'Material', 'Other', 'Mild', 'Moderate', 'Severe']),
  ]) {
    testWidgets('${locale.languageCode}: picker labels stay on one line at phone width',
        (tester) async {
      tester.view.physicalSize = const Size(390, 3000);
      tester.view.devicePixelRatio = 1.0;
      tester.platformDispatcher.textScaleFactorTestValue = 1.2;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        tester.platformDispatcher.clearTextScaleFactorTestValue();
      });
      final id = await DirectiveRepository(db).createDirective(FormType.combined);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: MaterialApp(
            locale: locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(body: AllergiesStep(directiveId: id)),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      for (final label in labels) {
        final found = find.text(label);
        expect(found, findsWidgets, reason: label);
        for (final e in found.evaluate()) {
          final rp = e.renderObject! as RenderParagraph;
          // One line = every glyph box shares the same top.
          final tops = rp
              .getBoxesForSelection(
                  TextSelection(baseOffset: 0, extentOffset: label.length))
              .map((b) => b.top.round())
              .toSet();
          expect(tops, hasLength(1), reason: '"$label" broke over ${tops.length} lines');
        }
      }
    });
  }
}
