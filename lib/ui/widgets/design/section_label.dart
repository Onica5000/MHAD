import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Uppercased, wide-tracked label used to group sections in the redesign.
///
/// Matches the prototype's `SectionLabel` atom (`ds.jsx::SectionLabel`),
/// which optionally accepts a `style` override — most callers leave the
/// color at the default muted-text, but a few (the empty-hero "Your first
/// directive" label, for one) tint it `p.primary` for emphasis.
class SectionLabel extends StatelessWidget {
  final String text;
  final EdgeInsetsGeometry padding;

  /// Optional override merged on top of the default uppercased monospace
  /// style. Use it to tint the label (e.g. `TextStyle(color: p.primary)`)
  /// without redefining the whole text style.
  final TextStyle? style;

  const SectionLabel(
    this.text, {
    this.padding = const EdgeInsets.fromLTRB(0, 18, 0, 8),
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        // The design-system `SectionLabel` atom (ds.jsx) renders the eyebrow in
        // the MONO face (JetBrains Mono, 10.5/600), not DM Sans. JetBrains Mono
        // is bundled (pubspec); the fallback chain keeps it monospaced if the
        // asset is ever missing on web.
        style: TextStyle(
          fontFamily: kMonoFamily,
          fontFamilyFallback: const [
            'Consolas',
            'Menlo',
            'Courier New',
            'monospace',
          ],
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ).merge(style),
      ),
    );
  }
}
