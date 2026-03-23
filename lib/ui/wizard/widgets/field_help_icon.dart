import 'package:flutter/material.dart';

/// A small info icon that shows a brief tooltip when tapped.
/// Designed for placement as a suffixIcon or next to a field label.
class FieldHelpIcon extends StatelessWidget {
  final String tooltip;

  const FieldHelpIcon({required this.tooltip, super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Help: $tooltip',
      child: IconButton(
        icon: Icon(
          Icons.help_outline,
          size: 18,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        tooltip: tooltip,
        onPressed: () => _showHelp(context),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 20, color: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(tooltip, style: Theme.of(ctx).textTheme.bodyMedium),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
