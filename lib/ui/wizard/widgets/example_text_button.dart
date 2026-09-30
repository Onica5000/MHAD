import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// A small "See examples" button that shows sample responses in a dialog.
/// Helps reduce writer's block on complex narrative fields.
class ExampleTextButton extends StatelessWidget {
  final String fieldName;
  final List<String> examples;

  const ExampleTextButton({
    required this.fieldName,
    required this.examples,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => _showExamples(context),
        icon: const Icon(Icons.lightbulb_outline, size: 16),
        label: Text(context.l10n.exampleTextSeeExamples),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
        ),
      ),
    );
  }

  void _showExamples(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.exampleTextTitle(fieldName)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ctx.l10n.exampleTextIntro,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              ...examples.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ctx.l10n.exampleTextNumbered(entry.key + 1),
                            style: Theme.of(ctx)
                                .textTheme
                                .labelSmall
                                ?.copyWith(color: cs.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(entry.value,
                              style: Theme.of(ctx).textTheme.bodySmall),
                        ],
                      ),
                    ),
                  )),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: cs.tertiaryContainer,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                child: Text(
                  ctx.l10n.exampleTextDisclaimer,
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                        color: cs.onTertiaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.exampleTextGotIt),
          ),
        ],
      ),
    );
  }
}
