import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/services/locked_progress/progress_autosave.dart';
import 'package:flutter_riverpod/legacy.dart' show StateController;
import 'package:mhad/ai/handoff/ai_handoff_data.dart';
import 'package:mhad/ai/handoff/handoff_parser.dart';
import 'package:mhad/ai/handoff/handoff_prompt.dart';
import 'package:mhad/ai/handoff/handoff_task.dart';
import 'package:mhad/ai/handoff/pending_handoff.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/ai/ai_privacy_dialog.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/utils/launch_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// The ONE copy-and-paste AI handoff card (user decision 2026-11-17), used
/// everywhere AI appears — Ask AI, the wizard's step helper, Learn, Autofill,
/// side effects, the diagnoses helper, field wording, the consistency check.
///
///   1. Choose your AI  (ChatGPT · Claude · Gemini · Grok — remembered;
///      services that can't take the needed attachment are marked/disabled)
///   2. Copy the instructions  (+ "Open ChatGPT" etc., + see exactly what's included)
///   3. Paste the answer  (JSON tasks only) → parsed → [onAnswer]
///
/// The privacy notice shows before the first copy of a session. A JSON task
/// starts the 30-minute wait (extendable); a used answer clears the clipboard.
class AiHandoffPanel extends ConsumerStatefulWidget {
  /// Builds the task when the person copies (so it includes what they typed).
  final HandoffTask Function(BuildContext context) buildTask;

  /// For JSON tasks: applies a parsed answer; resolves true when used.
  final Future<bool> Function(Map<String, dynamic> json)? onAnswer;

  final String title;
  final String? subtitle;

  /// False while the task isn't ready (e.g. no question typed yet).
  final bool enabled;

  /// Shown under a disabled Copy button: what to do first.
  final String? disabledHint;

  /// The attachment the task needs (decides which AIs fit).
  final HandoffAttachment attachment;

  /// The kind decides whether step 3 (paste) is shown.
  final HandoffTaskKind kind;

  /// JSON tasks: whether the person can come back to paste after leaving
  /// this page (the "Back to paste your AI answer" banner, the reload
  /// restore). False when the answer needs state that leaving loses.
  final bool resumable;

  /// Where to come back to paste — the page on screen by default.
  final String? resumeRoute;

  const AiHandoffPanel({
    required this.buildTask,
    required this.title,
    required this.kind,
    this.subtitle,
    this.onAnswer,
    this.enabled = true,
    this.disabledHint,
    this.attachment = HandoffAttachment.none,
    this.resumable = true,
    this.resumeRoute,
    super.key,
  });

  @override
  ConsumerState<AiHandoffPanel> createState() => _AiHandoffPanelState();
}

class _AiHandoffPanelState extends ConsumerState<AiHandoffPanel> {
  final _paste = TextEditingController();
  HandoffTask? _task;
  String? _prompt;
  bool _copied = false;
  bool _showPrompt = false;
  bool _done = false;

  /// The paste-by-hand box: on request, or by itself when the browser
  /// didn't hand over the clipboard (Firefox blocks reading it).
  bool _manual = false;
  bool _clipboardBlocked = false;
  HandoffProblem? _problem;
  Timer? _tick;

  /// Counts this card in [liveHandoffCardsProvider] while it's on screen
  /// (JSON tasks). Changed in a microtask: never mid-build or mid-unmount.
  StateController<Map<String, int>>? _live;
  late final String _liveTag;

  void _countLive(int by) {
    final live = _live;
    if (live == null) return;
    try {
      final n = (live.state[_liveTag] ?? 0) + by;
      live.state = {...live.state, _liveTag: n < 0 ? 0 : n};
    } catch (_) {
      // The app is shutting down.
    }
  }

