import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/accessibility_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

/// Accessibility settings (v2 prototype `m-a11y`, v3 phased rollout).
///
/// Implemented now (Phase 4):
/// - Text size slider — wires through `textScaleProvider` to the app shell
/// - Dyslexia-friendly font toggle (Atkinson Hyperlegible noted as Phase 2)
/// - Reduce motion toggle
/// - High contrast toggle
/// - Language picker (English shipped; Spanish partial; Chinese/Arabic
///   marked Phase 2)
/// - Read aloud, Switch Control, Hearing aid pairing — labeled as OS
///   handoffs (↗) per v3 spec
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
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          const SectionLabel('Accessibility'),
          const SizedBox(height: 6),
          const EditorialHeading(text: 'Make it readable.', size: 32),
          const SizedBox(height: 6),
          Text(
            'Adjust how the app feels for you. Changes apply everywhere '
            'instantly.',
            style: TextStyle(
              fontFamily: 'DM Sans',
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

          _SectionHeader('Reading'),
          _ToggleRow(
            title: 'Dyslexia-friendly font',
            sub: 'Atkinson Hyperlegible — bundling in Phase 2',
            phase: '2',
            value: settings.dyslexiaFont,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setDyslexiaFont(v),
          ),
          _ToggleRow(
            title: 'Read aloud',
            sub: 'Article body and headers · uses your device voice',
            handoff: true,
            value: false,
            onChanged: null,
          ),
          _ToggleRow(
            title: 'Reduce motion',
            sub: 'No transitions, no parallax',
            value: settings.reduceMotion,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setReduceMotion(v),
          ),
          _ToggleRow(
            title: 'High contrast',
            sub: 'Boosts separation between text and background',
            value: settings.highContrast,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setHighContrast(v),
          ),

          const SizedBox(height: 14),
          _SectionHeader('Language'),
          _LanguagePicker(
            selected: settings.languageCode,
            onChanged: (code) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setLanguage(code),
          ),
          const SizedBox(height: 10),
          const InfoBanner(
            icon: Icons.info_outline,
            variant: InfoBannerVariant.info,
            text:
                'Legal text is always rendered in English to preserve PA Act '
                '194 wording.',
          ),

          const SizedBox(height: 14),
          _SectionHeader('Hardware'),
          _ToggleRow(
            title: 'VoiceOver / TalkBack hints',
            sub: 'Extra context for every control',
            value: settings.voiceOverHints,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setVoiceOverHints(v),
          ),
          _ToggleRow(
            title: 'Switch Control',
            sub: 'OS-level — enable in iOS Settings → Accessibility',
            handoff: true,
            value: false,
            onChanged: null,
          ),
          _ToggleRow(
            title: 'Hearing aid pairing',
            sub: 'OS-level — pair in your device Settings',
            handoff: true,
            value: false,
            onChanged: null,
          ),
        ],
      )),
      ]),
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
            const SectionLabel('Text size'),
            const SizedBox(height: 10),
            Text(
              'People who I trust will make my decisions if I can\'t.',
              style: TextStyle(
                fontFamily: 'DM Sans',
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
                      0 => 'Small',
                      1 => 'Default',
                      2 => 'Large',
                      _ => 'Huge',
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
  final String? phase;
  const _ToggleRow({
    required this.title,
    required this.sub,
    required this.value,
    required this.onChanged,
    this.handoff = false,
    this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
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
          if (phase != null)
            Container(
              margin: const EdgeInsets.only(left: 6),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: dark ? SemanticColors.warningBgDark : SemanticColors.warningBgLight,
                border: Border.all(
                    color: dark
                        ? SemanticColors.warningBorderDark
                        : SemanticColors.warningBorderLight),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Phase $phase',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace'
                  ],
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: dark
                      ? SemanticColors.warningTextDark
                      : SemanticColors.warningTextLight,
                ),
              ),
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

class _LanguagePicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _LanguagePicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'en', label: Text('English')),
        ButtonSegment(value: 'es', label: Text('Español')),
        ButtonSegment(value: 'zh', label: Text('中文')),
        ButtonSegment(value: 'ar', label: Text('العربية')),
      ],
      selected: {selected},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
