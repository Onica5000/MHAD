import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/more_sheet.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';

/// Floating pill bottom navigation for the top-level destinations.
///
/// Mirrors the prototype's mobile nav (`mobile.jsx`): a rounded card pinned
/// near the bottom with `Home · Learn · Ask · Settings`. The active
/// destination is highlighted with `primaryLight` and is the only item that
/// shows its text label — inactive items are icon-only, exactly as the
/// prototype renders `{n.icon}{n.active && n.label}`.
///
/// Used as a `bottomNavigationBar` on the four top-level screens (Home,
/// Education, Assistant, Settings). Secondary destinations (New directive,
/// Export, AI setup, Privacy policy) are reached contextually and never
/// appear here — also per the prototype.
class MhadBottomNav extends ConsumerWidget {
  const MhadBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On wide (desktop / web) screens the persistent WebSidebar provides
    // navigation, so the floating pill must NOT also render — otherwise both
    // nav systems show at once. Mirror ResponsiveShell's breakpoint.
    if (MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint) {
      return const SizedBox.shrink();
    }

    final p = Theme.of(context).mhadPalette;
    final loc = GoRouterState.of(context).matchedLocation;
    final aiReady =
        ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty ?? false;

    final items = <_NavItem>[
      _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        active: loc == AppRoutes.home,
        onTap: () => context.go(AppRoutes.home),
      ),
      _NavItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: 'Learn',
        active: loc == AppRoutes.education,
        onTap: () => context.go(AppRoutes.education),
      ),
      _NavItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        label: 'Ask',
        active: loc == AppRoutes.assistant || loc == AppRoutes.aiSetup,
        onTap: () => context.go(
          aiReady ? AppRoutes.assistant : AppRoutes.aiSetup,
        ),
      ),
      _NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        active: loc == AppRoutes.settings,
        onTap: () => context.go(AppRoutes.settings),
      ),
      // "More" — opens a bottom sheet with the secondary destinations the
      // four primary tabs can't hold (Autofill, Download & print, AI setup,
      // Get help, Reset). Brings narrow-screen nav to parity with the desktop
      // sidebar. An action, never an "active" destination.
      _NavItem(
        icon: Icons.more_horiz,
        activeIcon: Icons.more_horiz,
        label: 'More',
        active: false,
        onTap: () => showMoreSheet(context, ref),
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        // Fixed, bounded height so the Scaffold body keeps its full
        // viewport — the bar never grows greedily.
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: p.card,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // Transparent Material gives the InkWells an ancestor without
          // painting over the rounded card surface above.
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                children: [
                  for (final item in items)
                    Expanded(child: _NavPill(item: item)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });
}

class _NavPill extends StatelessWidget {
  final _NavItem item;
  const _NavPill({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final fg = item.active ? p.onPrimaryLight : p.textMuted;

    // Visible pill matches the prototype (≈36px tall: icon 20 + 8px padding).
    // The tap target is expanded to a 48px-minimum box around it so it meets
    // the accessibility guideline without changing the prototype visual.
    final pill = Container(
      decoration: BoxDecoration(
        color: item.active ? p.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(item.active ? item.activeIcon : item.icon, size: 20, color: fg),
          if (item.active) ...[
            const SizedBox(width: 6),
            Text(
              item.label,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      button: true,
      selected: item.active,
      label: item.label,
      child: InkWell(
        onTap: item.active ? null : item.onTap,
        borderRadius: BorderRadius.circular(100),
        // 48px tall hit target (meets the accessibility guideline) with the
        // ~36px visible pill centred inside it — matches the prototype look.
        // FittedBox(scaleDown) lets the active item's icon+label shrink to fit
        // its share of the bar instead of overflowing: with five pills the
        // longest active label ("Settings") would otherwise exceed its ~1/5
        // slot on narrow widths. It never scales UP, so wide layouts are
        // unchanged; the InkWell above keeps the full 48px tap target.
        child: SizedBox(
          height: 48,
          child: Center(
            child: FittedBox(fit: BoxFit.scaleDown, child: pill),
          ),
        ),
      ),
    );
  }
}
