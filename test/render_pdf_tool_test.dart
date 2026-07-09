import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/export/pdf/pdf_generator.dart';

/// PDF visual-verification harness — writes SIX artifacts to build/_pdfcmp/
/// (filled + blank, for each of the three form types) so they can be
/// rasterised with tool/pdf_compare.py (PyMuPDF) and visually diffed against
/// the pre-refactor baselines and the official form (docs/PA MHAD.pdf).
/// Run with: `flutter test test/render_pdf_tool_test.dart`. The test env
/// falls back to Helvetica (the real app loads the editorial fonts), so this
/// verifies LAYOUT/structure, not the production typeface.
void main() {
  Directive filledDirective(FormType type) => Directive(
        id: 1,
        formType: type.name,
        status: 'complete',
        createdAt: 0,
        updatedAt: 0,
        executionDate: 1739000000000,
        expirationDate: 1802072000000,
        fullName: 'Alex M. Kowalski',
        dateOfBirth: '06/14/1989',
        address: '412 Maple St',
        address2: '',
        city: 'Pittsburgh',
        county: 'Allegheny',
        state: 'PA',
        zip: '15217',
        phone: '412-555-0143',
        effectiveCondition: '',
        triggerTwoProfessionals: true,
        triggerCourtOrder: false,
        triggerInvoluntaryCommitment: true,
        preferredDoctorName: 'Dr. R. Patel',
        preferredDoctorContact: 'UPMC Western · 412-555-0199',
        primaryDoctorName: 'Dr. Lee Howard',
        primaryDoctorSpecialty: 'Family medicine',
        primaryDoctorPhone: '412-555-0120',
        lastStepIndex: 10,
      );

  Directive blankDirective(FormType type) => Directive(
        id: 0,
        formType: type.name,
        status: 'blank',
        createdAt: 0,
        updatedAt: 0,
        fullName: '',
        dateOfBirth: '',
        address: '',
        address2: '',
        city: '',
        county: '',
        state: '',
        zip: '',
        phone: '',
        effectiveCondition: '',
        triggerTwoProfessionals: false,
        triggerCourtOrder: false,
        triggerInvoluntaryCommitment: false,
        preferredDoctorName: '',
        preferredDoctorContact: '',
        primaryDoctorName: '',
        primaryDoctorSpecialty: '',
        primaryDoctorPhone: '',
        lastStepIndex: 0,
      );

  const agents = [
    Agent(
      id: 1,
      directiveId: 1,
      agentType: 'primary',
      fullName: 'Jordan Lee',
      relationship: 'Sister',
      address: '87 Forbes Ave',
      address2: '',
      city: 'Pittsburgh',
      state: 'PA',
      zip: '15213',
      homePhone: '412-555-0188',
      workPhone: '',
      cellPhone: '412-555-0177',
      acceptanceNotes: '',
    ),
    Agent(
      id: 2,
      directiveId: 1,
      agentType: 'alternate',
      fullName: 'Sam Reyes',
      relationship: 'Spouse',
      address: '87 Forbes Ave',
      address2: '',
      city: 'Pittsburgh',
      state: 'PA',
      zip: '15213',
      homePhone: '412-555-0166',
      workPhone: '',
      cellPhone: '',
      acceptanceNotes: '',
    ),
  ];

  const prefs = DirectivePref(
    id: 1,
    directiveId: 1,
    treatmentFacilityPref: 'prefer',
    preferredFacilityName: 'UPMC Western Psychiatric | Pittsburgh, PA',
    avoidFacilityName:
        "St. Margaret's State Hospital | Prior negative experience",
    medicationConsent: 'yes',
    ectConsent: 'agentDecides',
    experimentalConsent: 'no',
    drugTrialConsent: 'agentDecides',
    agentCanConsentHospitalization: true,
    agentCanConsentMedication: true,
    agentAuthorityLimitations: '',
    roomPreferences: 'singleRoom,windowIfPossible,quietFloor,sameGenderRoommate',
    roomPreferencesNote: 'Away from loud areas if possible.',
    roommateGenderMatch: 'women',
    crisisPlanJson: '',
    selfBindingEnabled: false,
    sideEffectsJson: '',
  );

  const additional = AdditionalInstructionsTableData(
    id: 1,
    directiveId: 1,
    activities:
        'Walking and listening to music help. Bright, loud rooms worsen things.',
    crisisIntervention:
        'Speak calmly; give me space; my agent Jordan knows my preferences.',
    healthHistory: 'Bipolar I, diagnosed 2014. Two prior hospitalizations.',
    dietary: 'Vegetarian.',
    religious: 'Access to a chaplain on request.',
    childrenCustody: '',
    familyNotification:
        'Notify my sister Jordan. Do not contact my ex-spouse.',
    recordsDisclosure:
        'Authorized to receive my records: my agent Jordan Lee; Dr. Patel.',
    petCustody: 'My neighbor Casey cares for my cat, Olive.',
    other: '',
  );

  const guardian = GuardianNomination(
    id: 1,
    directiveId: 1,
    nomineeFullName: 'Dana Okafor',
    nomineeAddress: '500 Grant St',
    nomineeAddress2: '',
    nomineeCity: 'Pittsburgh',
    nomineeState: 'PA',
    nomineeZip: '15219',
    nomineePhone: '412-555-0210',
    nomineeRelationship: 'Attorney',
    guardianCanRevoke: false,
    guardianCanChangeAgent: false,
    guardianMustConsultAgent: true,
    guardianCanRevokeNote: '',
    guardianCanChangeAgentNote: '',
    guardianMustConsultAgentNote: 'Only about medication decisions.',
    guardianRelation: 'different',
  );

  const medications = [
    MedicationEntry(
      id: 1,
      directiveId: 1,
      entryType: 'exception',
      medicationName: 'Haloperidol',
      reason: 'Severe dystonic reaction',
      dosage: '',
      sortOrder: 0,
    ),
    MedicationEntry(
      id: 2,
      directiveId: 1,
      entryType: 'preferred',
      medicationName: 'Lithium',
      reason: 'Works well, stable for years',
      dosage: '',
      sortOrder: 1,
    ),
    MedicationEntry(
      id: 3,
      directiveId: 1,
      entryType: 'current',
      medicationName: 'Lamotrigine',
      reason: 'for bipolar disorder',
      dosage: '200 mg twice daily',
      sortOrder: 2,
    ),
  ];

  final witnesses = [
    WitnessesData(
      id: 1,
      directiveId: 1,
      witnessNumber: 1,
      fullName: '',
      address: '',
      address2: '',
      city: '',
      state: '',
      zip: '',
      phone: '',
    ),
    WitnessesData(
      id: 2,
      directiveId: 1,
      witnessNumber: 2,
      fullName: '',
      address: '',
      address2: '',
      city: '',
      state: '',
      zip: '',
      phone: '',
    ),
  ];

  PdfGenerator generatorFor(FormType type) => PdfGenerator(
        includeCombined: type == FormType.combined,
        includeDeclaration: type == FormType.declaration,
        includePoa: type == FormType.poa,
      );

  test('render filled + blank artifacts for all three forms', () async {
    Directory('build/_pdfcmp').createSync(recursive: true);

    for (final type in FormType.values) {
      // Filled — full fixture (declaration renderer ignores agents itself).
      final filled = await generatorFor(type).generate(
        directive: filledDirective(type),
        agents: type == FormType.declaration ? const [] : agents,
        prefs: prefs,
        additional: additional,
        guardian: guardian,
        medications: medications,
        witnesses: witnesses,
        diagnoses: const [],
      );
      final filledPath = 'build/_pdfcmp/filled_${type.name}.pdf';
      File(filledPath).writeAsBytesSync(filled);
      // ignore: avoid_print
      print('WROTE $filledPath (${filled.length} bytes)');
      expect(filled, isNotEmpty);

      // Blank — mirrors blank_form_service: empty directive, no collaborators.
      final blank = await generatorFor(type).generate(
        directive: blankDirective(type),
        agents: const [],
        prefs: null,
        additional: null,
        guardian: null,
        medications: const [],
        witnesses: const [],
        diagnoses: const [],
      );
      final blankPath = 'build/_pdfcmp/blank_${type.name}.pdf';
      File(blankPath).writeAsBytesSync(blank);
      // ignore: avoid_print
      print('WROTE $blankPath (${blank.length} bytes)');
      expect(blank, isNotEmpty);
    }
  });
}
