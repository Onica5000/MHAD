import 'package:flutter/material.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Full-screen FTC HBNR breach notice — the in-app contact channel promised in
/// `docs/BREACH_PLAN.md` (V4-H3). Covers the whole app until the user
/// acknowledges it; acknowledgement is stored per notice id, so a later notice
/// is shown again. With no active notice this is a pass-through.
///
/// Acknowledgement uses SharedPreferences, which on web is localStorage — it
/// survives reloads (unlike the in-memory directive DB), so users aren't
/// re-blocked every session. If storage is unavailable the notice simply shows
/// again next load, which errs on the side of the user seeing it.
class BreachNoticeGate extends StatefulWidget {
  final Widget child;

  /// The notice to show; defaults to the one in `app_data.json`. Injectable
  /// for tests.
  final BreachNotice? notice;

  /// Whether [notice] was already acknowledged — read before the first frame
  /// (see [loadAcknowledged]) so returning users don't see the notice flash.
  final bool initiallyAcknowledged;

  const BreachNoticeGate({
    super.key,
    required this.child,
    this.notice,
    this.initiallyAcknowledged = false,
  });

  static String ackKey(String id) => 'breach_notice_ack_$id';

  /// Reads the stored acknowledgement for [notice]. False when there is no
  /// notice or storage is unavailable (errs toward showing it).
  static Future<bool> loadAcknowledged(BreachNotice? notice) async {
    if (notice == null) return false;
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(ackKey(notice.id)) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  State<BreachNoticeGate> createState() => _BreachNoticeGateState();
}

class _BreachNoticeGateState extends State<BreachNoticeGate> {
  BreachNotice? get _notice => widget.notice ?? AppData.instance.breachNotice;

  late bool _acknowledged = widget.initiallyAcknowledged;

  Future<void> _acknowledge() async {
    final n = _notice;
    setState(() => _acknowledged = true);
    if (n == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(BreachNoticeGate.ackKey(n.id), true);
    } catch (_) {
      // Non-fatal: it will be shown again next load.
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = _notice;
    if (n == null || _acknowledged) return widget.child;
    return Stack(
      children: [
        // Keep the app mounted (state intact) but inert and hidden from
        // assistive tech while the notice is up.
        ExcludeSemantics(child: AbsorbPointer(child: widget.child)),
        Positioned.fill(
          child: _BreachNoticeView(notice: n, onAcknowledge: _acknowledge),
        ),
      ],
    );
  }
}

class _BreachNoticeView extends StatelessWidget {
  final BreachNotice notice;
  final VoidCallback onAcknowledge;

  const _BreachNoticeView({required this.notice, required this.onAcknowledge});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sections = <(String, String)>[
      (l10n.breachNoticeWhatHappened, notice.whatHappened),
      (l10n.breachNoticeInformationInvolved, notice.informationInvolved),
      (l10n.breachNoticeThirdParties, notice.thirdParties),
      (l10n.breachNoticeWhatWeAreDoing, notice.whatWeAreDoing),
      (l10n.breachNoticeWhatYouCanDo, notice.whatYouCanDo),
    ];
    return Material(
      color: theme.colorScheme.surface,
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    children: [
                      Icon(
                        Icons.report_outlined,
                        size: 40,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 12),
                      Semantics(
                        header: true,
                        child: Text(
                          notice.title.isNotEmpty
                              ? notice.title
                              : l10n.breachNoticeDefaultTitle,
                          style: theme.textTheme.headlineSmall,
                        ),
                      ),
                      if (notice.date.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(notice.date, style: theme.textTheme.bodySmall),
                      ],
                      for (final (heading, body) in sections)
                        if (body.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Semantics(
                            header: true,
                            child: Text(
                              heading,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          const SizedBox(height: 6),
                          SelectableText(
                            body,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      if (notice.contactMethods.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Semantics(
                          header: true,
                          child: Text(
                            l10n.breachNoticeContactUs,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 6),
                        for (final c in notice.contactMethods)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: SelectableText(
                              '• $c',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      autofocus: true,
                      onPressed: onAcknowledge,
                      child: Text(l10n.breachNoticeAcknowledge),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
