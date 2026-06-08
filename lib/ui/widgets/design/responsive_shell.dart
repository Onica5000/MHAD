import 'package:flutter/material.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/web_sidebar.dart';

/// Width threshold at which we switch from the mobile layout to the desktop
/// fixed-sidebar layout. Matches the prototype's web breakpoint.
const double kWideLayoutBreakpoint = 1000;

/// Comfortable reading measure for the *default* screen — prose, forms, and
/// single-column layouts (privacy policy, settings, wizard steps, most
/// detail screens). Long-form text and form fields read best at a
/// constrained width, so on wide monitors the surplus becomes side gutters
/// rather than stretching a paragraph to 180+ characters per line. The
/// wizard's internal `_WideStepRail` + 760-max-width form column sits inside
/// this envelope, so it is unaffected.
const double kReadingMaxWidth = 1100;

/// Wider cap for screens whose layouts are explicitly built to use the extra
/// horizontal space — multi-column dashboards, card grids, and two-pane
/// views. Previously every route shared the 1100px reading cap, which
/// starved these layouts and left large empty gutters on ≥1440px monitors
/// (e.g. the education topic grid was pinned to 3 columns, the home
/// dashboard column was needlessly narrow). At 1480 a 1440px viewport fills
/// edge-to-edge (minus the sidebar) and a 1920px viewport keeps a modest,
/// editorial gutter instead of a cavernous one.
const double kWideContentMaxWidth = 1480;

/// Routes that opt into [kWideContentMaxWidth]. Each already branches to a
/// horizontal layout at ≥1000px and only needs the room to spread into:
///   - home (`/`)            — dashboard column + right "Tools" sidebar
///   - education             — 2–4 column topic grid (`(w/360).clamp(2,4)`)
///   - assistant             — chat column + right context panel
///   - export (`/export/…`)  — preview / options two-pane
/// Everything else keeps [kReadingMaxWidth]. Matched against the concrete
/// path, so the parameterized `export` route is checked by prefix.
bool _routeUsesWideContent(String route) =>
    route == AppRoutes.home ||
    route == AppRoutes.education ||
    route == AppRoutes.assistant ||
    route.startsWith('/export/');

/// Wraps [child] so the navigation chrome matches the prototype:
///
///  - **Wide screens (≥ [kWideLayoutBreakpoint])** — a persistent
///    [WebSidebar] is shown to the left of the content (`web.jsx`).
///  - **Narrow screens** — [child] is returned unchanged. Top-level screens
///    supply their own floating bottom nav (`mobile.jsx`); there is no
///    hamburger drawer anywhere, exactly as the prototype specifies.
class ResponsiveShell extends StatelessWidget {
  final Widget child;
  const ResponsiveShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < kWideLayoutBreakpoint) {
      return child;
    }
    // ResponsiveShell lives in MaterialApp.router's builder callback, which
    // is *above* InheritedGoRouter in the widget tree. GoRouterState.of only
    // searches ancestors, so it cannot find the router here. Instead we read
    // the current route from the global appRouter directly and rebuild on
    // every navigation by listening to the routerDelegate (a ChangeNotifier).
    return ListenableBuilder(
      listenable: appRouter.routerDelegate,
      builder: (context, _) {
        final route =
            appRouter.routerDelegate.currentConfiguration.uri.path;
        // Route-aware content cap: space-using layouts (dashboard, grids,
        // two-pane) get [kWideContentMaxWidth]; prose/forms keep the tighter
        // [kReadingMaxWidth]. The cap is applied INSIDE the sidebar-adjusted
        // area, so any surplus beyond the cap falls as symmetric side
        // gutters, keeping each surface at its ideal measure.
        final maxContentWidth = _routeUsesWideContent(route)
            ? kWideContentMaxWidth
            : kReadingMaxWidth;
        return Row(
          children: [
            WebSidebar(activeRoute: route),
            Expanded(
              child: ClipRect(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
