import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

import 'lock_crypto.dart';

/// [LockCrypto] in pure Dart (pointycastle) — everywhere except the web, where
/// `lock_crypto_web.dart` uses the browser's Web Crypto instead.
LockCrypto createPlatformLockCrypto() => _PointyLockCrypto();

class _BytesKey implements LockKey {
  _BytesKey(this.bytes);
  final Uint8List bytes;
}

class _PointyLockCrypto implements LockCrypto {
  @override
  Future<LockKey> deriveKey(
      String passphrase, Uint8List salt, int iterations) async {
    final kdf = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, iterations, 32));
    return _BytesKey(
        kdf.process(Uint8List.fromList(utf8.encode(passphrase))));
  }

  GCMBlockCipher _gcm(
          bool sealing, LockKey key, Uint8List nonce, Uint8List aad) =>
      GCMBlockCipher(AESEngine())
        ..init(
            sealing,
            AEADParameters(
                KeyParameter((key as _BytesKey).bytes), 128, nonce, aad));

  @override
  Future<Uint8List> seal(LockKey key, Uint8List nonce, Uint8List plaintext,
          Uint8List aad) async =>
      _gcm(true, key, nonce, aad).process(plaintext);

  @override
  Future<Uint8List> open(
      LockKey key, Uint8List nonce, Uint8List sealed, Uint8List aad) async {
    try {
      return _gcm(false, key, nonce, aad).process(sealed);
    } catch (_) {
      throw const LockOpenException();
    }
  }
}
