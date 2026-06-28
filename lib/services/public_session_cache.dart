import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mhad/ai/ai_prefs.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages a short-lived cache for public mode session data.
///
/// When the app closes accidentally in public mode, the user has a grace
/// period ([ttl], default 10 minutes) to reopen the app and recover their
/// session. After the TTL expires, cached data is automatically discarded.
///
/// Cached items:
/// - AI config ([AiPrefs]): the per-provider API keys, active provider, and
///   chosen models (so the user doesn't have to re-enter them).
///
/// This cache is separate from [DraftRecoveryService] which handles form
/// data. Together they allow a near-complete session recovery after a crash.
///
/// When the user explicitly ends their session, [clearAll] wipes everything
/// immediately.
class PublicSessionCache {
  PublicSessionCache._();

  static Duration get ttl => sessionCacheTtl;

  static const _prefsKey = 'public_session_ai_prefs'; // JSON AiPrefs
  static const _legacyKeyKey = 'public_session_api_key'; // old single Gemini key
  static const _timestampKey = 'public_session_timestamp';

  // ── AI config cache ──────────────────────────────────────────────────

  /// Cache the full AI config with a timestamp.
  static Future<void> cachePrefs(AiPrefs prefs) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_prefsKey, jsonEncode(prefs.toJson()));
      await p.setString(_timestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('PublicSessionCache: failed to cache prefs: $e');
    }
  }

  /// Retrieve the cached AI config if still within TTL (null if expired/absent).
  /// Migrates an older single-key cache to the new per-provider shape.
  static Future<AiPrefs?> getCachedPrefs() async {
    try {
      final p = await SharedPreferences.getInstance();
      final ts = p.getString(_timestampKey);
      if (ts == null) return null;
      final savedAt = DateTime.tryParse(ts);
      if (savedAt == null) return null;
      if (DateTime.now().difference(savedAt) > ttl) {
        await clearAll();
        return null;
      }

      final raw = p.getString(_prefsKey);
      if (raw != null) {
        return AiPrefs.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
      // Legacy: a single cached Gemini key from before multi-provider.
      final legacy = p.getString(_legacyKeyKey);
      if (legacy != null && legacy.isNotEmpty) {
        return AiPrefs(
          provider: AiProvider.gemini,
          keys: {AiProvider.gemini: legacy},
        );
      }
      return null;
    } catch (e) {
      debugPrint('PublicSessionCache: failed to read cached prefs: $e');
      return null;
    }
  }

  // ── Cleanup ──────────────────────────────────────────────────────────

  /// Clear all cached public session data. Call on explicit session end.
  static Future<void> clearAll() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.remove(_prefsKey);
      await p.remove(_legacyKeyKey);
      await p.remove(_timestampKey);
    } catch (e) {
      debugPrint('PublicSessionCache: failed to clear: $e');
    }
  }
}
