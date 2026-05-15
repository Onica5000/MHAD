import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Editorial display heading rendered in italic serif.
///
/// Matches the prototype's `Editorial` atom — used for hero titles ("In your
/// words.", "Almost there.", "You did it.") that should feel like a magazine
/// pull-quote rather than UI chrome.
class EditorialHeading extends StatelessWidget {
  /// Either provide a single line via [text] or a TextSpan tree via [textSpan]
  /// for mixed coloring (e.g. "Fewer screens, [same legal coverage.]").
  final String? text;
  final InlineSpan? textSpan;
  final double size;
  final double height;
  final double letterSpacing;
  final Color? color;
  final TextAlign align;
  final FontStyle fontStyle;

  const EditorialHeading({
    this.text,
    this.textSpan,
    this.size = 40,
    this.height = 1.05,
    this.letterSpacing = -0.8,
    this.color,
    this.align = TextAlign.start,
    this.fontStyle = FontStyle.italic,
    super.key,
  }) : assert(text != null || textSpan != null,
            'EditorialHeading needs either text or textSpan');

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final style = TextStyle(
      fontFamily: 'Instrument Serif',
      fontFamilyFallback: const ['Georgia', 'Times New Roman', 'serif'],
      fontStyle: fontStyle,
      fontSize: size,
      fontWeight: FontWeight.w400,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? p.text,
    );

    if (textSpan != null) {
      return Text.rich(textSpan!, style: style, textAlign: align);
    }
    return Text(text!, style: style, textAlign: align);
  }
}

/// A large italic serif numeral. Used inside [StepHead] and on hero cards.
class SerifNumeral extends StatelessWidget {
  final int value;
  final double size;
  final Color? color;
  final FontWeight weight;

  const SerifNumeral({
    required this.value,
    this.size = 54,
    this.color,
    this.weight = FontWeight.w400,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Text(
      value.toString().padLeft(2, '0'),
      style: TextStyle(
        fontFamily: 'Instrument Serif',
        fontFamilyFallback: const ['Georgia', 'Times New Roman', 'serif'],
        fontStyle: FontStyle.italic,
        fontSize: size,
        fontWeight: weight,
        height: 1,
        letterSpacing: -1,
        color: color ?? p.primary,
      ),
    );
  }
}

/// Tight monospace caption used for wizard step counters etc.
/// "Step 3 of 9" rendered in JetBrains Mono uppercase with tracking.
class MonoCaption extends StatelessWidget {
  final String text;
  final double size;
  final double letterSpacing;
  final Color? color;
  final FontWeight weight;

  const MonoCaption(
    this.text, {
    this.size = 11,
    this.letterSpacing = 1.0,
    this.color,
    this.weight = FontWeight.w600,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'JetBrains Mono',
        fontFamilyFallback: const ['Consolas', 'Menlo', 'Courier New', 'monospace'],
        fontSize: size,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        color: color ?? p.textMuted,
      ),
    );
  }
}
