import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ai/smart_fill_service.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/services/clinical_data_service.dart';

/// Pins the smart-fill prompt contract: consent decisions are always sent,
/// described as BINDING, and free-text wizard fields are PII-stripped before
/// they reach the prompt. No network involved — [SmartFillService.buildPrompt]
/// is exercised directly.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SmartFillService service;

  setUpAll(() async {
    await AppData.load(); // buildPrompt reads appData.config / appData.legal
    service = SmartFillService(apiKey: 'test-key', model: 'test-model');
  });

  tearDownAll(() => service.dispose());

  group('describeConsent', () {
    test('maps each stored value to binding language', () {
      expect(SmartFillService.describeConsent(consentYes),
          'YES — user consents');
      expect(SmartFillService.describeConsent(consentNo),
          contains('hard no, do NOT suggest otherwise'));
      expect(SmartFillService.describeConsent(consentAgentDecides),
          contains('AGENT DECIDES'));
      expect(
        SmartFillService.describeConsent('${consentConditionalPrefix}only '
            'with my agent present'),
        'CONDITIONAL — user consents only if: only with my agent present',
      );
    });

    test('passes through an unrecognized value unchanged', () {
      expect(SmartFillService.describeConsent('something-else'),
          'something-else');
    });
  });

  group('buildPrompt', () {
    SmartFillInput input({
      String formType = 'combined',
      String ectConsent = consentNo,
      String healthHistory = '',
    }) =>
        SmartFillInput(
          conditions: const [IcdCondition(code: 'F31.9', name: 'Bipolar')],
          currentMedications: const ['Lamotrigine'],
          medicationsToAvoid: const ['Haloperidol'],
          formType: formType,
          existingEctConsent: ectConsent,
          existingHealthHistory: healthHistory,
        );

    test('always includes the BINDING consent block with all four consents',
        () {
      final prompt = service.buildPrompt(input());
      expect(prompt,
          contains('=== CONSENT DECISIONS (BINDING — do NOT contradict) ==='));
      expect(prompt, contains('Medication consent:'));
      expect(prompt, contains('ECT consent: NO — user refuses'));
      expect(prompt, contains('Experimental studies consent:'));
      expect(prompt, contains('Drug trial consent:'));
      expect(prompt, contains('=== END CONSENT DECISIONS ==='));
    });

    test('a conditional consent carries its restriction into the prompt', () {
      final prompt = service.buildPrompt(input(
          ectConsent: '${consentConditionalPrefix}only after two opinions'));
      expect(prompt,
          contains('CONDITIONAL — user consents only if: only after two'));
    });

    test('agent-authority lines appear for combined/poa but not declaration',
        () {
      final combined = service.buildPrompt(input(formType: 'combined'));
      expect(combined, contains('Agent consent to hospitalization:'));
      expect(combined, contains('"agent_guidance"'));

      final declaration = service.buildPrompt(input(formType: 'declaration'));
      expect(declaration, isNot(contains('Agent consent to hospitalization:')));
      expect(declaration, isNot(contains('"agent_guidance"')),
          reason: 'a declaration has no agent, so the agent field must be '
              'omitted from the requested JSON');
    });

    test('clinical inputs are carried through', () {
      final prompt = service.buildPrompt(input());
      expect(prompt, contains('F31.9 Bipolar'));
      expect(prompt, contains('Current meds: Lamotrigine'));
      expect(prompt, contains('Avoid meds: Haloperidol'));
    });

    test('free-text wizard fields are PII-stripped before entering the prompt',
        () {
      final prompt = service.buildPrompt(input(
          healthHistory: 'Hospitalized 2021. Contact Dr. Reyes at '
              '555-867-5309 or reyes@example.com.'));
      expect(prompt, contains('Health history:'));
      expect(prompt, isNot(contains('555-867-5309')),
          reason: 'phone numbers must never reach the AI prompt');
      expect(prompt, isNot(contains('reyes@example.com')),
          reason: 'email addresses must never reach the AI prompt');
    });

    test('medication list entries are PII-stripped too', () {
      final prompt = service.buildPrompt(SmartFillInput(
        conditions: const [IcdCondition(code: 'F31.9', name: 'Bipolar')],
        currentMedications: const [
          'Lamotrigine',
          'call me at 555-867-5309', // junk a user could type in a med field
        ],
        medicationsToAvoid: const ['haldol reyes@example.com'],
        formType: 'combined',
      ));
      expect(prompt, contains('Lamotrigine'));
      expect(prompt, isNot(contains('555-867-5309')),
          reason: 'med-list entries must pass the PII chokepoint');
      expect(prompt, isNot(contains('reyes@example.com')));
    });
  });

  group('SmartFillInput.sanitized', () {
    test('coerces an unknown form type to combined', () {
      final out = SmartFillInput(
        conditions: const [],
        currentMedications: const [],
        medicationsToAvoid: const [],
        formType: 'exploit',
      ).sanitized();
      expect(out.formType, 'combined');
    });

    test('clamps list lengths and field length to the configured caps', () {
      final many = List.generate(200, (i) => 'Med$i');
      final out = SmartFillInput(
        conditions: const [],
        currentMedications: many,
        medicationsToAvoid: const [],
        formType: 'poa',
        existingHealthHistory: 'x' * 100000,
      ).sanitized();
      expect(out.currentMedications.length,
          lessThanOrEqualTo(SmartFillInput.maxMedsPerCategory));
      expect(out.existingHealthHistory.length,
          lessThanOrEqualTo(SmartFillInput.maxFieldLength));
    });
  });
}
