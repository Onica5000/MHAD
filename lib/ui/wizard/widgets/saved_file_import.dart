import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/directive_export_service.dart';
import 'package:mhad/ui/progress/progress_gate.dart';
import 'package:mhad/ui/router.dart';

/// "Continue from a saved file": pick a previously-downloaded directive file
/// (`.mhad`), restore it into a fresh working directive, and open the wizard.
/// Distinct from snap-to-fill (which reads an arbitrary document); this
/// rehydrates the user's own exact export.
///
/// A passphrase-locked file (what downloads are since 2026-11-18) asks for
/// its passphrase, then offers to keep a locked copy on this device with that
/// same passphrase. An older file (readable, or scrambled with the app key)
/// opens directly, after the usual start question ([ensureProgressChoice]).
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
    final locked = DirectiveExportService.lockedFile(bytes);
    final int id;
    if (locked != null) {
      final payload = await openLockedFile(ref, locked);
      if (payload == null) return; // cancelled
      final data = DirectiveExportService.dataFromWrapped(payload);
      // Ask before restoring: once a directive exists, Home swaps the page
      // that started this import out.
      await offerKeepCopyAfterFile(ref);
      id = await repo.restoreFromSnapshot(data);
    } else {
      DirectiveExportService.parseFile(bytes); // unreadable? say so first
      if (!await ensureProgressChoice()) return;
      id = await DirectiveExportService(repo).importFile(bytes);
    }
    // The global router: the widget that started the import may be gone by
    // now (Home swaps its landing out once a directive exists).
    {
      appRouter.go(AppRoutes.wizardRoute(id));
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
