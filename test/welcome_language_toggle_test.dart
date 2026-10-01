import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/language_toggle.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The first-launch welcome gate offers English / Español before anything
/// else, and it drives the same setting as Accessibility.
void main() {
  setUpAll(() async {
    AppData.instance = AppData.fromJson(const {});
    // Real fonts: the default test font (Ahem) draws every glyph as a full
    // em square and reports overflows DM Sans never has.
    const families = {
      'DM Sans': [
        'DMSans-Regular',
        'DMSans-Medium',
        'DMSans-SemiBold',
        'DMSans-Bold',
      ],
      'Instrument Serif': ['InstrumentSerif-Regular', 'InstrumentSerif-Italic'],
      'JetBrains Mono': [
        'JetBrainsMono-Regular',
        'JetBrainsMono-Medium',
        'JetBrainsMono-SemiBold',
      ],
    };
    for (final e in families.entries) {
      final loader = FontLoader(e.key);
      for (final file in e.value) {
        loader.addFont(
          Future.value(
            ByteData.sublistView(
              File('assets/fonts/$file.ttf').readAsBytesSync(),
            ),
          ),
        );
      }
      await loader.load();
    }
  });

  for (final size in const [Size(390, 844), Size(1280, 900)]) {
    testWidgets('welcome gate switches to Spanish at ${size.width.toInt()}px', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      initRouter(
        DisclaimerNotifier(initialValue: false), // first launch → gate
        OnboardingNotifier(initialValue: false),
        PrivacyModeNotifier()..setPublicMode(),
      );
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final db = AppDatabase(NativeDatabase.memory());
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MhadApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(LanguageToggle), findsOneWidget);
      expect(find.text('A few things to understand.'), findsOneWidget);

      await tester.tap(find.text('Español'));
      await tester.pumpAndSettle();

      expect(find.text('Algunas cosas que debe saber.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('mhad_a11y_language'), 'es');

      // Same setting is shown selected in Accessibility.
      appRouter.go(AppRoutes.accessibility);
      await tester.pumpAndSettle();
      final seg = tester.widget<SegmentedButton<String>>(
        find.byType(SegmentedButton<String>),
      );
      expect(seg.selected, {'es'});

      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
      await db.close();
    });
  }
}
