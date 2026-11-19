import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/directive_export_service.dart';
import 'package:mhad/services/locked_progress/lock_crypto.dart';
import 'package:mhad/services/locked_progress/locked_format.dart';
import 'package:mhad/services/locked_progress/locked_progress_store.dart';
import 'package:mhad/services/locked_progress/progress_autosave.dart';
import 'package:mhad/services/passphrase/passphrase_lists.dart';
import 'package:mhad/services/passphrase/passphrase_strength.dart';
import 'package:mhad/ui/progress/passphrase_form.dart';
import 'package:mhad/ui/progress/progress_screens.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/utils/file_names.dart';
import 'package:share_plus/share_plus.dart';

/// Asks how to keep the work — once per tab, before anything is started or
/// opened (user decision 2026-11-18: "at the start"). True once the person
/// has chosen; false when they backed out (start nothing then), or when a
/// locked copy is waiting — the resume page opens instead. Always true off
/// the web.
Future<bool> ensureProgressChoice() async {
  if (!kIsWeb) return true;
  final store = lockedProgress;
  if (store.mode == ProgressMode.tabOnly) return true;
  if (store.mode == ProgressMode.locked && store.hasPassphrase) return true;
  if (store.savedCopy != null) {
    await appRouter.push(AppRoutes.resumeProgress);
    return false;
  }
  final nav = rootNavigatorKey.currentState;
  if (nav == null) return false;
  final chose = await nav.push<bool>(MaterialPageRoute(
    fullscreenDialog: true,
    builder: (_) => const ProgressChoiceScreen(),
  ));
  return chose == true;
}

/// A new directive of [type], after the choice. Null when the person backed
/// out.
Future<int?> startDirective(WidgetRef ref, FormType type) async {
  if (!await ensureProgressChoice()) return null;
  return ref.read(directiveRepositoryProvider).createDirective(type);
}

/// Downloads directive [directiveId] as a locked file (no expiry), with this
/// tab's passphrase — asking for one first when the person keeps nothing on
/// this device. Warns when the passphrase is weak or fair.
Future<void> downloadLockedProgress(
    BuildContext context, WidgetRef ref, int directiveId) async {
  final l = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final store = ref.read(lockedProgressProvider);
  if (!store.hasPassphrase) {
    final chosen = await Navigator.of(context).push<ChosenPassphrase>(
      MaterialPageRoute(
        builder: (_) =>
            PassphraseSetupScreen(actionLabel: l.passphraseLockAndDownload),
      ),
    );
    if (chosen == null) return;
    await store.setDownloadPassphrase(chosen.passphrase);
    ref.read(progressAutosaveProvider.notifier).noteStrength(chosen.estimate);
  }
  try {
    final wrapped = await DirectiveExportService(
            ref.read(directiveRepositoryProvider))
        .buildFilePayload(directiveId,
            nowMillis: DateTime.now().millisecondsSinceEpoch);
    final text = await store.lockForDownload(wrapped);
    if (text == null) return;
    final name = mhadFileName([
      kFileNamePrefix,
      'progress',
      DateFormat('yyyy-MM-dd').format(DateTime.now()),
    ], extension: DirectiveExportService.fileExtension);
    await SharePlus.instance.share(ShareParams(
      files: [
        XFile.fromData(Uint8List.fromList(utf8.encode(text)),
            mimeType: 'application/octet-stream', name: name)
      ],
      subject: l.exportShareSubjectEditable,
    ));
    final strength =
        ref.read(progressAutosaveProvider.notifier).passphraseStrength;
    final weak = strength != null &&
        strength.strength.index <= PassphraseStrength.fair.index;
    messenger.showSnackBar(SnackBar(
      duration: const Duration(seconds: 8),
      content: Text(weak
          ? l.progressDownloadWeakWarning(
              crackTimeLabel(l, strength.crackTime))
          : l.progressDownloadedLocked),
    ));
  } catch (e) {
    debugPrint('Locked download failed: $e');
    messenger.showSnackBar(
        SnackBar(content: Text(l.exportCouldnTSaveTheFile)));
  }
}

/// Asks for a locked file's passphrase until it opens (or the person
/// cancels). Returns the opened payload, or null. No try limit: a file can
/// be copied and guessed at elsewhere anyway.
Future<Object?> openLockedFile(BuildContext context, WidgetRef ref,
    LockedBlob blob) async {
  final store = ref.read(lockedProgressProvider);
  var wrong = false;
  while (true) {
    if (!context.mounted) return null;
    final passphrase = await showDialog<String>(
      context: context,
      builder: (_) => _FilePassphraseDialog(wrong: wrong),
    );
    if (passphrase == null) return null;
    try {
      final payload = await store.openFile(blob, passphrase);
      noteStrengthOf(ref, passphrase);
      return payload;
    } on LockOpenException {
      wrong = true;
    }
  }
}

/// Remembers how strong [passphrase] is (never the passphrase itself), for
/// the warning when a weak one locks a download.
void noteStrengthOf(WidgetRef ref, String passphrase) {
  final autosave = ref.read(progressAutosaveProvider.notifier);
  PassphraseLists.load().then(
      (lists) => autosave.noteStrength(estimatePassphrase(passphrase, lists)));
}

/// After a locked file opened: if this tab hasn't chosen yet, offer to keep
/// a locked copy with the file's own passphrase (or keep nothing).
Future<void> offerKeepCopyAfterFile(BuildContext context, WidgetRef ref) async {
  final store = ref.read(lockedProgressProvider);
  if (store.mode != ProgressMode.undecided) return;
  final l = context.l10n;
  final keep = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dctx) => AlertDialog(
      title: Text(l.progressChoiceTitle),
      content: Text(l.importKeepCopyBody(appData.config.progressWindowMinutes)),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: Text(l.importKeepCopyNo)),
        FilledButton(
            onPressed: () => Navigator.pop(dctx, true),
            child: Text(l.importKeepCopyYes)),
      ],
    ),
  );
  if (keep == true) {
    store.startLockedWithOpenedFile();
  } else {
    store.startTabOnly();
  }
  ref.read(progressAutosaveProvider.notifier).choiceChanged();
}

class _FilePassphraseDialog extends StatefulWidget {
  const _FilePassphraseDialog({required this.wrong});
  final bool wrong;

  @override
  State<_FilePassphraseDialog> createState() => _FilePassphraseDialogState();
}

class _FilePassphraseDialogState extends State<_FilePassphraseDialog> {
  final _field = TextEditingController();
  bool _show = false;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  void _submit() {
    if (_field.text.isNotEmpty) Navigator.pop(context, _field.text);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AlertDialog(
      title: Text(l.importLockedTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.importLockedBody),
          const SizedBox(height: 12),
          TextField(
            controller: _field,
            obscureText: !_show,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              labelText: l.passphraseFieldLabel,
              errorText: widget.wrong ? l.importLockedWrong : null,
              errorMaxLines: 3,
              suffixIcon: IconButton(
                tooltip: _show ? l.passphraseHide : l.passphraseShow,
                icon: Icon(_show
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => setState(() => _show = !_show),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l.cancel)),
        FilledButton(onPressed: _submit, child: Text(l.importLockedOpen)),
      ],
    );
  }
}
