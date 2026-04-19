import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Horizontal progress bar with the primary → primaryMid gradient fill used on
/// the wizard & directive cards.
class GradientProgress extends StatelessWidget {
  final double value; // 0..1
  final double height;

  const GradientProgress({
    required this.value,
    this.height = 5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final v = value.clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: p.border,
        borderRadius: BorderRadius.circular(100),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: v,
          heightFactor: 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [p.primary, p.primaryMid],
              ),
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ),
    );
  }
}
