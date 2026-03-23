import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages a user-chosen passcode for Private Mode on devices without
/// biometric authentication.
///
/// The passcode is hashed with HMAC-SHA256 using a per-user random salt
/// before being stored in [FlutterSecureStorage] (hardware-backed encrypted
/// storage). The salt is stored alongside the hash.
class PinAuthService {
  static const _pinHashKey = 'mhad_pin_hash';
  static const _pinSaltKey = 'mhad_pin_salt';

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Generates a cryptographically random 32-byte hex salt.
  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// HMAC-SHA256 of [pin] keyed with [salt].
  static String _hash(String pin, String salt) {
    final hmac = Hmac(sha256, utf8.encode(salt));
    return hmac.convert(utf8.encode(pin)).toString();
  }

  /// Whether a passcode has been set up previously.
  static Future<bool> hasPin() async {
    final stored = await _storage.read(key: _pinHashKey);
    return stored != null;
  }

  /// Store a new passcode (overwrites any existing one).
  static Future<void> setPin(String pin) async {
    final salt = _generateSalt();
    final hash = _hash(pin, salt);
    await _storage.write(key: _pinSaltKey, value: salt);
    await _storage.write(key: _pinHashKey, value: hash);
  }

  /// Returns `true` if [pin] matches the stored passcode.
  static Future<bool> verify(String pin) async {
    final storedHash = await _storage.read(key: _pinHashKey);
    final storedSalt = await _storage.read(key: _pinSaltKey);
    if (storedHash == null) return false;

    // Legacy support: if no salt exists (set before this upgrade), the hash
    // was plain SHA-256. Verify with the old method, then re-hash with salt.
    if (storedSalt == null) {
      final legacyHash = sha256.convert(utf8.encode(pin)).toString();
      if (legacyHash == storedHash) {
        // Upgrade to salted hash transparently.
        await setPin(pin);
        return true;
      }
      return false;
    }

    return storedHash == _hash(pin, storedSalt);
  }

  /// Remove the stored passcode.
  static Future<void> deletePin() async {
    await _storage.delete(key: _pinHashKey);
    await _storage.delete(key: _pinSaltKey);
  }
}
