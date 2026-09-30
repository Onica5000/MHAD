import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Which spot illustration to draw.
enum SpotArt {
  document,
  search,
  success,
  voice,
  shield,

  /// Two people side by side: trust, sharing a copy with your agent.
  people,

  /// An open book: the Learn hub.
  book,

  /// A calendar page with a check: renewals and reminders.
  calendar,

  /// A sunrise over hills with a path and a speech bubble: the welcome
  /// hero ("your voice, planned ahead"). Drawn clipped to the disc.
  welcome,
}

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

    if (art == SpotArt.welcome) {
      _paintWelcome(canvas, w, h, stroke, accent);
      return;
    }

    switch (art) {
      case SpotArt.welcome:
        break; // painted above
      case SpotArt.people:
        // Back figure (smaller, tinted) then front figure, heart between.
        final back = Paint()..color = p.primary.withValues(alpha: 0.22);
        canvas.drawCircle(Offset(w * 0.62, h * 0.40), w * 0.075, back);
        canvas.drawPath(
          Path()
            ..moveTo(w * 0.50, h * 0.72)
            ..quadraticBezierTo(w * 0.50, h * 0.52, w * 0.62, h * 0.52)
            ..quadraticBezierTo(w * 0.74, h * 0.52, w * 0.74, h * 0.72)
            ..close(),
          back,
        );
        canvas.drawCircle(Offset(w * 0.41, h * 0.40), w * 0.085, fill);
        canvas.drawCircle(Offset(w * 0.41, h * 0.40), w * 0.085, stroke);
        final body = Path()
          ..moveTo(w * 0.26, h * 0.74)
          ..quadraticBezierTo(w * 0.26, h * 0.53, w * 0.41, h * 0.53)
          ..quadraticBezierTo(w * 0.56, h * 0.53, w * 0.56, h * 0.74)
          ..close();
        canvas.drawPath(body, fill);
        canvas.drawPath(body, stroke);
        _heart(canvas, Offset(w * 0.53, h * 0.27), w * 0.10,
            Paint()..color = p.primaryMid);
      case SpotArt.book:
        for (final left in [true, false]) {
          final sgn = left ? -1.0 : 1.0;
          final page = Path()
            ..moveTo(w * 0.5, h * 0.33)
            ..quadraticBezierTo(w * (0.5 + sgn * 0.12), h * 0.27,
                w * (0.5 + sgn * 0.25), h * 0.31)
            ..lineTo(w * (0.5 + sgn * 0.25), h * 0.70)
            ..quadraticBezierTo(w * (0.5 + sgn * 0.12), h * 0.66,
                w * 0.5, h * 0.72)
            ..close();
          canvas.drawPath(page, fill);
          canvas.drawPath(page, stroke);
          for (var i = 0; i < 3; i++) {
            final y = h * (0.42 + i * 0.08);
            canvas.drawLine(Offset(w * (0.5 + sgn * 0.07), y),
                Offset(w * (0.5 + sgn * 0.19), y - h * 0.01), accent);
          }
        }
      case SpotArt.calendar:
        final r = Rect.fromLTWH(w * 0.26, h * 0.28, w * 0.48, h * 0.46);
        final rr = RRect.fromRectAndRadius(r, Radius.circular(w * 0.05));
        canvas.drawRRect(rr, fill);
        canvas.save();
        canvas.clipRRect(rr);
        canvas.drawRect(Rect.fromLTWH(r.left, r.top, r.width, h * 0.11),
            Paint()..color = p.primary);
        canvas.restore();
        canvas.drawRRect(rr, stroke);
        for (final x in [0.37, 0.63]) {
          canvas.drawLine(Offset(w * x, h * 0.23), Offset(w * x, h * 0.32),
              stroke);
        }
        final dot = Paint()..color = p.primaryMid;
        for (var row = 0; row < 2; row++) {
          for (var col = 0; col < 3; col++) {
            canvas.drawCircle(
                Offset(w * (0.36 + col * 0.10), h * (0.50 + row * 0.10)),
                w * 0.018,
                dot);
          }
        }
        final c = Offset(w * 0.68, h * 0.70);
        canvas.drawCircle(c, w * 0.10, Paint()..color = p.primary);
        canvas.drawPath(
          Path()
            ..moveTo(c.dx - w * 0.045, c.dy)
            ..lineTo(c.dx - w * 0.01, c.dy + w * 0.035)
            ..lineTo(c.dx + w * 0.05, c.dy - w * 0.04),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = w * 0.028
            ..strokeCap = StrokeCap.round
            ..color = p.onPrimary,
        );
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

  void _heart(Canvas canvas, Offset c, double size, Paint paint) {
    final s = size / 2;
    canvas.drawPath(
      Path()
        ..moveTo(c.dx, c.dy + s * 0.9)
        ..cubicTo(c.dx - s * 2.0, c.dy - s * 0.5, c.dx - s * 0.5, c.dy - s * 1.4,
            c.dx, c.dy - s * 0.4)
        ..cubicTo(c.dx + s * 0.5, c.dy - s * 1.4, c.dx + s * 2.0, c.dy - s * 0.5,
            c.dx, c.dy + s * 0.9)
        ..close(),
      paint,
    );
  }

  /// Sunrise over rolling hills, a path leading toward it, and a speech
  /// bubble carrying a heart: the user's own voice, set down ahead of time.
  void _paintWelcome(
      Canvas canvas, double w, double h, Paint stroke, Paint accent) {
    final disc = Path()
      ..addOval(Rect.fromCircle(center: Offset(w / 2, h / 2), radius: w * 0.48));
    canvas.save();
    canvas.clipPath(disc);
    // Sun + soft halo.
    final sun = Offset(w * 0.62, h * 0.50);
    canvas.drawCircle(
        sun, w * 0.22, Paint()..color = p.primaryMid.withValues(alpha: 0.14));
    canvas.drawCircle(
        sun, w * 0.13, Paint()..color = p.primaryMid.withValues(alpha: 0.45));
    // Far hill, then near hill.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.66)
        ..quadraticBezierTo(w * 0.28, h * 0.50, w * 0.58, h * 0.64)
        ..quadraticBezierTo(w * 0.80, h * 0.73, w, h * 0.60)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = p.primary.withValues(alpha: 0.18),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.80)
        ..quadraticBezierTo(w * 0.35, h * 0.66, w * 0.70, h * 0.78)
        ..quadraticBezierTo(w * 0.86, h * 0.83, w, h * 0.76)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = p.primary.withValues(alpha: 0.32),
    );
    // Winding path toward the sun.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.40, h * 1.0)
        ..quadraticBezierTo(w * 0.62, h * 0.86, w * 0.48, h * 0.78)
        ..quadraticBezierTo(w * 0.38, h * 0.73, w * 0.56, h * 0.67),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.022
        ..strokeCap = StrokeCap.round
        ..color = p.onPrimary.withValues(alpha: 0.85),
    );
    canvas.restore();

    // Speech bubble with a heart, upper left (outside the clip so the tail
    // reads cleanly).
    final bubble = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.14, h * 0.20, w * 0.30, h * 0.20),
        Radius.circular(w * 0.06));
    canvas.drawRRect(bubble, Paint()..color = p.card);
    canvas.drawRRect(bubble, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.22, h * 0.40)
        ..lineTo(w * 0.22, h * 0.47)
        ..lineTo(w * 0.29, h * 0.40),
      stroke,
    );
    _heart(canvas, Offset(w * 0.29, h * 0.30), w * 0.09,
        Paint()..color = p.primary);
  }

  @override
  bool shouldRepaint(_SpotPainter old) => old.art != art || old.p != p;
}
