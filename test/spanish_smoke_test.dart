import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

/// Spanish strings run ~20-30% longer than English. Render the main screens
/// in Spanish at phone and desktop widths; any RenderFlex overflow or other
/// build error fails the test.
void main() {
  setUpAll(() async {
    AppData.instance = AppData.fromJson(const {});
    // Measure with the real bundled fonts. The default test font (Ahem)
    // draws every glyph as a full em square, which flags "overflows" that
    // never happen with DM Sans.
    const families = {
      'DM Sans': ['DMSans-Regular', 'DMSans-Medium', 'DMSans-SemiBold', 'DMSans-Bold'],
      'Instrument Serif': ['InstrumentSerif-Regular', 'InstrumentSerif-Italic'],
      'JetBrains Mono': ['JetBrainsMono-Regular', 'JetBrainsMono-Medium', 'JetBrainsMono-SemiBold'],
    };
    for (final e in families.entries) {
      final loader = FontLoader(e.key);
      for (final file in e.value) {
        final bytes = File('assets/fonts/$file.ttf').readAsBytesSync();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    }
  });

  const sizes = {'phone': Size(390, 844), 'desktop': Size(1280, 900)};
  const routes = [
    AppRoutes.home,
    AppRoutes.education,
    AppRoutes.settings,
    AppRoutes.accessibility,
    AppRoutes.facilitator,
    AppRoutes.permissions,
  ];

  for (final size in sizes.entries) {
    for (final route in routes) {
      testWidgets('es · ${size.key} · $route renders without errors',
          (tester) async {
        SharedPreferences.setMockInitialValues({'mhad_a11y_language': 'es'});
        initRouter(
          DisclaimerNotifier(initialValue: true),
          OnboardingNotifier(initialValue: true),
          PrivacyModeNotifier()..setPublicMode(),
        );
        await tester.binding.setSurfaceSize(size.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final db = AppDatabase(NativeDatabase.memory());
        await tester.pumpWidget(ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MhadApp(),
        ));
        await tester.pumpAndSettle();
        appRouter.go(route);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final locale = Localizations.localeOf(
            tester.element(find.byType(Scaffold).first));
        expect(locale.languageCode, 'es');

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
        await db.close();
      });
    }
  }

  // Directive-scoped screens (the bulk of the copy) and the first-launch gates.
  final directiveRoutes = <String, String Function(int)>{
    'wizard': AppRoutes.wizardRoute,
    'wizard review': (id) => AppRoutes.wizardStepRoute(id, 10),
    'export': AppRoutes.exportRoute,
    'sign': AppRoutes.signRoute,
    'crisis plan': AppRoutes.crisisPlanRoute,
    'ulysses': AppRoutes.ulyssesRoute,
    'side effects': AppRoutes.sideEffectsRoute,
    'revoke': AppRoutes.revocationRoute,
    'findable': AppRoutes.findableRoute,
    'ai check': AppRoutes.aiCheckRoute,
  };
  for (final size in sizes.entries) {
    for (final r in directiveRoutes.entries) {
      testWidgets('es · ${size.key} · ${r.key} renders without errors',
          (tester) async {
        SharedPreferences.setMockInitialValues({'mhad_a11y_language': 'es'});
        initRouter(
          DisclaimerNotifier(initialValue: true),
          OnboardingNotifier(initialValue: true),
          PrivacyModeNotifier()..setPublicMode(),
        );
        await tester.binding.setSurfaceSize(size.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final db = AppDatabase(NativeDatabase.memory());
        final id = (await tester.runAsync(
          () => DirectiveRepository(db).createDirective(FormType.combined),
        ))!;
        await tester.pumpWidget(ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MhadApp(),
        ));
        await tester.pumpAndSettle();
        appRouter.go(r.value(id));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
        await db.close();
      });
    }
    for (final gate in ['disclaimer', 'onboarding']) {
      testWidgets('es · ${size.key} · $gate gate renders without errors',
          (tester) async {
        SharedPreferences.setMockInitialValues({'mhad_a11y_language': 'es'});
        initRouter(
          DisclaimerNotifier(initialValue: gate != 'disclaimer'),
          OnboardingNotifier(initialValue: gate != 'onboarding'),
          PrivacyModeNotifier()..setPublicMode(),
        );
        await tester.binding.setSurfaceSize(size.value);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final db = AppDatabase(NativeDatabase.memory());
        await tester.pumpWidget(ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MhadApp(),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        await tester.pumpWidget(const SizedBox());
        await tester.pump(const Duration(seconds: 1));
        await db.close();
      });
    }
  }

  testWidgets('es · accessibility shows the machine-translation notice',
      (tester) async {
    SharedPreferences.setMockInitialValues({'mhad_a11y_language': 'es'});
    initRouter(
      DisclaimerNotifier(initialValue: true),
      OnboardingNotifier(initialValue: true),
      PrivacyModeNotifier()..setPublicMode(),
    );
    await tester.binding.setSurfaceSize(const Size(1280, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MhadApp(),
    ));
    await tester.pumpAndSettle();
    appRouter.go(AppRoutes.accessibility);
    await tester.pumpAndSettle();
    expect(find.textContaining('hablante nativo'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
    await db.close();
  });
}
