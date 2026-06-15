import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/app_data/app_data.dart';

/// Guards the AppData layer — the source of truth for the app's dynamic facts
/// (assets/data/app_data.json). Locks the parse contract and confirms the
/// bundled asset actually loads and wires referral partners to their contacts.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppData.fromJson', () {
    test('parses contacts and links referral partners to contacts', () {
      final data = AppData.fromJson(const {
        'contacts': {
          'pmhca': {
            'name': 'PMHCA',
            'phone': '1-800-887-6422',
            'web': 'https://www.pmhca.org/',
          },
          'nrcPad': {
            'name': 'NRC-PAD',
            'web': 'https://nrc-pad.org/',
          },
        },
        'referralPartners': [
          {'contact': 'pmhca', 'sub': 'Peer support'},
          {'contact': 'nrcPad', 'sub': 'PAD info'},
          {'contact': 'missing', 'sub': 'dropped'},
        ],
      });

      expect(data.contact('pmhca').phone, '1-800-887-6422');
      expect(data.contact('pmhca').web, 'https://www.pmhca.org/');
      // nrcPad has no phone — must stay null (drives "no call button").
      expect(data.contact('nrcPad').phone, isNull);
      // Unknown referral contact key is dropped, not crashed on.
      expect(data.referralPartners.length, 2);
      expect(data.referralPartners.first.contact.name, 'PMHCA');
      expect(data.referralPartners.first.sub, 'Peer support');
    });

    test('missing contact key returns a safe empty entry, never null', () {
      final data = AppData.fromJson(const {'contacts': {}});
      expect(data.contact('nope').name, '');
      expect(data.contact('nope').phone, isNull);
    });
  });

  group('AppData.load (bundled asset)', () {
    test('loads assets/data/app_data.json with the expected contacts', () async {
      final data = await AppData.load();
      // Core crisis + advocacy contacts must be present and well-formed.
      expect(data.contact('crisis988').phone, '988');
      expect(data.contact('paProtectionAdvocacy').phone, '1-800-692-7443');
      expect(data.contact('paProtectionAdvocacy').tdd, '1-877-375-7139');
      expect(data.contact('pmhca').phone, '1-800-887-6422');
      expect(data.contact('mhapa').phone, '1-866-578-3659');
      // The facilitator referral list is data-driven (4 partners).
      expect(data.referralPartners.length, 4);
      // Every partner resolves to a real named contact.
      for (final p in data.referralPartners) {
        expect(p.contact.name, isNotEmpty);
      }
      // Singleton is published after load.
      expect(appData.contact('crisis988').phone, '988');
    });

    test('loads the AI config and privacy URL', () async {
      final data = await AppData.load();
      expect(data.ai.model, 'gemini-2.5-flash');
      expect(data.ai.maxContextTokens, 1048576);
      expect(data.ai.rpm, 10);
      expect(data.ai.rpd, 250);
      expect(data.ai.tpm, 250000);
      expect(data.privacyPolicyUrl, startsWith('https://'));
    });
  });

  group('AiConfig.fromJson', () {
    test('falls back to sane defaults when fields are missing', () {
      final ai = AiConfig.fromJson(const {});
      expect(ai.model, 'gemini-2.5-flash');
      expect(ai.maxContextTokens, 1048576);
      expect(ai.rpm, 10);
      expect(ai.rpd, 250);
    });
  });
}
