import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
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

    return Semantics(
      button: true,
      label: 'Import from document',
      child: Tooltip(
        message: hasApiKey
            ? 'Import data from a photo, PDF, or text file'
            : 'Set up AI to use document import',
        child: IconButton(
          icon: Icon(
            Icons.document_scanner,
            color: hasApiKey ? cs.primary : cs.onSurfaceVariant,
          ),
          onPressed: () {
            if (!hasApiKey) {
              context.push(AppRoutes.aiSetup);
              return;
            }
            showDocumentPipelineFlow(
              context,
              directiveId: directiveId,
              formType: formType,
            );
          },
        ),
      ),
    );
  }
}
