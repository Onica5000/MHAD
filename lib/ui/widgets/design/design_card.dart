import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

enum DesignCardVariant { plain, primary, warning, error, surface, tinted }

/// A themeable card used throughout the redesign. Matches the prototype's
/// default/primary/warning/error/surface/tinted variants.
class DesignCard extends StatelessWidget {
  final Widget child;
  final DesignCardVariant variant;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? radius;
  final BorderSide? overrideBorder;

  const DesignCard({
    required this.child,
    this.variant = DesignCardVariant.plain,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius,
    this.overrideBorder,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = theme.mhadPalette;
    final dark = theme.brightness == Brightness.dark;

    final (bg, borderSide) = switch (variant) {
      DesignCardVariant.plain => (p.card, BorderSide(color: p.border, width: 1)),
      DesignCardVariant.primary => (
          p.primaryLight,
          BorderSide(color: p.primary, width: 1.5)
        ),
      DesignCardVariant.warning => dark
          ? (SemanticColors.warningBgDark,
              BorderSide(color: SemanticColors.warningBorderDark))
          : (SemanticColors.warningBgLight,
              BorderSide(color: SemanticColors.warningBorderLight)),
      DesignCardVariant.error => dark
          ? (SemanticColors.errorBgDark,
              BorderSide(color: SemanticColors.errorBorderDark))
          : (SemanticColors.errorBgLight,
              BorderSide(color: SemanticColors.errorBorderLight)),
      DesignCardVariant.surface => (p.surface, BorderSide(color: p.border)),
      DesignCardVariant.tinted => (p.primaryTint, BorderSide(color: p.border)),
    };

    final effectiveBorder = overrideBorder ?? borderSide;
    final r = radius ?? DesignTokens.cardRadius;

    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(r),
        border: Border.fromBorderSide(effectiveBorder),
        boxShadow: DesignTokens.cardShadow(theme.brightness),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return Container(margin: margin, child: content);
    }

    return Container(
      margin: margin,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(r),
          child: content,
        ),
      ),
    );
  }
}
