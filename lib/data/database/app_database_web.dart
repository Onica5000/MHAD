import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

import 'app_database.dart';

/// Creates an AppDatabase for web — always in-memory (public mode only).
AppDatabase createAppDatabase() => createMemoryDatabase();

/// Creates an in-memory AppDatabase for web.
AppDatabase createMemoryDatabase() {
  return AppDatabase(_openWebConnection());
}

/// On web, encryption is not supported — falls back to in-memory.
AppDatabase createEncryptedDatabase(String encryptionKey) =>
    createMemoryDatabase();

/// Opens a WASM-based database for web.
/// Uses OPFS or IndexedDB for storage depending on browser support.
QueryExecutor _openWebConnection() {
  return LazyDatabase(() async {
    final result = await WasmDatabase.open(
      databaseName: 'mhad_web',
      sqlite3Uri: Uri.parse('sqlite3.wasm'),
      driftWorkerUri: Uri.parse('drift_worker.js'),
    );
    return result.resolvedExecutor;
  });
}
