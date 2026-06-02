import 'package:flutter/material.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/web_sidebar.dart';

/// Width threshold at which we switch from the mobile layout to the desktop
/// fixed-sidebar layout. Matches the prototype's web breakpoint.
const double kWideLayoutBreakpoint = 1000;

/// Soft cap on content width inside the desktop shell. The prototype's web
/// artboards are 1200px wide; at viewport widths greater than that, the
/// extra space becomes side gutters so the content keeps its editorial
/// proportions instead of stretching to fill 1920+ px monitors. Screens
/// that genuinely need the full width (e.g. the wizard's step rail layout)
/// can ignore the cap by opting out — none currently do; the wizard's
/// internal `_WideStepRail` + 760-max-width form column sits inside this
/// envelope.
const double kMaxContentWidth = 1100;

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
        return Row(
          children: [
            WebSidebar(activeRoute: route),
            Expanded(
              child: ClipRect(
                // Soft max-content cap — keeps the editorial column
                // proportional on 1920+ px monitors. The cap is applied
                // INSIDE the sidebar-adjusted area, so a 1440px viewport
                // with a 240px sidebar gives a 1200px content area which
                // is already under the cap; a 1920px viewport gives a
                // 1680px area, of which 1100 is used for content and
                // ~290px gutters fall on each side.
                child: Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: kMaxContentWidth),
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
