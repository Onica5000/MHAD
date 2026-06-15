import 'dart:convert';
import 'dart:typed_data';

import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/services/directive_file_codec.dart';

/// Thrown when an imported directive file can't be opened (corrupt, not a
/// directive file, or made by a newer app).
class DirectiveImportException implements Exception {
  final String message;
  DirectiveImportException(this.message);
  @override
  String toString() => message;
}

/// The user-owned, portable directive file: a full (PII-included) directive
/// snapshot, JSON-wrapped with a format/version header, written either as
/// plaintext or as an app-key-obfuscated container (the user chooses on
/// export — see [DirectiveFileCodec]). Re-importing rehydrates the directive
/// into a fresh working copy. No passphrase: the web app reads it directly.
class DirectiveExportService {
  final DirectiveRepository repo;
  DirectiveExportService(this.repo);

  static const fileFormat = 'mhad-directive';
  static const fileVersion = 1;
  static const fileExtension = 'mhad';

  /// Build the portable file bytes for [directiveId]. [encrypted] obfuscates
  /// with the app key; otherwise plaintext JSON. [nowMillis] stamps the export
  /// time (passed in so the result is deterministic / testable).
  Future<Uint8List> buildFile(
    int directiveId, {
    required bool encrypted,
    required int nowMillis,
  }) async {
    final data = await repo.snapshotDirective(directiveId, full: true);
    final wrapped = jsonEncode({
      'format': fileFormat,
      'version': fileVersion,
      'exportedAt': nowMillis,
      'data': data,
    });
    return DirectiveFileCodec.encode(wrapped, encrypted: encrypted);
  }

  /// Decode + validate [bytes], returning the inner snapshot data map. Throws
  /// [DirectiveImportException] with a user-facing message on failure.
  static Map<String, dynamic> parseFile(Uint8List bytes) {
    final String json;
    try {
      json = DirectiveFileCodec.decode(bytes);
    } on DirectiveFileException catch (e) {
      throw DirectiveImportException(e.message);
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } catch (_) {
      throw DirectiveImportException('The file is corrupted.');
    }
    if (decoded is! Map<String, dynamic>) {
      throw DirectiveImportException('This is not a directive file.');
    }
    if (decoded['format'] != fileFormat) {
      throw DirectiveImportException('This is not an MHAD directive file.');
    }
    final version = (decoded['version'] as num?)?.toInt() ?? 0;
    if (version > fileVersion) {
      throw DirectiveImportException(
          'This file was made by a newer version of the app. Please update to open it.');
    }
    final data = decoded['data'];
    if (data is! Map<String, dynamic>) {
      throw DirectiveImportException('The file contains no directive data.');
    }
    return data;
  }

  /// Decode + validate + restore into a NEW working directive; returns its id.
  Future<int> importFile(Uint8List bytes) async {
    final data = parseFile(bytes);
    return repo.restoreFromSnapshot(data);
  }

  /// Read the export timestamp without importing (for the validity/staleness
  /// surface). Returns null if the file can't be read.
  static int? exportedAtOf(Uint8List bytes) {
    try {
      final json = DirectiveFileCodec.decode(bytes);
      final obj = jsonDecode(json) as Map<String, dynamic>;
      return (obj['exportedAt'] as num?)?.toInt();
    } catch (_) {
      return null;
    }
  }
}
