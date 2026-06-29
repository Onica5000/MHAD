import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
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

          _SectionHeader('Reading'),
          _ToggleRow(
            title: 'Dyslexia-friendly font',
            sub: 'Atkinson Hyperlegible — clearer, easier letter shapes',
            value: settings.dyslexiaFont,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setDyslexiaFont(v),
          ),
          _ToggleRow(
            title: 'Bold text',
            sub: 'Heavier text weight everywhere',
            value: settings.boldText,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setBoldText(v),
          ),
          _ToggleRow(
            title: 'Reduce motion',
            sub: 'Removes screen transitions and animations',
            value: settings.reduceMotion,
            onChanged: (v) => ref
                .read(accessibilitySettingsProvider.notifier)
                .setReduceMotion(v),
          ),
          _ToggleRow(
            title: 'High contrast',
            sub: 'Maximizes separation between text and background',
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

          const SizedBox(height: 18),
          // Read it aloud with your browser or device — see the in-app guide.
          _ToggleRow(
            title: 'Read aloud',
            sub: 'Use your browser or device read-aloud — see the guide below',
            handoff: true,
            value: false,
            onChanged: null,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => _showReadAloudGuide(context),
              icon: const Icon(Icons.volume_up_outlined, size: 18),
              label: const Text('How to use read-aloud'),
            ),
          ),

          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => ref
                .read(accessibilitySettingsProvider.notifier)
                .resetToDefaults(),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset accessibility settings'),
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
        title: const Text('Read this page aloud'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your browser and device already have read-aloud built in — '
                'they work better than an in-app reader, so use one of these:',
              ),
              SizedBox(height: 12),
              _GuideItem(
                head: 'Chrome / Edge (desktop)',
                body: 'Right-click the page → “Read aloud” (Edge), or use the '
                    'Reading mode / an extension in Chrome. Edge: Ctrl+Shift+U.',
              ),
              _GuideItem(
                head: 'Android (Chrome)',
                body: 'Select text → tap “Listen”, or turn on '
                    'Settings → Accessibility → Select to Speak / TalkBack.',
              ),
              _GuideItem(
                head: 'iPhone / iPad (Safari)',
                body: 'Settings → Accessibility → Spoken Content → turn on '
                    '“Speak Screen”, then swipe down with two fingers.',
              ),
              _GuideItem(
                head: 'Windows',
                body: 'Narrator: Ctrl+Win+Enter. Or use Edge’s Read aloud above.',
              ),
              _GuideItem(
                head: 'macOS',
                body: 'System Settings → Accessibility → Spoken Content → '
                    '“Speak selection”, then press Option+Esc.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
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
            const SectionLabel('Text size'),
            const SizedBox(height: 10),
            Text(
              'People who I trust will make my decisions if I can\'t.',
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

class _LanguagePicker extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  const _LanguagePicker({required this.selected, required this.onChanged});

  // Only offer locales that are actually translated (have an ARB and are in
  // AppLocalizations.supportedLocales). 中文 / العربية were offered before but
  // had no translation and silently fell back to English — worse than omitting
  // them. Re-add each once its ARB lands (Arabic also needs RTL).
  static const _values = {'en', 'es'};

  @override
  Widget build(BuildContext context) {
    // Guard against a previously-stored unsupported code (e.g. 'zh'/'ar'):
    // SegmentedButton asserts the selection is among its segments.
    final sel = _values.contains(selected) ? selected : 'en';
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'en', label: Text('English')),
        ButtonSegment(value: 'es', label: Text('Español')),
      ],
      selected: {sel},
      onSelectionChanged: (s) => onChanged(s.first),
    );
  }
}
