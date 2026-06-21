import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/ui/export/pdf/pdf_generator.dart';

/// PDF visual-verification harness — writes a fully-populated Combined PDF to
/// build/_pdfcmp/app_combined.pdf so it can be rasterised (e.g. with PyMuPDF)
/// and visually diffed against the official form (docs/PA MHAD.pdf pages
/// 25-32). Run with: `flutter test test/render_pdf_tool_test.dart`. The test
/// env falls back to Helvetica (the real app loads the editorial fonts), so
/// this verifies LAYOUT/structure, not the production typeface.
void main() {
  test('render combined pdf to disk', () async {
    const directive = Directive(
      id: 1,
      formType: 'combined',
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
      avoidFacilityName: "St. Margaret's State Hospital | Prior negative experience",
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
      activities: 'Walking and listening to music help. Bright, loud rooms worsen things.',
      crisisIntervention: 'Speak calmly; give me space; my agent Jordan knows my preferences.',
      healthHistory: 'Bipolar I, diagnosed 2014. Two prior hospitalizations.',
      dietary: 'Vegetarian.',
      religious: 'Access to a chaplain on request.',
      childrenCustody: '',
      familyNotification: 'Notify my sister Jordan. Do not contact my ex-spouse.',
      recordsDisclosure: 'Authorized to receive my records: my agent Jordan Lee; Dr. Patel.',
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

    const generator = PdfGenerator(
      includeCombined: true,
      includeDeclaration: true,
      includePoa: true,
      includeSupplementary: false,
      includeNotes: false,
    );

    final bytes = await generator.generate(
      directive: directive,
      agents: agents,
      prefs: prefs,
      additional: additional,
      guardian: guardian,
      medications: medications,
      witnesses: witnesses,
      diagnoses: const [],
    );

    Directory('build/_pdfcmp').createSync(recursive: true);
    File('build/_pdfcmp/app_combined.pdf').writeAsBytesSync(bytes);
    // ignore: avoid_print
    print('WROTE build/_pdfcmp/app_combined.pdf (${bytes.length} bytes)');
    expect(bytes, isNotEmpty);
  });
}
