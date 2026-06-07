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

    final keyBytes = _pbkdf2(
      utf8.encode(passphrase),
      salt,
      _iterations,
      32,
    );
    final encrypter =
        enc.Encrypter(enc.AES(enc.Key(keyBytes), mode: enc.AESMode.cbc));
    final encrypted = encrypter.encrypt(plaintext, iv: enc.IV(ivBytes));

    return const JsonEncoder.withIndent('  ').convert({
      'fmt': _format,
      'kdf': 'pbkdf2-hmac-sha256',
      'iter': _iterations,
      'cipher': 'aes-256-cbc',
      'salt': base64Encode(salt),
      'iv': base64Encode(ivBytes),
      'ct': encrypted.base64,
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

    final keyBytes = _pbkdf2(utf8.encode(passphrase), salt, iter, 32);
    final encrypter =
        enc.Encrypter(enc.AES(enc.Key(keyBytes), mode: enc.AESMode.cbc));
    try {
      return encrypter.decrypt(
        enc.Encrypted.fromBase64(json['ct'] as String),
        iv: enc.IV(ivBytes),
      );
    } catch (_) {
      // Wrong key → PKCS7 unpad fails (or garbage). Treat as wrong passphrase.
      throw const ExportDecryptException();
    }
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
