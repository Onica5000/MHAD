import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

enum InfoBannerVariant { info, warning, error, success }

/// Small attention-grabbing banner used across screens to deliver short
/// contextual notices (disclaimer notes, AI readiness, privacy, etc).
class InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final InfoBannerVariant variant;
  final VoidCallback? onAction;
  final String? actionLabel;
  final EdgeInsetsGeometry? margin;

  const InfoBanner({
    required this.icon,
    required this.text,
    this.variant = InfoBannerVariant.info,
    this.onAction,
    this.actionLabel,
    this.margin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.mhadPalette;
    final dark = theme.brightness == Brightness.dark;

    final (bg, border, fg) = switch (variant) {
      InfoBannerVariant.info => (p.primaryLight, p.border, p.primaryDark),
      InfoBannerVariant.warning => dark
          ? (SemanticColors.warningBgDark, SemanticColors.warningBorderDark,
              SemanticColors.warningTextDark)
          : (SemanticColors.warningBgLight, SemanticColors.warningBorderLight,
              SemanticColors.warningTextLight),
      InfoBannerVariant.error => dark
          ? (SemanticColors.errorBgDark, SemanticColors.errorBorderDark,
              SemanticColors.errorTextDark)
          : (SemanticColors.errorBgLight, SemanticColors.errorBorderLight,
              SemanticColors.errorTextLight),
      InfoBannerVariant.success => dark
          ? (SemanticColors.successBgDark, SemanticColors.successBorderDark,
              SemanticColors.successTextDark)
          : (SemanticColors.successBgLight, SemanticColors.successBorderLight,
              SemanticColors.successTextLight),
    };

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: TextStyle(
                    color: fg,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                if (onAction != null && actionLabel != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: InkWell(
                      onTap: onAction,
                      child: Text(
                        '$actionLabel →',
                        style: TextStyle(
                          color: fg,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