  @override
  void initState() {
    super.initState();
    _liveTag = widget.kind.tag;
    if (widget.kind.returnsJson) {
      _live = ref.read(liveHandoffCardsProvider.notifier);
      Future.microtask(() => _countLive(1));
    }
    // Refresh the "N min left" line while waiting.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted && ref.read(pendingHandoffProvider) != null) setState(() {});
    });
  }

  @override
  void dispose() {
    if (_live != null) Future.microtask(() => _countLive(-1));
    _tick?.cancel();
    _paste.dispose();
    super.dispose();
  }

  AiHandoffData get _data => AiHandoffData.instance;

  /// How well service [s] fits the task's attachment: nothing to attach →
  /// yes; a document → photo OR PDF support; a recording → audio support.
  ServiceSupport _fit(AiService s) {
    final info = _data.info(s);
    if (info == null) return ServiceSupport.no;
    return switch (widget.attachment) {
      HandoffAttachment.none => ServiceSupport.yes,
      HandoffAttachment.document =>
        info.supports(HandoffInput.image) == ServiceSupport.yes ||
                info.supports(HandoffInput.pdf) == ServiceSupport.yes
            ? ServiceSupport.yes
            : ServiceSupport.no,
      HandoffAttachment.audio => info.supports(HandoffInput.audio),
    };
  }

  /// The chosen service, or the first one that fully fits the task.
  AiService? get _service {
    final chosen = ref.watch(preferredAiServiceProvider);
    if (chosen != null && _fit(chosen) != ServiceSupport.no) return chosen;
    for (final s in AiService.values) {
      if (_fit(s) == ServiceSupport.yes) return s;
    }
    return null;
  }

  String _label(AiService s) => _data.info(s)?.label ?? s.name;

  String? _note(AiService s) {
    if (widget.attachment != HandoffAttachment.audio) return null;
    return switch (_fit(s)) {
      ServiceSupport.paid => context.l10n.aiHandoffAudioPaid,
      ServiceSupport.no => context.l10n.aiHandoffAudioNo,
      ServiceSupport.unconfirmed => context.l10n.aiHandoffAudioMaybe,
      ServiceSupport.yes => null,
    };
  }

  Future<void> _copy() async {
    final service = _service;
    if (service == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.aiHandoffChooseFirst)));
      return;
    }
    if (!ref.read(handoffPrivacyAcknowledgedProvider)) {
      final ok = await showHandoffPrivacyDialog(context,
          serviceLabel: _label(service));
      if (!ok || !mounted) return;
      ref.read(handoffPrivacyAcknowledgedProvider.notifier).state = true;
    }
    if (!mounted) return;
    final task = widget.buildTask(context);
    final prompt = buildHandoffPrompt(
      task,
      languageCode: Localizations.localeOf(context).languageCode,
      paPhone: appData.phoneOf('paProtectionAdvocacy'),
    );
    await Clipboard.setData(ClipboardData(text: prompt));
    if (task.returnsJson) {
      ref.read(pendingHandoffProvider.notifier).start(
            taskTag: task.kind.tag,
            ref: task.ref,
            route: !widget.resumable
                ? ''
                : widget.resumeRoute ?? currentAppLocation().toString(),
          );
      // A phone may unload this tab while the person is in their AI app:
      // save the latest work (and the wait) now, the way they chose.
      if (widget.resumable) {
        unawaited(ref
            .read(progressAutosaveProvider.notifier)
            .saveNow(includeOpenStep: true));
      }
    }
    if (!mounted) return;
    setState(() {
      _task = task;
      _prompt = prompt;
      _copied = true;
      _done = false;
      _problem = null;
    });
  }

  Future<void> _open() async {
    final service = _service;
    final url = service == null ? null : _data.info(service)?.url;
    if (url == null) return;
    await launchOrCopy(context, url.toString(),
        mode: LaunchMode.externalApplication);
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (!mounted) return;
    final text = data?.text ?? '';
    if (text.trim().isEmpty) {
      // Nothing came through: blocked by the browser, or nothing copied —
      // open the box so the answer can be pasted by hand.
      setState(() {
        _manual = true;
        _clipboardBlocked = true;
        _problem = null;
      });
      return;
    }
    _paste.text = text;
    await _use();
  }

  Future<void> _use() async {
    final task = _task ?? widget.buildTask(context);
    // After a reload restored the work under a new id, the answer still
    // carries the old one from the copied instructions.
    final pending = ref.read(pendingHandoffProvider);
    final reply = parseHandoffReply(
      _paste.text,
      taskTag: task.kind.tag,
      ref: task.ref,
      alsoAccept: {
        if (pending != null &&
            pending.taskTag == task.kind.tag &&
            pending.ref == task.ref)
          pending.promptRef,
      },
    );
    if (!reply.ok) {
      setState(() => _problem = reply.problem);
      return;
    }
    final applied = await widget.onAnswer?.call(reply.json!) ?? false;
    if (!mounted || !applied) return;
    ref.read(pendingHandoffProvider.notifier).clear();
    // The clipboard held the person's answer (and the instructions before
    // it): clear it once used (user decision 2026-11-17).
    await Clipboard.setData(const ClipboardData(text: ''));
    if (!mounted) return;
    setState(() {
      _done = true;
      _problem = null;
      _paste.clear();
    });
  }

  Future<void> _copyFixIt() async {
    final task = _task ?? widget.buildTask(context);
    await Clipboard.setData(ClipboardData(
        text: context.l10n.aiHandoffFixItMessage(task.kind.tag, task.ref)));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.aiHandoffFixItCopied)));
  }

  String _problemText(HandoffProblem p) => switch (p) {
        HandoffProblem.empty => context.l10n.aiHandoffProblemEmpty,
        HandoffProblem.promptPastedBack =>
          context.l10n.aiHandoffProblemPromptBack,
        HandoffProblem.notJson => context.l10n.aiHandoffProblemNotJson,
        HandoffProblem.truncated => context.l10n.aiHandoffProblemTruncated,
        HandoffProblem.wrongTask => context.l10n.aiHandoffProblemWrongTask,
        HandoffProblem.wrongRef => context.l10n.aiHandoffProblemWrongRef,
        HandoffProblem.noAttachment =>
          context.l10n.aiHandoffProblemNoAttachment,
      };

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final t = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final service = _service;
    final serviceLabel = service == null ? '' : _label(service);
    // "ChatGPT", or "your AI" before one is chosen.
    final aiName = service == null ? l10n.aiHandoffYourAi : serviceLabel;
    final json = widget.kind.returnsJson;
    final pending = ref.watch(pendingHandoffProvider);
    final waiting = json &&
        pending != null &&
        pending.taskTag == widget.kind.tag &&
        !pending.isExpired();

    // Progress: a done step shows ✓ and the next one is highlighted. Sending
    // happens in the AI, so step 3 is confirmed by the answer coming back.
    final done = [service != null, _copied, _done, _done];
    final next = done.indexOf(false);

    Widget step(int n, String title, {String? help}) {
      final isDone = done[n - 1];
      final isNext = n - 1 == next;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: MediaQuery.disableAnimationsOf(context)
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDone || isNext ? p.primary : p.primaryLight,
                shape: BoxShape.circle,
              ),
              child: isDone
                  ? Icon(Icons.check, size: 16, color: p.onPrimary)
                  : Text('$n',
                      style: t.labelMedium!.copyWith(
                          color: isNext ? p.onPrimary : p.onPrimaryLight)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(title, style: t.titleSmall),
                  ),
                  if (help != null) ...[
                    const SizedBox(height: 2),
                    Text(help, style: t.bodySmall),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Content under a step, lined up with its title (24 circle + 8 gap).
    Widget indent(Widget child) => Padding(
          padding: const EdgeInsetsDirectional.only(start: 32),
          child: child,
        );

    // One line of the "in your AI" checklist.
    Widget todo(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  width: 6,
                  height: 6,
                  decoration:
                      BoxDecoration(color: p.primary, shape: BoxShape.circle),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(text, style: t.bodyMedium)),
            ],
          ),
        );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.auto_awesome,
                    size: 20, color: p.onPrimaryLight),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(widget.title, style: t.titleMedium),
                    ),
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(widget.subtitle!, style: t.bodySmall),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1 — Choose your AI
          step(1, l10n.aiHandoffChooseAi),
          indent(Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in AiService.values)
                if (_data.info(s) != null)
                  _ServiceChip(
                    label: _label(s),
                    note: _note(s),
                    selected: s == service,
                    enabled: _fit(s) != ServiceSupport.no,
                    onTap: () =>
                        ref.read(preferredAiServiceProvider.notifier).choose(s),
                  ),
            ],
          )),
          const SizedBox(height: 20),

          // 2 — Copy the message for your AI
          step(2, l10n.aiHandoffStepCopy, help: l10n.aiHandoffCopyHelp),
          indent(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FilledButton.icon(
                onPressed: widget.enabled ? _copy : null,
                icon: Icon(_copied ? Icons.check : Icons.content_copy,
                    size: 18),
                label: Text(_copied
                    ? l10n.aiHandoffCopyAgain
                    : l10n.aiHandoffCopyButton),
              ),
              if (!widget.enabled && widget.disabledHint != null) ...[
                const SizedBox(height: 8),
                Text(widget.disabledHint!, style: t.bodySmall),
              ],
              if (_copied) ...[
                const SizedBox(height: 8),
                Text(l10n.aiHandoffCopied(aiName),
                    style: t.bodySmall!.copyWith(
                        color: p.primary, fontWeight: FontWeight.w600)),
              ],
              if (_prompt != null)
                TextButton.icon(
                  onPressed: () => setState(() => _showPrompt = !_showPrompt),
                  icon: Icon(
                      _showPrompt ? Icons.expand_less : Icons.expand_more,
                      size: 18),
                  label: Text(_showPrompt
                      ? l10n.aiHandoffHideIncluded
                      : l10n.aiHandoffSeeIncluded),
                ),
              if (_showPrompt && _prompt != null)
                Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    border: Border.all(color: p.border),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(_prompt!, style: t.bodySmall),
                  ),
                ),
            ],
          )),
          const SizedBox(height: 20),

          // 3 — Send it in your AI (what to do there, in order)
          step(3, l10n.aiHandoffStepSend(aiName)),
          indent(Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              todo(l10n.aiHandoffSendOpen(aiName)),
              todo(l10n.aiHandoffSendPaste),
              if (widget.attachment == HandoffAttachment.document)
                todo(l10n.aiHandoffAttachDocumentTodo),
              if (widget.attachment == HandoffAttachment.audio)
                todo(l10n.aiHandoffAttachAudioTodo),
              todo(l10n.aiHandoffSendIt),
              if (service != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _open,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l10n.aiHandoffOpenService(serviceLabel)),
                ),
              ],
            ],
          )),
          const SizedBox(height: 20),

          // 4 — Bring the answer back (JSON tasks), or read it there
          if (json) ...[
            step(4, l10n.aiHandoffStepPaste, help: l10n.aiHandoffPasteHelp),
            indent(Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (waiting) _WaitRow(pending: pending),
                FilledButton.icon(
                  onPressed: _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste, size: 18),
                  label: Text(l10n.aiHandoffPasteButton),
                ),
                if (!_manual)
                  TextButton(
                    onPressed: () => setState(() => _manual = true),
                    child: Text(l10n.aiHandoffPasteManual),
                  ),
                if (_manual) ...[
                  const SizedBox(height: 12),
                  if (_clipboardBlocked) ...[
                    InfoBanner(
                      icon: Icons.content_paste_off,
                      variant: InfoBannerVariant.info,
                      text: l10n.aiHandoffClipboardBlocked,
                    ),
                    const SizedBox(height: 8),
                  ],
                  TextField(
                    controller: _paste,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: l10n.aiHandoffPasteHint,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: FilledButton(
                      onPressed: _use,
                      child: Text(l10n.aiHandoffUseAnswer),
                    ),
                  ),
                ],
                if (_problem != null) ...[
                  const SizedBox(height: 12),
                  InfoBanner(
                    icon: Icons.info_outline,
                    variant: InfoBannerVariant.warning,
                    text: _problemText(_problem!),
                  ),
                  TextButton.icon(
                    onPressed: _copyFixIt,
                    icon: const Icon(Icons.build_outlined, size: 18),
                    label: Text(l10n.aiHandoffFixItButton),
                  ),
                  Text(l10n.aiHandoffFreshAttempt, style: t.bodySmall),
                ],
                if (_done) ...[
                  const SizedBox(height: 12),
                  InfoBanner(
                    icon: Icons.check_circle_outline,
                    variant: InfoBannerVariant.success,
                    text: l10n.aiHandoffDone,
                  ),
                ],
              ],
            )),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.forum_outlined, size: 20, color: p.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.kind == HandoffTaskKind.fieldWording
                        ? l10n.aiHandoffWordingNote
                        : l10n.aiHandoffAnswerThere,
                    style: t.bodyMedium,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// "Waiting for your answer · N min left · Extend"; a warning when ≤ 5 min.
