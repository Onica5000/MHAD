import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';

/// Persistent left-rail navigation for wide (desktop / web) screens.
///
/// Mirrors the prototype's `WebSidebar`: brand mark, primary destinations,
/// crisis card pinned to the bottom, and a session-mode chip. On narrow
/// screens this is not shown — top-level screens use the floating
/// `MhadBottomNav` instead.
class WebSidebar extends ConsumerWidget {
  final String activeRoute;
  const WebSidebar({required this.activeRoute, super.key});

  static const double width = 232;

  /// Erase everything in this session and return to a blank start. Confirms
  /// first (destructive). Uses the root navigator's context because the sidebar
  /// lives above the router's Navigator/InheritedGoRouter.
  Future<void> _resetForm(WidgetRef ref) async {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (dctx) {
        final cs = Theme.of(dctx).colorScheme;
        return AlertDialog(
          icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 36),
          title: const Text('Reset and start fresh?'),
          content: const Text(
            'This permanently erases everything in this session — all '
            'directives, your AI key, and chat history — and returns you to a '
            'blank start.\n\nExport or print anything you want to keep first. '
            'This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dctx, true),
              style: FilledButton.styleFrom(backgroundColor: cs.error),
              child: const Text('Reset everything'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) return;

    await endPublicSession(ref);
    await WebSessionCache.clear();
    try {
      await ref.read(directiveRepositoryProvider).deleteAllDirectives();
    } catch (_) {}

    // Land on a blank Home — the visibly fresh dashboard is the confirmation.
    appRouter.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final aiReady =
        ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty ?? false;
    // Most-recently-edited directive — the "Download & print" destination
    // (export is a per-directive route).
    final recentId = ref.watch(allDirectivesProvider).maybeWhen(
      data: (list) {
        if (list.isEmpty) return null;
        final sorted = [...list]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        return sorted.first.id;
      },
      orElse: () => null,
    );
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
        onTap: () async {
          final id = recentId ??
              await ref
                  .read(directiveRepositoryProvider)
                  .createDirective(FormType.combined);
          appRouter.go(AppRoutes.uploadRoute(id));
        },
      ),
      _SidebarItem(
        icon: aiReady ? Icons.auto_awesome : Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        label: context.l10n.navAiAssistant,
        isActive: activeRoute == AppRoutes.assistant ||
            activeRoute == AppRoutes.aiSetup,
        trailing: aiReady
            ? _Badge(context.l10n.badgeAiReady, tone: 'ok')
            : _Badge(context.l10n.badgeAiSetUp),
        onTap: () =>
            appRouter.go(aiReady ? AppRoutes.assistant : AppRoutes.aiSetup),
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
        onTap: () async {
          final id = focusedId ??
              await ref
                  .read(directiveRepositoryProvider)
                  .createDirective(FormType.combined);
          appRouter.go(AppRoutes.exportRoute(id));
        },
      ),
      _SidebarItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: context.l10n.navSettings,
        isActive: activeRoute == AppRoutes.settings,
        onTap: () => appRouter.go(AppRoutes.settings),
      ),
      // Reset Form — erase everything and start completely fresh. An action,
      // not a destination (never "active"). delete_sweep reads as "clear it
      // all" rather than restart_alt's "refresh".
      _SidebarItem(
        icon: Icons.delete_sweep_outlined,
        activeIcon: Icons.delete_sweep_outlined,
        label: context.l10n.navResetForm,
        isActive: false,
        onTap: () => _resetForm(ref),
      ),
    ];

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: p.card,
        border: Border(right: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        right: false,
        child: Column(
          children: [
            // Brand
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: p.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'm',
                      style: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontFamilyFallback: const ['Georgia', 'serif'],
                        fontStyle: FontStyle.italic,
                        fontSize: 18,
                        color: p.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PA MHAD',
                        style: TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: p.text,
                        ),
                      ),
                      Text(
                        'ACT 194 · 2004',
                        style: TextStyle(
                          fontFamily: kMonoFamily,
                          fontFamilyFallback: const [
                            'Consolas',
                            'Menlo',
                            'Courier New',
                            'monospace'
                          ],
                          fontSize: 10,
                          letterSpacing: 0.6,
                          color: p.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(color: p.border, height: 1),
            const SizedBox(height: 8),

            // Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                children: [
                  for (final item in items)
                    _SidebarItemRow(
                      item: item,
                      active: item.isActive,
                      onTap: item.onTap,
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
    );
  }
}

class _SidebarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Widget? trailing;

  _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeIcon,
    this.trailing,
  });
}

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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Material(
        // Solid (not transparent) so the whole row reliably hit-tests on the
        // web canvas; p.card matches the sidebar background, so it looks the
        // same as a transparent row but always receives the tap.
        color: active ? p.primaryLight : p.card,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
            child: Row(
              children: [
                // "You are here" accent bar — transparent when inactive so the
                // row layout never shifts between states.
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: active ? p.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  active && item.activeIcon != null
                      ? item.activeIcon!
                      : item.icon,
                  size: 18,
                  color: active ? p.primary : p.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 13.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? p.onPrimaryLight : p.textMuted,
                    ),
                  ),
                ),
                if (item.trailing != null) item.trailing!,
              ],
            ),
          ),
        ),
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: kMonoFamily,
          fontFamilyFallback: const [
            'Consolas',
            'Menlo',
            'Courier New',
            'monospace'
          ],
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
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
    return Material(
      color: SemanticColors.errorBgLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          final ctx = rootNavigatorKey.currentContext;
          if (ctx != null) showCrisisSheet(ctx);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: SemanticColors.errorBorderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: const [
                  Icon(Icons.health_and_safety_outlined,
                      size: 14, color: SemanticColors.errorAccentLight),
                  SizedBox(width: 6),
                  Text(
                    '24/7 LIFELINE',
                    style: TextStyle(
                      fontFamily: kMonoFamily,
                      fontFamilyFallback: ['Consolas', 'Courier New', 'monospace'],
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                      color: SemanticColors.errorTextLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                '988 · Crisis help',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: SemanticColors.errorTextLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Click for more information',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 11,
                  color: SemanticColors.errorTextLight.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// True while the facilitator ("Get help") screen is open, so repeated taps on
/// the card don't push multiple stacked copies. Mirrors the crisis-sheet guard.
bool _getHelpOpen = false;

/// Prominent "Get help" card in the sidebar (above the crisis card): peer
/// specialists, rights advocates, clinician referral. Opens the facilitator
/// screen. Promoted here from Settings so it's clearly visible.
class _GetHelpCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: p.primaryTint,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () async {
          if (_getHelpOpen) return;
          _getHelpOpen = true;
          try {
            await appRouter.push(AppRoutes.facilitator);
          } finally {
            _getHelpOpen = false;
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.primary.withValues(alpha: 0.20)),
          ),
          child: Row(
            children: [
              Icon(Icons.support_agent_outlined, size: 20, color: p.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get help',
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Peer support · advocates · referrals',
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 11,
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
    );
  }
}
