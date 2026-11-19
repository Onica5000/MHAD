import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/locked_progress/locked_progress_store.dart';
import 'package:mhad/services/locked_progress/progress_autosave.dart';
import 'package:mhad/services/locked_progress/progress_payload.dart';
import 'package:mhad/ui/progress/passphrase_form.dart';
import 'package:mhad/ui/progress/progress_gate.dart' show noteStrengthOf;
import 'package:mhad/ui/progress/progress_restore.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';

/// The width these short pages are read at.
const double _pageWidth = 640;

/// A centered, width-capped, scrollable page body.
class _Page extends StatelessWidget {
  const _Page({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _pageWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
            children: children,
          ),
        ),
      );
}

/// "Keep your progress on this device?" — asked when the person starts
/// (user decision 2026-11-18). Pops true once they chose, null if they backed
/// out (then nothing is started).
class ProgressChoiceScreen extends ConsumerStatefulWidget {
  const ProgressChoiceScreen({super.key});

  @override
  ConsumerState<ProgressChoiceScreen> createState() =>
      _ProgressChoiceScreenState();
}

class _ProgressChoiceScreenState extends ConsumerState<ProgressChoiceScreen> {
  bool _locking = false;

  Future<void> _yes() async {
    final chosen = await Navigator.of(context).push<ChosenPassphrase>(
      MaterialPageRoute(
        builder: (_) => PassphraseSetupScreen(
            actionLabel: context.l10n.passphraseLockProgress),
      ),
    );
    if (chosen == null || !mounted) return;
    setState(() => _locking = true);
    await ref.read(lockedProgressProvider).startLocked(chosen.passphrase);
    ref.read(progressAutosaveProvider.notifier)
      ..noteStrength(chosen.estimate)
      ..choiceChanged();
    if (mounted) Navigator.of(context).pop(true);
  }

  void _no() {
    ref.read(lockedProgressProvider).startTabOnly();
    ref.read(progressAutosaveProvider.notifier).choiceChanged();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l.progressChoiceAppBar)),
      body: _locking
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l.progressLocking),
                ],
              ),
            )
          : _Page(children: [
              Text(l.progressChoiceTitle, style: text.headlineSmall),
              const SizedBox(height: 8),
              Text(l.progressChoiceLead, style: text.bodyLarge),
              const SizedBox(height: 24),
              _ChoiceCard(
                icon: Icons.lock_outline,
                title: l.progressChoiceYesTitle,
                body: l.progressChoiceYesBody(
                    appData.config.progressWindowMinutes),
                onTap: _yes,
              ),
              const SizedBox(height: 12),
              _ChoiceCard(
                icon: Icons.tab_outlined,
                title: l.progressChoiceNoTitle,
                body: l.progressChoiceNoBody,
                onTap: _no,
              ),
              const SizedBox(height: 24),
              Text(l.progressChoiceDownloadNote, style: text.bodyMedium),
            ]),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: title,
      hint: body,
      excludeSemantics: true,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: p.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: text.titleMedium),
                      const SizedBox(height: 4),
                      Text(body, style: text.bodyMedium),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: p.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Choosing a passphrase ([PassphraseForm]). Pops the [ChosenPassphrase], or
/// null if the person backed out.
class PassphraseSetupScreen extends StatefulWidget {
  const PassphraseSetupScreen({required this.actionLabel, super.key});

  /// "Lock my progress" or "Lock and download".
  final String actionLabel;

  @override
  State<PassphraseSetupScreen> createState() => _PassphraseSetupScreenState();
}

class _PassphraseSetupScreenState extends State<PassphraseSetupScreen> {
  ChosenPassphrase? _chosen;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.passphraseSetupTitle)),
      body: _Page(children: [
        Text(l.passphraseSetupLead,
            style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 12),
        InfoBanner(
          icon: Icons.warning_amber_rounded,
          text: l.passphraseForgetWarning,
          variant: InfoBannerVariant.warning,
        ),
        const SizedBox(height: 16),
        PassphraseForm(onChanged: (c) => setState(() => _chosen = c)),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed:
              _chosen == null ? null : () => Navigator.of(context).pop(_chosen),
          icon: const Icon(Icons.lock_outline),
          label: Text(widget.actionLabel),
        ),
      ]),
    );
  }
}

