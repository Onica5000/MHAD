import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Small pill-shaped controls for rows of short items (glossary words, list
/// entries). Built on real buttons, not Material chips: on the web, Flutter
/// gives EVERY chip a checked state (chip.dart sets `checked` in place of
/// `selected` there), so an action or input chip is announced as an unchecked
/// checkbox. FilterChip / ChoiceChip are fine: they ARE selectable.
/// `web_chip_semantics_rule_test` keeps the rule.

/// A pill that runs an action: tinted fill, or outlined (e.g. "+ Add").
class ActionPill extends StatelessWidget {
  const ActionPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.tooltip,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String? tooltip;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final cs = Theme.of(context).colorScheme;
    final style = TextButton.styleFrom(
      backgroundColor: outlined ? Colors.transparent : p.primaryTint,
      foregroundColor: outlined ? cs.onSurface : p.onPrimaryLight,
      shape: StadiumBorder(
        side: outlined ? BorderSide(color: cs.outline) : BorderSide.none,
      ),
      minimumSize: const Size(0, 40),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      tapTargetSize: MaterialTapTargetSize.padded,
      textStyle: Theme.of(context).textTheme.labelLarge,
    );
    // With a tooltip, it IS the accessible name ("What “Agent” means": it
    // contains the visible word, as WCAG 2.5.3 asks). A Tooltip outside the
    // button would put it on a separate node instead.
    final text = Text(label, semanticsLabel: tooltip);
    final button = icon == null
        ? TextButton(onPressed: onPressed, style: style, child: text)
        : TextButton.icon(
            onPressed: onPressed,
            style: style,
            icon: Icon(icon, size: 16),
            label: text,
          );
    return tooltip == null
        ? button
        : Tooltip(message: tooltip, excludeFromSemantics: true, child: button);
  }
}

/// An item in a list the person is building, with a remove button that names
/// the item ("Remove Racing thoughts").
class RemovablePill extends StatelessWidget {
  const RemovablePill({
    super.key,
    required this.label,
    required this.onRemove,
    this.background,
    this.foreground,
  });

  final String label;
  final VoidCallback onRemove;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final fg = foreground ?? p.onPrimaryLight;
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsetsDirectional.only(start: 16),
      decoration: ShapeDecoration(
        color: background ?? p.primaryTint,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: fg),
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: context.l10n.removeNamed(label),
            icon: Icon(Icons.close, size: 18, color: fg),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
