import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/domain/model/directive.dart';

void main() {
  group('FormType.steps', () {
    test('combined form includes all 14 steps', () {
      final steps = FormType.combined.steps;
      expect(steps.length, 14);
      expect(steps, contains(WizardStep.agentDesignation));
      expect(steps, contains(WizardStep.alternateAgent));
      expect(steps, contains(WizardStep.agentAuthority));
      expect(steps, contains(WizardStep.execution));
    });

    test('declaration form excludes agent steps', () {
      final steps = FormType.declaration.steps;
      expect(steps, isNot(contains(WizardStep.agentDesignation)));
      expect(steps, isNot(contains(WizardStep.alternateAgent)));
      expect(steps, isNot(contains(WizardStep.agentAuthority)));
    });

    test('declaration form still includes personal info and execution', () {
      final steps = FormType.declaration.steps;
      expect(steps, contains(WizardStep.personalInfo));
      expect(steps, contains(WizardStep.execution));
      expect(steps, contains(WizardStep.review));
    });

    test('poa form includes all steps including agent sections', () {
      final steps = FormType.poa.steps;
      expect(steps, contains(WizardStep.agentDesignation));
      expect(steps, contains(WizardStep.alternateAgent));
      expect(steps, contains(WizardStep.agentAuthority));
    });

    test('combined form has more steps than declaration', () {
      expect(
        FormType.combined.steps.length,
        greaterThan(FormType.declaration.steps.length),
      );
    });

    test('all steps lists start with personalInfo', () {
      for (final formType in FormType.values) {
        expect(formType.steps.first, WizardStep.personalInfo,
            reason: '${formType.name} should start with personalInfo');
      }
    });

    test('all steps lists end with execution', () {
      for (final formType in FormType.values) {
        expect(formType.steps.last, WizardStep.execution,
            reason: '${formType.name} should end with execution');
      }
    });

    test('review step always appears second-to-last', () {
      for (final formType in FormType.values) {
        final steps = formType.steps;
        expect(steps[steps.length - 2], WizardStep.review,
            reason: '${formType.name} should have review second-to-last');
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

  group('WizardStep.displayName', () {
    test('all wizard steps have non-empty display names', () {
      for (final step in WizardStep.values) {
        expect(step.displayName, isNotEmpty,
            reason: '${step.name} should have a displayName');
      }
    });
  });
}
