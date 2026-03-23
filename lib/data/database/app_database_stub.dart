import 'app_database.dart';

/// Stub — should never be called at runtime. The conditional import will
/// resolve to either app_database_native.dart or app_database_web.dart.
AppDatabase createAppDatabase() =>
    throw UnsupportedError('Platform not supported');

AppDatabase createMemoryDatabase() =>
    throw UnsupportedError('Platform not supported');

AppDatabase createEncryptedDatabase(String encryptionKey) =>
    throw UnsupportedError('Platform not supported');
