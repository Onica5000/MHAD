import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/services/export_formats_service.dart';
import 'package:mhad/services/fhir_export_service.dart';

/// Structure/regression coverage for the machine-readable exports (CSV, FHIR
/// XML, FHIR JSON). These share the `instruction_fields.dart` /
/// `agent_ext.dart` helpers; the tests lock the output shape so a future change
/// to those helpers can't silently drift the EHR/spreadsheet output.

Directive _directive() => const Directive(
      id: 7,
      formType: 'combined',
      status: 'complete',
      createdAt: 0,
      updatedAt: 0,
      executionDate: 1000,
      expirationDate: null,
      fullName: 'Jane & Doe', // '&' exercises XML escaping
      dateOfBirth: '01/15/1980',
      address: '123 Main St',
      address2: '',
      city: 'Philadelphia',
      county: 'Philadelphia',
      state: 'PA',
      zip: '19103',
      phone: '215-555-1234',
      effectiveCondition: 'when two professionals certify, in writing',
      triggerTwoProfessionals: true,
      triggerCourtOrder: false,
      triggerInvoluntaryCommitment: false,
      preferredDoctorName: '',
      preferredDoctorContact: '',
      primaryDoctorName: '',
      primaryDoctorSpecialty: '',
      primaryDoctorPhone: '',
      lastStepIndex: 0,
    );

Agent _agent() => const Agent(
      id: 1,
      directiveId: 7,
      agentType: 'primary',
      fullName: 'Mary Agent',
      relationship: 'Sister',
      address: '99 Agent Ave',
      address2: '',
      city: 'Pittsburgh',
      state: 'PA',
      zip: '15201',
      homePhone: '',
      workPhone: '',
      cellPhone: '412-555-0002',
      acceptanceNotes: '',
    );

MedicationEntry _med() => const MedicationEntry(
      id: 1,
      directiveId: 7,
      entryType: 'exception',
      medicationName: 'Haloperidol',
      reason: 'Adverse reaction',
      dosage: '',
      sortOrder: 0,
    );

DirectivePref _prefs() => const DirectivePref(
      id: 1,
      directiveId: 7,
      treatmentFacilityPref: 'noPreference',
      preferredFacilityName: '',
      avoidFacilityName: '',
      medicationConsent: 'yes',
      ectConsent: 'no',
      experimentalConsent: 'no',
      drugTrialConsent: 'no',
      agentCanConsentHospitalization: true,
      agentCanConsentMedication: true,
      agentAuthorityLimitations: '',
      roomPreferences: '',
      roomPreferencesNote: '',
      roommateGenderMatch: '',
      crisisPlanJson: '',
      selfBindingEnabled: false,
      sideEffectsJson: '',
    );

AdditionalInstructionsTableData _additional() =>
    const AdditionalInstructionsTableData(
      id: 1,
      directiveId: 7,
      activities: '',
      crisisIntervention: 'Play calming music',
      healthHistory: '',
      dietary: '',
      religious: '',
      childrenCustody: '',
      familyNotification: '',
      recordsDisclosure: '',
      petCustody: '',
      other: '',
    );

GuardianNomination _guardian() => const GuardianNomination(
      id: 1,
      directiveId: 7,
      nomineeFullName: 'Bob Guardian',
      nomineeAddress: '50 Guardian Rd',
      nomineeAddress2: '',
      nomineeCity: 'Harrisburg',
      nomineeState: 'PA',
      nomineeZip: '17101',
      nomineePhone: '717-555-9999',
      nomineeRelationship: 'Brother',
      guardianCanRevoke: false,
      guardianCanChangeAgent: false,
      guardianMustConsultAgent: false,
      guardianCanRevokeNote: '',
      guardianCanChangeAgentNote: '',
      guardianMustConsultAgentNote: '',
      guardianRelation: 'different',
    );

DiagnosisEntry _diagnosis() => const DiagnosisEntry(
      id: 1,
      directiveId: 7,
      icdCode: 'F31.9',
      name: 'Bipolar disorder',
      sortOrder: 0,
    );

void main() {
  group('exportAsCsv', () {
    final csv = ExportFormatsService.exportAsCsv(
      directive: _directive(),
      agents: [_agent()],
      medications: [_med()],
      prefs: _prefs(),
      additional: _additional(),
      guardian: _guardian(),
      diagnoses: [_diagnosis()],
    );

    test('has the RFC-4180 header row', () {
      expect(csv.startsWith('Section,Item,Detail\r\n'), isTrue);
    });

    test('includes agent, medication, diagnosis and instruction rows', () {
      expect(csv, contains('Mary Agent'));
      expect(csv, contains('Haloperidol'));
      expect(csv, contains('Bipolar disorder'));
      expect(csv, contains('Play calming music'));
    });

    test('quotes a field containing a comma', () {
      // effectiveCondition contains a comma → must be wrapped in quotes.
      expect(csv, contains('"when two professionals certify, in writing"'));
    });

    test('omits empty fields (no blank Detail rows)', () {
      // dietary/religious/etc. are empty and must not appear as rows.
      expect(csv, isNot(contains('Dietary'))); // empty → skipped
    });
  });

  group('exportAsFhirXml', () {
    final xml = ExportFormatsService.exportAsFhirXml(
      directive: _directive(),
      agents: [_agent()],
      medications: [_med()],
      prefs: _prefs(),
      additional: _additional(),
      guardian: _guardian(),
      diagnoses: [_diagnosis()],
    );

    test('is an XML Consent document', () {
      expect(xml.startsWith('<?xml'), isTrue);
      expect(xml, contains('<Consent xmlns="http://hl7.org/fhir">'));
      expect(xml.trimRight().endsWith('</Consent>'), isTrue);
    });

    test('escapes XML special characters', () {
      expect(xml, contains('Jane &amp; Doe'));
      expect(xml, isNot(contains('Jane & Doe')));
    });

    test('emits a deny provision for a refused medication', () {
      expect(xml, contains('<text value="Haloperidol"/>'));
      expect(xml, contains('<type value="deny"/>'));
    });

    test('emits actors for the agent and guardian', () {
      expect(xml, contains('Healthcare Power of Attorney'));
      expect(xml, contains('<display value="Guardian"/>'));
    });
  });

  group('exportAsJson (FHIR)', () {
    final json = FhirExportService.exportAsJson(
      directive: _directive(),
      agents: [_agent()],
      medications: [_med()],
      prefs: _prefs(),
      additional: _additional(),
      guardian: _guardian(),
      diagnoses: [_diagnosis()],
    );

    test('is valid JSON with a Consent resourceType', () {
      final decoded = jsonDecode(json) as Map<String, dynamic>;
      expect(decoded['resourceType'], 'Consent');
    });
  });
}
