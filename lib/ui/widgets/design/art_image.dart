import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/spot_illustration.dart';

/// Shows an [AppArt] illustration the same way everywhere:
///
/// - **decoded at display size** (`cacheWidth` from the laid-out size × device
///   pixel ratio, covering `BoxFit.cover` crops), so a 1600px hero doesn't
///   cost full-size memory on a phone;
/// - a palette-tinted placeholder while it loads, then a short fade-in (none
///   under reduce-motion);
/// - gently dimmed in dark mode so a light illustration doesn't glare;
/// - purely decorative: hidden from screen readers;
/// - if the asset ever fails to load, the code-drawn [SpotIllustration]
///   stand-in appears instead of a broken box.
///
/// Sizing: give [width] and/or [height]. With only one of them (or neither,
/// inside a width-bounded parent) the image keeps its own aspect ratio. Pass
/// [expand] to fill a parent that already has a fixed size.
class ArtImage extends StatelessWidget {
  final AppArt art;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  /// Overrides [AppArt.focal] for this particular crop.
  final Alignment? alignment;

  /// Fill the parent's (bounded) size instead of using the art's aspect ratio.
  final bool expand;

  const ArtImage(
    this.art, {
    this.width,
    this.height,
    this.radius = DesignTokens.cardRadius,
    this.fit = BoxFit.cover,
    this.alignment,
    this.expand = false,
    super.key,
  });

  /// Dark-mode dim applied over the art (~12% black).
  static const _darkDim = Color(0x1F000000);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.mhadPalette;
    final dark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    final image = LayoutBuilder(builder: (context, box) {
      final w = box.hasBoundedWidth ? box.maxWidth : (width ?? 400);
      final h = box.hasBoundedHeight ? box.maxHeight : w / art.aspectRatio;
      // Cover-cropping a wide image into a tall box scales it by HEIGHT, so
      // the decoded width must cover h × aspect, not just the box width.
      final needed = math.max(w, h * art.aspectRatio) * dpr;
      final cacheWidth = needed.clamp(64, art.maxPixelWidth.toDouble()).round();
      return Image.asset(
        art.assetPath,
        width: double.infinity,
        height: double.infinity,
        fit: fit,
        alignment: alignment ?? art.focal,
        cacheWidth: cacheWidth,
        filterQuality: FilterQuality.medium,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || reduceMotion) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stack) => Center(
          child: SpotIllustration(
            art: art.fallback,
            size: math.max(32, math.min(w, h) * 0.6),
          ),
        ),
      );
    });

    Widget framed = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: p.primaryTint,
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            if (dark) const ColoredBox(color: _darkDim),
          ],
        ),
      ),
    );

    if (!expand && (width == null || height == null)) {
      framed = AspectRatio(aspectRatio: art.aspectRatio, child: framed);
    }
    if (width != null || height != null) {
      framed = SizedBox(width: width, height: height, child: framed);
    }
    return ExcludeSemantics(child: framed);
  }
}
