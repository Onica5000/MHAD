import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';

/// A Back affordance that never dead-ends on mobile.
///
/// Some screens (Export, Autofill) are opened with `go()` from the WebSidebar /
/// the mobile "More" sheet so the desktop sidebar stays the way back. But on a
/// narrow layout there is no persistent sidebar, and `go()` leaves nothing on
/// the navigator to pop — so an in-body "Back" that only called `maybePop()`
/// did nothing, stranding the user.
///
/// [safeBack] first tries to pop (works when the screen was `push()`ed). If
/// there's nothing to pop, it falls back to Home — but ONLY on narrow widths,
/// where the user would otherwise be stuck. On wide layouts behaviour is
/// unchanged (pop-only; the WebSidebar is the way back), so the desktop
/// experience is untouched.
Future<void> safeBack(BuildContext context) async {
  final nav = Navigator.of(context);
  if (await nav.maybePop()) return;
  if (!context.mounted) return;
  final isNarrow = MediaQuery.sizeOf(context).width < kWideLayoutBreakpoint;
  if (isNarrow) context.go(AppRoutes.home);
}
