import 'package:flutter/material.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/web_sidebar.dart';

/// Width threshold at which we switch from the mobile layout to the desktop
/// fixed-sidebar layout. Matches the prototype's web breakpoint.
const double kWideLayoutBreakpoint = 1000;

// The Claude Design web prototype (`web.jsx` / `web-flow-screens.jsx`) uses
// exactly two desktop layout shells, and this shell reproduces both:
//
//   1. SIDEBAR + FILL — dense, multi-column app screens (dashboard, learn, AI,
//      export, wizard). In the prototype these are `WebSidebar(232) + a
//      flex:1 content column` that fills the full remaining width, flush to
//      the sidebar; long paragraphs inside are capped per-element, while card
//      grids span the whole width. See [_routeFills].
//
//   2. WEBCENTER — prose & pre-app flow screens (disclaimer, form-type, quiz,
//      sign, done, crisis, settings, article, …). In the prototype these are a
//      single column centered at `maxWidth 620–720`. The side gutters here are
//      intentional editorial measure, not wasted space.
//
// The previous single centered cap got both wrong: it over-guttered the dense
// screens (content floated in a centered island, detached from the sidebar)
// and over-widened prose to ~1100px.

/// Reading measure for [WebCenter]-style screens — prose, forms, flow, and
/// single-column detail screens. Mirrors the prototype's 620–720px column;
/// 760 also matches the repo's existing wizard form-column width. Centered in
/// the content area, so the surplus falls as symmetric gutters — the design's
/// editorial intent for these screens.
const double kReadingMaxWidth = 760;

/// Upper bound for FILL screens. The prototype fills 100% with no cap, but it
/// was drawn at 1200px artboards; on a real ultra-wide monitor an unbounded
/// fill would stretch the grids past their editorial proportions. 1800 lets
/// every common monitor up to 1920px fill completely (content area ≤ 1688)
/// and only bounds genuine ultra-wide (>2032px viewport). Content is
/// START-aligned (not centered) so it stays flush against the sidebar — never
/// a centered island with a left gutter.
const double kFillMaxWidth = 1800;

/// Routes whose screens have purpose-built multi-column desktop layouts and
/// should FILL the content area (prototype "sidebar + flex:1" pages):
///   - home (`/`)            — dashboard column + right "Tools" sidebar
///   - education             — 2–4 column topic grid (`(w/360).clamp(2,4)`)
///   - assistant             — chat column + right context panel
///   - export (`/export/…`)  — preview / options two-pane
///   - wizard (`/wizard/…`)  — step rail + form + AI rail
/// Everything else uses the centered [kReadingMaxWidth]. Parameterized routes
/// are matched by path prefix.
bool _routeFills(String route) =>
    route == AppRoutes.home ||
    route == AppRoutes.education ||
    route == AppRoutes.assistant ||
    route.startsWith('/export/') ||
    route.startsWith('/wizard/');

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
        // Two layout modes, matching the design's two web shells:
        //   FILL    — dense screens fill the width flush to the sidebar
        //             (START-aligned, generous cap).
        //   READING — prose/flow screens sit in a centered reading column.
        final fills = _routeFills(route);
        return Row(
          children: [
            WebSidebar(activeRoute: route),
            Expanded(
              child: ClipRect(
                child: Align(
                  // FILL: flush to the sidebar (top-left). READING: centered.
                  alignment:
                      fills ? Alignment.topLeft : Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: fills ? kFillMaxWidth : kReadingMaxWidth,
                    ),
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
