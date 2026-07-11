import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Thin progress dots row, one bar per step. Filled bars = completed/current.
/// Matches the prototype's `StepDots`.
///
/// When [onStepTap] is provided the bars become tappable (and keyboard
/// focusable) jump targets, giving narrow/mobile layouts the same free step
/// navigation the desktop step rail has (2026-07-11 UX audit B7). The visual
/// bar stays [height] tall; the hit area grows to a centered 20px band.
class StepDots extends StatelessWidget {
  final int current; // 1-based — the dot at position [current] is the last filled
  final int total;
  final double height;
  final EdgeInsetsGeometry padding;

  /// Called with the 0-based step index when a bar is tapped. Null = the
  /// row is purely decorative progress (previous behavior).
  final ValueChanged<int>? onStepTap;

  const StepDots({
    required this.current,
    required this.total,
    this.height = 3,
    this.padding = const EdgeInsets.fromLTRB(22, 12, 22, 0),
    this.onStepTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    Widget bar(int i) => Container(
          height: height,
          decoration: BoxDecoration(
            color: i < current ? p.primary : p.border,
            borderRadius: BorderRadius.circular(2),
          ),
        );

    return Semantics(
      container: true,
      label: 'Step $current of $total',
      child: Padding(
        padding: padding,
        child: Row(
          children: [
            for (int i = 0; i < total; i++) ...[
              Expanded(
                child: onStepTap == null
                    ? bar(i)
                    : Semantics(
                        button: true,
                        label: 'Go to step ${i + 1} of $total',
                        child: InkWell(
                          onTap: () => onStepTap!(i),
                          borderRadius: BorderRadius.circular(4),
                          child: SizedBox(
                            height: 20,
                            child: Center(child: bar(i)),
                          ),
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
