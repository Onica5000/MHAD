import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Which spot illustration to draw.
enum SpotArt { document, search, success, voice, shield }

/// A small, themeable line/duotone illustration for empty / success / hero
/// spots — drawn with [CustomPaint] so it's crisp at any size and recolors for
/// light/dark and every palette. Purely decorative (wrapped in ExcludeSemantics).
class SpotIllustration extends StatelessWidget {
  final SpotArt art;
  final double size;
  const SpotIllustration({required this.art, this.size = 96, super.key});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ExcludeSemantics(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(painter: _SpotPainter(art, p)),
      ),
    );
  }
}

class _SpotPainter extends CustomPainter {
  final SpotArt art;
  final MhadPalette p;
  const _SpotPainter(this.art, this.p);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Soft tinted disc behind every motif for a duotone, "designed" feel.
    canvas.drawCircle(
      Offset(w / 2, h / 2),
      w * 0.48,
      Paint()..color = p.primary.withValues(alpha: 0.08),
    );

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = p.primary;
    final fill = Paint()..color = p.primary.withValues(alpha: 0.16);
    final accent = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.028
      ..strokeCap = StrokeCap.round
      ..color = p.primaryMid;

    switch (art) {
      case SpotArt.document:
        final r = Rect.fromLTWH(w * 0.30, h * 0.22, w * 0.40, h * 0.52);
        final rr = RRect.fromRectAndRadius(r, Radius.circular(w * 0.04));
        canvas.drawRRect(rr, fill);
        canvas.drawRRect(rr, stroke);
        for (var i = 0; i < 3; i++) {
          final y = h * (0.34 + i * 0.10);
          canvas.drawLine(Offset(w * 0.37, y), Offset(w * 0.63, y), accent);
        }
        // Check seal, bottom-right.
        final c = Offset(w * 0.66, h * 0.68);
        canvas.drawCircle(c, w * 0.11, Paint()..color = p.primary);
        final chk = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.03
          ..strokeCap = StrokeCap.round
          ..color = p.onPrimary;
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - w * 0.05, c.dy)
            ..lineTo(c.dx - w * 0.01, c.dy + w * 0.04)
            ..lineTo(c.dx + w * 0.055, c.dy - w * 0.045),
          chk,
        );
      case SpotArt.search:
        final c = Offset(w * 0.44, h * 0.44);
        canvas.drawCircle(c, w * 0.20, fill);
        canvas.drawCircle(c, w * 0.20, stroke);
        canvas.drawLine(
            Offset(c.dx + w * 0.16, c.dy + h * 0.16),
            Offset(w * 0.72, h * 0.72),
            stroke..strokeWidth = w * 0.045);
      case SpotArt.success:
        final c = Offset(w / 2, h / 2);
        canvas.drawCircle(c, w * 0.26, fill);
        canvas.drawCircle(c, w * 0.26, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - w * 0.11, c.dy)
            ..lineTo(c.dx - w * 0.02, c.dy + w * 0.10)
            ..lineTo(c.dx + w * 0.13, c.dy - w * 0.10),
          accent..strokeWidth = w * 0.05,
        );
      case SpotArt.voice:
        // Speech bubble + sound bars — "in your words".
        final r = Rect.fromLTWH(w * 0.24, h * 0.26, w * 0.52, h * 0.36);
        final rr = RRect.fromRectAndRadius(r, Radius.circular(w * 0.08));
        canvas.drawRRect(rr, fill);
        canvas.drawRRect(rr, stroke);
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.36, h * 0.62)
            ..lineTo(w * 0.40, h * 0.74)
            ..lineTo(w * 0.50, h * 0.62),
          fill..style = PaintingStyle.fill,
        );
        for (var i = 0; i < 3; i++) {
          final x = w * (0.38 + i * 0.12);
          final bh = h * (0.06 + (i == 1 ? 0.08 : 0.03));
          canvas.drawLine(Offset(x, h * 0.44 - bh), Offset(x, h * 0.44 + bh),
              accent..strokeWidth = w * 0.035);
        }
      case SpotArt.shield:
        final path = Path()
          ..moveTo(w * 0.5, h * 0.20)
          ..lineTo(w * 0.74, h * 0.30)
          ..lineTo(w * 0.74, h * 0.52)
          ..arcToPoint(Offset(w * 0.5, h * 0.80),
              radius: Radius.circular(w * 0.5), clockwise: false)
          ..arcToPoint(Offset(w * 0.26, h * 0.52),
              radius: Radius.circular(w * 0.5), clockwise: false)
          ..lineTo(w * 0.26, h * 0.30)
          ..close();
        canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
        // Heart inside.
        final hc = Offset(w * 0.5, h * 0.50);
        final heart = Path()
          ..moveTo(hc.dx, hc.dy + h * 0.07)
          ..cubicTo(hc.dx - w * 0.16, hc.dy - h * 0.06, hc.dx - w * 0.04,
              hc.dy - h * 0.12, hc.dx, hc.dy - h * 0.04)
          ..cubicTo(hc.dx + w * 0.04, hc.dy - h * 0.12, hc.dx + w * 0.16,
              hc.dy - h * 0.06, hc.dx, hc.dy + h * 0.07)
          ..close();
        canvas.drawPath(heart, Paint()..color = p.primary);
    }
  }

  @override
  bool shouldRepaint(_SpotPainter old) => old.art != art || old.p != p;
}
