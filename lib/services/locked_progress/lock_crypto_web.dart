import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'lock_crypto.dart';

/// [LockCrypto] on the browser's Web Crypto (`crypto.subtle`): native code
/// maintained by the browser makers. The derived key is non-extractable — it
/// can seal and open, but no script (this app included) can read it out.
LockCrypto createPlatformLockCrypto() => _WebLockCrypto();

class _WebKey implements LockKey {
  _WebKey(this.key);
  final web.CryptoKey key;
}

/// A plain JS object (`{name: …, …}`) for Web Crypto's algorithm parameters.
JSObject _params(Map<String, JSAny> props) {
  final o = JSObject();
  props.forEach((k, v) => o.setProperty(k.toJS, v));
  return o;
}

class _WebLockCrypto implements LockCrypto {
  web.SubtleCrypto get _subtle => web.window.crypto.subtle;

  @override
  Future<LockKey> deriveKey(
      String passphrase, Uint8List salt, int iterations) async {
    final material = await _subtle
        .importKey(
          'raw',
          Uint8List.fromList(utf8.encode(passphrase)).toJS,
          'PBKDF2'.toJS,
          false,
          ['deriveKey'.toJS].toJS,
        )
        .toDart;
    final key = await _subtle
        .deriveKey(
          _params({
            'name': 'PBKDF2'.toJS,
            'salt': salt.toJS,
            'iterations': iterations.toJS,
            'hash': 'SHA-256'.toJS,
          }),
          material,
          _params({'name': 'AES-GCM'.toJS, 'length': 256.toJS}),
          false, // non-extractable
          ['encrypt'.toJS, 'decrypt'.toJS].toJS,
        )
        .toDart;
    return _WebKey(key! as web.CryptoKey);
  }

  JSObject _gcm(Uint8List nonce, Uint8List aad) => _params({
        'name': 'AES-GCM'.toJS,
        'iv': nonce.toJS,
        'additionalData': aad.toJS,
        'tagLength': 128.toJS,
      });

  @override
  Future<Uint8List> seal(LockKey key, Uint8List nonce, Uint8List plaintext,
      Uint8List aad) async {
    final out = await _subtle
        .encrypt(_gcm(nonce, aad), (key as _WebKey).key, plaintext.toJS)
        .toDart;
    return (out! as JSArrayBuffer).toDart.asUint8List();
  }

  @override
  Future<Uint8List> open(
      LockKey key, Uint8List nonce, Uint8List sealed, Uint8List aad) async {
    final JSAny? out;
    try {
      out = await _subtle
          .decrypt(_gcm(nonce, aad), (key as _WebKey).key, sealed.toJS)
          .toDart;
    } catch (_) {
      throw const LockOpenException();
    }
    return (out! as JSArrayBuffer).toDart.asUint8List();
  }
}
