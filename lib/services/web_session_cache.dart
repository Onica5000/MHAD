import 'package:mhad/data/repository/directive_repository.dart';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/ai/handoff/pending_handoff.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Caches the current directive data to SharedPreferences on web so that
/// a page reload can restore the user's work. Uses the same TTL as the
/// API key cache (10 minutes).
///
/// This is separate from [DraftRecoveryService] which handles crash recovery
/// on native platforms. On web, this provides seamless reload recovery.
class WebSessionCache {
  WebSessionCache._();

  static const _dataKey = 'web_session_directive';
  static const _tsKey = 'web_session_timestamp';
  static Duration get ttl => sessionCacheTtl;

  /// Save a directive snapshot.
  static Future<void> saveDirective(Map<String, dynamic> snapshot) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dataKey, jsonEncode(snapshot));
      await prefs.setString(_tsKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('WebSessionCache: save failed: $e');
    }
  }

  /// Snapshots directive [directiveId] for reload recovery (web only;
  /// identity stays out — see `snapshotDirective`). Best-effort and bounded:
  /// it must never block the caller (wizard navigation, a handoff copy), and a
  /// try/catch alone doesn't rescue a hang — only a throw — so every async hop
  /// has a timeout; on timeout the snapshot is simply skipped.
  static Future<void> cacheDirective(
      DirectiveRepository repo, int directiveId) async {
    if (!kIsWeb) return;
    try {
      final snap = await repo
          .snapshotDirective(directiveId)
          .timeout(const Duration(seconds: 3));
      if (snap.isNotEmpty) {
        await saveDirective(snap).timeout(const Duration(seconds: 3));
      }
    } catch (e) {
      debugPrint('Web cache save skipped (failed or timed out): $e');
    }
  }

  /// Refresh the freshness timestamp WITHOUT rewriting the snapshot. Called on
  /// a heartbeat while the tab is open so the [ttl] window effectively starts
  /// when the page is CLOSED or crashes — not when data was last saved. While
  /// the app stays open the timestamp keeps advancing, so the cached work never
  /// expires during active use; once the heartbeat stops (close/crash) the
  /// 10-minute countdown begins from that last beat.
  static Future<void> touch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.getString(_dataKey) == null) return; // nothing cached yet
      await prefs.setString(_tsKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('WebSessionCache: touch failed: $e');
    }
  }

  /// Read the cached directive if within TTL. Returns null if expired or absent.
  static Future<Map<String, dynamic>?> getCachedDirective() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getString(_tsKey);
      if (ts == null) return null;

      final savedAt = DateTime.tryParse(ts);
      if (savedAt == null) return null;

      final age = DateTime.now().difference(savedAt);
      // While the person is in their AI chat waiting to paste an answer back
      // (copy-and-paste handoff), the work is kept until that wait's deadline
      // (30 min, extendable) — a phone may unload this tab meanwhile.
      final handoffDeadline = await PendingHandoffStore.activeDeadline();
      final keptForHandoff =
          handoffDeadline != null && DateTime.now().isBefore(handoffDeadline);
      if (age > ttl && !keptForHandoff) {
        await clear();
        return null;
      }

      final data = prefs.getString(_dataKey);
      if (data == null) return null;

      return jsonDecode(data) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('WebSessionCache: read failed: $e');
      return null;
    }
  }

  /// Clear the cached directive.
  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dataKey);
      await prefs.remove(_tsKey);
    } catch (e) {
      debugPrint('WebSessionCache: clear failed: $e');
    }
  }
}
