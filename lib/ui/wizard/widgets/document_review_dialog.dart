import 'package:flutter/material.dart';
import 'package:mhad/ai/document_extraction_result.dart';

/// Shows extracted document data for review. The user can edit values,
/// check/uncheck items, and then import. Returns a map of accepted
/// field labels to their (possibly edited) values, or null if cancelled.
Future<Map<String, String>?> showDocumentReviewDialog(
  BuildContext context,
  DocumentExtractionResult result,
) {
  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => _ReviewDialog(result: result),
  );
}

class _ReviewDialog extends StatefulWidget {
  final DocumentExtractionResult result;
  const _ReviewDialog({required this.result});

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  late final Map<String, String> _values;
  late final Map<String, bool> _selected;

  @override
  void initState() {
    super.initState();
    _values = Map<String, String>.from(widget.result.toDisplayMap());
    _selected = {for (final key in _values.keys) key: true};
  }

  Future<void> _editField(String key) async {
    final controller = TextEditingController(text: _values[key]);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(key),
        content: TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result != null && mounted) {
      setState(() {
        _values[key] = result;
        if (result.trim().isNotEmpty) _selected[key] = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedCount = _selected.values.where((v) => v).length;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.fact_check, size: 22),
          SizedBox(width: 8),
          Expanded(child: Text('Review Extracted Data')),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review and edit the extracted information. '
              'Tap any item to modify it before importing.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _values.length,
                separatorBuilder: (_, _) => const SizedBox(height: 4),
                itemBuilder: (ctx, index) {
                  final key = _values.keys.elementAt(index);
                  final value = _values[key]!;
                  final checked = _selected[key]!;

                  return Card(
                    margin: EdgeInsets.zero,
                    color: checked
                        ? cs.surfaceContainerLow
                        : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _editField(key),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 2, 8, 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: checked,
                              onChanged: (v) => setState(
                                  () => _selected[key] = v ?? false),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(key,
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .labelLarge),
                                    const SizedBox(height: 2),
                                    Text(
                                      value,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(ctx)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Icon(Icons.edit,
                                size: 14, color: cs.onSurfaceVariant),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: cs.onTertiaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'AI extraction is not guaranteed to be accurate. '
                      'Always review and edit imported data.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: cs.onTertiaryContainer,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: selectedCount == 0
              ? null
              : () {
                  final accepted = <String, String>{};
                  for (final entry in _values.entries) {
                    if (_selected[entry.key] == true &&
                        entry.value.trim().isNotEmpty) {
                      accepted[entry.key] = entry.value;
                    }
                  }
                  Navigator.pop(context, accepted);
                },
          child: Text(
              'Import $selectedCount item${selectedCount == 1 ? '' : 's'}'),
        ),
      ],
    );
  }
}
