import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Small uppercase mono "● LABEL" status/notice pill. Previously copy-pasted
/// (status pill in past-detail, "PERMANENT ACTION" pill in revocation).
class MonoPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  /// Whether to prefix a "● " dot (the existing pills do).
  final bool dot;

  const MonoPill({
    required this.label,
    required this.foreground,
    required this.background,
    this.dot = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        '${dot ? '● ' : ''}${label.toUpperCase()}',
        style: TextStyle(
          fontFamily: kMonoFamily,
          fontFamilyFallback: const [
            'Consolas',
            'Menlo',
            'Courier New',
            'monospace'
          ],
          fontSize: 11,
          letterSpacing: 1,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}
