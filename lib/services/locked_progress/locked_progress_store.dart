import 'dart:convert';
import 'dart:math';

import 'key_value_store.dart';
import 'lock_crypto.dart';
import 'locked_format.dart';

/// How this tab keeps the person's work — asked when they start (user
/// decision 2026-11-18).
enum ProgressMode {
  /// Not asked yet in this tab.
  undecided,

  /// A passphrase-locked copy on this device, kept until
  /// [LockedProgressStore.window] after they leave.
  locked,

  /// Nothing kept outside this tab: erased when the tab closes.
  tabOnly,
}

/// What the resume screen can say before the passphrase is entered.
class SavedCopyInfo {
  const SavedCopyInfo({required this.saved, required this.expires});
  final DateTime? saved;
  final DateTime expires;
}

sealed class UnlockResult {
  const UnlockResult();
}

class Unlocked extends UnlockResult {
  const Unlocked(this.payload);
  final Map<String, dynamic> payload;
}

class WrongPassphrase extends UnlockResult {
  const WrongPassphrase(this.triesLeft);
  final int triesLeft;
}

/// The copy is gone: erased after too many wrong tries, expired meanwhile,
/// or damaged.
class CopyGone extends UnlockResult {
  const CopyGone();
}

enum SaveOutcome {
  saved,

  /// This tab's choice doesn't keep anything (yet).
  notKept,

  /// Another tab took this work over; this one stopped saving.
  otherTab,

  /// The browser refused (storage full, or blocked in a private window).
  refused,
}

/// Keeps the person's work between visits, the way they chose:
///
/// * **locked** — sealed with their passphrase ([sealPayload]) in
///   `localStorage`. It expires [window] after the page was last open in
///   front of them (each save and each heartbeat while the page is open
///   moves the expiry; a pending AI answer can stretch it). A closed tab
///   can't run code, so an expired copy is erased — unopened — by [sweep]
///   the next time the app starts in this browser. Ten wrong passphrases
///   erase it too.
/// * **tab only** — plain, in `sessionStorage`, gone when the tab closes.
///
/// The key lives only in memory: after a reload the passphrase is asked for
/// again. Only one tab writes at a time: unlocking in a second tab takes the
/// work over, and the first one stops saving ([SaveOutcome.otherTab]).
class LockedProgressStore {
  LockedProgressStore({
    required this.device,
    required this.tab,
    required this.crypto,
    required this.window,
    DateTime Function()? clock,
    this.iterations = kLockIterations,
    String? tabId,
  })  : _clock = clock ?? DateTime.now,
        tabId = tabId ?? _newTabId();

  final KeyValueStore device;
  final KeyValueStore tab;
  final LockCrypto crypto;

  /// How long the copy lasts after the page was last open
  /// (`progressWindowMinutes`, 30).
  final Duration Function() window;
  final int iterations;
  final String tabId;
  final DateTime Function() _clock;

  static const copyKey = 'mhad_locked_copy';
  static const triesKey = 'mhad_locked_tries';
  static const ownerKey = 'mhad_locked_owner';
  static const modeKey = 'mhad_progress_mode';
  static const tabCopyKey = 'mhad_tab_copy';
  static const maxTries = 10;

  /// Another tab counts as still working on the copy while its last save or
  /// heartbeat is this recent.
  static const ownerFresh = Duration(minutes: 2);

  /// An expiry further ahead than this isn't trusted (a changed clock).
  static const maxAhead = Duration(hours: 24);

  /// Readable recovery copies from before 2026-11-18 (shared_preferences
  /// keys, stored with its `flutter.` prefix) — erased on start.
  static const legacyKeys = [
    'flutter.web_session_directive',
    'flutter.web_session_timestamp',
    'flutter.mhad_draft_recovery',
    'flutter.ai_handoff_pending',
  ];

  LockSession? _session;
  Map<String, dynamic>? _lastPayload;
  DateTime? _keepUntil;
  Future<void> _queue = Future.value();

  ProgressMode get mode =>
      ProgressMode.values.asNameMap()[tab.read(modeKey)] ??
      ProgressMode.undecided;

