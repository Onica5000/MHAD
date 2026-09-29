import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/labeled_spinner.dart';

/// Full-pane loading state.
///
/// Replaces the bare `Center(child: CircularProgressIndicator())` that had
/// spread across a dozen screens: those gave no screen-reader cue, no sense of
/// *what* was loading, and — because each sat at whatever height its parent
/// happened to be — made the app appear to jump as panes swapped. This centers
/// a labeled spinner over a consistent minimum height with an optional caption.
///
/// Pass a [label] describing the specific thing being fetched ("Loading your
/// directives") so assistive tech announces something useful; it doubles as the
/// visible caption unless [showCaption] is false.
class PageLoading extends StatelessWidget {
  final String label;

  /// Whether to draw [label] as visible muted text under the spinner. Keep it
  /// on for slow/page-level waits; turn it off inside small inline panes where
  /// the caption would crowd the layout (the semantic label still applies).
  final bool showCaption;

  /// Minimum vertical space the state occupies, so swapping between loading
  /// and loaded content doesn't collapse and re-expand the scroll position.
  final double minHeight;

  const PageLoading({
    this.label = 'Loading',
    this.showCaption = true,
    this.minHeight = 180,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LabeledSpinner(label: label, size: 28, strokeWidth: 3),
            if (showCaption) ...[
              const SizedBox(height: DesignTokens.space12),
              // Already announced via the spinner's Semantics label — hide the
              // caption from screen readers so it isn't read out twice.
              ExcludeSemantics(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: DesignTokens.fontCaption,
                    color: p.textMuted,
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

/// Full-pane empty / error state: icon, headline, optional supporting line and
/// a single action. One look for "nothing here yet" and "that didn't load",
/// which previously varied per screen (some styled, some a bare sentence).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;

  /// Optional single action, e.g. a Retry button.
  final Widget? action;

  /// Announce [title] politely when this state appears — use for *error*
  /// states, where the user needs to know something failed. Leave false for
  /// ordinary "nothing here yet" emptiness, which isn't worth interrupting for.
  final bool announce;

  const EmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.announce = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: DesignTokens.space32,
        horizontal: DesignTokens.space20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: p.textMuted),
          const SizedBox(height: DesignTokens.space12),
          Semantics(
            liveRegion: announce,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(color: p.text),
            ),
          ),
          if (message != null) ...[
            const SizedBox(height: DesignTokens.space6),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: DesignTokens.fontCaption,
                height: 1.45,
                color: p.textMuted,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: DesignTokens.space16),
            action!,
          ],
        ],
      ),
    );
  }
}
