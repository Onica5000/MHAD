import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One saved admin backup snapshot — a full copy of a dynamic-data file (e.g.
/// app_data.json or educational_content.json) taken just before an update, so
/// it can be rolled back. [archived] entries are gzip-compressed at rest.
class BackupEntry {
  /// Epoch milliseconds the snapshot was taken.
  final int ts;

  /// Whether this entry currently lives in the compressed archive store.
  final bool archived;

  const BackupEntry({required this.ts, required this.archived});

  /// `YYYY-MM-DD HH:MM` for display (local time).
  String get label {
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}

/// Persistent, per-target history of admin-update backups (the in-app roll-back
/// safety net). It is INTENTIONALLY persistent across sessions — admin-only
/// (behind the passphrase gate) and holds only app config/content, never user
/// PII — so it is exempt from the app's ephemeral session clearing.
///
/// Retention: snapshots younger than [retentionDays] are kept full and instantly
/// restorable in the active store; once a snapshot passes a year it is moved to
/// a separate gzip-compressed archive store (still fully restorable, just
/// smaller) to save space. If the active store ever can't be written (web
/// localStorage quota), the oldest active snapshots are archived until it fits.
class AdminBackupStore {
  AdminBackupStore._();

  static const retentionDays = 365;
  static const _dayMs = 86400000;

  static String _activeKey(String target) => 'admin_backups_$target';
  static String _archiveKey(String target) => 'admin_backups_archive_$target';

  /// Save a new snapshot of [json] for [target] taken at [nowMs], then archive
  /// anything older than a year.
  static Future<void> append(String target, String json, int nowMs) async {
    final prefs = await SharedPreferences.getInstance();
    final active = _decode(prefs.getString(_activeKey(target)));
    // newest first.
    active.insert(0, {'ts': nowMs, 'json': json});
    await _pruneArchiveAndSave(prefs, target, active, nowMs);
  }

  /// All snapshots for [target] (active + archived), newest first.
  static Future<List<BackupEntry>> list(String target) async {
    final prefs = await SharedPreferences.getInstance();
    final active = _decode(prefs.getString(_activeKey(target)));
    final archive = _decode(prefs.getString(_archiveKey(target)));
    final out = <BackupEntry>[
      for (final e in active)
        BackupEntry(ts: (e['ts'] as num).toInt(), archived: false),
      for (final e in archive)
        BackupEntry(ts: (e['ts'] as num).toInt(), archived: true),
    ];
    out.sort((a, b) => b.ts.compareTo(a.ts));
    return out;
  }

  /// The full JSON for the snapshot at [ts] (decompressing if it is archived),
  /// or null if there is no such snapshot.
  static Future<String?> read(String target, int ts) async {
    final prefs = await SharedPreferences.getInstance();
    for (final e in _decode(prefs.getString(_activeKey(target)))) {
      if ((e['ts'] as num).toInt() == ts) return e['json'] as String;
    }
    for (final e in _decode(prefs.getString(_archiveKey(target)))) {
      if ((e['ts'] as num).toInt() == ts) {
        return utf8.decode(
            GZipDecoder().decodeBytes(base64Decode(e['gz'] as String)));
      }
    }
    return null;
  }

  // ── internals ──────────────────────────────────────────────────────────

  static Future<void> _pruneArchiveAndSave(SharedPreferences prefs,
      String target, List<Map<String, dynamic>> active, int nowMs) async {
    final cutoff = nowMs - retentionDays * _dayMs;
    final keep = <Map<String, dynamic>>[];
    final toArchive = <Map<String, dynamic>>[];
    for (final e in active) {
      ((e['ts'] as num).toInt() < cutoff ? toArchive : keep).add(e);
    }
    if (toArchive.isNotEmpty) await _archive(prefs, target, toArchive);

    // Write the active store; if it overflows (web localStorage quota), archive
    // the oldest kept snapshots (at the end of the newest-first list) until it
    // fits, so a new backup is never lost to a full store.
    while (true) {
      try {
        await prefs.setString(_activeKey(target), jsonEncode(keep));
        return;
      } catch (_) {
        if (keep.isEmpty) return; // nothing left to shed; give up quietly
        await _archive(prefs, target, [keep.removeLast()]);
      }
    }
  }

  static Future<void> _archive(SharedPreferences prefs, String target,
      List<Map<String, dynamic>> entries) async {
    final archive = _decode(prefs.getString(_archiveKey(target)));
    for (final e in entries) {
      final gz = GZipEncoder().encodeBytes(utf8.encode(e['json'] as String));
      archive.add({'ts': e['ts'], 'gz': base64Encode(gz)});
    }
    archive.sort((a, b) => (b['ts'] as num).compareTo(a['ts'] as num));
    await prefs.setString(_archiveKey(target), jsonEncode(archive));
  }

  static List<Map<String, dynamic>> _decode(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      return [
        for (final e in jsonDecode(raw) as List)
          (e as Map).cast<String, dynamic>(),
      ];
    } catch (_) {
      return [];
    }
  }
}
