import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

/// Persistent left-rail navigation for wide (desktop / web) screens.
///
/// Mirrors the prototype's `WebSidebar`: brand mark, primary destinations,
/// crisis card pinned to the bottom, and a session-mode chip. On narrow
/// screens the [ResponsiveShell] swaps this out for the standard
/// [MhadAppDrawer].
class WebSidebar extends ConsumerWidget {
  final String activeRoute;
  const WebSidebar({required this.activeRoute, super.key});

  static const double width = 232;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final mode = ref.watch(privacyModeNotifierProvider);
    final aiReady =
        ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty ?? false;

    final items = <_SidebarItem>[
      _SidebarItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'My directives',
        route: AppRoutes.home,
      ),
      _SidebarItem(
        icon: Icons.add_circle_outline,
        activeIcon: Icons.add_circle,
        label: 'New directive',
        route: AppRoutes.formTypeSelection,
        push: true,
      ),
      _SidebarItem(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: 'Learn',
        route: AppRoutes.education,
      ),
      _SidebarItem(
        icon: aiReady ? Icons.auto_awesome : Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        label: 'AI assistant',
        route: AppRoutes.aiSetup,
        trailing: aiReady ? _Badge('READY', tone: 'ok') : _Badge('SET UP'),
      ),
      _SidebarItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        route: AppRoutes.settings,
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
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          color: p.text,
                        ),
                      ),
                      Text(
                        'ACT 194 · 2004',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontFamilyFallback: const [
                            'Consolas',
                            'Menlo',
                            'Courier New',
                            'monospace'
                          ],
                          fontSize: 9.5,
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
                      active: _matchesActive(item.route, activeRoute),
                      onTap: () => _navigate(context, item),
                    ),
                ],
              ),
            ),

            // Crisis card pinned at bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: _CrisisCard(),
            ),

            // Session-mode chip
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: p.primary,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'AK',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: p.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mode.isPrivate ? 'Private session' : 'Public session',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: p.text,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          mode.isPrivate
                              ? '● ENCRYPTED'
                              : (mode.isPublic
                                  ? '● IN-MEMORY'
                                  : '● NO SESSION'),
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontFamilyFallback: const [
                              'Consolas',
                              'Menlo',
                              'Courier New',
                              'monospace'
                            ],
                            fontSize: 9.5,
                            letterSpacing: 0.4,
                            color: mode.isPrivate
                                ? SemanticColors.successTextLight
                                : SemanticColors.warningTextLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _matchesActive(String routeMatcher, String currentRoute) {
    if (routeMatcher == currentRoute) return true;
    // Home: also match nested wizard routes since they're still in the home
    // workflow but should not highlight Home — return false there.
    return false;
  }

  static void _navigate(BuildContext context, _SidebarItem item) {
    if (item.push) {
      context.push(item.route);
    } else {
      if (item.route == GoRouterState.of(context).matchedLocation) return;
      // For routes that are "primary destinations", swap with go(); for
      // others that are pushed onto the stack from primary screens, use push.
      if (item.route == AppRoutes.home) {
        context.go(item.route);
      } else {
        context.push(item.route);
      }
    }
  }
}

class _SidebarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;
  final bool push;
  final Widget? trailing;

  _SidebarItem({
    required this.icon,
    required this.label,
    required this.route,
    this.activeIcon,
    this.push = false,
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
        color: active ? p.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Icon(
                  active && item.activeIcon != null
                      ? item.activeIcon!
                      : item.icon,
                  size: 18,
                  color: active ? p.onPrimaryLight : p.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
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
          fontFamily: 'JetBrains Mono',
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

class _CrisisCard extends StatelessWidget {
  Future<void> _call(BuildContext context) async {
    if (!kIsWeb) {
      final url = Uri.parse('tel:$crisis988Phone');
      if (await canLaunchUrl(url)) await launchUrl(url);
    } else {
      await Clipboard.setData(const ClipboardData(text: crisis988Phone));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('988 copied to clipboard')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SemanticColors.errorBgLight,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _call(context),
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
                  Icon(Icons.phone_outlined,
                      size: 14, color: SemanticColors.errorAccentLight),
                  SizedBox(width: 6),
                  Text(
                    '24/7 LIFELINE',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
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
                '988 · Call or text',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: SemanticColors.errorTextLight,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Free, confidential, anytime.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
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
