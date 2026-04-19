import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/services/screenshot_protection_service.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/theme/theme_controller.dart';
import 'package:mhad/ui/widgets/design/app_drawer.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
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
      backgroundColor: p.surface,
      drawer: const MhadAppDrawer(),
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          const SectionLabel('Appearance'),
          const SizedBox(height: 8),
          DesignCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Color theme',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                Column(
                  children: ThemePalette.values
                      .map((pal) => _PaletteTile(
                            palette: pal,
                            selected: themeSettings.palette == pal,
                            onTap: () => themeCtrl.setPalette(pal),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
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
                if (platformIsAndroid && !kIsWeb) ...[
                  Divider(height: 1, color: p.border),
                  SwitchListTile(
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    onChanged: (_) async {
                      await ScreenshotProtectionService.toggle();
                      setState(() {});
                    },
                  ),
                ],
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
          const SizedBox(height: 24),

          DesignCard(
            variant: DesignCardVariant.surface,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Text(
                  'PA Mental Health Advance Directive\n'
                  'Under Pennsylvania Act 194 of 2004\n\n'
                  'This app helps you document your mental health treatment '
                  'preferences. It is not a substitute for legal advice.\n\n'
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
                color: p.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: p.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
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

class _PaletteTile extends StatelessWidget {
  final ThemePalette palette;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteTile({
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final swatch = palette.light;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected ? p.primaryLight : Colors.transparent,
            border: Border.all(
              color: selected ? p.primary : p.border,
              width: selected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    colors: [swatch.primary, swatch.primaryMid],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      palette.label,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      palette.description,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: p.primary, size: 22)
              else
                Icon(Icons.circle_outlined, color: p.border, size: 22),
            ],
          ),
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
