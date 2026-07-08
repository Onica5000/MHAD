import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thrown when the database encryption key exists (or may exist) in secure
/// storage but could not be read. Callers must NOT fall back to generating a
/// new key: overwriting the stored key would permanently brick an existing
/// SQLCipher-encrypted database.
class DatabaseKeyUnavailableException implements Exception {
  final Object cause;
  DatabaseKeyUnavailableException(this.cause);

  @override
  String toString() =>
      'DatabaseKeyUnavailableException: secure storage could not be read '
      '($cause)';
}

/// Manages the database encryption key lifecycle.
///
/// The key is a random 32-byte hex string generated on first launch and stored
/// in flutter_secure_storage. It is used as the SQLCipher PRAGMA key for the
/// encrypted Drift database in private mode.
class DatabaseEncryptionService {
  static const _storageKey = 'mhad_db_encryption_key';

  static const FlutterSecureStorage _defaultStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static FlutterSecureStorage _storage = _defaultStorage;

  /// Replaces the secure-storage backend in tests.
  @visibleForTesting
  static set storage(FlutterSecureStorage value) => _storage = value;

  /// Restores the real secure-storage backend after a test.
  @visibleForTesting
  static void resetStorage() => _storage = _defaultStorage;

  /// Returns the encryption key, generating and persisting one if it does not
  /// yet exist.
  ///
  /// A key is only generated when the read *succeeded* and found nothing.
  /// If the read throws (locked keystore, plugin failure), this retries once
  /// and then throws [DatabaseKeyUnavailableException] — generating a fresh
  /// key on a transient read failure would overwrite the real key and make
  /// the existing encrypted database permanently unreadable.
  static Future<String> getOrCreateKey() async {
    final existing = await _readKeyWithRetry();
    if (existing != null && existing.length == 64) {
      return existing;
    }

    // Generate a cryptographically random 32-byte hex key.
    final key = _generateRandomHexKey(32);
    await _storage.write(key: _storageKey, value: key);
    return key;
  }

  /// Reads the stored key, retrying once on failure (transient keystore
  /// errors right after unlock are the common case). Throws
  /// [DatabaseKeyUnavailableException] if both attempts fail.
  static Future<String?> _readKeyWithRetry() async {
    try {
      return await _storage.read(key: _storageKey);
    } catch (e) {
      debugPrint('DB encryption key read failed, retrying once: $e');
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return await _storage.read(key: _storageKey);
    } catch (e) {
      throw DatabaseKeyUnavailableException(e);
    }
  }

  /// Generates a random hex string of [byteLength] bytes (output is
  /// [byteLength * 2] hex characters).
  static String _generateRandomHexKey(int byteLength) {
    final random = Random.secure();
    final bytes = List<int>.generate(byteLength, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Checks whether an encryption key already exists in secure storage.
  static Future<bool> hasKey() async {
    try {
      final existing = await _storage.read(key: _storageKey);
      return existing != null && existing.length == 64;
    } catch (_) {
      return false;
    }
  }

  /// Deletes the encryption key. WARNING: this makes any existing encrypted
  /// database unreadable. Only use for factory-reset scenarios.
  static Future<void> deleteKey() async {
    await _storage.delete(key: _storageKey);
  }
}
