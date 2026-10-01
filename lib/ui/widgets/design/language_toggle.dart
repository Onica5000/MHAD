import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';

/// English / Español switch bound to the app-wide language setting
/// ([accessibilitySettingsProvider]). Used on the first-launch welcome gate
/// and in Accessibility settings, so a change in one is reflected in both.
///
/// Labels are endonyms ("English", "Español") in every locale, so a reader
/// can always find their own language.
class LanguageToggle extends ConsumerWidget {
  /// Header variant (the welcome gate): no checkmark, so it stays narrow.
  final bool compact;

  const LanguageToggle({this.compact = false, super.key});

  // Only offer locales that are actually translated (have an ARB and are in
  // AppLocalizations.supportedLocales). Re-add others once their ARB lands
  // (Arabic would also need RTL).
  static const _values = {'en', 'es'};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      accessibilitySettingsProvider.select((s) => s.languageCode),
    );
    // Guard against a previously-stored unsupported code (e.g. 'zh'/'ar'):
    // SegmentedButton asserts the selection is among its segments.
    final sel = _values.contains(selected) ? selected : 'en';
    final cs = Theme.of(context).colorScheme;
    final button = SegmentedButton<String>(
      showSelectedIcon: !compact,
      // 48dp minimum height: the accessibility tap-target guideline (the
      // default SegmentedButton is 40dp).
      // The selected language is filled with the primary color so the
      // current choice reads at a glance (the default tint is faint).
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? cs.primary : null,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (states) =>
              states.contains(WidgetState.selected) ? cs.onPrimary : null,
        ),
      ),
      segments: [
        ButtonSegment(
          value: 'en',
          label: Text(context.l10n.accessibilitySettingsEnglish),
        ),
        ButtonSegment(
          value: 'es',
          label: Text(context.l10n.accessibilitySettingsEspaOl),
        ),
      ],
      selected: {sel},
      onSelectionChanged: (s) =>
          ref.read(accessibilitySettingsProvider.notifier).setLanguage(s.first),
    );
    return Semantics(
      container: true,
      label: context.l10n.accessibilitySettingsSectionLanguage,
      child: button,
    );
  }
}
