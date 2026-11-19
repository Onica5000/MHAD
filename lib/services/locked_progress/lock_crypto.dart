import 'dart:typed_data';

import 'lock_crypto_io.dart'
    if (dart.library.js_interop) 'lock_crypto_web.dart' as platform;

/// The two operations a locked copy needs (user decision 2026-11-18):
///
/// * turn the person's passphrase into a 256-bit key with
///   **PBKDF2-HMAC-SHA-256** (random 16-byte salt; the rounds are in
///   `kLockIterations`), and
/// * seal / open data with **AES-256-GCM** (12-byte nonce, 128-bit tag), with
///   the copy's readable header bound in as additional authenticated data.
///
/// On the web this is the browser's own Web Crypto: the key is derived as a
/// non-extractable `CryptoKey`, so not even this app's code can read it out,
/// and the passphrase itself is never stored. Elsewhere (tests, Windows) it is
/// pointycastle. Both produce identical bytes: the known-answer vector in
/// test/unit/locked_format_test.dart (and test/web/lock_crypto_web_test.dart,
/// run in Chrome) was computed with Web Crypto.
///
/// The passphrase is used as typed (UTF-8, no Unicode normalization) so both
/// implementations see the same bytes.
abstract class LockCrypto {
  Future<LockKey> deriveKey(String passphrase, Uint8List salt, int iterations);

  /// AES-256-GCM: the ciphertext followed by the 16-byte tag.
  Future<Uint8List> seal(
      LockKey key, Uint8List nonce, Uint8List plaintext, Uint8List aad);

  /// Reverses [seal]. Throws [LockOpenException] when the key is wrong or any
  /// byte of [sealed] or [aad] was changed.
  Future<Uint8List> open(
      LockKey key, Uint8List nonce, Uint8List sealed, Uint8List aad);
}

/// A derived key. Opaque: on the web it wraps a non-extractable CryptoKey.
abstract class LockKey {}

/// A wrong passphrase, or locked data that was changed or damaged. AES-GCM
/// can't tell those apart, and the app doesn't try to.
class LockOpenException implements Exception {
  const LockOpenException();
}

/// This platform's implementation (Web Crypto on the web).
LockCrypto createLockCrypto() => platform.createPlatformLockCrypto();
