import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/directive_export_service.dart';
import 'package:mhad/ui/router.dart';

/// "Continue from a saved file": pick a previously-downloaded directive file
/// (`.mhad`, encrypted or plaintext), restore it into a fresh working directive,
/// and open the wizard. Distinct from snap-to-fill (which reads an arbitrary
/// document); this rehydrates the user's own exact export. Decodes via
/// [DirectiveExportService] (no passphrase — the app reads it directly).
Future<void> importSavedDirectiveFile(
    BuildContext context, WidgetRef ref) async {
  // App-level messenger captured before any await so the post-import notice
  // survives both the file-picker gap and the navigation below.
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final file = await FilePicker.pickFile(
    type: FileType.custom,
    allowedExtensions: ['mhad', 'json', 'txt'],
  );
  if (file == null) return; // cancelled
  Uint8List? bytes;
  try {
    bytes = await file.readAsBytes();
  } catch (_) {
    bytes = null;
  }
  if (bytes == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.savedImportCouldNotRead)),
      );
    }
    return;
  }
  try {
    final repo = ref.read(directiveRepositoryProvider);
    final id = await DirectiveExportService(repo).importFile(bytes);
    if (context.mounted) {
      context.go(AppRoutes.wizardRoute(id));
      // Imported files come back as an editable draft (see
      // DirectiveRepository.restoreFromSnapshot) — make the re-sign step clear
      // so the user doesn't assume the old signature still makes it valid.
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.savedImportImportedAsDraft),
          duration: const Duration(seconds: 7),
        ),
      );
    }
  } on DirectiveImportException catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.messageIn(context.l10n))),
      );
    }
  }
}
