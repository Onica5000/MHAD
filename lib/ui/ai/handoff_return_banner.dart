import 'package:flutter/foundation.dart' show mapEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/handoff/pending_handoff.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// "Back to paste your AI answer" — shown across the app while an answer is
/// pending (copy-and-paste handoff) and the person is somewhere else: they
/// wandered off on a PC, or a phone's browser reloaded MHAD while they were
/// in their AI app (Home restores the work, and this leads back).
///
/// Hidden on the page that is waiting, while a card that can take the answer
/// is on screen (e.g. inside a dialog), and for waits that can't be resumed.
class HandoffReturnBanner extends ConsumerWidget {
  /// The page on screen (path + query) — see [currentAppLocation].
  final Uri current;
  const HandoffReturnBanner({required this.current, super.key});

  /// Whether [route] names the page at [current] (path and query).
  static bool isSamePage(String route, Uri current) {
    final r = Uri.parse(route);
    return r.path == current.path &&
        mapEquals(r.queryParameters, current.queryParameters);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingHandoffProvider);
    final live = ref.watch(liveHandoffCardsProvider);
    if (pending == null ||
        !pending.resumable ||
        pending.isExpired() ||
        (live[pending.taskTag] ?? 0) > 0 ||
        isSamePage(pending.route, current)) {
      return const SizedBox.shrink();
    }
    final p = Theme.of(context).mhadPalette;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(DesignTokens.buttonRadius),
      side: BorderSide(color: p.primaryLight),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Material(
        color: p.primaryTint,
        shape: shape,
        child: InkWell(
          customBorder: shape,
          onTap: () => appRouter.go(pending.route),
          child: Semantics(
            button: true,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.content_paste_go, size: 20, color: p.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.aiHandoffBackToPaste,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: p.onPrimaryLight,
                      ),
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 20, color: p.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
