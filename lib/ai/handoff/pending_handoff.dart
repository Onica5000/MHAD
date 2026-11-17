import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mhad/ai/handoff/ai_handoff_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An answer MHAD is waiting for while the person is in their AI chat.
///
/// Kept for [window] (30 minutes, user decision 2026-11-17) and extendable:
/// while one is pending, the web session's recovery copy is kept that long
/// too ([PendingHandoffStore.activeDeadline]), so a phone that unloads the
/// MHAD tab while the person is in another app doesn't lose their work.
class PendingHandoff {
  static const window = Duration(minutes: 30);

  /// The task tag the answer must carry.
  final String taskTag;

  /// What it is for (e.g. `d12`).
  final String ref;

  /// Where to paste the answer (the page that started it).
  final String route;
  final DateTime deadline;

  const PendingHandoff({
    required this.taskTag,
    required this.ref,
    required this.route,
    required this.deadline,
  });

  Duration remaining([DateTime? now]) =>
      deadline.difference(now ?? DateTime.now());
  bool isExpired([DateTime? now]) => remaining(now) <= Duration.zero;

  PendingHandoff copyWith({DateTime? deadline}) => PendingHandoff(
        taskTag: taskTag,
        ref: ref,
        route: route,
        deadline: deadline ?? this.deadline,
      );

  Map<String, dynamic> toJson() => {
        'task': taskTag,
        'ref': ref,
        'route': route,
        'deadline': deadline.toIso8601String(),
      };

  static PendingHandoff? fromJson(Map<String, dynamic> m) {
    final d = DateTime.tryParse('${m['deadline']}');
    if (d == null) return null;
    return PendingHandoff(
      taskTag: '${m['task']}',
      ref: '${m['ref']}',
      route: '${m['route']}',
      deadline: d,
    );
  }
}

/// Browser-storage persistence (survives a tab reload) — the same storage the
/// web session's recovery copy uses.
abstract final class PendingHandoffStore {
  static const _key = 'ai_handoff_pending';

  static Future<PendingHandoff?> read() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      return PendingHandoff.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(PendingHandoff? p) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (p == null) {
        await prefs.remove(_key);
      } else {
        await prefs.setString(_key, jsonEncode(p.toJson()));
      }
    } catch (_) {}
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
  @override
  PendingHandoff? build() {
    PendingHandoffStore.read().then((p) {
      if (p != null && !p.isExpired() && state == null) state = p;
    });
    return null;
  }

  /// Starts (or restarts) the wait for [taskTag]'s answer about [ref].
  void start({
    required String taskTag,
    required String ref,
    required String route,
  }) {
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
    final now = DateTime.now();
    final base = p.deadline.isAfter(now) ? p.deadline : now;
    state = p.copyWith(deadline: base.add(PendingHandoff.window));
    PendingHandoffStore.write(state);
  }

  void clear() {
    state = null;
    PendingHandoffStore.write(null);
  }
}

final pendingHandoffProvider =
    NotifierProvider<PendingHandoffNotifier, PendingHandoff?>(
        PendingHandoffNotifier.new);

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
}

final preferredAiServiceProvider =
    NotifierProvider<PreferredAiServiceNotifier, AiService?>(
        PreferredAiServiceNotifier.new);