/// "Welcome back": the locked copy waits for its passphrase. Ten wrong ones
/// erase it ([LockedProgressStore.maxTries]). "Delete it and start over"
/// erases it at once.
class ResumeProgressScreen extends ConsumerStatefulWidget {
  const ResumeProgressScreen({super.key});

  @override
  ConsumerState<ResumeProgressScreen> createState() =>
      _ResumeProgressScreenState();
}

class _ResumeProgressScreenState extends ConsumerState<ResumeProgressScreen> {
  final _field = TextEditingController();
  bool _show = false;
  bool _busy = false;
  int? _triesLeft;
  String? _gone;

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  Future<void> _unlock() async {
    if (_busy || _field.text.isEmpty) return;
    final l = context.l10n;
    setState(() => _busy = true);
    final store = ref.read(lockedProgressProvider);
    final result = await store.unlock(_field.text);
    if (!mounted) return;
    switch (result) {
      case Unlocked(:final payload):
        noteStrengthOf(ref.read(progressAutosaveProvider.notifier), _field.text);
        ref.read(progressAutosaveProvider.notifier).choiceChanged();
        final restored = await restoreProgressPayload(
            ref.read(directiveRepositoryProvider), payload);
        if (!mounted || !context.mounted) return;
        openRestoredProgress(context, ref, restored,
            personalInfoMissing: false);
      case WrongPassphrase(:final triesLeft):
        _field.clear();
        setState(() {
          _busy = false;
          _triesLeft = triesLeft;
        });
      case CopyGone():
        setState(() {
          _busy = false;
          _gone = _triesLeft == 1
              ? l.resumeErased(LockedProgressStore.maxTries)
              : l.resumeGone;
        });
    }
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final yes = await showDialog<bool>(
      context: context,
      builder: (dctx) => AlertDialog(
        title: Text(l.resumeDeleteConfirmTitle),
        content: Text(l.resumeDeleteConfirmBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dctx, false),
              child: Text(l.cancel)),
          FilledButton(
              onPressed: () => Navigator.pop(dctx, true),
              child: Text(l.resumeDeleteConfirm)),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    ref.read(lockedProgressProvider).eraseCopy();
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.resumeDeleted)));
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = Theme.of(context).textTheme;
    final info = ref.read(lockedProgressProvider).savedCopy;
    final time = DateFormat.jm(Localizations.localeOf(context).toString());
    final gone = _gone ?? (info == null ? l.resumeGone : null);
    return Scaffold(
      appBar: AppBar(title: Text(l.resumeTitle)),
      body: _Page(children: [
        if (gone != null) ...[
          InfoBanner(icon: Icons.info_outline, text: gone),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => context.go(AppRoutes.home),
            child: Text(l.resumeStartOver),
          ),
        ] else ...[
          Text(
            l.resumeSavedAt(time.format(info!.saved?.toLocal() ??
                info.expires.toLocal())),
            style: text.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(l.resumeOpenUntil(time.format(info.expires.toLocal())),
              style: text.bodyMedium),
          const SizedBox(height: 16),
          TextField(
            controller: _field,
            obscureText: !_show,
            autofocus: true,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.visiblePassword,
            onSubmitted: (_) => _unlock(),
            decoration: InputDecoration(
              labelText: l.passphraseFieldLabel,
              suffixIcon: IconButton(
                tooltip: _show ? l.passphraseHide : l.passphraseShow,
                icon: Icon(_show
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined),
                onPressed: () => setState(() => _show = !_show),
              ),
            ),
          ),
          if (_triesLeft != null) ...[
            const SizedBox(height: 12),
            Semantics(
              liveRegion: true,
              child: InfoBanner(
                icon: Icons.error_outline,
                text: l.resumeWrong(_triesLeft!),
                variant: InfoBannerVariant.error,
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _busy ? null : _unlock,
            icon: _busy
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.lock_open_outlined),
            label: Text(_busy ? l.resumeChecking : l.resumeUnlock),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _busy ? null : _delete,
            child: Text(l.resumeDelete),
          ),
        ],
      ]),
    );
  }
}
