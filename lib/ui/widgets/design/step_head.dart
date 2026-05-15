import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';

/// Editorial wizard step header: oversized italic serif numeral on the left,
/// "STEP n OF total" mono label, then bold sans title and subtitle.
class StepHead extends StatelessWidget {
  final int stepNumber; // 1-based
  final int totalSteps;
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  const StepHead({
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.fromLTRB(22, 24, 22, 16),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SerifNumeral(value: stepNumber, size: 54),
              const SizedBox(width: 14),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MonoCaption('Step $stepNumber of $totalSteps'),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.15,
              color: p.text,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              subtitle!,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                color: p.textMuted,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
