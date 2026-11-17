import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ui/router.dart';

/// A Back affordance that never dead-ends on mobile.
///
/// Some screens (Export, Autofill) are opened with `go()` from the WebSidebar /
/// the mobile "More" sheet so the desktop sidebar stays the way back. But on a
/// narrow layout there is no persistent sidebar, and `go()` leaves nothing on
/// the navigator to pop — so an in-body "Back" that only called `maybePop()`
/// did nothing, stranding the user.
///
/// [safeBack] first tries to pop (works when the screen was `push()`ed). If
/// there's nothing to pop, it goes Home — on every width (2026-11 overhaul:
/// desktop used to do nothing, so a visible "Back" link silently failed on a
/// page opened from the sidebar or a shared link).
Future<void> safeBack(BuildContext context) async {
  final nav = Navigator.of(context);
  if (await nav.maybePop()) return;
  if (!context.mounted) return;
  context.go(AppRoutes.home);
}
