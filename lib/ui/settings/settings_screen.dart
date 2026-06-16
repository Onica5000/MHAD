import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/data_export_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/services/screenshot_protection_service.dart';
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/ui/disclaimer/disclaimer_screen.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/theme/theme_controller.dart';
import 'package:mhad/ui/widgets/design/bottom_nav.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/utils/platform_utils.dart';

/// Central settings hub — AI setup, privacy policy, screenshot protection,
/// appearance (theme + mode), and app info.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final themeSettings = ref.watch(appThemeControllerProvider);
    final themeCtrl = ref.read(appThemeControllerProvider.notifier);

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      bottomNavigationBar: const MhadBottomNav(),
      // Material AppBar dropped 2026-06-04 — prototype ScrSettings
      // (mobile-extra.jsx L1066-1129) sits the CrisisTopBar at the top of
      // the screen body, not a Material chrome. The 38pt 'Settings'
      // header is the in-body title.
      body: Column(
        children: [
          const CrisisTopBar(compact: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
              children: [
                const SectionLabel('Account'),
                const EditorialHeading(
                  text: 'Settings',
                  size: 38,
                  height: 1.0,
                  letterSpacing: -0.5,
                ),
                const SizedBox(height: 12),
                // Profile chip — matches prototype `ScrSettings` profile chip
                // (mobile-extra.jsx L1076-1088). Pulls the user's name from the
                // most-recently-edited directive (same source as the home
                // greeting); status pill reflects current privacy mode.
                const _ProfileChip(),
                const SizedBox(height: 18),
                // "My directive" group hoisted to the top per prototype
                // L1091-1096 (the first group after the profile chip).
                const _CurrentDirectiveSection(),
                const SectionLabel('Appearance'),
                const SizedBox(height: 8),
          // Per user direction (2026-06-02): the app ships in the Deep Navy
          // palette only — no in-app palette picker. The teal/sage palettes
          // remain in `app_theme.dart` as inert tokens (the design system
          // still documents all three) but are not reachable from the UI.
          DesignCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brightness',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                _ThemeModeSegment(
                  mode: themeSettings.mode,
                  onChanged: themeCtrl.setMode,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const SectionLabel('AI & Privacy'),
          const SizedBox(height: 8),
          DesignCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.auto_awesome,
                  title: 'AI Assistant Setup',
                  subtitle: 'Configure your free Gemini API key',
                  onTap: () => context.push(AppRoutes.aiSetup),
                ),
                Divider(height: 1, color: p.border),
                _SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  subtitle: 'How your data is stored and protected',
                  onTap: () => context.push(AppRoutes.privacyPolicy),
                ),
                Divider(height: 1, color: p.border),
                _SettingsRow(
                  icon: Icons.shield_outlined,
                  title: 'Privacy & permissions',
                  subtitle:
                      'What permissions the app uses, and what we promise '
                      'about each',
                  onTap: () => context.push(AppRoutes.permissions),
                ),
                Divider(height: 1, color: p.border),
                _SettingsRow(
                  icon: Icons.gavel_rounded,
                  title: 'Legal Disclaimer',
                  subtitle: 'Terms, limitations, and your legal rights',
                  onTap: () {
                    // Use Navigator.push (not GoRouter) so the GoRouter
                    // redirect logic — which would bounce away from
                    // AppRoutes.disclaimer since it's already accepted —
                    // does not interfere with the read-only view.
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DisclaimerScreen.readOnly(),
                      ),
                    );
                  },
                ),
                if (platformIsAndroid && !kIsWeb) ...[
                  Divider(height: 1, color: p.border),
                  // SwitchListTile needs its own Material ancestor inside
                  // DesignCard's DecoratedBox, otherwise its background and
                  // ink splashes paint behind the card surface (Flutter
                  // assertion: "ListTile background color or ink splashes
                  // may be invisible"). Material(type: transparency) keeps
                  // the parent card's bg visible while giving the tile a
                  // valid Material parent.
                  Material(
                    type: MaterialType.transparency,
                    child: SwitchListTile(
                      secondary: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: p.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          ScreenshotProtectionService.isEnabled
                              ? Icons.screen_lock_portrait
                              : Icons.screenshot_outlined,
                          color: p.primary,
                          size: 20,
                        ),
                      ),
                      title: const Text('Screenshot Protection'),
                      subtitle: Text(
                        ScreenshotProtectionService.isEnabled
                            ? 'Screenshots are blocked'
                            : 'Screenshots are allowed',
                        style: TextStyle(color: p.textMuted, fontSize: 12),
                      ),
                      value: ScreenshotProtectionService.isEnabled,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      onChanged: (_) async {
                        await ScreenshotProtectionService.toggle();
                        setState(() {});
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Data & privacy actions — moved here from the home screen's
          // (now-removed) AppBar popup menu. Visibility is mode-aware:
          // Export and Switch-to-Public only apply when there's a
          // Private session in progress; Delete All Data is always
          // available.
          const SectionLabel('Data & privacy'),
          const SizedBox(height: 8),
          DesignCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                if (ref.watch(privacyModeNotifierProvider).isPrivate) ...[
                  _SettingsRow(
                    icon: Icons.download_outlined,
                    title: 'Export all data',
                    subtitle:
                        'Save every directive on this device as a JSON '
                        'bundle',
                    onTap: () => _exportAllData(context, ref),
                  ),
                  Divider(height: 1, color: p.border),
                  _SettingsRow(
                    icon: Icons.visibility_off_outlined,
                    title: 'Switch to public mode',
                    subtitle:
                        'Start an in-memory session — nothing saved to '
                        'disk',
                    onTap: () => _confirmSwitchToPublic(context, ref),
                  ),
                  Divider(height: 1, color: p.border),
                ],
                _SettingsRow(
                  icon: Icons.delete_forever,
                  title: 'Delete all data',
                  subtitle:
                      'Permanently remove every directive on this device',
                  iconTint: Theme.of(context).colorScheme.error,
                  titleTint: Theme.of(context).colorScheme.error,
                  onTap: () => _deleteAllData(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const SectionLabel('Learn More'),
          const SizedBox(height: 8),
          DesignCard(
            padding: EdgeInsets.zero,
            child: _SettingsRow(
              icon: Icons.school_outlined,
              title: 'Education & Resources',
              subtitle: 'FAQ, glossary, and legal information',
              onTap: () => context.push(AppRoutes.education),
            ),
          ),
          const SizedBox(height: 20),

          // _CurrentDirectiveSection was hoisted to the top of the
          // ListView (right under the profile chip) 2026-06-04 to match
          // prototype L1091-1096 — it used to live in this slot.
          const SectionLabel('Help & accessibility'),
          const SizedBox(height: 8),
          DesignCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.support_agent_outlined,
                  title: 'Get help',
                  subtitle:
                      'Peer specialists, rights advocates, clinician referral',
                  onTap: () => context.push(AppRoutes.facilitator),
                ),
                Divider(height: 1, color: p.border),
                _SettingsRow(
                  icon: Icons.accessibility_new,
                  title: 'Accessibility',
                  subtitle:
                      'Text size, dyslexia font, language, screen reader',
                  onTap: () => context.push(AppRoutes.accessibility),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Maintainer tool: visible (so the owner can find and test it) but
          // still passphrase-gated on the screen itself. The long-press on the
          // "About" heading below remains as a discreet alternate entry point.
          DesignCard(
            variant: DesignCardVariant.surface,
            padding: EdgeInsets.zero,
            child: _SettingsRow(
              icon: Icons.admin_panel_settings_outlined,
              title: 'AI data update tool',
              subtitle:
                  'Maintainer tool — have the AI propose updates to the app’s '
                  'information (contacts, AI limits, legal facts) and review them '
                  'before applying. Passphrase-protected.',
              onTap: () => context.push(AppRoutes.admin),
            ),
          ),
          const SizedBox(height: 24),

          DesignCard(
            variant: DesignCardVariant.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Long-press opens the hidden admin data-update tool (behind a
                // passphrase). Kept as a discreet alternate to the visible row
                // added above.
                GestureDetector(
                  onLongPress: () => context.push(AppRoutes.admin),
                  child: Text(
                    'About',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'PA Mental Health Advance Directive\n'
                  'Under Pennsylvania Act 194 of 2004 (effective January 29, '
                  '2005)\n\n'
                  'This app helps you document your mental health treatment '
                  'preferences. It is not legal or medical advice, and not a '
                  'substitute for a licensed attorney or clinician. See the '
                  'full Legal Disclaimer above for details.\n\n'
                  'Your directive is valid for two years from the date you sign '
                  'it — unless you are found incapable of making mental health '
                  'decisions at the time it would expire, in which case it '
                  'stays in effect until your capacity returns.\n\n'
                  'Form content based on the official PA MHAD booklet '
                  'published by the Disabilities Law Project (2005).',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: p.textMuted,
                    height: 1.5,
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
    );
  }

  // ─── Data & privacy actions (moved from home_screen.dart) ────────────────

  Future<void> _exportAllData(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(appDatabaseProvider);
      final service = DataExportService(db);
      await service.exportAll();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmSwitchToPublic(
      BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(privacyModeNotifierProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Switch to Public Mode?'),
        content: const Text(
          'Your saved directives will no longer be accessible in this session. '
          'No data will be deleted — you can access your directives again in a '
          'future Private session.\n\nYou cannot return to Private Mode without '
          'restarting the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Switch to Public'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      notifier.downgradeToPublic();
    }
  }

  Future<void> _deleteAllData(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all your directives, preferences, '
          "and local data. Data previously sent to Google's AI cannot be "
          'recalled. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(directiveRepositoryProvider).deleteAllDirectives();
      const storage = FlutterSecureStorage();
      await storage.deleteAll();
      await WebSessionCache.clear();
      await endPublicSession(ref);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete data: $e')),
        );
      }
    }
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  /// Optional override for the icon-tile foreground (icon color). Defaults
  /// to the primary palette color. Used by the destructive rows in the
  /// Data & privacy section to tint Delete in `colorScheme.error`.
  final Color? iconTint;

  /// Optional override for the title text color. Defaults to the inherited
  /// text style. Used by the same destructive rows.
  final Color? titleTint;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconTint,
    this.titleTint,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final fg = iconTint ?? p.primary;
    final tBg = iconTint == null
        ? p.primaryLight
        : iconTint!.withValues(alpha: 0.12);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: tBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: fg, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: titleTint,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      color: p.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: p.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ThemeModeSegment extends StatelessWidget {
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;
  const _ThemeModeSegment({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    const options = [
      (ThemeMode.system, 'Auto', Icons.brightness_auto),
      (ThemeMode.light, 'Light', Icons.light_mode),
      (ThemeMode.dark, 'Dark', Icons.dark_mode),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.primaryTint,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = opt.$1 == mode;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(opt.$1),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? p.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(opt.$3,
                        size: 18,
                        color: selected ? p.primary : p.textMuted),
                    const SizedBox(height: 4),
                    Text(
                      opt.$2,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? p.text : p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Primary-filled profile chip rendered at the top of the settings page.
///
/// Matches prototype `ScrSettings` (mobile-extra.jsx L1076-1088):
///   - 44pt circular avatar with the user's initials in a translucent
///     onPrimary fill
///   - Name in 15pt bold onPrimary
///   - Monospace status line: "● [PRIVACY MODE] · [AUTH METHOD]"
///
/// Falls back to a generic profile when no directive carries a stored
/// fullName — e.g. on a first launch before any wizard data is filled.
class _ProfileChip extends ConsumerWidget {
  const _ProfileChip();

  String _initialsFor(String name) {
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  String _statusFor(BuildContext context, PrivacyModeNotifier mode) {
    final modeWord = mode.isPrivate
        ? 'PRIVATE'
        : (mode.isPublic ? 'PUBLIC' : 'NO SESSION');
    // Auth method: web has no biometrics; mobile uses biometrics for
    // private mode. Public mode shows the ephemeral storage caveat.
    final authPart = kIsWeb
        ? 'IN-MEMORY ONLY'
        : (mode.isPrivate
            ? 'BIOMETRICS'
            : (mode.isPublic ? 'EPHEMERAL' : '—'));
    return '● $modeWord MODE · $authPart';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final mode = ref.watch(privacyModeNotifierProvider);
    final directivesAsync = ref.watch(allDirectivesProvider);

    final name = directivesAsync.maybeWhen(
      data: (list) {
        if (list.isEmpty) return '';
        final sorted = [...list]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        final src = sorted.firstWhere(
          (d) => d.fullName.trim().isNotEmpty,
          orElse: () => sorted.first,
        );
        return src.fullName.trim();
      },
      orElse: () => '',
    );

    final displayName = name.isEmpty ? 'PA MHAD user' : name;
    final initials = _initialsFor(name);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.primary,
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.onPrimary.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: p.onPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: p.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  _statusFor(context, mode),
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace',
                    ],
                    fontSize: 11,
                    letterSpacing: 0.4,
                    color: p.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "My current directive" Settings group — surfaces Phase 4 destinations
/// for the most-recently-completed directive when one exists. When no
/// completed directive is on file, the section renders nothing.
class _CurrentDirectiveSection extends ConsumerWidget {
  const _CurrentDirectiveSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final directivesAsync = ref.watch(allDirectivesProvider);

    return directivesAsync.maybeWhen(
      data: (list) {
        // Use the most-recently-edited directive of ANY status. These screens
        // operate on a directive (clinician view, crisis plan, QR, etc.), so
        // they only require that one exists — NOT that it's signed/complete.
        // Web directives are signed on paper and rarely reach "complete", so
        // gating on completion hid the whole section (and made these screens
        // unreachable on web).
        final sorted = [...list]
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        if (sorted.isEmpty) return const SizedBox.shrink();
        final d = sorted.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('My current directive'),
            const SizedBox(height: 8),
            DesignCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.swap_horiz_outlined,
                    title: 'Plain ↔ Legal language toggle',
                    subtitle: 'Switch how the text reads',
                    onTap: () =>
                        context.push(AppRoutes.legalToggleRoute(d.id)),
                  ),
                  Divider(height: 1, color: p.border),
                  // Crisis plan / WRAP and the Self-binding (Ulysses) clause
                  // moved into the wizard's "Anything else" step (2026-06-13).
                  _SettingsRow(
                    icon: Icons.auto_awesome_outlined,
                    title: 'AI consistency check',
                    subtitle: 'Flag cross-step contradictions',
                    onTap: () =>
                        context.push(AppRoutes.aiCheckRoute(d.id)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
