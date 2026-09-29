import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/bottom_nav.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/design/web_sidebar.dart';

/// V4-H6 — `ResponsiveShell` layout + `MhadBottomNav` highlight/navigation.
///
/// The shell and nav read the GLOBAL [appRouter] (they live above the router),
/// so each test installs a lightweight stub router with placeholder pages at
/// the real route paths. That isolates the shell's own decisions — which
/// chrome to show, how wide the content column is, which tab is active —
/// from every real screen's content.
void main() {
  const stubPaths = [
    AppRoutes.home,
    AppRoutes.disclaimer,
    AppRoutes.modeSelection,
    AppRoutes.onboarding,
    AppRoutes.education,
    AppRoutes.assistant,
    AppRoutes.aiSetup,
    AppRoutes.settings,
    AppRoutes.privacyPolicy,
    AppRoutes.export,
    AppRoutes.wizard,
    AppRoutes.sign,
  ];

  Key pageKey(String location) => ValueKey('page:$location');

  void installRouter(String initial) {
    appRouter = GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: initial,
      routes: [
        for (final path in stubPaths)
          GoRoute(
            path: path,
            builder: (_, state) => Scaffold(
              key: pageKey(state.matchedLocation),
              body: Text('page ${state.matchedLocation}'),
            ),
          ),
      ],
    );
  }

  String currentRoute() {
    final cfg = appRouter.routerDelegate.currentConfiguration;
    return cfg.lastOrNull?.matchedLocation ?? cfg.uri.path;
  }

  Future<void> pumpShell(
    WidgetTester tester, {
    required Size size,
    required String initial,
    String? apiKey,
  }) async {
    // Boot directly at the requested size: at desktop width this is the
    // direct-load path where the router notifies mid-build (see
    // _RouteListener in responsive_shell.dart).
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    installRouter(initial);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        // A static list instead of the Drift watch-stream: the stream's
        // coalescing timer outlives the widget tree in the test harness.
        allDirectivesProvider.overrideWith((ref) => Stream.value(const [])),
        apiKeyProvider.overrideWithValue(AsyncValue.data(apiKey)),
      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        theme: buildMhadTheme(ThemePalette.teal, Brightness.light),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => ResponsiveShell(child: child!),
      ),
    ));
    await tester.pumpAndSettle();
  }

  const phone = Size(390, 844);
  const desktop = Size(1440, 900);

  // ── Chrome selection ─────────────────────────────────────────────────────

  group('chrome selection', () {
    testWidgets('narrow: bottom nav, no sidebar', (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.home);
      expect(find.byType(MhadBottomNav), findsOneWidget);
      expect(find.byType(WebSidebar), findsNothing);
    });

    testWidgets('wide: sidebar, no bottom nav', (tester) async {
      await pumpShell(tester, size: desktop, initial: AppRoutes.home);
      expect(find.byType(WebSidebar), findsOneWidget);
      expect(find.byType(MhadBottomNav), findsNothing);
    });

    testWidgets('breakpoint is inclusive at kWideLayoutBreakpoint',
        (tester) async {
      await pumpShell(tester,
          size: const Size(kWideLayoutBreakpoint, 800),
          initial: AppRoutes.home);
      expect(find.byType(WebSidebar), findsOneWidget);
    });

    testWidgets('one pixel under the breakpoint is the mobile layout',
        (tester) async {
      await pumpShell(tester,
          size: const Size(kWideLayoutBreakpoint - 1, 800),
          initial: AppRoutes.home);
      expect(find.byType(WebSidebar), findsNothing);
      expect(find.byType(MhadBottomNav), findsOneWidget);
    });

    for (final gate in const [
      AppRoutes.disclaimer,
      AppRoutes.modeSelection,
      AppRoutes.onboarding,
    ]) {
      testWidgets('gate route $gate hides all app nav (narrow + wide)',
          (tester) async {
        await pumpShell(tester, size: phone, initial: gate);
        expect(find.byType(MhadBottomNav), findsNothing);

        tester.view.physicalSize = desktop;
        await tester.pumpAndSettle();
        expect(find.byType(WebSidebar), findsNothing);
        // Centered in the reading column without a sidebar.
        expect(tester.getSize(find.byKey(pageKey(gate))).width,
            kReadingMaxWidth);
      });
    }

    testWidgets('bottom nav appears once the user leaves a gate route',
        (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.disclaimer);
      expect(find.byType(MhadBottomNav), findsNothing);

      appRouter.go(AppRoutes.home);
      await tester.pumpAndSettle();
      expect(find.byType(MhadBottomNav), findsOneWidget);
    });
  });

  // ── Wide content width (fill vs reading vs full-bleed) ───────────────────

  group('wide content width', () {
    double contentArea(WidgetTester tester) =>
        desktop.width - tester.getSize(find.byType(WebSidebar)).width;

    double pageWidth(WidgetTester tester, String loc) =>
        tester.getSize(find.byKey(pageKey(loc))).width;

    testWidgets('reading routes are capped at kReadingMaxWidth and centered',
        (tester) async {
      await pumpShell(tester, size: desktop, initial: AppRoutes.settings);
      expect(pageWidth(tester, AppRoutes.settings), kReadingMaxWidth);

      // Centered: equal gutters either side within the content area.
      final sidebarRight = tester.getTopRight(find.byType(WebSidebar)).dx;
      final rect = tester.getRect(find.byKey(pageKey(AppRoutes.settings)));
      expect(rect.left - sidebarRight, closeTo(desktop.width - rect.right, 1));
    });

    for (final loc in const [
      AppRoutes.home,
      AppRoutes.education,
      AppRoutes.assistant,
      '/wizard/1',
    ]) {
      testWidgets('fill route $loc spans the content area flush to the sidebar',
          (tester) async {
        await pumpShell(tester, size: desktop, initial: loc);
        expect(pageWidth(tester, loc), contentArea(tester));
        expect(tester.getTopLeft(find.byKey(pageKey(loc))).dx,
            tester.getTopRight(find.byType(WebSidebar)).dx);
      });
    }

    for (final loc in const ['/export/1', '/sign/1']) {
      testWidgets('full-bleed route $loc fills the whole content area',
          (tester) async {
        await pumpShell(tester, size: desktop, initial: loc);
        expect(pageWidth(tester, loc), contentArea(tester));
      });
    }

    testWidgets(
        'a route pushed over a reading route uses ITS layout, not the '
        'underlying one', (tester) async {
      await pumpShell(tester, size: desktop, initial: AppRoutes.settings);
      unawaited(appRouter.push('/export/7'));
      await tester.pumpAndSettle();

      expect(currentRoute(), '/export/7');
      expect(pageWidth(tester, '/export/7'), contentArea(tester),
          reason: 'pushed export must not inherit the 760px reading column');
    });
  });

  // ── Bottom nav highlight + navigation ────────────────────────────────────

  group('bottom nav', () {
    // Only the active pill renders its text label; inactive pills are
    // icon-only (label is in Semantics). So a visible Text with the label is
    // the active-tab signal, scoped to the nav so page text can't match.
    Finder navText(String label) => find.descendant(
        of: find.byType(MhadBottomNav), matching: find.text(label));

    const tabs = {
      AppRoutes.home: 'Home',
      AppRoutes.education: 'Learn',
      AppRoutes.settings: 'Settings',
      AppRoutes.assistant: 'Ask',
      AppRoutes.aiSetup: 'Ask',
    };

    for (final entry in tabs.entries) {
      testWidgets('${entry.key} highlights exactly the "${entry.value}" tab',
          (tester) async {
        await pumpShell(tester, size: phone, initial: entry.key);
        for (final label in const ['Home', 'Learn', 'Ask', 'Settings', 'More']) {
          expect(navText(label),
              label == entry.value ? findsOneWidget : findsNothing,
              reason: '"$label" active state on ${entry.key}');
        }
      });
    }

    testWidgets('a secondary route highlights no tab', (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.privacyPolicy);
      for (final label in const ['Home', 'Learn', 'Ask', 'Settings', 'More']) {
        expect(navText(label), findsNothing);
      }
    });

    testWidgets('tapping a tab navigates and moves the highlight',
        (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.home);

      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
      expect(currentRoute(), AppRoutes.settings);
      expect(navText('Settings'), findsOneWidget);
      expect(navText('Home'), findsNothing);

      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      expect(currentRoute(), AppRoutes.home);
    });

    testWidgets('Ask goes to AI setup when no key is configured',
        (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.home);
      await tester.tap(find.bySemanticsLabel('Ask'));
      await tester.pumpAndSettle();
      expect(currentRoute(), AppRoutes.aiSetup);
    });

    testWidgets('Ask goes straight to the assistant when a key is set',
        (tester) async {
      await pumpShell(tester,
          size: phone, initial: AppRoutes.home, apiKey: 'test-key');
      await tester.tap(find.bySemanticsLabel('Ask'));
      await tester.pumpAndSettle();
      expect(currentRoute(), AppRoutes.assistant);
    });

    testWidgets('tapping the already-active tab does not navigate',
        (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.education);
      var notifications = 0;
      void listener() => notifications++;
      appRouter.routerDelegate.addListener(listener);
      addTearDown(() => appRouter.routerDelegate.removeListener(listener));

      // The active pill shows its visible label; tap that.
      await tester.tap(navText('Learn'));
      await tester.pumpAndSettle();
      expect(notifications, 0);
      expect(currentRoute(), AppRoutes.education);
    });

    testWidgets('every nav pill keeps a 48px-tall tap target', (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.home);
      final inkWells = find.descendant(
          of: find.byType(MhadBottomNav), matching: find.byType(InkWell));
      expect(inkWells, findsNWidgets(5));
      for (final e in inkWells.evaluate()) {
        expect(tester.getSize(find.byWidget(e.widget)).height,
            greaterThanOrEqualTo(48));
      }
    });
  });
}
