import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/main.dart' show MhadApp;
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/education/learn_ai_panel.dart';
import 'package:mhad/ui/router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/real_fonts.dart';

/// Review "missing verification": a release build prints NOTHING when a
/// widget overflows or is laid out under unbounded constraints — it just
/// paints wrong or not at all. This renders the redesigned top-level screens
/// across the window sizes where the layout switches (phone, the 1000px
/// desktop breakpoint, a wide desktop), in both shipped languages, at normal
/// and large text, with the real fonts, and fails on any layout exception.
///
/// (Per-directive screens are covered at phone/desktop by
/// spanish_smoke_test.dart.)
void main() {
  setUpAll(() async {
    AppData.instance = AppData.fromJson(const {});
    await loadRealFonts();
  });

  const sizes = {
    'phone': Size(390, 844),
    'breakpoint': Size(1000, 700),
    'desktop': Size(1440, 900),
  };
  const routes = [AppRoutes.home, AppRoutes.education, AppRoutes.settings];

  for (final lang in const ['en', 'es']) {
    for (final scale in const [1.0, 1.3]) {
      for (final size in sizes.entries) {
        for (final route in routes) {
          testWidgets('$lang · text ${scale}x · ${size.key} · $route lays out',
              (tester) async {
            SharedPreferences.setMockInitialValues({
              'mhad_a11y_language': lang,
              'mhad_a11y_text_scale': scale,
            });
            initRouter(
              DisclaimerNotifier(initialValue: true),
              OnboardingNotifier(initialValue: true),
              PrivacyModeNotifier()..setPublicMode(),
            );
            // The VIEW size (what MediaQuery reports), not setSurfaceSize:
            // that only resized the render surface while MediaQuery kept the
            // 800x600 test default, so every 'desktop' case silently ran the
            // phone layout.
            tester.view.physicalSize = size.value;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(() {
              tester.view.resetPhysicalSize();
              tester.view.resetDevicePixelRatio();
            });
            final db = AppDatabase(NativeDatabase.memory());
            await tester.pumpWidget(ProviderScope(
              overrides: [appDatabaseProvider.overrideWithValue(db)],
              child: const MhadApp(),
            ));
            await tester.pumpAndSettle();
            appRouter.go(route);
            await tester.pumpAndSettle();

            expect(tester.takeException(), isNull);
            if (route == AppRoutes.education) {
              // The AI panel only joins Learn with room beside the reading
              // column (not at the 1000px breakpoint; not on phones).
              expect(find.byType(LearnAiPanel),
                  size.key == 'desktop' ? findsOneWidget : findsNothing,
                  reason: 'Learn AI panel at ${size.key}');
            }

            await tester.pumpWidget(const SizedBox());
            await tester.pump(const Duration(seconds: 1));
            await db.close();
          });
        }
      }
    }
  }
}
