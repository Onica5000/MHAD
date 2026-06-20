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
      expect(data.ai.model, 'gemini-3.5-flash');
      expect(data.ai.maxContextTokens, 1048576);
      expect(data.ai.rpm, 15);
      expect(data.ai.rpd, 1500);
      expect(data.ai.tpm, 1000000);
      expect(data.privacyPolicyUrl, startsWith('https://'));
    });
  });

  group('AiConfig.fromJson', () {
    test('falls back to sane defaults when fields are missing', () {
      final ai = AiConfig.fromJson(const {});
      expect(ai.model, 'gemini-3.5-flash');
      expect(ai.maxContextTokens, 1048576);
      expect(ai.rpm, 15);
      expect(ai.rpd, 1500);
    });
  });

  group('LegalFacts (verify tier)', () {
    test('bundled asset carries the canonical legal facts', () async {
      final data = await AppData.load();
      final l = data.legal;
      expect(l.validityYears, 2);
      expect(l.witnessMinAge, 18);
      expect(l.ntiDrugs, contains('lithium'));
      expect(l.ntiDrugs, contains('valproic acid'));
      expect(l.involuntaryCommitment['section302Hours'], 120);
      expect(l.involuntaryCommitment['section304Days'], 90);
      expect(l.citations['providerMustComply'], '20 Pa.C.S. §5842');
      // The prose-location manifest the Phase-4 admin flow uses for verify-tier
      // edits must point at the real source files.
      expect(l.proseLocations, contains('lib/data/educational_content.dart'));
    });

    test('defaults are sane when the block is absent', () {
      final l = LegalFacts.fromJson(const {});
      expect(l.validityYears, 2);
      expect(l.witnessMinAge, 18);
      expect(l.ntiDrugs, isEmpty);
      expect(l.citations, isEmpty);
    });
  });

  group('AppConfig (auto tier — backend knobs)', () {
    test('bundled asset carries the config knobs', () async {
      final data = await AppData.load();
      final c = data.config;
      expect(c.chatTimeoutSeconds, 30);
      expect(c.documentExtractionTimeoutSeconds, 60);
      expect(c.retryMaxAttempts, 3);
      expect(c.retryBackoffsMs, [0, 500, 2000]);
      expect(c.renewalWindowDays, 28);
      expect(c.checkInWindowDays, 90);
      expect(c.sessionCacheMinutes, 10);
      expect(c.clinicalMaxRequestsPerSecond, 20);
      expect(c.maxImageDimension, 1024);
      expect(c.maxUploadBytes, 10485760);
      // Duration helpers compose correctly.
      expect(c.chatTimeout, const Duration(seconds: 30));
      expect(c.sessionCacheTtl, const Duration(minutes: 10));
      expect(c.retryBackoffs.last, const Duration(seconds: 2));
    });

    test('defaults mirror the old code constants when the block is absent', () {
      final c = AppConfig.fromJson(const {});
      expect(c.chatTimeoutSeconds, 30);
      expect(c.smartFillTimeoutSeconds, 45);
      expect(c.renewalCooldownDays, 7);
      expect(c.maxChatMessages, 100);
      expect(c.textFieldMaxChars, 2000);
      expect(c.medicationNoteMaxChars, 500);
    });
  });

  group('dated + facts blocks', () {
    test('bundled asset carries dated/version + facts copy', () async {
      final data = await AppData.load();
      expect(data.dateFact('privacyPolicyVersion'), 'v1.1');
      expect(data.dateFact('privacyPolicyUpdated'), 'May 2026');
      expect(data.fact('facilitatorCompletionStat'), contains('Swanson'));
      expect(data.geminiApiKeyUrl, startsWith('https://'));
    });
  });
}
