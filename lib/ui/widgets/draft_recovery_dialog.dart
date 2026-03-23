import 'package:flutter/material.dart';
import 'package:mhad/services/draft_recovery_service.dart';

/// Checks for a crash-recovery draft on app startup and shows a dialog
/// offering to restore it. Call from the home screen's initState.
Future<void> checkAndOfferDraftRecovery(BuildContext context) async {
  final draft = await DraftRecoveryService.checkForDraft();
  if (draft == null || !context.mounted) return;

  final restore = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.restore, color: cs.primary),
            const SizedBox(width: 8),
            const Expanded(child: Text('Recover Unsaved Work?')),
          ],
        ),
        content: Text(
          'It looks like the app closed unexpectedly. '
          'An auto-saved draft was found from ${draft.ageDescription}.\n\n'
          'This draft contains your treatment preferences and '
          'medical data (no personal information was saved).\n\n'
          'Would you like to restore it?',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await DraftRecoveryService.clearDraft();
              if (ctx.mounted) Navigator.pop(ctx, false);
            },
            child: const Text('Discard'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Restore'),
          ),
        ],
      );
    },
  );

  if (restore == true && context.mounted) {
    // Navigate to the wizard for the saved directive
    // The draft data will be applied by the wizard steps that read it
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Draft restored for directive #${draft.directiveId}. '
            'Personal information fields will need to be re-entered.'),
        duration: const Duration(seconds: 5),
      ),
    );
  } else {
    await DraftRecoveryService.clearDraft();
  }
}
