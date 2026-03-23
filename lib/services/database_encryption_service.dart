import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the database encryption key lifecycle.
///
/// The key is a random 32-byte hex string generated on first launch and stored
/// in flutter_secure_storage. It is used as the SQLCipher PRAGMA key for the
/// encrypted Drift database in private mode.
class DatabaseEncryptionService {
  static const _storageKey = 'mhad_db_encryption_key';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Returns the encryption key, generating and persisting one if it does not
  /// yet exist.
  static Future<String> getOrCreateKey() async {
    try {
      final existing = await _storage.read(key: _storageKey);
      if (existing != null && existing.length == 64) {
        return existing;
      }
    } catch (e) {
      debugPrint('Failed to read DB encryption key, generating new one: $e');
    }

    // Generate a cryptographically random 32-byte hex key.
    final key = _generateRandomHexKey(32);
    await _storage.write(key: _storageKey, value: key);
    return key;
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
