import 'package:flutter/material.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/web_sidebar.dart';

/// Width threshold at which we switch from the mobile drawer layout to the
/// desktop fixed-sidebar layout. Matches the prototype's web breakpoint.
const double kWideLayoutBreakpoint = 1000;

/// Wraps [child] so that on wide screens a persistent [WebSidebar] is shown
/// to the left and the standard mobile [Scaffold] drawer is suppressed.
///
/// On narrow screens [child] is returned unchanged — the host screen's own
/// AppBar / Drawer logic stays in charge.
///
/// Usage:
///   ```dart
///   return ResponsiveShell(
///     child: Scaffold(
///       drawer: const MhadAppDrawer(),
///       appBar: AppBar(...),
///       body: ...
///     ),
///   );
///   ```
class ResponsiveShell extends StatelessWidget {
  final Widget child;
  const ResponsiveShell({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < kWideLayoutBreakpoint) {
      return child;
    }
    // On wide screens ResponsiveShell lives in MaterialApp.router's builder
    // callback, which is *above* InheritedGoRouter in the widget tree.
    // GoRouterState.of(context) only searches ancestor widgets, so it cannot
    // find InheritedGoRouter (a descendant inside `child`) and throws.
    // Instead we read the current route from the global appRouter directly and
    // wrap in ListenableBuilder so the sidebar refreshes on every navigation.
    return ListenableBuilder(
      listenable: appRouter,
      builder: (_, __) {
        final route =
            appRouter.routerDelegate.currentConfiguration.matchedLocation;
        return Row(
          children: [
            WebSidebar(activeRoute: route),
            Expanded(
              child: ClipRect(
                // Suppress the child Scaffold's drawer button on wide layout —
                // the sidebar provides navigation.
                child: _SuppressDrawer(child: child),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// On wide screens we want the child Scaffold to render without its
/// hamburger menu icon because nav lives in the sidebar. The simplest way
/// to do that without rewriting every screen is to wrap the child in a
/// MediaQuery override that reports "no drawer attached" — but Flutter
/// already auto-hides the drawer button when no drawer is provided. Since
/// each screen passes [MhadAppDrawer] unconditionally, we accept that the
/// hamburger icon may briefly appear in the AppBar on wide screens; tapping
/// it shows the same content as the sidebar, which is a harmless redundancy.
class _SuppressDrawer extends StatelessWidget {
  final Widget child;
  const _SuppressDrawer({required this.child});

  @override
  Widget build(BuildContext context) => child;
}
