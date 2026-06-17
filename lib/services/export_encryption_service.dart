import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// Password-protects a text export with AES-256-CBC. The key is derived from
/// the user's passphrase with PBKDF2-HMAC-SHA256 (random per-export salt), so
/// the same passphrase never yields the same key twice. Output is a small,
/// self-describing JSON envelope that [decryptEnvelope] can reverse in-app.
///
/// Why not a password-protected PDF? The `pdf` package cannot produce encrypted
/// PDFs (GAP_ANALYSIS_V4 M8). This protects the *data* export instead and keeps
/// the open path inside the app, so a recipient never needs an external tool —
/// they only need the passphrase, shared separately from the file.
class ExportEncryptionService {
  ExportEncryptionService._();

  static const _format = 'MHAD-ENC-v1';
  static const _iterations = 120000;

  /// Encrypts [plaintext] with [passphrase], returning a JSON envelope string.
  static String encryptToEnvelope(String plaintext, String passphrase) {
    final rnd = Random.secure();
    final salt =
        Uint8List.fromList(List<int>.generate(16, (_) => rnd.nextInt(256)));
    final ivBytes =
        Uint8List.fromList(List<int>.generate(16, (_) => rnd.nextInt(256)));

    // 64-byte derived key: first 32 = AES key, next 32 = HMAC (auth) key.
    // PBKDF2 block 1 is identical whether dkLen is 32 or 64, so the AES key is
    // unchanged from the original v1 envelopes (they still decrypt).
    final dk = _pbkdf2(utf8.encode(passphrase), salt, _iterations, 64);
    final aesKey = Uint8List.sublistView(dk, 0, 32);
    final macKey = Uint8List.sublistView(dk, 32, 64);

    final encrypter =
        enc.Encrypter(enc.AES(enc.Key(aesKey), mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: enc.IV(ivBytes));

    // Encrypt-then-MAC: authenticate salt‖iv‖ciphertext so a wrong passphrase
    // (or any tampering) is detected deterministically, instead of relying on
    // PKCS7 unpadding to happen to fail (which it only does ~99.6% of the time
    // — the source of a flaky "wrong passphrase" failure).
    final mac =
        _hmac(macKey, [...salt, ...ivBytes, ...encrypted.bytes]);

    return const JsonEncoder.withIndent('  ').convert({
      'fmt': _format,
      'kdf': 'pbkdf2-hmac-sha256',
      'iter': _iterations,
      'cipher': 'aes-256-cbc',
      'mac': 'hmac-sha256-encrypt-then-mac',
      'salt': base64Encode(salt),
      'iv': base64Encode(ivBytes),
      'ct': encrypted.base64,
      'tag': base64Encode(mac),
    });
  }

  /// Reverses [encryptToEnvelope]. Throws [FormatException] if the envelope is
  /// malformed and [ExportDecryptException] if the passphrase is wrong.
  static String decryptEnvelope(String envelope, String passphrase) {
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(envelope) as Map<String, dynamic>;
    } catch (_) {
      throw const FormatException('Not a valid encrypted export.');
    }
    if (json['fmt'] != _format) {
      throw const FormatException('Unrecognized export format.');
    }
    final salt = base64Decode(json['salt'] as String);
    final ivBytes = base64Decode(json['iv'] as String);
    final iter = (json['iter'] as num?)?.toInt() ?? _iterations;
    final ctBytes = base64Decode(json['ct'] as String);

    final dk = _pbkdf2(utf8.encode(passphrase), salt, iter, 64);
    final aesKey = Uint8List.sublistView(dk, 0, 32);
    final macKey = Uint8List.sublistView(dk, 32, 64);

    // If the envelope carries an auth tag (new format), verify it FIRST: a
    // wrong passphrase yields a wrong MAC key → mismatch → wrong-passphrase,
    // deterministically. Legacy envelopes without a tag fall back to the
    // PKCS7-unpad heuristic below.
    final tag = json['tag'];
    if (tag is String) {
      final expected = _hmac(macKey, [...salt, ...ivBytes, ...ctBytes]);
      if (!_constantTimeEquals(expected, base64Decode(tag))) {
        throw const ExportDecryptException();
      }
    }

    final encrypter =
        enc.Encrypter(enc.AES(enc.Key(aesKey), mode: enc.AESMode.cbc));
    try {
      return encrypter.decrypt(
        enc.Encrypted(ctBytes),
        iv: enc.IV(ivBytes),
      );
    } catch (_) {
      // Wrong key → PKCS7 unpad fails (or garbage). Treat as wrong passphrase.
      throw const ExportDecryptException();
    }
  }

  /// HMAC-SHA256 of [data] under [key].
  static Uint8List _hmac(List<int> key, List<int> data) =>
      Uint8List.fromList(Hmac(sha256, key).convert(data).bytes);

  /// Length-and-content equality in (close to) constant time — avoids leaking
  /// where two MACs first differ via early-exit timing.
  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }

  /// PBKDF2-HMAC-SHA256 using only the `crypto` package.
  static Uint8List _pbkdf2(
      List<int> password, List<int> salt, int iterations, int dkLen) {
    final hmac = Hmac(sha256, password);
    final numBlocks = (dkLen / 32).ceil();
    final dk = <int>[];
    for (var block = 1; block <= numBlocks; block++) {
      final blockIndex = Uint8List(4)
        ..buffer.asByteData().setUint32(0, block, Endian.big);
      var u = hmac.convert([...salt, ...blockIndex]).bytes;
      final t = List<int>.from(u);
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        for (var j = 0; j < t.length; j++) {
          t[j] ^= u[j];
        }
      }
      dk.addAll(t);
    }
    return Uint8List.fromList(dk.sublist(0, dkLen));
  }
}

/// Thrown by [ExportEncryptionService.decryptEnvelope] when the passphrase is
/// wrong (decryption produced invalid padding).
class ExportDecryptException implements Exception {
  const ExportDecryptException();
  @override
  String toString() => 'Wrong passphrase, or the export is corrupted.';
}
