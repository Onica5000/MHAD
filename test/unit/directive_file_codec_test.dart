import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/directive_file_codec.dart';

void main() {
  const sampleJson = '{"version":3,"directive":{"fullName":"Test Pérson 🙂",'
      '"formType":"combined","instructions":"No haloperidol — see notes."}}';

  group('plaintext form', () {
    test('round-trips and is not detected as encrypted', () {
      final bytes = DirectiveFileCodec.encode(sampleJson, encrypted: false);
      expect(DirectiveFileCodec.isEncrypted(bytes), isFalse);
      expect(DirectiveFileCodec.decode(bytes), sampleJson);
    });

    test('non-JSON plaintext throws DirectiveFileException', () {
      final bytes = Uint8List.fromList(utf8.encode('just some text'));
      expect(() => DirectiveFileCodec.decode(bytes),
          throwsA(isA<DirectiveFileException>()));
    });
  });

  group('obfuscated (MHAD1) container', () {
    test('round-trips, including non-ASCII content', () {
      final bytes = DirectiveFileCodec.encode(sampleJson, encrypted: true);
      expect(DirectiveFileCodec.isEncrypted(bytes), isTrue);
      expect(DirectiveFileCodec.decode(bytes), sampleJson);
    });

    test('container layout: magic MHAD1 + version 1 + 16-byte IV', () {
      final bytes = DirectiveFileCodec.encode(sampleJson, encrypted: true);
      expect(utf8.decode(bytes.sublist(0, 5)), 'MHAD1');
      expect(bytes[5], 1, reason: 'container version byte');
      expect(bytes.length, greaterThan(22),
          reason: 'must contain IV + at least one ciphertext block');
    });

    test('payload is actually unreadable (no plaintext leaks into the file)',
        () {
      final bytes = DirectiveFileCodec.encode(sampleJson, encrypted: true);
      final asLatin1 = String.fromCharCodes(bytes);
      expect(asLatin1.contains('fullName'), isFalse);
      expect(asLatin1.contains('haloperidol'), isFalse);
    });

    test('fresh IV per encode: same JSON gives different bytes, both decode',
        () {
      final a = DirectiveFileCodec.encode(sampleJson, encrypted: true);
      final b = DirectiveFileCodec.encode(sampleJson, encrypted: true);
      expect(a, isNot(equals(b)), reason: 'IV must be random per export');
      expect(DirectiveFileCodec.decode(a), sampleJson);
      expect(DirectiveFileCodec.decode(b), sampleJson);
    });

    test('tampered IV is rejected (corrupts the gzip header deterministically)',
        () {
      final bytes = DirectiveFileCodec.encode(sampleJson, encrypted: true);
      // Flipping an IV byte corrupts the FIRST plaintext block — the gzip
      // magic — so decode must fail every time (unlike a padding-byte flip,
      // which unauthenticated CBC only catches probabilistically).
      final tampered = Uint8List.fromList(bytes);
      tampered[6] ^= 0xFF; // first IV byte
      expect(() => DirectiveFileCodec.decode(tampered),
          throwsA(isA<DirectiveFileException>()));
    });

    test('tampered ciphertext is rejected', () {
      final bytes = DirectiveFileCodec.encode(sampleJson, encrypted: true);
      final tampered = Uint8List.fromList(bytes);
      tampered[22] ^= 0xFF; // first ciphertext byte → gzip header garbage
      expect(() => DirectiveFileCodec.decode(tampered),
          throwsA(isA<DirectiveFileException>()));
    });

    test('truncated container is rejected', () {
      final bytes = DirectiveFileCodec.encode(sampleJson, encrypted: true);
      final truncated = Uint8List.fromList(bytes.sublist(0, 20));
      expect(() => DirectiveFileCodec.decode(truncated),
          throwsA(isA<DirectiveFileException>()));
    });

    test('magic prefix alone (no body) is rejected, not crashed on', () {
      final bytes = Uint8List.fromList(utf8.encode('MHAD1'));
      expect(DirectiveFileCodec.isEncrypted(bytes), isTrue);
      expect(() => DirectiveFileCodec.decode(bytes),
          throwsA(isA<DirectiveFileException>()));
    });
  });

  test('isEncrypted is false for short and JSON inputs', () {
    expect(DirectiveFileCodec.isEncrypted(Uint8List(0)), isFalse);
    expect(DirectiveFileCodec.isEncrypted(Uint8List.fromList([0x4D])), isFalse);
    expect(
        DirectiveFileCodec.isEncrypted(
            Uint8List.fromList(utf8.encode(sampleJson))),
        isFalse);
  });
}
