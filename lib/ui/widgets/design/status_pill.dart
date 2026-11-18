import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Small uppercase "● LABEL" status pill (a directive's status, "PERMANENT
/// ACTION" on Revoke). It HUGS its text wherever it is placed: in a ListView
/// the old pill was stretched across the whole column (2026-11 overhaul).
class StatusPill extends StatelessWidget {
  final String label;
  final Color foreground;
  final Color background;

  /// Whether to prefix a "● " dot (the existing pills do).
  final bool dot;

  const StatusPill({
    required this.label,
    required this.foreground,
    required this.background,
    this.dot = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
      ),
      child: Text(
        '${dot ? '● ' : ''}${label.toUpperCase()}',
        style: TextStyle(
          fontSize: 12, letterSpacing: MhadType.trackingEyebrow,
          fontWeight: FontWeight.w700,
          color: foreground,
        ),
      ),
      ),
    );
  }
}
