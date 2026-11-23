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

    test('declaration form excludes peopleITrust but keeps the guardian part',
        () {
      final steps = FormType.declaration.steps;
      expect(steps, isNot(contains(WizardStep.peopleITrust)));
      // The official Declaration has "E. Preference as to a court-appointed
      // guardian" (20 Pa.C.S. § 5823 form), so the person can fill it in.
      expect(steps, contains(WizardStep.guardianNomination));
      // 11 - 1 (peopleITrust) = 10
      expect(steps.length, 10);
    });

    test('declaration form still includes about you and review & sign', () {
      final steps = FormType.declaration.steps;
      expect(steps, contains(WizardStep.aboutYou));
      expect(steps, contains(WizardStep.reviewAndSign));
    });

    test('poa form keeps agents + guardian, drops clinical steps + free-form',
        () {
      final steps = FormType.poa.steps;
      expect(steps, contains(WizardStep.peopleITrust));
      expect(steps, contains(WizardStep.guardianNomination));
      // POA is purely about appointing the agent — it drops "Anything else"
      // (only Declaration + Combined carry the free-form step).
      expect(steps, isNot(contains(WizardStep.anythingElse)));
      // POA drops the five preference-only clinical steps.
      expect(steps, isNot(contains(WizardStep.whereIWantCare)));
      expect(steps, isNot(contains(WizardStep.diagnoses)));
      expect(steps, isNot(contains(WizardStep.medications)));
      expect(steps, isNot(contains(WizardStep.allergies)));
      // The official POA form asks whether the agent may consent to ECT,
      // experimental studies and drug trials (part D.3-5).
      expect(steps, contains(WizardStep.proceduresResearch));
      // aboutYou, whenItKicksIn, peopleITrust, guardian, procedures, review
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
