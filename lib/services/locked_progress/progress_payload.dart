import 'package:mhad/ai/handoff/handoff_task.dart' show directiveIdOfHandoffRef;
import 'package:mhad/ai/handoff/pending_handoff.dart';
import 'package:mhad/data/repository/directive_repository.dart';

/// What a progress copy holds: every directive in this tab, which one was
/// being worked on, and a pending copy-and-paste AI answer.
///
/// [full] includes names, addresses and agents — only for the
/// passphrase-locked copy. The tab-only copy leaves them out, as the old
/// readable recovery copy did.
Future<Map<String, dynamic>> buildProgressPayload(
  DirectiveRepository repo, {
  required bool full,
  int? currentId,
  PendingHandoff? handoff,
}) async {
  final directives = <Map<String, dynamic>>[];
  for (final d in await repo.getAllDirectives()) {
    final snap = await repo.snapshotDirective(d.id, full: full);
    if (snap.isNotEmpty) directives.add({'id': d.id, 'snapshot': snap});
  }
  return {
    'v': 1,
    'directives': directives,
    'current': ?currentId,
    if (handoff != null && !handoff.isExpired()) 'handoff': handoff.toJson(),
  };
}

/// The result of putting a progress copy back into this tab.
class RestoredProgress {
  const RestoredProgress({required this.ids, this.current, this.handoff});

  /// Old directive id (in the copy) → new id (in this tab).
  final Map<int, int> ids;

  /// The directive that was being worked on, under its new id.
  final int? current;

  /// A still-pending AI answer, moved onto its directive's new id.
  final PendingHandoff? handoff;

  bool get isEmpty => ids.isEmpty;
}

/// Restores [payload] (from [buildProgressPayload]) into this tab's database.
/// Each directive comes back as a new working draft
/// ([DirectiveRepository.restoreFromSnapshot]).
Future<RestoredProgress> restoreProgressPayload(
    DirectiveRepository repo, Map<String, dynamic> payload) async {
  final ids = <int, int>{};
  final list = payload['directives'];
  if (list is List) {
    for (final e in list) {
      if (e is! Map) continue;
      final snap = e['snapshot'];
      if (snap is! Map<String, dynamic>) continue;
      final newId = await repo.restoreFromSnapshot(snap);
      final old = e['id'];
      if (old is int) ids[old] = newId;
    }
  }
  final current = payload['current'];
  PendingHandoff? handoff;
  final h = payload['handoff'];
  if (h is Map<String, dynamic>) {
    final p = PendingHandoff.fromJson(h);
    final oldId = p == null ? null : directiveIdOfHandoffRef(p.ref);
    final newId = oldId == null ? null : ids[oldId];
    if (p != null && !p.isExpired() && newId != null) {
      handoff = p.remappedTo(newId);
    }
  }
  return RestoredProgress(
    ids: ids,
    current: current is int ? ids[current] : null,
    handoff: handoff,
  );
}
