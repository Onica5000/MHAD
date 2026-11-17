import 'package:flutter/material.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/ui/app_actions.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Persistent left-rail navigation for wide (desktop / web) screens.
///
/// Mirrors the prototype's `WebSidebar`: brand mark, primary destinations,
/// crisis card pinned to the bottom, and a session-mode chip. On narrow
/// screens this is not shown — top-level screens use the floating
/// `MhadBottomNav` instead.
class WebSidebar extends ConsumerWidget {
  final String activeRoute;

  /// Focus mode (see `routeUsesFocusMode` in responsive_shell.dart): a 72px
  /// icon rail with the SAME destinations, each with a tooltip (also shown on
  /// keyboard focus) and a full screen-reader label.
  final bool compact;
  const WebSidebar({required this.activeRoute, this.compact = false, super.key});

  static const double width = 232;
  static const double compactWidth = 72;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final aiReady =
        ref.watch(apiKeyProvider).value?.isNotEmpty ?? false;
    // Most-recently-edited directive — the "Download & print" destination
    // (export is a per-directive route).
    final recentId =
        mostRecentDirectiveId(ref.watch(allDirectivesProvider).value ?? const []);
    // Directive currently in focus: prefer the one in the active route
    // (/wizard/:id, /sign/:id, /export/:id, /upload/:id, /wizard-complete/:id),
    // else the most-recently-edited. This lets "Download & print" open the SAME
    // directive's export as the wizard's "Preview & download packet" button,
    // instead of guessing via most-recent (which differs when you have more
    // than one directive).
    final routeSegs =
        activeRoute.split('/').where((s) => s.isNotEmpty).toList();
    final routeId = routeSegs.length >= 2 ? int.tryParse(routeSegs.last) : null;
    final focusedId = routeId ?? recentId;

