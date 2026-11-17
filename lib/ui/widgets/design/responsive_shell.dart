import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/route_titles.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/bottom_nav.dart';
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
    route.startsWith('/wizard/') ||
    route.startsWith('/upload/');

/// Pre-dashboard gate / welcome screens, shown BEFORE the user reaches the
/// home dashboard (disclaimer → privacy mode → onboarding intro). The
/// persistent [WebSidebar] is hidden on these so the first-run flow has no app
/// navigation chrome yet — the sidebar first appears on the dashboard and
/// stays for the rest of the app.
bool _routeHidesSidebar(String route) =>
    route == AppRoutes.disclaimer ||
    route == AppRoutes.modeSelection ||
    route == AppRoutes.onboarding;

/// Routes in desktop "focus mode": the 232px sidebar shrinks to a 72px icon
/// rail so a dense multi-column screen gets the room. The wizard only for now
/// (review R7 / "cut or defer": /sign and /upload are short single-column
/// flows, where the compact rail's accessibility cost buys little).
bool routeUsesFocusMode(String route) => route.startsWith('/wizard/');

/// Width the desktop shell gives the sidebar on [route]: 0 on the gates,
/// [WebSidebar.compactWidth] in focus mode, [WebSidebar.width] otherwise.
/// ONE definition for the shell and any screen needing its content width.
double sidebarWidthFor(String route) {
  if (_routeHidesSidebar(route)) return 0;
  return routeUsesFocusMode(route)
      ? WebSidebar.compactWidth
      : WebSidebar.width;
}

/// The routed pages get their OWN semantics container. Every page route has a
/// modal barrier whose BlockSemantics drops all semantics painted before it
/// in the same container — and the sidebar is painted before the Navigator,
/// so on desktop the whole sidebar (nav, Get help, 988 crisis card) was
/// invisible to screen readers. A container boundary keeps the barrier's
/// blocking inside the page area.
Widget _pageSemantics(Widget page) => Semantics(container: true, child: page);

