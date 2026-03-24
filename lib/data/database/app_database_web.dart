import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

import 'app_database.dart';

/// Creates an AppDatabase for web — always in-memory (public mode only).
/// Data is lost when the tab/browser is closed, by design.
AppDatabase createAppDatabase() => createMemoryDatabase();

/// Creates an in-memory AppDatabase for web.
AppDatabase createMemoryDatabase() {
  return AppDatabase(_openInMemoryWebConnection());
}

/// On web, encryption is not supported — falls back to in-memory.
AppDatabase createEncryptedDatabase(String encryptionKey) =>
    createMemoryDatabase();

/// Opens a truly in-memory WASM database — no OPFS or IndexedDB persistence.
QueryExecutor _openInMemoryWebConnection() {
  return LazyDatabase(() async {
    final sqlite3 =
        await WasmSqlite3.loadFromUrl(Uri.parse('sqlite3.wasm'));
    sqlite3.registerVirtualFileSystem(
      InMemoryFileSystem(),
      makeDefault: true,
    );
    return WasmDatabase.inMemory(sqlite3);
  });
}