    // Items + destinations mirror the design `WebSidebar`:
    // Start · Learn · AI assistant · Download & print · Settings.
    // Navigation goes through the GLOBAL appRouter — the sidebar lives in
    // MaterialApp.router's builder (above InheritedGoRouter), so
    // context.go/push / GoRouterState.of(context) have no router to find and
    // silently fail.
    final items = <_SidebarItem>[
      _SidebarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: context.l10n.navStart,
        isActive: activeRoute == AppRoutes.home,
        onTap: () => appRouter.go(AppRoutes.home),
      ),
      _SidebarItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: context.l10n.navLearn,
        isActive: activeRoute == AppRoutes.education,
        onTap: () => appRouter.go(AppRoutes.education),
      ),
      _SidebarItem(
        icon: Icons.document_scanner_outlined,
        activeIcon: Icons.document_scanner,
        label: context.l10n.navAutofill,
        isActive: activeRoute.startsWith('/upload/'),
        // Reuse the most-recent directive (the one you're working on) so the
        // page autofills it; with none on file (fresh web session), create a
        // Combined directive first. Either way the upload page is reachable
        // again after the AI-setup hop drops you in the assistant.
        onTap: () => openForDirective(ref, AppRoutes.uploadRoute,
            preferredId: recentId),
      ),
      // With the API path hidden (AiConfig.apiModeVisible) this is "Ask AI"
      // — the copy-and-paste handoff needs no setup, so no SET UP badge.
      if (appData.ai.apiModeVisible)
        _SidebarItem(
          icon: aiReady ? Icons.auto_awesome : Icons.auto_awesome_outlined,
          activeIcon: Icons.auto_awesome,
          label: context.l10n.navAiAssistant,
          isActive: activeRoute == AppRoutes.assistant ||
              activeRoute == AppRoutes.aiSetup,
          badge: aiReady
              ? context.l10n.badgeAiReady
              : context.l10n.badgeAiSetUp,
          badgeOk: aiReady,
          onTap: () =>
              appRouter.go(aiReady ? AppRoutes.assistant : AppRoutes.aiSetup),
        )
      else
        _SidebarItem(
          icon: Icons.auto_awesome_outlined,
          activeIcon: Icons.auto_awesome,
          label: context.l10n.navAskAi,
          isActive: activeRoute == AppRoutes.assistant,
          onTap: () => appRouter.go(AppRoutes.assistant),
        ),
      _SidebarItem(
        icon: Icons.print_outlined,
        activeIcon: Icons.print,
        label: context.l10n.navDownloadPrint,
        isActive: activeRoute.startsWith('/export/'),
        // Open the export/preview screen for the directive you're working on
        // (same destination as the wizard's "Preview & download packet"). With
        // none on file (fresh web session — in-memory DB, nothing saved yet)
        // create a Combined directive first rather than bouncing to Home, so
        // this always lands on the export screen.
        //
        // Use go(), NOT push(): every other global-nav item uses go(), and the
        // ResponsiveShell picks the page layout from
        // `routerDelegate.currentConfiguration.uri.path`, which IGNORES
        // ImperativeRouteMatches (i.e. push()). After a push the shell would
        // read the *underlying* route instead — so opening export from a
        // reading route (Settings) rendered the export tool inside the centered
        // 760px reading column, while opening it from a fill route (Learn)
        // looked right. go() replaces the stack so the shell always sees
        // /export/… and gives it the correct full-bleed layout.
        onTap: () => openForDirective(ref, AppRoutes.exportRoute,
            preferredId: focusedId),
      ),
      _SidebarItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: context.l10n.navSettings,
        isActive: activeRoute == AppRoutes.settings,
        onTap: () => appRouter.go(AppRoutes.settings),
      ),
    ];

    // Reset Form — erase everything and start completely fresh. An ACTION,
    // not a destination: it sits apart from the nav below a divider (a
    // destructive control right beside Settings invited mis-taps; its confirm
    // dialog was the only guard). delete_sweep reads as "clear it all".
    final reset = _SidebarItem(
      icon: Icons.delete_sweep_outlined,
      label: context.l10n.navResetForm,
      isActive: false,
      danger: true,
      onTap: () => confirmAndResetSession(ref),
    );

    // Material root: the sidebar is built in MaterialApp.router's builder,
    // ABOVE the routed Navigator, so without its own Material the brand text
    // fell back to Flutter's no-Material text style (the yellow double
    // underline seen under "PA MHAD · ACT 194 · 2004" on the live site).
    if (compact) {
      return Material(
        color: p.card,
        child: _CompactRail(items: items, reset: reset),
      );
    }
    return Material(
      color: p.card,
      child: Container(
      width: width,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            // Brand
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const ExcludeSemantics(child: _BrandMark()),
                  const SizedBox(width: 8),
                  Flexible(
                    // Lets the wordmark wrap instead of overflowing the fixed-width
                    // sidebar when the fallback font runs wide.
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.pinDialogPaMhad,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700, letterSpacing: MhadType.trackingTitle,
                            color: p.text,
                          ),
                        ),
                        Text(
                          context.l10n.webSidebarAct1942004,
                          style: TextStyle(
                            fontSize: 12, letterSpacing: MhadType.trackingLabel,
                            color: p.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: p.border, height: 1),
            const SizedBox(height: 8),

            // Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final item in items)
                    _SidebarItemRow(
                      item: item,
                      active: item.isActive,
                      onTap: item.onTap,
                    ),
                  const SizedBox(height: 12),
                  Divider(color: p.border, height: 1),
                  const SizedBox(height: 12),
                  _SidebarItemRow(
                    item: reset,
                    active: false,
                    onTap: reset.onTap,
                  ),
                ],
              ),
            ),

            // "Get help" pinned directly above the crisis card — peer
            // specialists, rights advocates, clinician referral. Promoted here
            // from Settings so this important info is prominent.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: _GetHelpCard(),
            ),

            // Crisis card pinned at bottom (in addition to the global floating
            // button). Opens the full crisis-resources sheet.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
              child: _CrisisCard(),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  /// Short status shown beside the label (e.g. "SET UP" / "READY" on AI
  /// assistant) — also read by screen readers and shown as a dot on the rail.
  final String? badge;
  final bool badgeOk;

  /// Destructive action (Reset): error-tinted icon and text.
  final bool danger;

  _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeIcon,
    this.badge,
    this.badgeOk = false,
    this.danger = false,
  });

  /// What a screen reader announces: "AI assistant, Set up".
  String get semanticsLabel => badge == null ? label : '$label, $badge';
}

