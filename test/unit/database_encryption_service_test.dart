import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/database_encryption_service.dart';

/// Scriptable fake secure storage: each read consumes the next behavior in
/// [readScript]; writes are recorded so tests can assert the key was (not)
/// overwritten.
class _FakeSecureStorage extends Fake implements FlutterSecureStorage {
  _FakeSecureStorage(this.readScript);

  /// Each entry is either a `String?` to return or an [Exception] to throw.
  final List<Object?> readScript;
  int readCalls = 0;
  final List<String?> writes = [];

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    final behavior =
        readCalls < readScript.length ? readScript[readCalls] : readScript.last;
    readCalls++;
    if (behavior is Exception) throw behavior;
    return behavior as String?;
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    writes.add(value);
  }
}

void main() {
  final validKey = 'a' * 64;

  tearDown(DatabaseEncryptionService.resetStorage);

  group('getOrCreateKey', () {
    test('returns the existing key without writing', () async {
      final storage = _FakeSecureStorage([validKey]);
      DatabaseEncryptionService.storage = storage;

      final key = await DatabaseEncryptionService.getOrCreateKey();

      expect(key, validKey);
      expect(storage.writes, isEmpty);
    });

    test('generates and persists a key when none is stored', () async {
      final storage = _FakeSecureStorage([null]);
      DatabaseEncryptionService.storage = storage;

      final key = await DatabaseEncryptionService.getOrCreateKey();

      expect(key, hasLength(64));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(key), isTrue);
      expect(storage.writes, [key]);
    });

    test('retries a failed read and returns the existing key', () async {
      final storage = _FakeSecureStorage([
        Exception('keystore locked'),
        validKey,
      ]);
      DatabaseEncryptionService.storage = storage;

      final key = await DatabaseEncryptionService.getOrCreateKey();

      expect(key, validKey);
      expect(storage.readCalls, 2);
      expect(storage.writes, isEmpty,
          reason: 'a transient read failure must never overwrite the key');
    });

    test(
        'throws (and never writes) when the read keeps failing — '
        'regenerating would brick the existing encrypted database', () async {
      final storage = _FakeSecureStorage([
        Exception('keystore locked'),
        Exception('keystore locked'),
      ]);
      DatabaseEncryptionService.storage = storage;

      await expectLater(
        DatabaseEncryptionService.getOrCreateKey(),
        throwsA(isA<DatabaseKeyUnavailableException>()),
      );
      expect(storage.writes, isEmpty,
          reason: 'a failed read must never overwrite the key');
    });
  });

  group('hasKey', () {
    test('true for a stored 64-char key', () async {
      DatabaseEncryptionService.storage = _FakeSecureStorage([validKey]);
      expect(await DatabaseEncryptionService.hasKey(), isTrue);
    });

    test('false when storage read fails', () async {
      DatabaseEncryptionService.storage =
          _FakeSecureStorage([Exception('unavailable')]);
      expect(await DatabaseEncryptionService.hasKey(), isFalse);
    });
  });
}
