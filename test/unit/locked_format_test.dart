import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/locked_progress/lock_crypto.dart';
import 'package:mhad/services/locked_progress/locked_format.dart';

/// Known-answer vector computed with Web Crypto (PBKDF2-HMAC-SHA-256 →
/// AES-256-GCM) — the same numbers test/web/lock_crypto_web_test.dart checks
/// in Chrome, so the pure-Dart and browser implementations stay identical.
const webCryptoVector = (
  passphrase: 'Blue horse ñ!',
  iterations: 1000,
  salt: '000102030405060708090a0b0c0d0e0f',
  nonce: 'a0a1a2a3a4a5a6a7a8a9aaab',
  aad: '{"format":"pa-mhad-locked","v":1}',
  plaintext: 'locked progress test vector',
  sealed: '3f91f7bae6e900df13e652aa366425b2f36360b1f4e3328d88b3ebc6a03844e0'
      'bbfd694c0618530fb5eb2e',
);

Uint8List unhex(String h) => Uint8List.fromList([
      for (var i = 0; i < h.length; i += 2)
        int.parse(h.substring(i, i + 2), radix: 16)
    ]);

String hex(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();

void main() {
  final crypto = createLockCrypto();
  // Low rounds keep the tests fast; each header carries its own rounds.
  Future<LockSession> session(String p) =>
      LockSession.create(crypto, p, iterations: 1000);

  test('matches the Web Crypto known-answer vector', () async {
    const v = webCryptoVector;
    final key = await crypto.deriveKey(v.passphrase, unhex(v.salt), v.iterations);
    final sealed = await crypto.seal(key, unhex(v.nonce),
        Uint8List.fromList(utf8.encode(v.plaintext)),
        Uint8List.fromList(utf8.encode(v.aad)));
    expect(hex(sealed), v.sealed);
    final opened = await crypto.open(key, unhex(v.nonce), unhex(v.sealed),
        Uint8List.fromList(utf8.encode(v.aad)));
    expect(utf8.decode(opened), v.plaintext);
  });

  test('a locked copy opens with its passphrase and keeps the payload', () async {
    final s = await session('Blue horse tea!');
    final payload = {
      'directives': [
        {'fullName': 'Ana Núñez', 'meds': ['lithium']}
      ],
      'n': 3,
    };
    final expires = DateTime.utc(2026, 11, 18, 21, 30);
    final blob = await sealPayload(crypto, s, payload,
        kind: LockedKind.copy, expires: expires);
    final text = blob.encode();
    expect(text, isNot(contains('Ana')), reason: 'nothing readable');

    final parsed = LockedBlob.tryParse(text)!;
    expect(parsed.header.kind, LockedKind.copy);
    expect(parsed.header.expires, expires);
    expect(parsed.header.iterations, 1000);
    final again = await LockSession.forHeader(crypto, 'Blue horse tea!', parsed.header);
    expect(await openPayload(crypto, again, parsed), payload);
  });

  test('a wrong passphrase fails cleanly', () async {
    final blob = await sealPayload(crypto, await session('Blue horse tea!'),
        {'x': 1}, kind: LockedKind.file);
    final wrong = await LockSession.forHeader(crypto, 'Blue horse tea', blob.header);
    expect(() => openPayload(crypto, wrong, blob),
        throwsA(isA<LockOpenException>()));
  });

  test('editing the readable label (pushing the expiry back) breaks the copy',
      () async {
    final s = await session('Blue horse tea!');
    final blob = await sealPayload(crypto, s, {'x': 1},
        kind: LockedKind.copy, expires: DateTime.utc(2026, 11, 18, 21));
    final j = jsonDecode(blob.encode()) as Map<String, dynamic>;
    j['expires'] = DateTime.utc(2030).millisecondsSinceEpoch;
    final tampered = LockedBlob.tryParse(jsonEncode(j))!;
    expect(tampered.header.expires, DateTime.utc(2030));
    expect(() => openPayload(crypto, s, tampered),
        throwsA(isA<LockOpenException>()));
  });

  test('a changed data byte breaks the copy', () async {
    final s = await session('Blue horse tea!');
    final blob = await sealPayload(crypto, s, {'x': 1}, kind: LockedKind.file);
    final bad = Uint8List.fromList(blob.sealed)..[3] ^= 1;
    expect(() => openPayload(crypto, s, LockedBlob(blob.header, bad)),
        throwsA(isA<LockOpenException>()));
  });

  test('each save uses a fresh nonce; the salt stays with the session', () async {
    final s = await session('Blue horse tea!');
    final a = await sealPayload(crypto, s, {'x': 1}, kind: LockedKind.file);
    final b = await sealPayload(crypto, s, {'x': 1}, kind: LockedKind.file);
    expect(hex(a.header.nonce), isNot(hex(b.header.nonce)));
    expect(hex(a.header.salt), hex(b.header.salt));
    expect(a.header.salt, hasLength(16));
    expect(a.header.nonce, hasLength(12));
  });

  test('the label is read the same whatever the key order on disk', () async {
    final s = await session('Blue horse tea!');
    final blob = await sealPayload(crypto, s, {'x': 1},
        kind: LockedKind.copy, expires: DateTime.utc(2026, 11, 18, 21));
    final j = jsonDecode(blob.encode()) as Map<String, dynamic>;
    final reordered = {
      for (final k in j.keys.toList().reversed) k: j[k],
    };
    final parsed = LockedBlob.tryParse(jsonEncode(reordered))!;
    expect(await openPayload(crypto, s, parsed), {'x': 1});
  });

  test('other text is not mistaken for a locked copy', () {
    expect(LockedBlob.tryParse('{"fullName":"Ana"}'), isNull); // old plain file
    expect(LockedBlob.tryParse('not json'), isNull);
    expect(
        LockedBlob.tryParse(jsonEncode({
          'format': kLockedFormat,
          'v': kLockedFormatVersion + 1, // a newer format
          'data': '',
        })),
        isNull);
  });

  test('the real setting is 600,000 rounds', () {
    expect(kLockIterations, 600000);
  });
}
