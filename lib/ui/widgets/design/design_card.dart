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
  /// Web/desktop hover-lift: when true AND [onTap] is set, the card raises on
  /// hover (deeper shadow + a few px rise). Opt-in; default keeps the flat
  /// resting card. Honors reduce-motion (no animation when disabled).
  final bool hoverLift;

  const DesignCard({
    required this.child,
    this.variant = DesignCardVariant.plain,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.radius,
    this.overrideBorder,
    this.hoverLift = false,
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

    // Tappable cards get an explicit button role for screen readers and a
    // visible keyboard-focus ring (2026-07-11 UX audit A1) — the InkWell
    // alone announced as a generic tappable and had no focus indication.
    return Container(
      margin: margin,
      child: Semantics(
        button: true,
        child: _TappableCard(
          bg: bg,
          border: effectiveBorder,
          radius: r,
          padding: padding,
          onTap: onTap!,
          hoverLift: hoverLift,
          child: child,
        ),
      ),
    );
  }
}

/// Wraps ANY card-like child so it raises on pointer hover (web/desktop):
/// adds a deeper shadow + a few-px rise. Transparent to layout and hit-testing
/// (taps pass through), and skips animation under reduce-motion. Use for custom
/// cards that aren't built with [DesignCard].
class HoverLift extends StatefulWidget {
  final Widget child;
  final double radius;
  final double lift;
  /// When false, the child is returned unchanged (no hover effect) — e.g. for
  /// disabled cards that aren't tappable.
  final bool enabled;
  const HoverLift({
    required this.child,
    this.radius = DesignTokens.cardRadius,
    this.lift = 3,
    this.enabled = true,
    super.key,
  });

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    final b = Theme.of(context).brightness;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final lifted = _hover && !reduce;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: reduce ? Duration.zero : const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: lifted
            ? Matrix4.translationValues(0.0, -widget.lift, 0.0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: _hover ? DesignTokens.raisedShadow(b) : null,
        ),
        child: widget.child,
      ),
    );
  }
}

/// Tappable card body shared by both DesignCard tap paths: hover lift
/// (optional, web/desktop), plus a visible keyboard-focus ring drawn as a
/// spread shadow (no layout shift). Animation is skipped under
/// reduce-motion. (Replaces the old _HoverLiftCard — UX audit A1.)
class _TappableCard extends StatefulWidget {
  final Color bg;
  final BorderSide border;
  final double radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback onTap;
  final bool hoverLift;
  final Widget child;
  const _TappableCard({
    required this.bg,
    required this.border,
    required this.radius,
    required this.padding,
    required this.onTap,
    required this.hoverLift,
    required this.child,
  });

  @override
  State<_TappableCard> createState() => _TappableCardState();
}

class _TappableCardState extends State<_TappableCard> {
  bool _hover = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = theme.brightness;
    final p = theme.mhadPalette;
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final lifted = widget.hoverLift && _hover && !reduce;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: reduce ? Duration.zero : const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        transform: lifted
            ? Matrix4.translationValues(0.0, -3.0, 0.0)
            : Matrix4.identity(),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: widget.bg,
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.fromBorderSide(widget.border),
          boxShadow: [
            // Keyboard-focus ring: a hard spread shadow (no layout shift).
            if (_focused)
              BoxShadow(color: p.primary, spreadRadius: 2),
            ...(widget.hoverLift && _hover
                ? DesignTokens.raisedShadow(b)
                : DesignTokens.cardShadow(b)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.radius),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(widget.radius),
            onFocusChange: (f) => setState(() => _focused = f),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
