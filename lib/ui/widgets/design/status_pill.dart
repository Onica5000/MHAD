import 'package:flutter/material.dart';

/// Small rounded pill with icon + label used for status chips in the redesign.
class StatusPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  const StatusPill({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}
