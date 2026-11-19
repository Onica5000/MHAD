import 'package:mhad/ai/handoff/handoff_task.dart';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mhad/ai/handoff/ai_handoff_data.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/services/locked_progress/key_value_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An answer MHAD is waiting for while the person is in their AI chat.
///
/// Kept for [window] (30 minutes, user decision 2026-11-17) and extendable:
/// while one is pending, a passphrase-locked progress copy is kept at least
/// that long too ([PendingHandoffStore.activeDeadline]), so a phone that
/// unloads the MHAD tab while the person is in another app doesn't lose
/// their work.
class PendingHandoff {
  /// The same window as the locked progress copy (`progressWindowMinutes`).
  static Duration get window => appData.config.progressWindow;

  /// The task tag the answer must carry.
  final String taskTag;

  /// What it is for, as this page builds it now (e.g. `d12`).
  final String ref;

  /// The reference inside the copied instructions — what the answer carries.
  /// The same as [ref] unless a reload restored the work under a new id.
  final String promptRef;

  /// Where to come back to paste the answer; empty when it can't be resumed
  /// elsewhere (the answer needs state that leaving the page loses).
  final String route;
  final DateTime deadline;

  const PendingHandoff({
    required this.taskTag,
    required this.ref,
    required this.route,
    required this.deadline,
    String? promptRef,
  }) : promptRef = promptRef ?? ref;

  /// Whether the "Back to paste your AI answer" banner and the reload
  /// restore can lead back to [route].
  bool get resumable => route.isNotEmpty;

  Duration remaining([DateTime? now]) =>
      deadline.difference(now ?? DateTime.now());
  bool isExpired([DateTime? now]) => remaining(now) <= Duration.zero;

  PendingHandoff copyWith({DateTime? deadline, String? ref, String? route}) =>
      PendingHandoff(
        taskTag: taskTag,
        ref: ref ?? this.ref,
        route: route ?? this.route,
        deadline: deadline ?? this.deadline,
        promptRef: promptRef,
      );

  /// This wait, moved to directive [newId] after a reload restored the work
  /// under a new id: [route] and [ref] follow the new id; [promptRef] keeps
  /// the old one, which is what the answer carries.
  PendingHandoff remappedTo(int newId) {
    final oldId = directiveIdOfHandoffRef(ref);
    if (oldId == null || oldId == newId) return this;
    var moved = route;
    if (route.startsWith('/')) {
      final uri = Uri.parse(route);
      final path = '/${[
        for (final seg in uri.pathSegments) seg == '$oldId' ? '$newId' : seg,
      ].join('/')}';
      moved = uri.hasQuery ? '$path?${uri.query}' : path;
    }
    return copyWith(ref: directiveHandoffRef(newId), route: moved);
  }

  Map<String, dynamic> toJson() => {
        'task': taskTag,
        'ref': ref,
        'promptRef': promptRef,
        'route': route,
        'deadline': deadline.toIso8601String(),
      };

  static PendingHandoff? fromJson(Map<String, dynamic> m) {
    final d = DateTime.tryParse('${m['deadline']}');
    if (d == null) return null;
    return PendingHandoff(
      taskTag: '${m['task']}',
      ref: '${m['ref']}',
      promptRef: m['promptRef'] == null ? null : '${m['promptRef']}',
      route: '${m['route']}',
      deadline: d,
    );
  }
}

/// Tab storage (`sessionStorage`): survives a reload of this tab and is
/// erased when the tab closes. A passphrase-locked progress copy carries the
/// wait too, so it comes back with the work after the tab was closed.
abstract final class PendingHandoffStore {
  static const _key = 'ai_handoff_pending';

