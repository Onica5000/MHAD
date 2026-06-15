import 'package:flutter/material.dart';

/// Small rounded "988" crisis pill shown in the corner of the disclaimer gate
/// and the onboarding intro. Colors are passed in so the caller can be
/// light/dark-aware; [onTap] decides the action (open the crisis sheet, or dial
/// 988 directly). The 48px outer height keeps an accessible tap target.
class Crisis988Pill extends StatelessWidget {
  final Color bg;
  final Color border;
  final Color fg;
  final VoidCallback onTap;
  final String label;

  const Crisis988Pill({
    required this.bg,
    required this.border,
    required this.fg,
    required this.onTap,
    this.label = 'Need 988',
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Need 988 — open crisis resources',
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 48,
            child: Center(
              widthFactor: 1,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone_outlined, size: 11, color: fg),
                    const SizedBox(width: 5),
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
