import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/handoff/pending_handoff.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/passphrase/passphrase_strength.dart';
import 'package:mhad/utils/page_visibility.dart';

import 'key_value_store.dart';
import 'lock_crypto.dart';
import 'locked_progress_store.dart';
import 'progress_payload.dart';

/// This page's one progress store. A global (not created by a provider) so
/// `main()` can run [LockedProgressStore.sweep] before the first frame —
/// an expired copy is erased before anything is shown.
final LockedProgressStore lockedProgress = LockedProgressStore(
  device: deviceStore,
  tab: tabStore,
  crypto: createLockCrypto(),
  window: () => appData.config.progressWindow,
);

final lockedProgressProvider =
    Provider<LockedProgressStore>((_) => lockedProgress);

/// What the screens show about saving: the wizard's chip, and the notices
/// for "open in another tab" and "the browser wouldn't keep it".
@immutable
class ProgressStatus {
  const ProgressStatus({
    this.mode = ProgressMode.undecided,
    this.lastSaved,
    this.outcome,
  });

  final ProgressMode mode;
  final DateTime? lastSaved;
  final SaveOutcome? outcome;

  bool get openElsewhere => outcome == SaveOutcome.otherTab;
  bool get refused => outcome == SaveOutcome.refused;
}

/// Keeps the person's work the way they chose ([ProgressMode]), on the web:
///
/// * a couple of seconds after any change to the database;
/// * when the page is hidden (another tab or app, a locked phone, closing),
///   after asking the open wizard step to save what's typed — quietly, so no
///   warnings flash ([WizardStepMixin.saveQuietly]);
/// * every minute while the page is open, a fresh expiry for the locked copy
///   (the heartbeat), so the 30 minutes run from when the person left.
class ProgressAutosave extends Notifier<ProgressStatus> {
  static const debounce = Duration(seconds: 2);
  static const heartbeat = Duration(minutes: 1);

  Timer? _debounceTimer;
  Timer? _heartbeatTimer;
  ({int directiveId, Future<void> Function() save})? _openStep;
  Future<void>? _inFlight;
  bool _again = false;
  bool _againWithStep = false;

  LockedProgressStore get _store => ref.read(lockedProgressProvider);

  @override
  ProgressStatus build() {
    final store = ref.read(lockedProgressProvider);
    if (!kIsWeb) return ProgressStatus(mode: store.mode);
    final changes =
        ref.watch(appDatabaseProvider).tableUpdates().listen((_) => _schedule());
    final stopListening =
        listenPageVisibility(onHidden: _onHidden, onVisible: _onVisible);
    if (pageIsVisible) _startHeartbeat();
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _heartbeatTimer?.cancel();
      changes.cancel();
      stopListening();
    });
    return ProgressStatus(mode: store.mode);
  }

  PassphraseEstimate? _strength;

  /// How strong this tab's passphrase is (never the passphrase itself) — for
  /// the warning when a weak one locks a download. Null when unknown.
  PassphraseEstimate? get passphraseStrength => _strength;
  void noteStrength(PassphraseEstimate estimate) => _strength = estimate;

  /// The person made or changed their choice: show it and save right away.
  void choiceChanged() {
    state = ProgressStatus(mode: _store.mode);
    unawaited(saveNow());
  }

  /// The open wizard step, which can save what's typed without warnings.
  void registerOpenStep(int directiveId, Future<void> Function() save) =>
      _openStep = (directiveId: directiveId, save: save);

  void unregisterOpenStep(int directiveId) {
    if (_openStep?.directiveId == directiveId) _openStep = null;
  }

  void _schedule() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => unawaited(saveNow()));
  }

  /// Saves now. One save at a time; a request during a save runs right after
  /// it, so the newest state always lands last.
  Future<void> saveNow({bool includeOpenStep = false}) {
    final running = _inFlight;
    if (running != null) {
      _again = true;
      _againWithStep |= includeOpenStep;
      return running;
    }
    final run = _save(includeOpenStep).whenComplete(() {
      _inFlight = null;
      if (_again) {
        final withStep = _againWithStep;
        _again = false;
        _againWithStep = false;
        unawaited(saveNow(includeOpenStep: withStep));
      }
    });
    _inFlight = run;
    return run;
  }

  Future<void> _save(bool includeOpenStep) async {
    final store = _store;
    final mode = store.mode;
    if (mode == ProgressMode.undecided) return;
    if (mode == ProgressMode.locked && !store.hasPassphrase) return;
    if (includeOpenStep) {
      try {
        await _openStep?.save();
      } catch (e) {
        debugPrint('Quiet step save failed: $e');
      }
    }
    try {
      final handoff = ref.read(pendingHandoffProvider);
      final payload = await buildProgressPayload(
        ref.read(directiveRepositoryProvider),
        full: mode == ProgressMode.locked,
        currentId: _openStep?.directiveId,
        handoff: handoff,
      );
      final outcome =
          await store.save(payload, keepUntil: handoff?.deadline);
      _report(outcome);
    } catch (e) {
      debugPrint('Progress save failed: $e');
    }
  }

  void _report(SaveOutcome outcome) {
    if (!ref.mounted) return;
    state = ProgressStatus(
      mode: _store.mode,
      lastSaved:
          outcome == SaveOutcome.saved ? DateTime.now() : state.lastSaved,
      outcome: outcome,
    );
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(heartbeat, (_) => unawaited(_beat()));
  }

  Future<void> _beat() async {
    final outcome = await _store.reseal();
    if (outcome != SaveOutcome.notKept) _report(outcome);
  }

  void _onHidden() {
    _heartbeatTimer?.cancel();
    _debounceTimer?.cancel();
    unawaited(saveNow(includeOpenStep: true));
  }

  void _onVisible() {
    _startHeartbeat();
    unawaited(_beat());
  }
}

final progressAutosaveProvider =
    NotifierProvider<ProgressAutosave, ProgressStatus>(ProgressAutosave.new);
