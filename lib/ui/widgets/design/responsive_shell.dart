import 'package:flutter/material.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/web_sidebar.dart';

/// Width threshold at which we switch from the mobile layout to the desktop
/// fixed-sidebar layout. Matches the prototype's web breakpoint.
const double kWideLayoutBreakpoint = 1000;

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
            Expanded(child: ClipRect(child: child)),
          ],
        );
      },
    );
  }
}