  static Future<PendingHandoff?> read() async {
    try {
      final raw = tabStore.read(_key);
      if (raw == null) return null;
      return PendingHandoff.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(PendingHandoff? p) async {
    if (p == null) {
      tabStore.remove(_key);
    } else {
      tabStore.write(_key, jsonEncode(p.toJson()));
    }
  }

  /// The deadline of a pending, unexpired handoff — the web session cache
  /// keeps the work at least this long.
  static Future<DateTime?> activeDeadline() async {
    final p = await read();
    if (p == null || p.isExpired()) return null;
    return p.deadline;
  }
}

/// The pending answer, if any (restored after a reload).
class PendingHandoffNotifier extends Notifier<PendingHandoff?> {
  /// Set once this session starts, extends, clears or moves a wait, so the
  /// stored wait loaded at startup can't overwrite it.
  bool _touched = false;

  @override
  PendingHandoff? build() {
    PendingHandoffStore.read().then((p) {
      if (p != null && !p.isExpired() && !_touched) state = p;
    });
    return null;
  }

  /// Starts (or restarts) the wait for [taskTag]'s answer about [ref].
  void start({
    required String taskTag,
    required String ref,
    required String route,
  }) {
    _touched = true;
    state = PendingHandoff(
      taskTag: taskTag,
      ref: ref,
      route: route,
      deadline: DateTime.now().add(PendingHandoff.window),
    );
    PendingHandoffStore.write(state);
  }

  /// Another [PendingHandoff.window] from now (or from the deadline, if later).
  void extend() {
    final p = state;
    if (p == null) return;
    _touched = true;
    final now = DateTime.now();
    final base = p.deadline.isAfter(now) ? p.deadline : now;
    state = p.copyWith(deadline: base.add(PendingHandoff.window));
    PendingHandoffStore.write(state);
  }

  void clear() {
    _touched = true;
    state = null;
    PendingHandoffStore.write(null);
  }

  /// Takes over a wait that came back with a restored progress copy (already
  /// moved onto its directive's new id).
  void adopt(PendingHandoff p) {
    _touched = true;
    state = p;
    PendingHandoffStore.write(p);
  }

  /// Moves the wait onto directive [newId] after a reload restored the work
  /// under a new id ([PendingHandoff.remappedTo]). Reads browser storage
  /// itself: the restore can run before this notifier's own load. Returns
  /// the live wait, or null (an expired one is dropped).
  Future<PendingHandoff?> remapDirective(int newId) async {
    final p = state ?? await PendingHandoffStore.read();
    _touched = true;
    if (p == null || p.isExpired()) {
      clear();
      return null;
    }
    final moved = p.remappedTo(newId);
    state = moved;
    await PendingHandoffStore.write(moved);
    return moved;
  }
}

final pendingHandoffProvider =
    NotifierProvider<PendingHandoffNotifier, PendingHandoff?>(
        PendingHandoffNotifier.new);

/// JSON handoff cards on screen: task tag → how many. The "Back to paste your
/// AI answer" banner hides while one that can take the pending answer is
/// showing (e.g. Snap-to-fill's dialog over the wizard).
final liveHandoffCardsProvider =
    StateProvider<Map<String, int>>((ref) => const {});

/// The privacy notice is shown once per session (user decision 2026-11-17).
final handoffPrivacyAcknowledgedProvider = StateProvider<bool>((ref) => false);

/// The person's chosen AI service, remembered in browser storage (not
/// sensitive). Null until they pick one.
class PreferredAiServiceNotifier extends Notifier<AiService?> {
  static const _key = 'ai_handoff_service';

  @override
  AiService? build() {
    SharedPreferences.getInstance().then((prefs) {
      final name = prefs.getString(_key);
      final match = AiService.values.where((s) => s.name == name);
      if (match.isNotEmpty && state == null) state = match.first;
    }).catchError((_) {});
    return null;
  }

  void choose(AiService s) {
    state = s;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setString(_key, s.name))
        .catchError((_) => false);
  }

  /// "Start over": forget which service was used.
  void forget() {
    state = null;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.remove(_key))
        .catchError((_) => false);
  }
}

final preferredAiServiceProvider =
    NotifierProvider<PreferredAiServiceNotifier, AiService?>(
        PreferredAiServiceNotifier.new);
