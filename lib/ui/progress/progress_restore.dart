import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/handoff/pending_handoff.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/services/locked_progress/progress_payload.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/utils/a11y_announce.dart';

/// After a progress copy came back into this tab ([restoreProgressPayload]):
/// adopt its pending AI answer, say so, and open where the person was — the
/// paste page they were waiting on, else the directive they were working
/// on. [personalInfoMissing]: the tab-only copy leaves names and addresses
/// out, so they need typing again.
void openRestoredProgress(
  BuildContext context,
  WidgetRef ref,
  RestoredProgress restored, {
  required bool personalInfoMissing,
}) {
  final waits = ref.read(pendingHandoffProvider.notifier);
  final handoff = restored.handoff;
  if (handoff != null) {
    waits.adopt(handoff);
  } else {
    waits.clear();
  }
  final current = restored.current ??
      (restored.ids.isEmpty ? null : restored.ids.values.last);
  final target = handoff != null && handoff.resumable
      ? handoff.route
      : current != null
          ? AppRoutes.wizardRoute(current)
          : AppRoutes.home;

  final l = context.l10n;
  final message = personalInfoMissing
      ? l.homeSessionRestoredPersonalInfoMust
      : l.progressRestored;
  announce(context, message);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
  );
  appRouter.go(target);
}