/// Keyboard-focus tint for sidebar controls: InkWell's default focus overlay
/// is nearly invisible on the card background (review R8).
Color _focusTint(MhadPalette p) => p.primary.withValues(alpha: 0.16);

class _SidebarItemRow extends StatelessWidget {
  final _SidebarItem item;
  final bool active;
  final VoidCallback onTap;
  const _SidebarItemRow({
    required this.item,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dangerColor = SemanticColors.errorText(Theme.of(context).brightness);
    final fg = item.danger
        ? dangerColor
        : (active ? p.onPrimaryLight : p.textMuted);
    // One announced node per row: "Learn, button, selected" — not the icon,
    // label and badge as three separate stops.
    return MergeSemantics(
      child: Semantics(
        button: true,
        selected: active,
        child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        // Solid (not transparent) so the whole row reliably hit-tests on the
        // web canvas; p.card matches the sidebar background, so it looks the
        // same as a transparent row but always receives the tap.
        color: active ? p.primaryLight : p.card,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        child: InkWell(
          onTap: onTap,
          focusColor: _focusTint(p),
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Row(
              children: [
                // "You are here" accent bar — transparent when inactive so the
                // row layout never shifts between states.
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: active ? p.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  active && item.activeIcon != null
                      ? item.activeIcon!
                      : item.icon,
                  size: 18,
                  color: item.danger
                      ? dangerColor
                      : (active ? p.primary : p.textMuted),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: fg,
                    ),
                  ),
                ),
                if (item.badge != null)
                  _Badge(item.badge!, tone: item.badgeOk ? 'ok' : 'primary'),
              ],
            ),
          ),
        ),
      ),
        ),
      ),
    );
  }
}

/// The focus-mode sidebar: a 72px icon rail with the same destinations, the
/// separated Reset action, Get help and the 988 crisis button. Every icon has
/// a tooltip that also appears on KEYBOARD focus (Flutter tooltips otherwise
/// show only on hover / long-press) and a full screen-reader label.
class _CompactRail extends StatelessWidget {
  final List<_SidebarItem> items;
  final _SidebarItem reset;
  const _CompactRail({required this.items, required this.reset});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final brightness = Theme.of(context).brightness;
    return Container(
      width: WebSidebar.compactWidth,
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Semantics(
              label: context.l10n.pinDialogPaMhad,
              child: ExcludeSemantics(child: _BrandMark(size: 36)),
            ),
            const SizedBox(height: 12),
            Divider(color: p.border, height: 1, indent: 14, endIndent: 14),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final item in items)
                    _RailButton(
                      icon: item.isActive && item.activeIcon != null
                          ? item.activeIcon!
                          : item.icon,
                      label: item.semanticsLabel,
                      tooltip: item.label,
                      selected: item.isActive,
                      dot: item.badge == null
                          ? null
                          : (item.badgeOk
                              ? SemanticColors.successText(brightness)
                              : p.primary),
                      onTap: item.onTap,
                    ),
                  const SizedBox(height: 8),
                  Divider(color: p.border, height: 1),
                  const SizedBox(height: 8),
                  _RailButton(
                    icon: reset.icon,
                    label: reset.label,
                    tooltip: reset.label,
                    selected: false,
                    iconColor: SemanticColors.errorText(brightness),
                    onTap: reset.onTap,
                  ),
                ],
              ),
            ),
            _RailButton(
              icon: Icons.support_agent_outlined,
              label: context.l10n.moreSheetGetHelp,
              tooltip: context.l10n.moreSheetGetHelp,
              selected: false,
              onTap: openGetHelp,
            ),
            const SizedBox(height: 6),
            // 988 stays one tap away with a 48px target and a red cue.
            _RailButton(
              icon: Icons.health_and_safety_outlined,
              label: context.l10n.webSidebar988CrisisHelp,
              tooltip: context.l10n.webSidebar988CrisisHelp,
              selected: false,
              iconColor: SemanticColors.errorText(brightness),
              background: SemanticColors.errorBg(brightness),
              onTap: openCrisisHelp,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _RailButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final bool selected;
  final Color? dot;
  final Color? iconColor;
  final Color? background;
  final VoidCallback onTap;
  const _RailButton({
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.selected,
    required this.onTap,
    this.dot,
    this.iconColor,
    this.background,
  });

  @override
  State<_RailButton> createState() => _RailButtonState();
}