  /// Whether a passphrase is set in this tab (for saving or downloading).
  bool get hasPassphrase => _session != null;

  DateTime get _now => _clock().toUtc();

  /// On start, before anything is shown: erase the old readable copies and
  /// any locked copy that expired, is damaged, looks tampered with or has run
  /// out of tries.
  void sweep() {
    for (final k in legacyKeys) {
      device.remove(k);
    }
    _validCopy();
  }

  /// The locked copy that can still be resumed, if any.
  SavedCopyInfo? get savedCopy {
    final blob = _validCopy();
    if (blob == null) return null;
    return SavedCopyInfo(saved: blob.header.saved, expires: blob.header.expires!);
  }

  LockedBlob? _validCopy() {
    final text = device.read(copyKey);
    if (text == null) return null;
    final blob = LockedBlob.tryParse(text);
    final expires = blob?.header.expires;
    final now = _now;
    final usable = blob != null &&
        blob.header.kind == LockedKind.copy &&
        expires != null &&
        now.isBefore(expires) &&
        expires.isBefore(now.add(maxAhead)) &&
        _tries < maxTries;
    if (!usable) {
      eraseCopy();
      return null;
    }
    return blob;
  }

  int get _tries => int.tryParse(device.read(triesKey) ?? '') ?? 0;

  /// The person chose to keep a locked copy and set [passphrase].
  Future<void> startLocked(String passphrase) async {
    _session = await LockSession.create(crypto, passphrase,
        iterations: iterations);
    _beginLocked();
  }

  /// The person chose to keep a locked copy with the passphrase of the file
  /// they just opened ([openFile]).
  void startLockedWithOpenedFile() {
    if (_fileSession == null) return;
    _session = _fileSession;
    _beginLocked();
  }

  void _beginLocked() {
    tab.write(modeKey, ProgressMode.locked.name);
    _claim();
  }

  /// The person chose not to keep a copy outside this tab. (A locked copy
  /// another tab is still using is left alone; see [stopKeeping].)
  void startTabOnly() {
    _session = null;
    tab.write(modeKey, ProgressMode.tabOnly.name);
  }

  /// A passphrase for downloads only, when the person keeps nothing on this
  /// device (tab-only) — remembered in memory for this tab.
  Future<void> setDownloadPassphrase(String passphrase) async {
    _session =
        await LockSession.create(crypto, passphrase, iterations: iterations);
  }

  /// Opens the saved copy. A wrong passphrase uses up one of [maxTries];
  /// the last one erases the copy.
  Future<UnlockResult> unlock(String passphrase) async {
    final blob = _validCopy();
    if (blob == null) return const CopyGone();
    final session =
        await LockSession.forHeader(crypto, passphrase, blob.header);
    final Object? payload;
    try {
      payload = await openPayload(crypto, session, blob);
    } on LockOpenException {
      final tries = _tries + 1;
      if (tries >= maxTries) {
        eraseCopy();
        return const CopyGone();
      }
      device.write(triesKey, '$tries');
      return WrongPassphrase(maxTries - tries);
    }
    if (payload is! Map<String, dynamic>) {
      eraseCopy();
      return const CopyGone();
    }
    device.remove(triesKey);
    _session = session;
    _lastPayload = payload;
    _beginLocked();
    return Unlocked(payload);
  }

  /// Keeps [payload] the way this tab's [mode] says. [keepUntil] (a pending
  /// AI answer's deadline) can stretch a locked copy past [window].
  Future<SaveOutcome> save(Map<String, dynamic> payload,
      {DateTime? keepUntil}) {
    switch (mode) {
      case ProgressMode.undecided:
        return Future.value(SaveOutcome.notKept);
      case ProgressMode.tabOnly:
        return Future.value(tab.write(tabCopyKey, jsonEncode(payload))
            ? SaveOutcome.saved
            : SaveOutcome.refused);
      case ProgressMode.locked:
        if (_session == null) return Future.value(SaveOutcome.notKept);
        _lastPayload = payload;
        _keepUntil = keepUntil;
        return _serial(_sealAndWrite);
    }
  }

