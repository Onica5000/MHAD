import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'mhad_draft_recovery';

/// Save draft JSON to shared_preferences on web.
Future<void> saveDraftPlatform(String jsonString) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonString);
  } catch (e) {
    debugPrint('Draft save failed: $e');
  }
}

/// Read draft JSON from shared_preferences. Returns null if not found.
Future<String?> readDraftPlatform() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  } catch (e) {
    debugPrint('Draft read failed: $e');
    return null;
  }
}

/// Delete the draft from shared_preferences.
Future<void> clearDraftPlatform() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  } catch (e) {
    debugPrint('Draft clear failed: $e');
  }
}
