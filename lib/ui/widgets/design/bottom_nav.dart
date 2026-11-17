import 'package:flutter/material.dart';
import 'package:mhad/ui/widgets/design/primary_destinations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/more_sheet.dart';

/// Floating pill bottom navigation for the top-level destinations.
///
/// Mirrors the prototype's mobile nav (`mobile.jsx`): a rounded card pinned
/// near the bottom with `Home · Learn · Ask · Settings`. The active
/// destination is highlighted with `primaryLight` and is the only item that
/// shows its text label — inactive items are icon-only, exactly as the
/// prototype renders `{n.icon}{n.active && n.label}`.
///
/// Rendered ONCE in [ResponsiveShell] as a persistent bottom strip on narrow
/// (mobile) layouts — present on every in-app screen, with each screen's own
/// content (including its own bottom action bar) sitting above it. Because the
/// shell lives above the router, this reads the active route from [activeRoute]
/// (supplied by the shell) and navigates via the global [appRouter] rather than
/// `context.go`/`GoRouterState.of` (which need an InheritedGoRouter ancestor).
class MhadBottomNav extends ConsumerWidget {
  /// The current top-level location, supplied by the shell.
  final String activeRoute;
  const MhadBottomNav({required this.activeRoute, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final loc = activeRoute;
    final aiReady =
        ref.watch(apiKeyProvider).value?.isNotEmpty ?? false;

    final items = <_NavItem>[
      // Home · Learn · Ask · Settings — the shared definition (also used by
      // the More sheet when the wizard hides this nav).
      for (final d in primaryDestinations(context, aiReady: aiReady))
        _NavItem(
          icon: d.icon,
          activeIcon: d.activeIcon,
          label: d.label,
          active: d.isActiveOn(loc),
          onTap: () => appRouter.go(d.route),
        ),
      // "More" — opens a bottom sheet with the secondary destinations the
      // four primary tabs can't hold (Autofill, Download & print, Get help,
      // Reset). Opened via the root navigator since the shell is above the
      // router. An action, never an "active" destination.
      _NavItem(
        icon: Icons.more_horiz,
        activeIcon: Icons.more_horiz,
        label: context.l10n.navMore,
        active: false,
        onTap: () {
          final ctx = rootNavigatorKey.currentContext;
          if (ctx != null) showMoreSheet(ctx, ref);
        },
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        // Fixed, bounded height so the Scaffold body keeps its full
        // viewport — the bar never grows greedily.
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: p.card,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
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

    // Every tab shows its icon AND a short label (2026-11 redesign): an
    // icon-only tab was ambiguous (the sparkle for "Ask" especially). The
    // active tab gets a tinted pill behind its icon and a bold label.
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
          decoration: BoxDecoration(
            color: item.active ? p.primaryLight : Colors.transparent,
            borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          ),
          child: Icon(
            item.active ? item.activeIcon : item.icon,
            size: 22,
            color: item.active ? p.onPrimaryLight : p.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          maxLines: 1,
          style: TextStyle(
            fontSize: 12,
            fontWeight: item.active ? FontWeight.w700 : FontWeight.w500,
            color: item.active ? p.primary : p.textMuted,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      selected: item.active,
      label: item.label,
      child: InkWell(
        onTap: item.active ? null : item.onTap,
        borderRadius: BorderRadius.circular(DesignTokens.iconTileRadius),
        // A 56px-tall hit target (above the 48px guideline). FittedBox
        // (scaleDown) lets a long label (Spanish "Configuración") shrink to
        // its ~1/5 slot instead of overflowing; it never scales up. The
        // visual content is excluded from semantics: the Semantics label
        // above already says it, once. The 4px side padding INSIDE the
        // FittedBox keeps neighbours apart: Spanish "Aprender" (bold, active)
        // ran straight into "Preguntar" — now a long label shrinks a little
        // instead, leaving at least 8px between labels.
        child: SizedBox(
          height: 56,
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ExcludeSemantics(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
