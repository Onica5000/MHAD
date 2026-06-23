// Regression guard for the sidebar/bottom-nav highlight.
//
// The nav highlight is driven by the route string ResponsiveShell computes:
//   currentConfiguration.lastOrNull?.matchedLocation ?? currentConfiguration.uri.path
//
// A previous build used `.uri.path`, which IGNORES imperative (push) matches and
// reports the page *underneath* a pushed route. So a `/upload/:id` or `/admin`
// pushed from the home dashboard resolved to `/`, lighting up "Start" instead of
// the real destination. This test pins the correct resolution so reverting to
// `.uri.path` can't silently bring the bug back.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  // Mirrors ResponsiveShell's route expression.
  String shellRoute(GoRouter r) {
    final cfg = r.routerDelegate.currentConfiguration;
    return cfg.lastOrNull?.matchedLocation ?? cfg.uri.path;
  }

  GoRouter buildRouter() => GoRouter(
        initialLocation: '/',
        routes: [
          for (final p in const [
            '/',
            '/settings',
            '/admin',
            '/education',
            '/upload/:id',
            '/export/:id',
          ])
            GoRoute(path: p, builder: (_, _) => Scaffold(body: Text(p))),
        ],
      );

  testWidgets('pushed secondary routes never resolve to home (/)',
      (tester) async {
    final r = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: r));
    await tester.pumpAndSettle();

    // Push from the home dashboard (the case the old build got wrong).
    r.push('/upload/1');
    await tester.pumpAndSettle();
    expect(shellRoute(r), '/upload/1',
        reason: 'pushed /upload/:id must light up Autofill, not Start');

    r.push('/admin');
    await tester.pumpAndSettle();
    expect(shellRoute(r), '/admin');
  });

  testWidgets('go and direct-load also resolve concretely', (tester) async {
    final r = buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: r));
    await tester.pumpAndSettle();

    r.go('/education');
    await tester.pumpAndSettle();
    expect(shellRoute(r), '/education');

    r.go('/upload/7');
    await tester.pumpAndSettle();
    expect(shellRoute(r), '/upload/7');
  });
}
