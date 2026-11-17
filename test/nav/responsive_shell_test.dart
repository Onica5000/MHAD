import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';
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

    // ── 2026-11 shell foundation ────────────────────────────────────────

    testWidgets('wide: sidebar destinations are visible to screen readers',
        (tester) async {
      // Page routes' modal barriers used to BlockSemantics the sidebar
      // (painted before the Navigator): desktop screen readers could not
      // reach Start/Learn/Settings or the 988 card at all.
      final handle = tester.ensureSemantics();
      await pumpShell(tester, size: desktop, initial: AppRoutes.settings);
      expect(find.bySemanticsLabel(RegExp('^Learn')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('988')), findsOneWidget);
      handle.dispose();
    });

    testWidgets('focus mode: wizard + Export get the 72px rail, others 232px',
        (tester) async {
      await pumpShell(tester, size: desktop, initial: '/wizard/1');
      expect(tester.getSize(find.byType(WebSidebar)).width,
          WebSidebar.compactWidth);
      expect(sidebarWidthFor('/wizard/1'), WebSidebar.compactWidth);
      expect(sidebarWidthFor('/export/1'), WebSidebar.compactWidth);
      expect(sidebarWidthFor('/sign/1'), WebSidebar.width);
      expect(sidebarWidthFor(AppRoutes.settings), WebSidebar.width);
      expect(sidebarWidthFor(AppRoutes.disclaimer), 0);
    });

    testWidgets('narrow: the wizard hides the bottom nav, other pages keep it',
        (tester) async {
      expect(routeHidesBottomNav('/wizard/1'), isTrue);
      expect(routeHidesBottomNav('/export/1'), isFalse);
      await pumpShell(tester, size: phone, initial: '/wizard/1');
      expect(find.byType(MhadBottomNav), findsNothing);
      appRouter.go(AppRoutes.settings);
      await tester.pumpAndSettle();
      expect(find.byType(MhadBottomNav), findsOneWidget);
    });

    testWidgets('focus-mode rail still exposes every destination by name',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpShell(tester, size: desktop, initial: '/wizard/1');
      for (final label in ['Start', 'Learn', 'Settings', 'Reset Form']) {
        expect(find.bySemanticsLabel(RegExp('^$label')), findsOneWidget,
            reason: '$label missing from the compact rail');
      }
      handle.dispose();
    });

    testWidgets('narrow: the bottom nav hides while the keyboard is open',
        (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.settings);
      expect(find.byType(MhadBottomNav), findsOneWidget);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(find.byType(MhadBottomNav), findsNothing);
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
        // Gates are capped at kGateMaxWidth (wide enough for SplitHero's
        // photo panel beside the content) and get no sidebar.
        expect(tester.getSize(find.byKey(pageKey(gate))).width,
            desktop.width < kGateMaxWidth ? desktop.width : kGateMaxWidth);
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
    // Every tab shows its label (2026-11 redesign), so the active-tab signal
    // is the tab's Semantics `selected` state — what a screen reader
    // announces. navText finds a tab's visible label, scoped to the nav.
    Finder navText(String label) => find.descendant(
        of: find.byType(MhadBottomNav), matching: find.text(label));

    bool tabSelected(WidgetTester tester, String label) => tester
        .widgetList<Semantics>(find.descendant(
            of: find.byType(MhadBottomNav), matching: find.byType(Semantics)))
        .where((w) => w.properties.label == label)
        .single
        .properties
        .selected ==
        true;

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
          expect(navText(label), findsOneWidget,
              reason: 'every tab shows its label');
          expect(tabSelected(tester, label), label == entry.value,
              reason: '"$label" active state on ${entry.key}');
        }
      });
    }

    testWidgets('a secondary route highlights no tab', (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.privacyPolicy);
      for (final label in const ['Home', 'Learn', 'Ask', 'Settings', 'More']) {
        expect(tabSelected(tester, label), isFalse);
      }
    });

    testWidgets('tapping a tab navigates and moves the highlight',
        (tester) async {
      await pumpShell(tester, size: phone, initial: AppRoutes.home);

      await tester.tap(find.bySemanticsLabel('Settings'));
      await tester.pumpAndSettle();
      expect(currentRoute(), AppRoutes.settings);
      expect(tabSelected(tester, 'Settings'), isTrue);
      expect(tabSelected(tester, 'Home'), isFalse);

      await tester.tap(find.bySemanticsLabel('Home'));
      await tester.pumpAndSettle();
      expect(currentRoute(), AppRoutes.home);
    });

    testWidgets('Ask opens Ask AI without any key (copy-and-paste handoff)',
        (tester) async {
      // The API-key AI is hidden by default (AiConfig.apiModeVisible), so
      // AI help needs no setup.
      await pumpShell(tester, size: phone, initial: AppRoutes.home);
      await tester.tap(find.bySemanticsLabel('Ask'));
      await tester.pumpAndSettle();
      expect(currentRoute(), AppRoutes.assistant);
    });

    testWidgets('with the API path shown, Ask without a key goes to AI setup',
        (tester) async {
      final saved = AppData.instance;
      AppData.instance = AppData.fromJson(const {
        'ai': {'apiModeVisible': true},
      });
      addTearDown(() => AppData.instance = saved);
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
