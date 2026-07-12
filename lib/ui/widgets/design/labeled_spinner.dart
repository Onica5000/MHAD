import 'package:flutter/material.dart';

/// A [CircularProgressIndicator] with a screen-reader label (2026-07-11 UX
/// audit A5 — bare spinners give assistive-tech users no "loading" cue).
/// Use a context-specific [label] when the caller knows what's loading.
class LabeledSpinner extends StatelessWidget {
  final String label;
  final double? size;
  final double? strokeWidth;
  final Color? color;

  const LabeledSpinner({
    this.label = 'Loading',
    this.size,
    this.strokeWidth,
    this.color,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final spinner = CircularProgressIndicator(
      strokeWidth: strokeWidth ?? 4,
      color: color,
    );
    return Semantics(
      label: label,
      child: size == null
          ? spinner
          : SizedBox(width: size, height: size, child: spinner),
    );
  }
}
