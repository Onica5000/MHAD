import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:share_plus/share_plus.dart';

/// Exports all directive data as a JSON file for backup.
class DataExportService {
  final AppDatabase _db;
  DataExportService(this._db);

  /// Exports all directives with associated data as a JSON file and opens
  /// the system share sheet.
  ///
  /// The JSON is passed directly to the share sheet as in-memory bytes
  /// rather than written to a temporary file, so no unencrypted PII
  /// touches the filesystem.
  Future<void> exportAll() async {
    final directives = await _db.select(_db.directives).get();
    final agents = await _db.select(_db.agents).get();
    final meds = await _db.select(_db.medicationEntries).get();
    final prefs = await _db.select(_db.directivePrefs).get();
    final instructions =
        await _db.select(_db.additionalInstructionsTable).get();
    final witnesses = await _db.select(_db.witnesses).get();
    final guardians = await _db.select(_db.guardianNominations).get();

    final export = {
      'exportDate': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'directives': directives.map((d) => d.toJson()).toList(),
      'agents': agents.map((a) => a.toJson()).toList(),
      'medications': meds.map((m) => m.toJson()).toList(),
      'preferences': prefs.map((p) => p.toJson()).toList(),
      'additionalInstructions': instructions.map((i) => i.toJson()).toList(),
      'witnesses': witnesses.map((w) => {
            'id': w.id,
            'directiveId': w.directiveId,
            'witnessNumber': w.witnessNumber,
            'fullName': w.fullName,
            'address': w.address,
            // Exclude signature base64 from JSON export for size
            'signatureDate': w.signatureDate,
          }).toList(),
      'guardianNominations': guardians.map((g) => g.toJson()).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(export);
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));

    try {
      await Share.shareXFiles(
        [XFile.fromData(bytes, name: 'mhad_backup.json', mimeType: 'application/json')],
        subject: 'PA MHAD Data Backup',
      );
    } catch (e) {
      debugPrint('Share failed, falling back to clipboard: $e');
      // Fallback: copy JSON to clipboard
      await Clipboard.setData(ClipboardData(text: jsonStr));
      rethrow;
    }
  }
}
