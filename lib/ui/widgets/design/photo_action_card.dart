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
class PhotoActionCard extends StatelessWidget {
  final AppArt art;
  final String title;
  final String? body;
  final String? cta;
  final VoidCallback onTap;
  final double photoHeight;

  const PhotoActionCard({
    required this.art,
    required this.title,
    required this.onTap,
    this.body,
    this.cta,
    this.photoHeight = 140,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.mhadPalette;
    const r = Radius.circular(DesignTokens.cardRadius);
    return DesignCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: r, topRight: r),
            child: ArtImage(art, height: photoHeight, expand: true, radius: 0),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                      color: p.textMuted,
                      height: 1.45,
                    ),
                  ),
                ],
                if (cta != null) ...[
                  const SizedBox(height: 10),
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
          ),
        ],
      ),
    );
  }
}
