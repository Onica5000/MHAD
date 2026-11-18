import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Which editorial display level a heading is (see [MhadType]).
enum HeadingLevel {
  /// Hub hero titles — Home, Learn (42).
  display,

  /// Page titles — every other page, gates, wizard steps (34).
  page,

  /// Sub-titles — sheets, dialogs, feature cards (28).
  sub,
}

/// Editorial display heading — the serif headline voice of the app.
///
/// ONE style per [level], read from the theme's display slots (2026-11
/// overhaul: callers used to pass their own size, and page titles came in six
/// sizes, 26–38). The theme makes it italic Instrument Serif normally, and the
/// dyslexia-friendly font upright when that setting is on — the old widget
/// hard-coded the serif and ignored the setting.
///
/// Either provide a single line via [text] or a TextSpan tree via [textSpan]
/// for mixed coloring (e.g. "Understand [before] you sign.").
class EditorialHeading extends StatelessWidget {
  final String? text;
  final InlineSpan? textSpan;
  final HeadingLevel level;
  final Color? color;
  final TextAlign align;

  const EditorialHeading({
    this.text,
    this.textSpan,
    this.level = HeadingLevel.page,
    this.color,
    this.align = TextAlign.start,
    super.key,
  }) : assert(text != null || textSpan != null,
            'EditorialHeading needs either text or textSpan');

  /// The theme style for [level] — for the few headlines that are built as
  /// rich text by hand but must match the heading levels.
  static TextStyle styleFor(BuildContext context, HeadingLevel level) {
    final t = Theme.of(context).textTheme;
    return switch (level) {
      HeadingLevel.display => t.displayLarge!,
      HeadingLevel.page => t.displayMedium!,
      HeadingLevel.sub => t.displaySmall!,
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final style = styleFor(context, level).copyWith(color: color ?? p.text);
    if (textSpan != null) {
      return Text.rich(textSpan!, style: style, textAlign: align);
    }
    return Text(text!, style: style, textAlign: align);
  }
}

/// A large serif numeral (step counters on hero cards). Follows the theme's
/// display face, so it turns upright with the dyslexia-friendly font.
class SerifNumeral extends StatelessWidget {
  final int value;
  final double size;
  final Color? color;

  const SerifNumeral({
    required this.value,
    this.size = 54,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final display = Theme.of(context).textTheme.displayLarge!;
    final editorial = display.fontFamily == kSerifFamily;
    return Text(
      value.toString().padLeft(2, '0'),
      style: display.copyWith(
        fontSize: editorial ? size : (size * 0.82).roundToDouble(), height: MhadType.leadingTitle,
        color: color ?? p.primary,
      ),
    );
  }
}

/// Small uppercase caption used for wizard step counters etc. ("STEP 3 OF 9"),
/// in the shared eyebrow style ([MhadText.eyebrow]). Was `MonoCaption`
/// (JetBrains Mono) before the 2026-11 redesign.
class CapsCaption extends StatelessWidget {
  final String text;
  final double size;
  final Color? color;

  const CapsCaption(
    this.text, {
    this.size = MhadType.caption,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Text(
      text.toUpperCase(),
      style: MhadText.eyebrow(color ?? p.textMuted, size: size),
    );
  }
}