  /// Seals the last payload again with a fresh expiry — the heartbeat while
  /// the page is open.
  Future<SaveOutcome> reseal() {
    if (mode != ProgressMode.locked ||
        _session == null ||
        _lastPayload == null) {
      return Future.value(SaveOutcome.notKept);
    }
    return _serial(_sealAndWrite);
  }

  /// Saves never overlap: a slower, older seal can't land after a newer one.
  Future<SaveOutcome> _serial(Future<SaveOutcome> Function() op) {
    final next = _queue.then((_) => op());
    _queue = next.then((_) {}, onError: (_) {});
    return next;
  }

  Future<SaveOutcome> _sealAndWrite() async {
    if (openElsewhere) return SaveOutcome.otherTab;
    final now = _now;
    var expires = now.add(window());
    final keep = _keepUntil?.toUtc();
    if (keep != null && keep.isAfter(expires)) expires = keep;
    final cap = now.add(maxAhead - const Duration(minutes: 1));
    if (expires.isAfter(cap)) expires = cap;
    final blob = await sealPayload(crypto, _session!, _lastPayload,
        kind: LockedKind.copy, expires: expires, saved: now);
    if (!device.write(copyKey, blob.encode())) return SaveOutcome.refused;
    _claim();
    return SaveOutcome.saved;
  }

  /// Whether another tab is working on the locked copy right now.
  bool get openElsewhere {
    final raw = device.read(ownerKey);
    if (raw == null) return false;
    final parts = raw.split('|');
    if (parts.first == tabId || parts.length < 2) return false;
    final beat = int.tryParse(parts[1]);
    if (beat == null) return false;
    return _clock().millisecondsSinceEpoch - beat <
        ownerFresh.inMilliseconds;
  }

  void _claim() =>
      device.write(ownerKey, '$tabId|${_clock().millisecondsSinceEpoch}');

  /// The tab-only copy (after a reload of this tab), if any.
  Map<String, dynamic>? get tabCopy {
    final raw = tab.read(tabCopyKey);
    if (raw == null) return null;
    try {
      final j = jsonDecode(raw);
      return j is Map<String, dynamic> ? j : null;
    } catch (_) {
      return null;
    }
  }

  /// Erases the locked copy now ("Delete it" on the resume screen, too many
  /// wrong tries, an expired or damaged copy).
  void eraseCopy() {
    device.remove(copyKey);
    device.remove(triesKey);
    device.remove(ownerKey);
  }

  /// "Delete saved progress": erases this tab's locked copy and keeps work
  /// in this tab only from now on.
  void stopKeeping() {
    if (!openElsewhere) eraseCopy();
    _lastPayload = null;
    startTabOnly();
  }

  /// After a reload the key is gone. With no copy left to unlock, the choice
  /// is asked again at the next start.
  void forgetChoiceIfNothingToUnlock() {
    if (mode == ProgressMode.locked && _session == null && savedCopy == null) {
      tab.remove(modeKey);
    }
  }

  /// Everything this feature keeps, gone (Reset): both copies, the choice
  /// and the passphrase.
  void eraseAll() {
    eraseCopy();
    tab.remove(tabCopyKey);
    tab.remove(modeKey);
    _session = null;
    _fileSession = null;
    _lastPayload = null;
  }

  /// A locked file of [payload] to download (no expiry), with this tab's
  /// passphrase. Null when no passphrase is set yet.
  Future<String?> lockForDownload(Object? payload) async {
    final session = _session;
    if (session == null) return null;
    final blob =
        await sealPayload(crypto, session, payload, kind: LockedKind.file);
    return blob.encode();
  }

  LockSession? _fileSession;

  /// Opens a downloaded locked file. Throws [LockOpenException] on a wrong
  /// passphrase. A file has no try limit: it can be copied and guessed at
  /// elsewhere anyway.
  Future<Object?> openFile(LockedBlob blob, String passphrase) async {
    final session =
        await LockSession.forHeader(crypto, passphrase, blob.header);
    final payload = await openPayload(crypto, session, blob);
    _fileSession = session;
    return payload;
  }
}

String _newTabId() {
  final r = Random.secure();
  return List<int>.generate(8, (_) => r.nextInt(256))
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
}