/// Browser-tab title for the current route (see route_titles.dart). Built
/// inside the route listener so it updates on every navigation.
Widget _titled(BuildContext context, String route, Widget child) => Title(
      title: routeTitle(context.l10n, route),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: child,
    );

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
    final wide = width >= kWideLayoutBreakpoint;
    // Narrow (mobile): a persistent bottom nav across the whole app, with each
    // screen's content (and its own bottom action bar) above it. The routed
    // Navigator (`child`) stays OUTSIDE the route listener so navigation never
    // rebuilds it mid-notification ("markNeedsBuild during build"); only the
    // nav strip listens and rebuilds. Hidden on pre-app gate screens.
    if (!wide) {
      return Column(
        children: [
          Expanded(child: _pageSemantics(child)),
          _RouteListener(
            listenable: appRouter.routerDelegate,
            builder: (context, _) {
              final route = appRouter
                      .routerDelegate.currentConfiguration.lastOrNull
                      ?.matchedLocation ??
                  appRouter.routerDelegate.currentConfiguration.uri.path;
              // While the on-screen keyboard is up, the nav would sit above it
              // AND the routed Scaffold subtracts the full inset again, costing
              // the page the nav's height twice (review R4). Hide it then.
              final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
              final hideNav = _routeHidesSidebar(route) || keyboardOpen;
              return _titled(
                context,
                route,
                hideNav
                    ? const SizedBox.shrink()
                    : MhadBottomNav(activeRoute: route),
              );
            },
          ),
        ],
      );
    }

    // ResponsiveShell lives in MaterialApp.router's builder callback, which
    // is *above* InheritedGoRouter in the widget tree. GoRouterState.of only
    // searches ancestors, so it cannot find the router here. Instead we read
    // the current route from the global appRouter directly and rebuild on
    // every navigation by listening to the routerDelegate (a ChangeNotifier).
    return _RouteListener(
      listenable: appRouter.routerDelegate,
      builder: (context, _) {
        // Use the TOP match's concrete location, not `.uri.path`.
        // RouteMatchList.uri intentionally ignores ImperativeRouteMatches, so
        // after an imperative `push()` it reports the route *underneath* the
        // pushed one. That made a pushed `/export/…` inherit the layout of
        // wherever it was opened from — full-bleed when pushed from a fill
        // route (Learn), but crammed into the 760px reading column when pushed
        // from a reading route (Settings, past-directive detail). `last`
        // includes imperative matches and exposes the real concrete path
        // (e.g. `/export/5`), so the shell always picks the right shell.
        final matchList =
            appRouter.routerDelegate.currentConfiguration;
        final route =
            matchList.lastOrNull?.matchedLocation ?? matchList.uri.path;
        // Pre-dashboard gate/welcome screens: no sidebar yet. Center the
        // reading content in the full window (no nav rail) until the user
        // reaches the dashboard.
        if (_routeHidesSidebar(route)) {
          // Gutters in the page background (no white "strip"), and a TIGHT
          // width like the reading branch below — the old Align+ConstrainedBox
          // passed loose constraints, the pattern that collapsed Row>Expanded
          // in release builds (review R15).
          return _titled(
            context,
            route,
            ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth < kReadingMaxWidth
                      ? constraints.maxWidth
                      : kReadingMaxWidth;
                  return ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SizedBox(
                        width: w,
                        height: constraints.maxHeight,
                        child: _pageSemantics(child),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        // Two layout modes, matching the design's two web shells:
        //   FILL    — dense screens fill the width flush to the sidebar
        //             (START-aligned, generous cap).
        //   READING — prose/flow screens sit in a centered reading column.
        final fills = _routeFills(route);
        // Pages that must use the FULL content width (no editorial cap, no
        // centered gutters), handed TIGHT constraints below so their content
        // fills flush from the sidebar to the window edge:
        //   /export/          — the 3-column export tool (thumbnails · preview · rail)
        //   /sign/            — the "Make it legal" signing screen (fill, not centered)
        final bool fullBleed = route.startsWith('/export/') ||
            route.startsWith('/sign/');
        final page = _pageSemantics(child);
        // Tab order: the PAGE first, then the sidebar (review R8) — otherwise
        // keyboard users crossed ~9 sidebar stops before every form field.
        // Overlay.wrap: the sidebar is built ABOVE the routed Navigator (whose
        // Overlay hosts the pages), so its tooltips — the compact rail's only
        // visible labels — need their own Overlay; without it Tooltip throws
        // "No Overlay widget found". Wrapping the whole row lets a tooltip
        // draw over the page area.
        return _titled(
          context,
          route,
          Overlay.wrap(
            child: FocusTraversalGroup(
            policy: OrderedTraversalPolicy(),
            child: Row(
          children: [
            FocusTraversalOrder(
              order: const NumericFocusOrder(2),
              child: FocusTraversalGroup(
                child: WebSidebar(
                  activeRoute: route,
                  compact: routeUsesFocusMode(route),
                ),
              ),
            ),
            // FULL-BLEED (export): hand the child the Expanded's TIGHT width
            // directly. The Align path below passes *loose* constraints, which
            // lets a self-sizing Scaffold/Row collapse to its columns' intrinsic
            // width (~760px) and float centered with empty gutters on a wide
            // monitor — the bug we keep chasing. A direct child forces it to
            // fill the whole content area, flush from sidebar to window edge.
            if (fullBleed)
              Expanded(
                child: FocusTraversalOrder(
                  order: const NumericFocusOrder(1),
                  child: FocusTraversalGroup(child: page),
                ),
              )
            else
              Expanded(
                // Hand the child a TIGHT width, not a capped-but-loose one.
                // The old `Align > ConstrainedBox(maxWidth:…)` only bounded the
                // *max* width; Align passes loose constraints, so a self-sizing
                // Scaffold/ListView could collapse toward a degenerate width. In
                // a --release build (asserts stripped) that degenerate width is
                // effectively unbounded: a plain Text then renders at its full
                // natural width (looks fine) while every `Row > Expanded` inside
                // collapses to 0 and its text wraps one word per line — the
                // "vertical text" bug (seen on /side-effects, latent on every
                // reading route). A LayoutBuilder + SizedBox(width:) gives the
                // child an exact width so it can never self-collapse.
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cap = fills ? kFillMaxWidth : kReadingMaxWidth;
                    final w = constraints.maxWidth < cap
                        ? constraints.maxWidth
                        : cap;
                    // The gutters beside a capped page take the page
                    // background (they used to show the bare white canvas,
                    // so reading routes looked like a floating strip).
                    return ColoredBox(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: ClipRect(
                        child: Align(
                          // FILL: flush to the sidebar (top-left).
                          // READING: centered reading column.
                          alignment:
                              fills ? Alignment.topLeft : Alignment.topCenter,
                          child: SizedBox(
                            width: w,
                            child: FocusTraversalOrder(
                              order: const NumericFocusOrder(1),
                              child: FocusTraversalGroup(child: page),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
            ),
          ),
          ),
        );
      },
    );
  }
}

/// A [ListenableBuilder] for the router delegate that tolerates notifications
/// fired mid-build.
///
/// The shell sits ABOVE the routed Navigator, but the router can notify while
/// its own subtree is building: on the initial route parse, and when an
/// imperative `push()` settles. On wide layouts the routed child is built
/// inside this listener (via LayoutBuilder), so a plain [ListenableBuilder]
/// would call markNeedsBuild on an ancestor during build — a debug assert that
/// also drops the rebuild, leaving the shell on the previous route's layout.
/// Here a notification during the build/layout phase is deferred to the end
/// of the frame; any other notification rebuilds immediately.
class _RouteListener extends StatefulWidget {
  final Listenable listenable;
  final TransitionBuilder builder;
  const _RouteListener({required this.listenable, required this.builder});

  @override
  State<_RouteListener> createState() => _RouteListenerState();
}

class _RouteListenerState extends State<_RouteListener> {
  bool _rebuildScheduled = false;

  @override
  void initState() {
    super.initState();
    widget.listenable.addListener(_onChange);
  }

  @override
  void didUpdateWidget(_RouteListener oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listenable != widget.listenable) {
      oldWidget.listenable.removeListener(_onChange);
      widget.listenable.addListener(_onChange);
    }
  }

  @override
  void dispose() {
    widget.listenable.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase != SchedulerPhase.persistentCallbacks) {
      if (mounted) setState(() {});
      return;
    }
    if (_rebuildScheduled) return;
    _rebuildScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _rebuildScheduled = false;
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, null);
}
