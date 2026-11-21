import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/ui/export/pdf/pdf_form_sections.dart';

/// The POA form's medication section follows the agent-authority answer
/// ("Agent may consent to medication"). It used to read medicationConsent —
/// which a POA person can never set and which defaults to 'yes' — so a POA
/// PDF always checked "I consent to the medications that my agent agrees to"
/// and could never check "My agent is not authorized…".
void main() {
  DirectivePref prefs({required bool agentMay, String medicationConsent = 'yes'}) =>
      DirectivePref(
        id: 1,
        directiveId: 1,
        treatmentFacilityPref: 'noPreference',
        preferredFacilityName: '',
        avoidFacilityName: '',
        medicationConsent: medicationConsent,
        ectConsent: 'no',
        experimentalConsent: 'no',
        drugTrialConsent: 'no',
        agentCanConsentHospitalization: false,
        agentCanConsentMedication: agentMay,
        agentAuthorityLimitations: '',
        roomPreferences: '',
        roomPreferencesNote: '',
        roommateGenderMatch: '',
        crisisPlanJson: '',
        selfBindingEnabled: false,
        sideEffectsJson: '',
      );

  test('agent may NOT consent → "My agent is not authorized" (even with the yes default)', () {
    final c = poaMedicationChecks(prefs(agentMay: false), hasLists: false);
    expect(c.notAuthorized, isTrue);
    expect(c.consent, isFalse);
    expect(c.consentWithLists, isFalse);
  });

  test('agent may consent → the consent row, or the with-exceptions row when lists exist', () {
    expect(poaMedicationChecks(prefs(agentMay: true), hasLists: false).consent, isTrue);
    final withLists = poaMedicationChecks(prefs(agentMay: true), hasLists: true);
    expect(withLists.consentWithLists, isTrue);
    expect(withLists.consent, isFalse);
    expect(withLists.notAuthorized, isFalse);
  });

  test('medicationConsent no longer decides the POA rows', () {
    final c = poaMedicationChecks(
        prefs(agentMay: true, medicationConsent: 'no'), hasLists: false);
    expect(c.notAuthorized, isFalse);
    expect(c.consent, isTrue);
  });
}
