import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Sticky bottom action bar for the wizard. Renders an optional secondary
/// (ghost-style) action on the left and a primary action on the right with a
/// trailing arrow icon. Blends into the scaffold via a top gradient so content
/// fades behind it as the user scrolls.
class WizardBottomBar extends StatelessWidget {
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool primaryLoading;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final IconData primaryIcon;
  final bool showGradient;

  const WizardBottomBar({
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryLoading = false,
    this.secondaryLabel,
    this.onSecondary,
    this.primaryIcon = Icons.arrow_forward,
    this.showGradient = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
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
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Row(
            children: [
              if (secondaryLabel != null)
                TextButton(
                  onPressed: onSecondary,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                  child: Text(
                    secondaryLabel!,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: p.primary,
                    ),
                  ),
                ),
              const Spacer(),
              SizedBox(
                height: DesignTokens.buttonHeightMd,
                child: FilledButton.icon(
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
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
