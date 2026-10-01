import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/language_toggle.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

/// Accessibility settings. All preferences persist via SharedPreferences
/// (see [AccessibilitySettingsNotifier]) and apply app-wide:
/// - Text size slider → MediaQuery.textScaler
/// - Dyslexia-friendly font (Atkinson Hyperlegible) → theme fontFamily
/// - Bold text → theme font weights
/// - Reduce motion → no route transitions + MediaQuery.disableAnimations
/// - High contrast → pure black/white text + stronger outlines
/// - Language picker (English + Spanish — the locales with ARB translations;
///   中文/العربية were removed until translated, since they fell back to English)
/// - Read aloud → an in-app guide to the browser/OS built-in reader
/// - Reset accessibility settings → restores defaults
class AccessibilitySettingsScreen extends ConsumerWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final settings = ref.watch(accessibilitySettingsProvider);

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrA (gap-analysis.jsx L1067-1161) has CrisisBar + an
      // in-body Back chevron — no Material AppBar. The editorial
      // 'Make it readable.' heading owns the visual title.
      body: Column(children: [
        WizardHeader(
          backLabel: context.l10n.back,
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          SectionLabel(context.l10n.accessibilitySettingsAccessibility),
          const SizedBox(height: 6),
          EditorialHeading(text: context.l10n.accessibilitySettingsMakeItReadable, size: 32),
          const SizedBox(height: 6),
          Text(
            context.l10n.accessibilitySettingsAdjustHowTheAppFeels,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 14,
              color: p.textMuted,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 18),
          _TextSizeCard(
            value: settings.textScale,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setTextScale(v),
          ),
          const SizedBox(height: 14),

          _SectionHeader(context.l10n.accessibilitySettingsSectionReading),
          _ToggleRow(
            title: context.l10n.accessibilitySettingsDyslexiaFriendlyFont,
            sub: context.l10n.accessibilitySettingsAtkinsonHyperlegibleClearerEasierLetter,
            value: settings.dyslexiaFont,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setDyslexiaFont(v),
          ),
          _ToggleRow(
            title: context.l10n.accessibilitySettingsBoldText,
            sub: context.l10n.accessibilitySettingsHeavierTextWeightEverywhere,
            value: settings.boldText,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setBoldText(v),
          ),
          _ToggleRow(
            title: context.l10n.accessibilitySettingsReduceMotion,
            sub: context.l10n.accessibilitySettingsRemovesScreenTransitionsAndAnimations,
            value: settings.reduceMotion,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setReduceMotion(v),
          ),
          _ToggleRow(
            title: context.l10n.accessibilitySettingsHighContrast,
            sub: context.l10n.accessibilitySettingsMaximizesSeparationBetweenTextAnd,
            value: settings.highContrast,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setHighContrast(v),
          ),

          const SizedBox(height: 14),
          _SectionHeader(context.l10n.accessibilitySettingsSectionLanguage),
          const LanguageToggle(),
          const SizedBox(height: 10),
          InfoBanner(
            icon: Icons.info_outline,
            variant: InfoBannerVariant.info,
            text:
                context.l10n.accessibilitySettingsLegalTextIsAlwaysRendered,
          ),
          if (settings.languageCode == 'es') ...[
            const SizedBox(height: 10),
            InfoBanner(
              icon: Icons.translate,
              variant: InfoBannerVariant.warning,
              text: context.l10n.accessibilitySettingsSpanishReviewNotice,
            ),
          ],

          const SizedBox(height: 18),
          // Read it aloud with your browser or device — see the in-app guide.
          _ToggleRow(
            title: context.l10n.accessibilitySettingsReadAloud,
            sub: context.l10n.accessibilitySettingsUseYourBrowserOrDevice,
            handoff: true,
            value: false,
            onChanged: null,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showReadAloudGuide(context),
              icon: const Icon(Icons.volume_up_outlined, size: 18),
              label: Text(context.l10n.accessibilitySettingsHowToUseReadAloud),
            ),
          ),

          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => ref
                .read(accessibilitySettingsProvider.notifier)
                .resetToDefaults(),
            icon: const Icon(Icons.restart_alt),
            label: Text(context.l10n.accessibilitySettingsResetAccessibilitySettings),
          ),
        ],
      )),
      ]),
    );
  }

  /// In-app guide for using the browser / OS built-in read-aloud (the app does
  /// not ship its own TTS — the platform tools are better and already present).
  void _showReadAloudGuide(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.volume_up_outlined),
        title: Text(context.l10n.accessibilitySettingsReadThisPageAloud),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.accessibilitySettingsYourBrowserAndDeviceAlready,
              ),
              SizedBox(height: 12),
              _GuideItem(
                head: context.l10n.accessibilitySettingsChromeEdgeDesktop,
                body: context.l10n.accessibilitySettingsRightClickThePageRead,
              ),
              _GuideItem(
                head: 'Android (Chrome)',
                body: context.l10n.accessibilitySettingsSelectTextTapListenOr,
              ),
              _GuideItem(
                head: 'iPhone / iPad (Safari)',
                body: context.l10n.accessibilitySettingsSettingsAccessibilitySpokenContentTurn,
              ),
              _GuideItem(
                head: 'Windows',
                body: context.l10n.accessibilitySettingsNarratorCtrlWinEnterOr,
              ),
              _GuideItem(
                head: 'macOS',
                body: context.l10n.accessibilitySettingsSystemSettingsAccessibilitySpokenContent,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.exampleTextGotIt),
          ),
        ],
      ),
    );
  }
}

class _GuideItem extends StatelessWidget {
  final String head;
  final String body;
  const _GuideItem({required this.head, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(head, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(body, style: const TextStyle(fontSize: 13, height: 1.4)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
      child: SectionLabel(text),
    );
  }
}

class _TextSizeCard extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _TextSizeCard({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(context.l10n.accessibilitySettingsTextSize),
            const SizedBox(height: 10),
            Text(
              context.l10n.accessibilitySettingsPeopleWhoITrustWill,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 13 + value * 4,
                color: p.text,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text('A',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                Expanded(
                  child: Slider(
                    min: 0,
                    max: 3,
                    divisions: 3,
                    value: value,
                    label: switch (value.round()) {
                      0 => context.l10n.accessibilitySettingsTextSizeSmall,
                      1 => context.l10n.accessibilitySettingsTextSizeDefault,
                      2 => context.l10n.accessibilitySettingsTextSizeLarge,
                      _ => context.l10n.accessibilitySettingsTextSizeHuge,
                    },
                    onChanged: onChanged,
                  ),
                ),
                const Text('A',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String sub;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool handoff;
  const _ToggleRow({
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
    this.handoff = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return SwitchListTile(
      title: Row(
        children: [
          Expanded(child: Text(title)),
          if (handoff)
            Padding(
              padding: const EdgeInsets.only(left: 6),
              child: Icon(Icons.arrow_outward,
                  size: 16, color: p.textMuted),
            ),
        ],
      ),
      subtitle: Text(sub),
      value: value,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.trailing,
      contentPadding: EdgeInsets.zero,
    );
  }
}
