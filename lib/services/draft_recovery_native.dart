import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

const _fileName = 'mhad_draft_recovery.json';

Future<File> _draftFile() async {
  final dir = await getApplicationCacheDirectory();
  return File('${dir.path}/$_fileName');
}

/// Save draft JSON to a file in the app cache directory.
Future<void> saveDraftPlatform(String jsonString) async {
  try {
    final file = await _draftFile();
    await file.writeAsString(jsonString);
  } catch (e) {
    debugPrint('Draft save failed: $e');
  }
}

/// Read draft JSON from file. Returns null if not found.
Future<String?> readDraftPlatform() async {
  try {
    final file = await _draftFile();
    if (!await file.exists()) return null;
    return await file.readAsString();
  } catch (e) {
    debugPrint('Draft read failed: $e');
    return null;
  }
}

/// Delete the draft file.
Future<void> clearDraftPlatform() async {
  try {
    final file = await _draftFile();
    if (await file.exists()) await file.delete();
  } catch (e) {
    debugPrint('Draft clear failed: $e');
  }
}
