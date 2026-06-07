import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Thin in-body header row that replaces the wizard's Material AppBar
/// across every step screen. Matches ds.jsx::WizardHeader (L251-263):
///
///   * 8px top / 22px sides / 0 bottom padding (no Material chrome height)
///   * Left: chevron + "Back" label, primary 13/600
///   * Right: "Save & exit" label, textMuted 13/500 (overridable via [right])
///
/// Each side is hit-tested individually as a 48dp tap target via Semantics +
/// InkWell so Android a11y guidelines still pass. The header has no
/// background fill — it sits directly on the scaffold background and lets
/// content below scroll up under it visually if the caller wants.
class WizardHeader extends StatelessWidget {
  /// Label for the left affordance. Defaults to "Back".
  final String backLabel;

  /// Tap handler for the left affordance. When null the row renders the
  /// label but doesn't respond to taps (used on step 1 where there's no
  /// previous step — callers should prefer passing a Save-and-exit handler
  /// instead of a null Back).
  final VoidCallback? onBack;

  /// Label for the right affordance. Defaults to "Save & exit". Set to an
  /// empty string to hide the right side entirely.
  final String actionLabel;

  /// Tap handler for the right affordance.
  final VoidCallback? onAction;

  /// Optional widget to render on the right in place of the default text
  /// action — used by the read-only / past-detail variants that want a
  /// status pill there.
  final Widget? right;

  final EdgeInsetsGeometry padding;

  const WizardHeader({
    this.backLabel = 'Back',
    this.onBack,
    this.actionLabel = 'Save & exit',
    this.onAction,
    this.right,
    this.padding = const EdgeInsets.fromLTRB(22, 8, 22, 0),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: padding,
      // Row sits 48dp tall so each side's InkWell renders a ≥48×48 tap target
      // (Android a11y guideline). The visible chevron/label stays compact —
      // it's vertically centred inside the taller hit area, so the editorial
      // thinness is preserved while the touch region meets the guideline.
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Semantics(
              button: onBack != null,
              label: backLabel,
              child: InkWell(
                onTap: onBack,
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chevron_left, size: 16, color: p.primary),
                        const SizedBox(width: 2),
                        Text(
                          backLabel,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            if (right != null)
              right!
            else if (actionLabel.isNotEmpty)
              Semantics(
                button: onAction != null,
                label: actionLabel,
                child: InkWell(
                  onTap: onAction,
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          actionLabel,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: p.textMuted,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
