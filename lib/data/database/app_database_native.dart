import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

import 'app_database.dart';

/// Creates an AppDatabase backed by an unencrypted file (legacy / fallback).
AppDatabase createAppDatabase() => AppDatabase(openConnection());

/// Creates an in-memory AppDatabase (public mode).
AppDatabase createMemoryDatabase() => AppDatabase(openMemoryConnection());

/// Creates an encrypted file-based AppDatabase using SQLCipher.
AppDatabase createEncryptedDatabase(String encryptionKey) =>
    AppDatabase(openEncryptedConnection(encryptionKey));

/// Registers the SQLCipher native library bundled by sqlcipher_flutter_libs.
Future<void> _setupSqlCipher() async {
  if (Platform.isAndroid) {
    await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();
    open.overrideFor(OperatingSystem.android, openCipherOnAndroid);
  }
}

/// In-memory connection with SQLCipher library setup.
QueryExecutor openMemoryConnection() {
  return LazyDatabase(() async {
    await _setupSqlCipher();
    return NativeDatabase.memory();
  });
}

/// Unencrypted file-based connection.
QueryExecutor openConnection() {
  return LazyDatabase(() async {
    await _setupSqlCipher();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mhad.db'));
    return NativeDatabase(file);
  });
}

/// Opens an encrypted SQLCipher database connection.
QueryExecutor openEncryptedConnection(String key) {
  return LazyDatabase(() async {
    await _setupSqlCipher();
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'mhad_encrypted.db'));

    NativeDatabase openDb() => NativeDatabase(
          file,
          setup: (rawDb) {
            rawDb.execute("PRAGMA key = '$key'");
            rawDb.select('SELECT count(*) FROM sqlite_master');
          },
        );

    try {
      return openDb();
    } catch (e) {
      debugPrint(
          'Encrypted DB open failed ($e), deleting and recreating.');
      if (await file.exists()) {
        await file.delete();
      }
      return openDb();
    }
  });
}
