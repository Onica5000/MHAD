@TestOn('browser')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/locked_progress/lock_crypto.dart';
import 'package:mhad/services/locked_progress/locked_format.dart';

import '../unit/locked_format_test.dart' show webCryptoVector, hex, unhex;

/// The browser's Web Crypto path (what ships). Run with:
///   flutter test --platform chrome test/web/lock_crypto_web_test.dart
void main() {
  final crypto = createLockCrypto();

  test('Web Crypto matches the known-answer vector', () async {
    const v = webCryptoVector;
    final key =
        await crypto.deriveKey(v.passphrase, unhex(v.salt), v.iterations);
    final sealed = await crypto.seal(key, unhex(v.nonce),
        Uint8List.fromList(utf8.encode(v.plaintext)),
        Uint8List.fromList(utf8.encode(v.aad)));
    expect(hex(sealed), v.sealed);
  });

  test('Web Crypto round trip, wrong passphrase and tampering', () async {
    final s = await LockSession.create(crypto, 'Blue horse tea!',
        iterations: 1000);
    final blob = await sealPayload(crypto, s, {'a': 'ñ'},
        kind: LockedKind.copy, expires: DateTime.utc(2026, 11, 18, 21));
    final parsed = LockedBlob.tryParse(blob.encode())!;
    expect(await openPayload(crypto, s, parsed), {'a': 'ñ'});

    final wrong = await LockSession.forHeader(crypto, 'blue horse tea!', parsed.header);
    expect(() => openPayload(crypto, wrong, parsed),
        throwsA(isA<LockOpenException>()));

    final j = jsonDecode(blob.encode()) as Map<String, dynamic>;
    j['expires'] = DateTime.utc(2030).millisecondsSinceEpoch;
    expect(() => openPayload(crypto, s, LockedBlob.tryParse(jsonEncode(j))!),
        throwsA(isA<LockOpenException>()));
  });

  test('600,000 rounds stay quick enough in the browser', () async {
    final sw = Stopwatch()..start();
    await LockSession.create(crypto, 'Blue horse tea!');
    sw.stop();
    // ~0.1 s on a desktop; phones are a few times slower.
    expect(sw.elapsedMilliseconds, lessThan(5000));
    // ignore: avoid_print
    print('PBKDF2 600k in this browser: ${sw.elapsedMilliseconds} ms');
  });
}
