import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

/// Encodes/decodes the portable directive file.
///
/// Two forms, the user's choice on export:
/// - **plaintext** — UTF-8 JSON (readable; for users who don't want encryption).
/// - **obfuscated** — `gzip(JSON)` → AES-256-CBC with an **app-embedded key** →
///   a small app-specific binary container (magic `MHAD1` + version + IV + ct).
///
/// Per the product decision this is **obfuscation, not confidentiality**: the
/// key ships in the (public, client-side) app, so a determined person could
/// extract it. It "hinders anyone from reading" the file — which is the bar —
/// and the web app can decrypt it with no passphrase. (Tamper-evidence comes
/// from the JSON-structure check on decode; AES-GCM's auth tag wasn't needed
/// for an obfuscation file.) For real confidentiality a user passphrase would
/// be required — deliberately not used here.
class DirectiveFileCodec {
  DirectiveFileCodec._();

  /// File magic: "MHAD1". Encrypted files start with this; plaintext (JSON)
  /// files start with '{', so decode auto-detects.
  static const List<int> _magic = [0x4D, 0x48, 0x41, 0x44, 0x31];
  static const int _version = 1;

  /// App-embedded 256-bit key (obfuscation). Derived from a fixed string so the
  /// key bytes are stable across builds and platforms.
  static final enc.Key _appKey = enc.Key(Uint8List.fromList(
      sha256.convert(utf8.encode('mhad.directive.obfuscation.key.v1')).bytes));

  /// Encode [json] to file bytes. [encrypted] = false → plaintext UTF-8.
  static Uint8List encode(String json, {required bool encrypted}) {
    if (!encrypted) return Uint8List.fromList(utf8.encode(json));

    final gz = GZipEncoder().encode(utf8.encode(json));
    final rnd = Random.secure();
    final iv = enc.IV(
        Uint8List.fromList(List<int>.generate(16, (_) => rnd.nextInt(256))));
    final encrypter =
        enc.Encrypter(enc.AES(_appKey, mode: enc.AESMode.cbc));
    final ct = encrypter.encryptBytes(gz, iv: iv).bytes;

    final out = BytesBuilder();
    out.add(_magic);
    out.addByte(_version);
    out.add(iv.bytes);
    out.add(ct);
    return out.toBytes();
  }

  /// Whether [bytes] is an obfuscated MHAD container (vs plaintext JSON).
  static bool isEncrypted(Uint8List bytes) {
    if (bytes.length < _magic.length) return false;
    for (var i = 0; i < _magic.length; i++) {
      if (bytes[i] != _magic[i]) return false;
    }
    return true;
  }

  /// Decode file [bytes] back to the JSON string, auto-detecting encrypted vs
  /// plaintext. Throws [DirectiveFileException] on any failure.
  static String decode(Uint8List bytes) {
    if (isEncrypted(bytes)) {
      try {
        // [magic(5)][version(1)][iv(16)][ciphertext...]
        final iv = enc.IV(Uint8List.fromList(bytes.sublist(6, 22)));
        final ct = Uint8List.fromList(bytes.sublist(22));
        final encrypter =
            enc.Encrypter(enc.AES(_appKey, mode: enc.AESMode.cbc));
        final gz = encrypter.decryptBytes(enc.Encrypted(ct), iv: iv);
        final json = utf8.decode(GZipDecoder().decodeBytes(gz));
        jsonDecode(json); // structure check (tamper-evidence)
        return json;
      } catch (_) {
        throw const DirectiveFileException(
            'Could not read the file — it is corrupted or not an MHAD directive file.');
      }
    }
    try {
      final json = utf8.decode(bytes);
      jsonDecode(json);
      return json;
    } catch (_) {
      throw const DirectiveFileException(
          'This file is not a recognized directive file.');
    }
  }
}

class DirectiveFileException implements Exception {
  final String message;
  const DirectiveFileException(this.message);
  @override
  String toString() => message;
}
