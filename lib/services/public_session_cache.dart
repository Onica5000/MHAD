import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages a short-lived cache for public mode session data.
///
/// When the app closes accidentally in public mode, the user has a grace
/// period ([ttl], default 10 minutes) to reopen the app and recover their
/// session. After the TTL expires, cached data is automatically discarded.
///
/// Cached items:
/// - Gemini API key (so the user doesn't have to re-enter it)
///
/// This cache is separate from [DraftRecoveryService] which handles form
/// data. Together they allow a near-complete session recovery after a crash.
///
/// When the user explicitly ends their session, [clearAll] wipes everything
/// immediately.
class PublicSessionCache {
  PublicSessionCache._();

  static const ttl = Duration(minutes: 10);

  static const _apiKeyKey = 'public_session_api_key';
  static const _timestampKey = 'public_session_timestamp';

  // ── API key cache ────────────────────────────────────────────────────

  /// Cache the API key with a timestamp.
  static Future<void> cacheApiKey(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_apiKeyKey, key);
      await prefs.setString(
          _timestampKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('PublicSessionCache: failed to cache API key: $e');
    }
  }

  /// Retrieve the cached API key if it's still within TTL.
  /// Returns null if expired or not found.
  static Future<String?> getCachedApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getString(_timestampKey);
      if (ts == null) return null;

      final savedAt = DateTime.tryParse(ts);
      if (savedAt == null) return null;

      final age = DateTime.now().difference(savedAt);
      if (age > ttl) {
        // Expired — clean up
        await _clearApiKey(prefs);
        return null;
      }

      return prefs.getString(_apiKeyKey);
    } catch (e) {
      debugPrint('PublicSessionCache: failed to read cached API key: $e');
      return null;
    }
  }

  /// How long ago the session was cached, or null if no cache exists.
  static Future<Duration?> getCacheAge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ts = prefs.getString(_timestampKey);
      if (ts == null) return null;
      final savedAt = DateTime.tryParse(ts);
      if (savedAt == null) return null;
      final age = DateTime.now().difference(savedAt);
      if (age > ttl) return null;
      return age;
    } catch (_) {
      return null;
    }
  }

  // ── Cleanup ──────────────────────────────────────────────────────────

  /// Clear all cached public session data. Call on explicit session end.
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await _clearApiKey(prefs);
    } catch (e) {
      debugPrint('PublicSessionCache: failed to clear: $e');
    }
  }

  static Future<void> _clearApiKey(SharedPreferences prefs) async {
    await prefs.remove(_apiKeyKey);
    await prefs.remove(_timestampKey);
  }
}
