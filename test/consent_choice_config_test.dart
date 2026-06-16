import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/ui/wizard/steps/consent_choice_step.dart';

/// Guards the most dangerous failure mode of the EctStep/ExperimentalStudiesStep/
/// DrugTrialsStep → [ConsentChoiceStep] merge: a mis-wired config that writes a
/// consent value to the WRONG preference column (or reads from it), silently
/// corrupting a clinically meaningful field. Each config's read/write callback
/// must touch ONLY its own column.
void main() {
  group('ConsentChoiceConfig column wiring', () {
    test('ect.write sets only ectConsent', () {
      final c = ConsentChoiceConfig.ect.write(7, 'yes');
      expect(c.directiveId.value, 7);
      expect(c.ectConsent.value, 'yes');
      expect(c.experimentalConsent.present, isFalse);
      expect(c.drugTrialConsent.present, isFalse);
    });

    test('experimental.write sets only experimentalConsent', () {
      final c = ConsentChoiceConfig.experimental.write(7, 'yes');
      expect(c.directiveId.value, 7);
      expect(c.experimentalConsent.value, 'yes');
      expect(c.ectConsent.present, isFalse);
      expect(c.drugTrialConsent.present, isFalse);
    });

    test('drugTrials.write sets only drugTrialConsent', () {
      final c = ConsentChoiceConfig.drugTrials.write(7, 'yes');
      expect(c.directiveId.value, 7);
      expect(c.drugTrialConsent.value, 'yes');
      expect(c.ectConsent.present, isFalse);
      expect(c.experimentalConsent.present, isFalse);
    });

    test('configs carry distinct copy/stepIds', () {
      final ids = {
        ConsentChoiceConfig.ect.stepId,
        ConsentChoiceConfig.experimental.stepId,
        ConsentChoiceConfig.drugTrials.stepId,
      };
      expect(ids, {'ect', 'experimentalStudies', 'drugTrials'});
    });
  });
}