class _RailButtonState extends State<_RailButton> {
  final _tooltip = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final color = widget.iconColor ??
        (widget.selected ? p.primary : p.textMuted);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Tooltip(
        key: _tooltip,
        message: widget.tooltip,
        excludeFromSemantics: true, // the Semantics label below says it
        preferBelow: false,
        child: Semantics(
          button: true,
          selected: widget.selected,
          label: widget.label,
          child: Material(
            color: widget.selected
                ? p.primaryLight
                : (widget.background ?? p.card),
            borderRadius: BorderRadius.circular(DesignTokens.iconTileRadius),
            child: InkWell(
              onTap: widget.onTap,
              focusColor: _focusTint(p),
              onFocusChange: (focused) {
                if (focused) _tooltip.currentState?.ensureTooltipVisible();
              },
              borderRadius: BorderRadius.circular(DesignTokens.iconTileRadius),
              child: SizedBox(
                height: 48,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ExcludeSemantics(
                      child: Icon(widget.icon, size: 22, color: color),
                    ),
                    if (widget.dot != null)
                      Positioned(
                        top: 10,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: widget.dot,
                            shape: BoxShape.circle,
                            border: Border.all(color: p.card, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The italic "m" brand tile (also mirrored in web/index.html's boot splash).
class _BrandMark extends StatelessWidget {
  final double size;
  const _BrandMark({this.size = 32});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: p.primary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      alignment: Alignment.center,
      child: Text(
        'm',
        style: MhadText.serifAccent(context, size: size * 0.56, color: p.onPrimary),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final String tone; // 'ok' or default (primary)
  const _Badge(this.label, {this.tone = 'primary'});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final bg = tone == 'ok'
        ? SemanticColors.successBgLight
        : p.primaryLight;
    final fg = tone == 'ok'
        ? SemanticColors.successTextLight
        : p.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700, letterSpacing: MhadType.trackingLabel,
          color: fg,
        ),
      ),
    );
  }
}

/// Sidebar crisis card. Tapping opens the full crisis-resources sheet (via the
/// root navigator, since the sidebar sits above the router). Complements the
/// global floating crisis button.
class _CrisisCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
      color: SemanticColors.errorBgLight,
      borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
      child: InkWell(
        onTap: openCrisisHelp,
        focusColor: SemanticColors.errorAccentLight.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
            border: Border.all(color: SemanticColors.errorBorderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.health_and_safety_outlined,
                      size: 14, color: SemanticColors.errorAccentLight),
                  SizedBox(width: 6),
                  // Flexible: may wrap in Spanish or at large text sizes
                  // instead of overflowing the fixed-width sidebar.
                  Flexible(
                    child: Text(
                      context.l10n.webSidebar247Lifeline,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700, letterSpacing: MhadType.trackingLabel,
                        color: SemanticColors.errorTextLight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.webSidebar988CrisisHelp,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: SemanticColors.errorTextLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                context.l10n.webSidebarClickForMoreInformation,
                style: TextStyle(
                  fontSize: 12,
                  color: SemanticColors.errorTextLight.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}

/// True while the facilitator ("Get help") screen is open, so repeated taps on
/// the card don't push multiple stacked copies. Mirrors the crisis-sheet guard.

/// Prominent "Get help" card in the sidebar (above the crisis card): peer
/// specialists, rights advocates, clinician referral. Opens the facilitator
/// screen. Promoted here from Settings so it's clearly visible.
class _GetHelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: Material(
      color: p.primaryTint,
      borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
      child: InkWell(
        onTap: openGetHelp,
        focusColor: _focusTint(p),
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
            border: Border.all(color: p.primary.withValues(alpha: 0.20)),
          ),
          child: Row(
            children: [
              Icon(Icons.support_agent_outlined, size: 20, color: p.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.moreSheetGetHelp,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      context.l10n.webSidebarPeerSupportAdvocatesReferrals,
                      style: TextStyle(
                        fontSize: 12,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
        ),
      ),
    );
  }
}
