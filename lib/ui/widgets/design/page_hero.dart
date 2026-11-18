import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/art_image.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// How much room the hero's photo takes.
enum PageHeroSize {
  /// Overview screens (Home, Learn): a large photo beside the text on wide
  /// screens, a full-width banner above it on phones.
  large,

  /// Everything else: a medium photo beside the text on wide screens and a
  /// small rounded thumbnail beside the title on phones, so forms and lists
  /// below are not pushed down.
  compact,
}

/// One page intro for the whole app: eyebrow + title + lead + photo.
///
/// Replaces the per-screen hand-built intros (IllustratedIntro, BrandMotif
/// headers, hand-typed serif titles). Each screen keeps its own back / close
/// control above it — the hero never removes navigation.
///
/// The layout decision uses the hero's OWN width (it sits inside the page
/// column), which is right here: it only chooses where the photo goes, not
/// whether the desktop shell is active.
class PageHero extends StatelessWidget {
  final AppArt art;
  final String? eyebrow;

  /// The heading — usually an [EditorialHeading] or a styled [Text]. It is
  /// marked as a header for screen readers.
  final Widget title;

  /// Supporting sentence under the title.
  final String? lead;

  /// Optional widgets under the lead (e.g. a primary action row).
  final Widget? bottom;
  final PageHeroSize size;

  /// Width at which the photo moves beside the text.
  static const double sideBySideAt = 640;

  const PageHero({
    required this.art,
    required this.title,
    this.eyebrow,
    this.lead,
    this.bottom,
    this.size = PageHeroSize.compact,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.mhadPalette;

    Widget textColumn({bool withThumb = false}) {
      final heading = Semantics(header: true, child: title);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (eyebrow != null)
            SectionLabel(eyebrow!, padding: const EdgeInsets.only(bottom: 8)),
          if (withThumb)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: heading),
                const SizedBox(width: DesignTokens.space16),
                ArtImage(art,
                    width: 72, height: 72, radius: DesignTokens.cardRadius),
              ],
            )
          else
            heading,
          if (lead != null) ...[
            const SizedBox(height: DesignTokens.space12),
            Text(
              lead!,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: p.textMuted, height: MhadType.leadingParagraph,
              ),
            ),
          ],
          if (bottom != null) ...[
            const SizedBox(height: DesignTokens.space20),
            bottom!,
          ],
        ],
      );
    }

    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= sideBySideAt;
      if (wide) {
        final fraction = size == PageHeroSize.large ? 0.44 : 0.34;
        final cap = size == PageHeroSize.large ? 480.0 : 300.0;
        final artWidth = math.min(box.maxWidth * fraction, cap);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: textColumn()),
            const SizedBox(width: DesignTokens.space32),
            ArtImage(art, width: artWidth, radius: DesignTokens.radiusLg),
          ],
        );
      }
      if (size == PageHeroSize.large) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ArtImage(art, height: 176, expand: true,
                radius: DesignTokens.radiusLg),
            const SizedBox(height: DesignTokens.space20),
            textColumn(),
          ],
        );
      }
      return textColumn(withThumb: true);
    });
  }
}
