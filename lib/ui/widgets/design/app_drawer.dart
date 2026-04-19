import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Universal hamburger drawer used across every primary screen. Exposes the
/// top-level destinations (Home, New Directive, Learn, AI Setup, Settings,
/// Privacy Policy) and shows the current session mode.
class MhadAppDrawer extends ConsumerWidget {
  const MhadAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final mode = ref.watch(privacyModeNotifierProvider);
    final aiReady = ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty ?? false;

    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: p.card,
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              decoration: BoxDecoration(
                color: p.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        tooltip: 'Close menu',
                        onPressed: () => Navigator.of(context).maybePop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'PA Mental Health\nAdvance Directive',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mode.isPrivate
                              ? SemanticColors.successTextLight
                              : SemanticColors.warningTextLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mode.isPrivate
                              ? 'Private session · Encrypted'
                              : (mode.isPublic
                                  ? 'Public session · Not saved'
                                  : 'No session selected'),
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Primary destinations
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    active: currentRoute == AppRoutes.home,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (currentRoute != AppRoutes.home) {
                        context.go(AppRoutes.home);
                      }
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.add_circle_outline,
                    activeIcon: Icons.add_circle,
                    label: 'New Directive',
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.formTypeSelection);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.menu_book_outlined,
                    activeIcon: Icons.menu_book,
                    label: 'Learn About MHADs',
                    active: currentRoute == AppRoutes.education,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (currentRoute != AppRoutes.education) {
                        context.push(AppRoutes.education);
                      }
                    },
                  ),
                  _DrawerItem(
                    icon: aiReady
                        ? Icons.auto_awesome
                        : Icons.auto_awesome_outlined,
                    activeIcon: Icons.auto_awesome,
                    label: 'AI Assistant',
                    trailing: aiReady
                        ? _ReadyBadge(color: p.primary)
                        : _SetupBadge(color: p.primary),
                    active: currentRoute == AppRoutes.aiSetup,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.aiSetup);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
                    child: Text(
                      'ACCOUNT',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: p.textMuted,
                      ),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    active: currentRoute == AppRoutes.settings,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (currentRoute != AppRoutes.settings) {
                        context.push(AppRoutes.settings);
                      }
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.privacy_tip_outlined,
                    activeIcon: Icons.privacy_tip,
                    label: 'Privacy Policy',
                    active: currentRoute == AppRoutes.privacyPolicy,
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(AppRoutes.privacyPolicy);
                    },
                  ),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MHAD v1.0${kIsWeb ? ' · Web' : ''}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: p.textMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No tracking. No ads.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
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
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Widget? trailing;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.activeIcon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final color = active ? p.primary : p.text;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: active ? p.primaryLight : Colors.transparent,
            border: Border(
              left: BorderSide(
                color: active ? p.primary : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                active && activeIcon != null ? activeIcon! : icon,
                color: color,
                size: 22,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}

class _ReadyBadge extends StatelessWidget {
  final Color color;
  const _ReadyBadge({required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: SemanticColors.successBgLight,
          borderRadius: BorderRadius.circular(100),
        ),
        child: const Text(
          'Ready',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: SemanticColors.successTextLight,
          ),
        ),
      );
}

class _SetupBadge extends StatelessWidget {
  final Color color;
  const _SetupBadge({required this.color});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          'Set up',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );
}
