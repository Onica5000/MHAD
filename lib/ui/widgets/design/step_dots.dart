import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Thin progress dots row, one bar per step. Filled bars = completed/current.
/// Matches the prototype's `StepDots`.
class StepDots extends StatelessWidget {
  final int current; // 1-based — the dot at position [current] is the last filled
  final int total;
  final double height;
  final EdgeInsetsGeometry padding;

  const StepDots({
    required this.current,
    required this.total,
    this.height = 3,
    this.padding = const EdgeInsets.fromLTRB(22, 12, 22, 0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      label: 'Step $current of $total',
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            for (int i = 0; i < total; i++) ...[
              Expanded(
                child: Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: i < current ? p.primary : p.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (i < total - 1) const SizedBox(width: 4),
            ],
          ],
        ),
      ),
    );
  }
}
