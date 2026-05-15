import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/domain/model/directive.dart';

void main() {
  group('FormType.steps (9-step redesign)', () {
    test('combined form includes all 9 steps', () {
      final steps = FormType.combined.steps;
      expect(steps.length, 9);
      expect(steps, contains(WizardStep.peopleITrust));
      expect(steps, contains(WizardStep.guardianNomination));
      expect(steps, contains(WizardStep.reviewAndSign));
    });

    test('declaration form excludes peopleITrust', () {
      final steps = FormType.declaration.steps;
      expect(steps, isNot(contains(WizardStep.peopleITrust)));
      expect(steps.length, 8);
    });

    test('declaration form still includes about you and review & sign', () {
      final steps = FormType.declaration.steps;
      expect(steps, contains(WizardStep.aboutYou));
      expect(steps, contains(WizardStep.reviewAndSign));
    });

    test('poa form includes peopleITrust', () {
      final steps = FormType.poa.steps;
      expect(steps, contains(WizardStep.peopleITrust));
      expect(steps.length, 9);
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
