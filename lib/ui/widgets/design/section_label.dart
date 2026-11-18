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

  /// Optional override merged on top of the default uppercased eyebrow
  /// style ([MhadText.eyebrow]). Use it to tint the label (e.g. `TextStyle(color: p.primary)`)
  /// without redefining the whole text style.
  final TextStyle? style;

  const SectionLabel(
    this.text, {
    this.padding = const EdgeInsets.fromLTRB(0, 20, 0, 8),
    this.style,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        text.toUpperCase(),
        // Shared eyebrow style (MhadText.eyebrow): DM Sans small caps, which
        // replaced the old JetBrains Mono eyebrow in the 2026-11 redesign.
        style: MhadText.eyebrow(Theme.of(context).colorScheme.onSurfaceVariant)
            .merge(style),
      ),
    );
  }
}
