import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/wizard/widgets/document_pipeline_flow.dart';

/// A button that triggers the integrated document import pipeline:
/// pick document → extract → validate via NIH → review → smart fill → apply.
class DocumentImportButton extends ConsumerWidget {
  final int directiveId;
  final String formType;

  const DocumentImportButton({
    required this.directiveId,
    required this.formType,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasApiKey = ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty == true;
    final cs = Theme.of(context).colorScheme;

    return TextButton.icon(
      icon: Icon(
        Icons.document_scanner,
        size: 18,
        color: hasApiKey ? cs.primary : cs.onSurfaceVariant,
      ),
      label: Text(
        'Import',
        style: TextStyle(
          fontSize: 12,
          color: hasApiKey ? cs.primary : cs.onSurfaceVariant,
        ),
      ),
      onPressed: () {
        // Always open the snap-to-fill pipeline — it shows a "Set up AI"
        // banner when no key is set, rather than the user being bounced to
        // setup before they ever see the page.
        showDocumentPipelineFlow(
          context,
          directiveId: directiveId,
          formType: formType,
        );
      },
    );
  }
}
