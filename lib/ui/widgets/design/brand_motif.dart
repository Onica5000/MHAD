import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// A themeable, purely-decorative brand backdrop for hero / empty / feature
/// surfaces: a soft gradient wash with overlapping low-alpha "ripple" rings in
/// the active palette. Calm, on-brand, and recolors automatically for
/// light/dark and all three palettes.
///
/// It NEVER affects its child's layout or behavior — [child] is painted on top
/// of the motif, sized normally. Use [height] for a standalone banner, or pass
/// a [child] to wrap content with the motif behind it.
class BrandMotif extends StatelessWidget {
  final Widget? child;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double radius;
  /// 0 = subtle (refined), 1 = stronger (bolder). Defaults to a hybrid 0.7.
  final double intensity;

  const BrandMotif({
    this.child,
    this.height,
    this.padding = EdgeInsets.zero,
    this.radius = DesignTokens.cardRadius,
    this.intensity = 0.7,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: p.heroWash),
        child: CustomPaint(
          painter: _MotifPainter(p, intensity),
          child: SizedBox(
            height: child == null ? (height ?? 180) : null,
            width: double.infinity,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

/// Full-bleed gradient + motif backdrop for a screen hero. Drop it as the FIRST
/// child of a [Stack] — it expands to fill and ignores pointer input, so it sits
/// purely behind the existing content with no layout or interaction impact.
class BrandBackdrop extends StatelessWidget {
  final double intensity;
  /// Optional palette override for surfaces (e.g. the disclaimer gate) that
  /// thread their own palette instead of relying on the ambient theme.
  final MhadPalette? palette;
  const BrandBackdrop({this.intensity = 0.7, this.palette, super.key});

  @override
  Widget build(BuildContext context) {
    final p = palette ?? Theme.of(context).mhadPalette;
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(gradient: p.heroWash),
          child: CustomPaint(painter: _MotifPainter(p, intensity)),
        ),
      ),
    );
  }
}

class _MotifPainter extends CustomPainter {
  final MhadPalette p;
  final double intensity;
  const _MotifPainter(this.p, this.intensity);

  @override
  void paint(Canvas canvas, Size size) {
    final i = intensity.clamp(0.0, 1.0);

    // Soft filled blob, top-right — the bolder accent.
    final blob = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          p.primary.withValues(alpha: 0.10 + 0.10 * i),
          p.primaryMid.withValues(alpha: 0.04 + 0.06 * i),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(
        Offset(size.width * 0.92, size.height * 0.10), size.height * 0.55, blob);

    // Concentric "ripple" rings, bottom-left — the calm, refined motif.
    final ringCenter = Offset(size.width * 0.06, size.height * 0.96);
    for (var r = 1; r <= 4; r++) {
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = p.primary.withValues(alpha: (0.07 + 0.05 * i) / r);
      canvas.drawCircle(ringCenter, size.height * 0.28 * r, ring);
    }

    // A faint mid-tone wash circle, center-right, for depth.
    final depth = Paint()
      ..color = p.primaryMid.withValues(alpha: 0.03 + 0.03 * i);
    canvas.drawCircle(
        Offset(size.width * 0.62, size.height * 0.85), size.height * 0.4, depth);
  }

  @override
  bool shouldRepaint(_MotifPainter old) =>
      old.intensity != intensity || old.p != p;
}
