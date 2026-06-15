import 'dart:convert';

import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/services/export_encryption_service.dart';

/// Thrown when an imported directive file can't be opened (wrong passphrase,
/// not a directive file, corrupt, or made by a newer app).
class DirectiveImportException implements Exception {
  final String message;
  DirectiveImportException(this.message);
  @override
  String toString() => message;
}

/// The user-owned, portable directive file: a full (PII-included) directive
/// snapshot, JSON-wrapped with a format/version header, encrypted with the
/// user's passphrase. The user keeps the file; nothing is stored server-side.
/// Re-importing rehydrates the directive into a fresh working copy.
class DirectiveExportService {
  final DirectiveRepository repo;
  DirectiveExportService(this.repo);

  static const fileFormat = 'mhad-directive';
  static const fileVersion = 1;

  /// File extension for downloads.
  static const fileExtension = 'mhad';

  /// Build the encrypted file contents for [directiveId]. [nowMillis] stamps
  /// the export time (passed in so the result is deterministic / testable).
  Future<String> buildEncryptedFile(
    int directiveId,
    String passphrase, {
    required int nowMillis,
  }) async {
    final data = await repo.snapshotDirective(directiveId, full: true);
    final wrapped = jsonEncode({
      'format': fileFormat,
      'version': fileVersion,
      'exportedAt': nowMillis,
      'data': data,
    });
    return ExportEncryptionService.encryptToEnvelope(wrapped, passphrase);
  }

  /// Decrypt + validate [fileContents], returning the inner snapshot data map.
  /// Throws [DirectiveImportException] with a user-facing message on failure.
  static Map<String, dynamic> parseEncryptedFile(
      String fileContents, String passphrase) {
    final String plain;
    try {
      plain = ExportEncryptionService.decryptEnvelope(fileContents, passphrase);
    } catch (_) {
      throw DirectiveImportException(
          'Could not open the file — the passphrase is wrong, or this is not '
          'a directive file.');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(plain);
    } catch (_) {
      throw DirectiveImportException(
          'The file is corrupted or not a directive export.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw DirectiveImportException('The file is not a directive export.');
    }
    if (decoded['format'] != fileFormat) {
      throw DirectiveImportException('This is not an MHAD directive file.');
    }
    final version = (decoded['version'] as num?)?.toInt() ?? 0;
    if (version > fileVersion) {
      throw DirectiveImportException(
          'This file was made by a newer version of the app. Please update to '
          'open it.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw DirectiveImportException('The file contains no directive data.');
    }
    return data;
  }

  /// Decrypt + validate + restore into a NEW working directive; returns its id.
  Future<int> importEncryptedFile(
      String fileContents, String passphrase) async {
    final data = parseEncryptedFile(fileContents, passphrase);
    return repo.restoreFromSnapshot(data);
  }

  /// Read the export timestamp without importing (for the validity/staleness
  /// surface). Returns null if the file can't be read.
  static int? exportedAtOf(String fileContents, String passphrase) {
    try {
      final plain =
          ExportEncryptionService.decryptEnvelope(fileContents, passphrase);
      final obj = jsonDecode(plain) as Map<String, dynamic>;
      return (obj['exportedAt'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }
}
