import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/art_image.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';

/// Wizard step header: "STEP n OF total" caption, bold title and subtitle,
/// with the step's own photo beside them, and the step's top-right actions
/// (Exit, and on phones "More").
///
/// The photo is ALWAYS shown at a fixed size — never toggled when the
/// keyboard opens, which would relayout in the same frame the keyboard
/// animates and make the focused field jump (review R5). It replaced the
/// oversized serif step numeral of the first design.
class StepHead extends StatelessWidget {
  final int stepNumber; // 1-based
  final int totalSteps;
  final String title;
  final String? subtitle;

  /// The step's photo (see WizardStepArt in app_art.dart).
  final AppArt? art;

  /// When set, renders an "Exit" button in the top-right of the header.
  final VoidCallback? onExit;

  /// When set (phones), a "More" button beside Exit opens the app's More
  /// sheet — the wizard hides the bottom nav to give the form room, so every
  /// destination (incl. 988 crisis help) stays one tap away here.
  final VoidCallback? onMore;
  final EdgeInsetsGeometry padding;

  const StepHead({
    required this.stepNumber,
    required this.totalSteps,
    required this.title,
    this.subtitle,
    this.art,
    this.onExit,
    this.onMore,
    this.padding = const EdgeInsets.fromLTRB(20, 12, 20, 16),
    super.key,
  });

  /// Photo size: compact on phones, larger once the form column is roomy.
  static const double _photoNarrow = 56;
  static const double _photoWide = 96;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    // One clean spoken announcement that re-fires on every step change
    // (liveRegion) instead of the screen reader reading the caption, the
    // title and the subtitle as three separate nodes.
    final announcement = StringBuffer(
        '${context.l10n.stepDotsStepOf(stepNumber, totalSteps)}. $title');
    if (subtitle != null) announcement.write('. $subtitle');

    Widget headerAction({
      required String label,
      required IconData icon,
      required VoidCallback onTap,
    }) =>
        Semantics(
          button: true,
          label: label,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
            child: SizedBox(
              height: 44,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: p.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(icon, size: 16, color: p.primary),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

    return Padding(
      padding: padding,
      child: LayoutBuilder(builder: (context, box) {
        final photo = box.maxWidth >= 600 ? _photoWide : _photoNarrow;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    liveRegion: true,
                    label: announcement.toString(),
                    child: ExcludeSemantics(
                      child: CapsCaption(context.l10n
                          .stepDotsStepOf(stepNumber, totalSteps)),
                    ),
                  ),
                ),
                if (onMore != null)
                  headerAction(
                    label: context.l10n.navMore,
                    icon: Icons.more_horiz,
                    onTap: onMore!,
                  ),
                if (onExit != null)
                  headerAction(
                    label: context.l10n.wizardExit,
                    icon: Icons.close,
                    onTap: onExit!,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700, letterSpacing: MhadType.trackingTitle, height: MhadType.leadingTitle,
                            color: p.text,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 14,
                              color: p.textMuted, height: MhadType.leadingParagraph,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (art != null) ...[
                  const SizedBox(width: 16),
                  ArtImage(
                    art!,
                    width: photo,
                    height: photo,
                    radius: DesignTokens.cardRadius,
                  ),
                ],
              ],
            ),
          ],
        );
      }),
    );
  }
}
