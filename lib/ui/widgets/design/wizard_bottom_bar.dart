import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Sticky bottom action bar for the wizard: the primary action (Continue) on
/// the right with a trailing arrow, an optional secondary action (Back) and
/// optional AI help (✦ Ask). Blends into the scaffold via a top gradient so
/// content fades behind it as the user scrolls.
///
/// Layout — the same places on every step:
///   * without Ask:  [Back] ............ [Continue →]
///   * with Ask:     [✦ Ask] ..... [Back] [Continue →]
/// Ask is a tinted secondary button (one primary action per bar).
class WizardBottomBar extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryLoading;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData primaryIcon;
  final bool showGradient;

  /// Optional AI help on the left (✦ + [assistLabel]). When it doesn't fit
  /// beside Back and Continue at the current width, text size and language,
  /// it shrinks to the ✦ icon, named by [assistTooltip], so the row never
  /// overflows.
  final String? assistLabel;
  final String? assistTooltip;
  final VoidCallback? onAssist;

  const WizardBottomBar({
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryLoading = false,
    this.secondaryLabel,
    this.onSecondary,
    this.primaryIcon = Icons.arrow_forward,
    this.showGradient = true,
    this.assistLabel,
    this.assistTooltip,
    this.onAssist,
    super.key,
  });

  static const _backGap = 8.0;
  static const _groupGap = 16.0;

  /// How Ask fits beside Back and Continue in [maxWidth], measured with the
  /// buttons' own theme text styles at the current text size (the app's
  /// default is 1.2×): labelled, the ✦ icon, or — at the largest text on a
  /// small phone — not at all (the More sheet still has Ask AI).
  _AssistFit _assistFit(BuildContext context, double maxWidth) {
    final theme = Theme.of(context);
    final filled = theme.filledButtonTheme.style?.textStyle?.resolve(const {}) ??
        theme.textTheme.labelLarge ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    final text = (theme.textButtonTheme.style?.textStyle?.resolve(const {}) ??
            const TextStyle())
        .copyWith(fontSize: 14, fontWeight: FontWeight.w600);
    double w(String label, TextStyle style) {
      final tp = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout();
      final width = tp.width;
      tp.dispose();
      return width;
    }

    final back = secondaryLabel == null
        ? 0.0
        : w(secondaryLabel!, text) + 32 + _backGap;
    final primary = w(primaryLabel, filled) + 18 + 8 + 48;
    if (assistLabel != null &&
        w(assistLabel!, filled) + 18 + 8 + 32 + _groupGap + back + primary <=
            maxWidth) {
      return _AssistFit.labelled;
    }
    return 48 + _groupGap + back + primary <= maxWidth
        ? _AssistFit.icon
        : _AssistFit.none;
  }

  Widget _assist(BuildContext context, {required bool labelled}) {
    final p = Theme.of(context).mhadPalette;
    const icon = Icon(Icons.auto_awesome, size: 18);
    if (!labelled) {
      return IconButton(
        onPressed: onAssist,
        icon: icon,
        tooltip: assistTooltip ?? assistLabel,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        style: IconButton.styleFrom(
          backgroundColor: p.primaryLight,
          foregroundColor: p.onPrimaryLight,
        ),
      );
    }
    return Tooltip(
      message: assistTooltip ?? '',
      child: FilledButton.icon(
        onPressed: onAssist,
        icon: icon,
        // Spoken as the full name (it contains the visible word).
        label: Text(assistLabel!, semanticsLabel: assistTooltip),
        style: FilledButton.styleFrom(
          backgroundColor: p.primaryLight,
          foregroundColor: p.onPrimaryLight,
          elevation: 0,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final back = secondaryLabel == null
        ? null
        : TextButton(
            onPressed: onSecondary,
            style: TextButton.styleFrom(
              // Guarantee a 48px tap target (accessibility) for Back.
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            child: Text(
              secondaryLabel!,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.primary,
              ),
            ),
          );
    // Height comes from the button's own style, NOT a SizedBox wrapper. A
    // tight-height SizedBox while the Row measures this child at unbounded
    // width made the button's tap-target padder throw "infinite width", so
    // the bar failed to paint.
    final primary = FilledButton.icon(
      onPressed: primaryLoading ? null : onPrimary,
      icon: primaryLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(primaryIcon, size: 18),
      label: Text(primaryLabel),
      style: FilledButton.styleFrom(
        iconAlignment: IconAlignment.end,
        minimumSize: Size(0, DesignTokens.buttonHeightMd),
        padding: const EdgeInsets.symmetric(horizontal: 24),
      ),
    );
    return Container(
      decoration: showGradient
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  p.scaffoldBackground.withValues(alpha: 0),
                  p.scaffoldBackground.withValues(alpha: 0.96),
                  p.scaffoldBackground,
                ],
                stops: const [0.0, 0.35, 1.0],
              ),
            )
          : BoxDecoration(
              color: p.card,
              border: Border(top: BorderSide(color: p.border)),
            ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          // spaceBetween (NOT a Spacer): a Spacer is a flex child, which makes
          // the Row measure its non-flex children (the FilledButton) at an
          // unbounded width first — and the button can't lay out under infinite
          // width, so the whole bar failed to paint (the "no nav buttons on
          // mobile" bug). With no flex child the children are measured at the
          // real bounded width. An empty leading box keeps Continue right-
          // aligned when there's no Back.
          child: LayoutBuilder(builder: (context, constraints) {
            final fit = onAssist == null
                ? _AssistFit.none
                : _assistFit(context, constraints.maxWidth);
            if (fit == _AssistFit.none) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [back ?? const SizedBox.shrink(), primary],
              );
            }
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _assist(context, labelled: fit == _AssistFit.labelled),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (back != null) ...[back, const SizedBox(width: _backGap)],
                    primary,
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

enum _AssistFit { labelled, icon, none }
