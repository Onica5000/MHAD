// Every route the app can show has a browser-tab title (review R9), in every
// shipped locale.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/route_titles.dart';
import 'package:mhad/ui/router.dart';

Iterable<String> _paths(List<RouteBase> routes) sync* {
  for (final r in routes) {
    if (r is GoRoute) yield r.path;
    yield* _paths(r.routes);
  }
}

void main() {
  final paths = _paths(appRouter.configuration.routes)
      .map((p) => p.replaceAll(':directiveId', '1'))
      .toList();

  test('the router is not empty', () => expect(paths.length, greaterThan(20)));

  for (final locale in AppLocalizations.supportedLocales) {
    test('every route has a tab title in ${locale.languageCode}', () async {
      final l = await AppLocalizations.delegate.load(locale);
      for (final path in paths) {
        final usesAppName =
            path == AppRoutes.home || path == AppRoutes.modeSelection;
        final page = routePageName(l, path);
        if (usesAppName) {
          expect(page, isNull, reason: path);
          expect(routeTitle(l, path), l.mainAppTitle);
        } else {
          expect(page, isNotNull, reason: '$path has no tab title');
          expect(routeTitle(l, path), contains(page!));
        }
      }
    });
  }

  test('parameterised locations resolve by their first segment', () async {
    final l = await AppLocalizations.delegate.load(const Locale('en'));
    expect(routePageName(l, '/wizard/5?step=3'), l.homeHeroYourMhad);
    expect(routeTitle(l, '/education'), 'Learn · PA MHAD');
  });
}
