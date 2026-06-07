import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/services/export_encryption_service.dart';

void main() {
  group('ExportEncryptionService', () {
    const plaintext = 'PA MHAD data export\r\nSection,Item,Detail\r\n'
        'Directive,Full name,Jane Q. Public';
    const pass = 'correct horse battery staple';

    test('round-trips encrypt → decrypt with the right passphrase', () {
      final envelope =
          ExportEncryptionService.encryptToEnvelope(plaintext, pass);
      final decrypted =
          ExportEncryptionService.decryptEnvelope(envelope, pass);
      expect(decrypted, plaintext);
    });

    test('envelope does not leak the plaintext', () {
      final envelope =
          ExportEncryptionService.encryptToEnvelope(plaintext, pass);
      expect(envelope.contains('Jane Q. Public'), isFalse);
      expect(envelope.contains('MHAD-ENC-v1'), isTrue);
    });

    test('a different passphrase throws ExportDecryptException', () {
      final envelope =
          ExportEncryptionService.encryptToEnvelope(plaintext, pass);
      expect(
        () => ExportEncryptionService.decryptEnvelope(envelope, 'wrong pass'),
        throwsA(isA<ExportDecryptException>()),
      );
    });

    test('two encryptions of the same input differ (random salt/IV)', () {
      final a = ExportEncryptionService.encryptToEnvelope(plaintext, pass);
      final b = ExportEncryptionService.encryptToEnvelope(plaintext, pass);
      expect(a, isNot(b));
    });

    test('malformed envelope throws FormatException', () {
      expect(
        () => ExportEncryptionService.decryptEnvelope('not json', pass),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
