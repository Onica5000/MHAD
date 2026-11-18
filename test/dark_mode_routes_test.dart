import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/real_fonts.dart';

/// Every route, at phone and desktop sizes, renders in DARK mode with no
/// layout exception (user, 2026-11-17: "some of the text can't be read in
/// dark mode"). This sweep found a white band around the phone nav and an
/// Upload button that never laid out.
///
/// Readability itself is checked in test/unit/palette_contrast_test.dart,
/// computed from the colors. Pixel sampling (Flutter's contrast guidelines)
/// was tried here and can't be trusted on this UI: on gradient cards and
/// thin serif headings it compares two background shades, so clearly
/// readable text measured 1.1–3.4:1.
void main() {
  setUpAll(() async {
    AppData.instance = AppData.fromJson(const {});
    await loadRealFonts();
  });

  const sizes = {'phone': Size(390, 844), 'desktop': Size(1440, 900)};
  final routes = [
    '/', '/education', '/assistant', '/settings', '/accessibility',
    '/privacy-policy', '/permissions', '/facilitator', '/audio-guide',
    for (var i = 0; i < 11; i++) '/wizard/1?step=$i',
    '/upload/1', '/crisis-plan/1', '/ulysses/1', '/side-effects/1',
    '/findable/1', '/ai-check/1', '/sign/1', '/export/1', '/revoke/1',
    '/past/1',
  ];

  for (final size in sizes.entries) {
    for (final route in routes) {
      testWidgets('dark · ${size.key} · $route renders',
          (tester) async {
        SharedPreferences.setMockInitialValues({
          'mhad_theme_mode': 'dark',
          // No fade-ins mid-check (an animating heading reads as invisible).
          'mhad_a11y_reduce_motion': true,
        });
        initRouter(
          DisclaimerNotifier(initialValue: true),
          OnboardingNotifier(initialValue: true),
          PrivacyModeNotifier()..setPublicMode(),
        );
        tester.view.physicalSize = size.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final db = AppDatabase(NativeDatabase.memory());
        await DirectiveRepository(db).createDirective(FormType.combined);
        appRouter.go(route);
        await tester.pumpWidget(ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MhadApp(),
        ));
        // Frames, not pumpAndSettle: some screens keep a spinner running.
        for (var i = 0; i < 8; i++) {
          await tester.pump(const Duration(milliseconds: 250));
        }
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
        await db.close();
      });
    }
  }
}
