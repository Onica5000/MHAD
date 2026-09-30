import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/services/screenshot_protection_service.dart';
import 'package:mhad/ui/disclaimer/disclaimer_screen.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
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
      // Material AppBar dropped 2026-06-04 — prototype ScrSettings
      // (mobile-extra.jsx L1066-1129) sits the CrisisTopBar at the top of
      // the screen body, not a Material chrome. The 38pt 'Settings'
      // header is the in-body title.
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              children: [
                SectionLabel(context.l10n.settingsAccount),
                EditorialHeading(
                  text: context.l10n.navSettings,
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
                SectionLabel(context.l10n.settingsAppearance),
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
                  context.l10n.settingsBrightness,
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

          // Regrouped 2026-07-11 (UX audit C3): the old "AI & Privacy" card
          // mixed one functional item (AI setup) with three legal/
          // informational ones. AI assistant is now its own functional
          // section; the legal/privacy items live under "Legal & privacy".
          SectionLabel(context.l10n.navAiAssistant),
          const SizedBox(height: 8),
          DesignCard(
            padding: EdgeInsets.zero,
            child: _SettingsRow(
              icon: Icons.auto_awesome,
              title: context.l10n.navAiAssistant,
              subtitle: context.l10n.settingsChooseAProviderAndAdd,
              onTap: () => context.push(AppRoutes.aiSetup),
            ),
          ),
          const SizedBox(height: 20),

          // "Get help" moved to the left sidebar (above the crisis card) for
          // prominence. Accessibility stays here.
          SectionLabel(context.l10n.accessibilitySettingsAccessibility),
          const SizedBox(height: 8),
          DesignCard(
            padding: EdgeInsets.zero,
            child: _SettingsRow(
              icon: Icons.accessibility_new,
              title: context.l10n.accessibilitySettingsAccessibility,
              subtitle: context.l10n.settingsTextSizeDyslexiaFontBold,
              onTap: () => context.push(AppRoutes.accessibility),
            ),
          ),
          const SizedBox(height: 20),

          SectionLabel(context.l10n.settingsLegalPrivacy),
          const SizedBox(height: 8),
          DesignCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  title: context.l10n.privacyPolicyPrivacyPolicy,
                  subtitle: context.l10n.settingsHowYourDataIsStored,
                  onTap: () => context.push(AppRoutes.privacyPolicy),
                ),
                Divider(height: 1, color: p.border),
                _SettingsRow(
                  icon: Icons.shield_outlined,
                  title: context.l10n.settingsPrivacyPermissions,
                  subtitle:
                      context.l10n.settingsWhatPermissionsTheAppUses,
                  onTap: () => context.push(AppRoutes.permissions),
                ),
                Divider(height: 1, color: p.border),
                _SettingsRow(
                  icon: Icons.gavel_rounded,
                  title: context.l10n.settingsLegalDisclaimer,
                  subtitle: context.l10n.settingsTermsLimitationsAndYourLegal,
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
                          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
                        ),
                        child: Icon(
                          ScreenshotProtectionService.isEnabled
                              ? Icons.screen_lock_portrait
                              : Icons.screenshot_outlined,
                          color: p.primary,
                          size: 20,
                        ),
                      ),
                      title: Text(context.l10n.settingsScreenshotProtection),
                      subtitle: Text(
                        ScreenshotProtectionService.isEnabled
                            ? context.l10n.settingsScreenshotsAreBlocked
                            : context.l10n.settingsScreenshotsAreAllowed,
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
          const SizedBox(height: 24),

          // (The "Data & privacy" and "Learn More" sections were removed —
          // Learn lives in the main nav, and session/end-session controls live
          // on the public-mode notice. The visible "AI data update tool" card
          // was removed 2026-07-11 (UX audit C3) — the maintainer tool is
          // reached via the long-press on the "About" heading below, still
          // passphrase-gated.)

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
                    context.l10n.settingsAbout,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.settingsPaMentalHealthAdvanceDirective,
                  style: TextStyle(
                    fontFamily: kSansFamily,
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

}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final fg = p.primary;
    final tBg = p.primaryLight;
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
                borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
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
                    style: const TextStyle(
                      fontFamily: kSansFamily,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: kSansFamily,
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
    final options = [
      (ThemeMode.system, context.l10n.settingsThemeAuto, Icons.brightness_auto),
      (ThemeMode.light, context.l10n.settingsThemeLight, Icons.light_mode),
      (ThemeMode.dark, context.l10n.settingsThemeDark, Icons.dark_mode),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.primaryTint,
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
      ),
      child: Row(
        children: options.map((opt) {
          final selected = opt.$1 == mode;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(opt.$1),
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? p.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
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
                        fontFamily: kSansFamily,
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
    // The web app is the only shipping surface — always in-memory, no
    // public/private mode choice exists.
    final l = context.l10n;
    if (kIsWeb) return l.settingsStatusWebInMemory;
    // Native (deferred): public/private mode + auth method.
    final modeWord = mode.isPrivate
        ? l.settingsStatusPrivate
        : (mode.isPublic ? l.settingsStatusPublic : l.settingsStatusNoSession);
    final authPart = mode.isPrivate
        ? l.settingsStatusBiometrics
        : (mode.isPublic ? l.settingsStatusEphemeral : '—');
    return l.settingsStatusNative(modeWord, authPart);
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

    final displayName = name.isEmpty ? context.l10n.settingsDefaultUserName : name;
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
                fontFamily: kSansFamily,
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
                    fontFamily: kSansFamily,
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
                    fontFamily: kMonoFamily,
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

