import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';

/// Editorial wizard step header: oversized italic serif numeral on the left,
/// "STEP n OF total" mono label, then bold sans title and subtitle. An
/// optional top-right [onExit] affordance sits level with the numeral (the
/// wizard's "Exit" moved here from a separate header row above).
class StepHead extends StatelessWidget {
  final int stepNumber; // 1-based
  final int totalSteps;
  final String title;
  final String? subtitle;

  /// When set, renders an "Exit" button in the top-right of the header,
  /// aligned with the step numeral.
  final VoidCallback? onExit;
  final EdgeInsetsGeometry padding;

  const StepHead({
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    this.subtitle,
    this.onExit,
    this.padding = const EdgeInsets.fromLTRB(22, 10, 22, 16),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    // One clean spoken announcement that re-fires on every step change
    // (liveRegion) instead of the screen reader reading the decorative serif
    // numeral, the mono caption, and the title as three separate nodes.
    final announcement = StringBuffer('Step $stepNumber of $totalSteps. $title');
    if (subtitle != null) announcement.write('. $subtitle');
    return Semantics(
      liveRegion: true,
      label: announcement.toString(),
      child: Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ExcludeSemantics(
                  child: Row(
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
                ),
              ),
              if (onExit != null)
                Semantics(
                  button: true,
                  label: 'Exit',
                  child: InkWell(
                    onTap: onExit,
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 44,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Exit',
                              style: TextStyle(
                                fontFamily: kSansFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: p.primary,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Icon(Icons.close, size: 15, color: p.primary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 26,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.4,
                height: 1.15,
                color: p.text,
              ),
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 6),
            ExcludeSemantics(
              child: Text(
                subtitle!,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 14,
                  color: p.textMuted,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ],
      ),
      ),
    );
  }
}
