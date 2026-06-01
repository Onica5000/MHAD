import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/domain/model/directive.dart';

void main() {
  group('FormType.steps (11-step redesign — Phase 3)', () {
    test('combined form includes all 11 steps', () {
      final steps = FormType.combined.steps;
      expect(steps.length, 11);
      expect(steps, contains(WizardStep.peopleITrust));
      expect(steps, contains(WizardStep.guardianNomination));
      expect(steps, contains(WizardStep.diagnoses));
      expect(steps, contains(WizardStep.allergies));
      expect(steps, contains(WizardStep.reviewAndSign));
    });

    test('declaration form excludes peopleITrust + guardianNomination', () {
      final steps = FormType.declaration.steps;
      expect(steps, isNot(contains(WizardStep.peopleITrust)));
      expect(steps, isNot(contains(WizardStep.guardianNomination)));
      // 11 - 2 (peopleITrust, guardianNomination) = 9
      expect(steps.length, 9);
    });

    test('declaration form still includes about you and review & sign', () {
      final steps = FormType.declaration.steps;
      expect(steps, contains(WizardStep.aboutYou));
      expect(steps, contains(WizardStep.reviewAndSign));
    });

    test('poa form keeps agents + guardian + free-form, drops clinical steps',
        () {
      final steps = FormType.poa.steps;
      expect(steps, contains(WizardStep.peopleITrust));
      expect(steps, contains(WizardStep.guardianNomination));
      // POA still includes "Anything else" so the user has a place to write
      // free-form context for the agent.
      expect(steps, contains(WizardStep.anythingElse));
      // POA drops the five preference-only clinical steps.
      expect(steps, isNot(contains(WizardStep.whereIWantCare)));
      expect(steps, isNot(contains(WizardStep.diagnoses)));
      expect(steps, isNot(contains(WizardStep.medications)));
      expect(steps, isNot(contains(WizardStep.allergies)));
      expect(steps, isNot(contains(WizardStep.proceduresResearch)));
      // 11 - 5 = 6
      expect(steps.length, 6);
    });

    test('combined form has more steps than declaration', () {
      expect(
        FormType.combined.steps.length,
        greaterThan(FormType.declaration.steps.length),
      );
    });

    test('all step lists start with aboutYou', () {
      for (final formType in FormType.values) {
        expect(formType.steps.first, WizardStep.aboutYou,
            reason: '${formType.name} should start with aboutYou');
      }
    });

    test('all step lists end with reviewAndSign', () {
      for (final formType in FormType.values) {
        expect(formType.steps.last, WizardStep.reviewAndSign,
            reason: '${formType.name} should end with reviewAndSign');
      }
    });
  });

  group('FormType.hasAgentSections', () {
    test('combined has agent sections', () {
      expect(FormType.combined.hasAgentSections, isTrue);
    });

    test('poa has agent sections', () {
      expect(FormType.poa.hasAgentSections, isTrue);
    });

    test('declaration does not have agent sections', () {
      expect(FormType.declaration.hasAgentSections, isFalse);
    });
  });

  group('WizardStep.displayName + subtitle', () {
    test('all wizard steps have non-empty display names', () {
      for (final step in WizardStep.values) {
        expect(step.displayName, isNotEmpty,
            reason: '${step.name} should have a displayName');
      }
    });

    test('all wizard steps have non-empty subtitles', () {
      for (final step in WizardStep.values) {
        expect(step.subtitle, isNotEmpty,
            reason: '${step.name} should have a subtitle');
      }
    });
  });
}