class _WaitRow extends ConsumerWidget {
  final PendingHandoff pending;
  const _WaitRow({required this.pending});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minutes = (pending.remaining().inSeconds / 60).ceil();
    final extend = TextButton(
      onPressed: () => ref.read(pendingHandoffProvider.notifier).extend(),
      child: Text(context.l10n.aiHandoffExtend(
          PendingHandoff.window.inMinutes)),
    );
    if (minutes <= 5) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InfoBanner(
          icon: Icons.timer_outlined,
          variant: InfoBannerVariant.warning,
          text: context.l10n.aiHandoffExpiring(minutes),
          actionLabel: context.l10n.aiHandoffExtend(
          PendingHandoff.window.inMinutes),
          onAction: () => ref.read(pendingHandoffProvider.notifier).extend(),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.timer_outlined,
              size: 16, color: Theme.of(context).mhadPalette.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(context.l10n.aiHandoffWaiting(minutes),
                style: Theme.of(context).textTheme.bodySmall),
          ),
          extend,
        ],
      ),
    );
  }
}

/// One AI service choice: name, optional capability note, selected state.
class _ServiceChip extends StatelessWidget {
  final String label;
  final String? note;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _ServiceChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final t = Theme.of(context).textTheme;
    final fg = !enabled
        ? p.textMuted
        : selected
            ? p.onPrimary
            : p.text;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: note == null ? label : '$label, $note',
      child: Material(
        color: selected ? p.primary : p.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: selected ? p.primary : p.border),
          borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ExcludeSemantics(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (selected) ...[
                          Icon(Icons.check, size: 16, color: fg),
                          const SizedBox(width: 4),
                        ],
                        Text(label, style: t.labelLarge!.copyWith(color: fg)),
                      ],
                    ),
                    if (note != null)
                      Text(note!,
                          style: t.labelMedium!.copyWith(
                              color: selected ? p.onPrimary : p.textMuted)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
