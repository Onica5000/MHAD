import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/art_image.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';

/// A tappable card led by a photo: photo, title, short description and a
/// "Do this →" call to action. One definition for every photo card (Home's
/// ways to start, onboarding's choices, Learn's categories).
///
/// Built on [DesignCard], so it announces as a button, shows a keyboard focus
/// ring and lifts on hover. Put it in a width-bounded slot (Expanded, a grid
/// cell): the photo takes the card's width.
///
/// For a ROW of these, use [EqualHeightRow] so the boxes match and the CTAs
/// line up (each card with `fillHeight: true`).
class PhotoActionCard extends StatelessWidget {
  final AppArt art;
  final String title;
  final String? body;
  final String? cta;
  final VoidCallback onTap;
  final double photoHeight;

  /// Fill the height the parent gives and pin the CTA to the bottom, so a row
  /// of sibling cards lines up: same box height, CTAs on one line. Leave false
  /// when the parent gives unbounded height (a plain column of cards).
  final bool fillHeight;

  const PhotoActionCard({
    required this.art,
    required this.title,
    required this.onTap,
    this.body,
    this.cta,
    this.photoHeight = 140,
    this.fillHeight = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.mhadPalette;
    const r = Radius.circular(DesignTokens.cardRadius);
    final size = fillHeight ? MainAxisSize.max : MainAxisSize.min;

    final text = Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: size,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: p.text,
            ),
          ),
          if (body != null) ...[
            const SizedBox(height: 4),
            Text(
              body!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: p.textMuted, height: MhadType.leadingParagraph,
              ),
            ),
          ],
          if (cta != null) ...[
            const SizedBox(height: 10),
            // In an equal-height row the CTA sits at the bottom of every card.
            if (fillHeight) const Spacer(),
            Text(
              '$cta →',
              style: theme.textTheme.labelLarge?.copyWith(
                color: p.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );

    return DesignCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: size,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: r, topRight: r),
            child: ArtImage(art, height: photoHeight, expand: true, radius: 0),
          ),
          if (fillHeight) Expanded(child: text) else text,
        ],
      ),
    );
  }
}

/// A row of sibling cards that all take the height of the tallest, with a
/// fixed gap — the ONE way to lay out a row of cards so the boxes are
/// symmetrical (a plain Row lets each card size to its own text).
///
/// Uses IntrinsicHeight, so children must be measurable: no LayoutBuilder
/// directly inside (ArtImage is fine when it has a fixed height, as in
/// [PhotoActionCard]). Cards should fill the height they are given (e.g.
/// `PhotoActionCard(fillHeight: true)`).
class EqualHeightRow extends StatelessWidget {
  final List<Widget> children;
  final double gap;

  /// Optional per-child flex (defaults to equal widths).
  final List<int>? flex;

  const EqualHeightRow({
    required this.children,
    this.gap = DesignTokens.space16,
    this.flex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: gap),
            Expanded(flex: flex?[i] ?? 1, child: children[i]),
          ],
        ],
      ),
    );
  }
}
