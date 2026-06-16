import 'package:flutter/material.dart';

/// A full-width 1px dashed horizontal rule (Flutter has no built-in dashed
/// Divider). Previously a `_DashedLinePainter` copy-pasted into the past-detail
/// and share-sheet screens.
class DashedDivider extends StatelessWidget {
  final Color color;
  const DashedDivider({required this.color, super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(double.infinity, 1),
        painter: _DashedLinePainter(color: color),
      );
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double x = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
