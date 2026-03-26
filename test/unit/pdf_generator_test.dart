import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/ui/export/pdf/notes_pdf.dart';
import 'package:mhad/ui/export/pdf/pdf_generator.dart';
import 'package:mhad/ui/export/pdf/supplementary_pdf.dart';

// ─── Shared test fixtures ────────────────────────────────────────────────────

/// Minimal valid Directive for testing — all required fields populated with
/// realistic but trivially simple values.
Directive _makeDirective() => const Directive(
      id: 1,
      formType: 'combined',
      status: 'draft',
      createdAt: 0,
      updatedAt: 0,
      executionDate: null,
      expirationDate: null,
      fullName: 'Jane Doe',
      dateOfBirth: '01/15/1980',
      address: '123 Main St',
      address2: '',
      city: 'Philadelphia',
      state: 'PA',
      zip: '19103',
      phone: '215-555-1234',
      effectiveCondition: '',
      preferredDoctorName: '',
      preferredDoctorContact: '',
      lastStepIndex: 0,
    );

Agent _makeAgent() => const Agent(
      id: 1,
      directiveId: 1,
      agentType: 'primary',
      fullName: 'Mary Agent',
      relationship: 'Sister',
      address: '99 Agent Ave, Pittsburgh, PA 15201',
      homePhone: '412-555-0001',
      workPhone: '',
      cellPhone: '412-555-0002',
    );

DirectivePref _makePrefs() => const DirectivePref(
      id: 1,
      directiveId: 1,
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
    );

AdditionalInstructionsTableData _makeAdditional() =>
    const AdditionalInstructionsTableData(
      id: 1,
      directiveId: 1,
      activities: '',
      crisisIntervention: '',
      healthHistory: '',
      dietary: '',
      religious: '',
      childrenCustody: '',
      familyNotification: '',
      recordsDisclosure: '',
      petCustody: '',
      other: '',
    );

GuardianNomination _makeGuardian() => const GuardianNomination(
      id: 1,
      directiveId: 1,
      nomineeFullName: 'Bob Guardian',
      nomineeAddress: '50 Guardian Rd, Harrisburg, PA 17101',
      nomineePhone: '717-555-9999',
      nomineeRelationship: 'Brother',
      guardianCanRevoke: false,
    );

MedicationEntry _makeMedication() => const MedicationEntry(
      id: 1,
      directiveId: 1,
      entryType: 'exception',
      medicationName: 'Medication A',
      reason: 'Adverse reaction',
      sortOrder: 0,
    );

WitnessesData _makeWitness(int number) => WitnessesData(
      id: number,
      directiveId: 1,
      witnessNumber: number,
      fullName: 'Witness $number',
      address: '$number Witness Way, Philadelphia, PA 19103',
      phone: '215-555-000$number',
    );

// ─── Tests ───────────────────────────────────────────────────────────────────

void main() {
  // ── supplementary_pdf.dart ─────────────────────────────────────────────────

  group('buildSupplementaryPages()', () {
    test('returns a non-empty list of pages', () {
      final pages = buildSupplementaryPages();
      expect(pages, isNotEmpty);
    });

    test('returns exactly one page', () {
      final pages = buildSupplementaryPages();
      expect(pages, hasLength(1));
    });
  });

  // ── notes_pdf.dart ─────────────────────────────────────────────────────────

  group('buildNotesPages()', () {
    test('returns a non-empty list of pages', () {
      final pages = buildNotesPages();
      expect(pages, isNotEmpty);
    });

    test('returns exactly one page', () {
      final pages = buildNotesPages();
      expect(pages, hasLength(1));
    });
  });

  // ── PdfGenerator.generate() ────────────────────────────────────────────────

  group('PdfGenerator.generate()', () {
    // Shared fixture data used across all PdfGenerator tests.
    late Directive directive;
    late List<Agent> agents;
    late DirectivePref prefs;
    late AdditionalInstructionsTableData additional;
    late GuardianNomination guardian;
    late List<MedicationEntry> medications;
    late List<WitnessesData> witnesses;

    setUp(() {
      directive = _makeDirective();
      agents = [_makeAgent()];
      prefs = _makePrefs();
      additional = _makeAdditional();
      guardian = _makeGuardian();
      medications = [_makeMedication()];
      witnesses = [_makeWitness(1), _makeWitness(2)];
    });

    Future<Uint8List> generate(PdfGenerator generator) =>
        generator.generate(
          directive: directive,
          agents: agents,
          prefs: prefs,
          additional: additional,
          guardian: guardian,
          medications: medications,
          witnesses: witnesses,
          diagnoses: const [],
        );

    test('only combinedSelected → produces non-empty PDF bytes', () async {
      final generator = const PdfGenerator(
        includeCombined: true,
        includeDeclaration: false,
        includePoa: false,
        includeSupplementary: false,
        includeNotes: false,
      );

      final bytes = await generate(generator);

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('only supplementary selected → produces non-empty PDF bytes', () async {
      final generator = const PdfGenerator(
        includeCombined: false,
        includeDeclaration: false,
        includePoa: false,
        includeSupplementary: true,
        includeNotes: false,
      );

      final bytes = await generate(generator);

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('only notes selected → produces non-empty PDF bytes', () async {
      final generator = const PdfGenerator(
        includeCombined: false,
        includeDeclaration: false,
        includePoa: false,
        includeSupplementary: false,
        includeNotes: true,
      );

      final bytes = await generate(generator);

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('all flags true → produces non-empty PDF bytes', () async {
      final generator = const PdfGenerator(
        includeCombined: true,
        includeDeclaration: true,
        includePoa: true,
        includeSupplementary: true,
        includeNotes: true,
      );

      final bytes = await generate(generator);

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('supplementary + notes (no form pages) → produces non-empty PDF bytes',
        () async {
      final generator = const PdfGenerator(
        includeCombined: false,
        includeDeclaration: false,
        includePoa: false,
        includeSupplementary: true,
        includeNotes: true,
      );

      final bytes = await generate(generator);

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('combined + supplementary → produces non-empty PDF bytes', () async {
      final generator = const PdfGenerator(
        includeCombined: true,
        includeDeclaration: false,
        includePoa: false,
        includeSupplementary: true,
        includeNotes: false,
      );

      final bytes = await generate(generator);

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('declaration only → produces non-empty PDF bytes', () async {
      final generator = const PdfGenerator(
        includeCombined: false,
        includeDeclaration: true,
        includePoa: false,
        includeSupplementary: false,
        includeNotes: false,
      );

      final bytes = await generate(generator);

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('POA only → produces non-empty PDF bytes', () async {
      final generator = const PdfGenerator(
        includeCombined: false,
        includeDeclaration: false,
        includePoa: true,
        includeSupplementary: false,
        includeNotes: false,
      );

      final bytes = await generate(generator);

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('generates without error when optional data is null', () async {
      final generator = const PdfGenerator(
        includeCombined: true,
        includeDeclaration: true,
        includePoa: true,
        includeSupplementary: true,
        includeNotes: true,
      );

      // prefs, additional, and guardian are all nullable in the generate()
      // signature — verify that passing null does not throw.
      final bytes = await generator.generate(
        directive: directive,
        agents: agents,
        prefs: null,
        additional: null,
        guardian: null,
        medications: const [],
        witnesses: const [],
      );

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });

    test('generates without error when agents and medications lists are empty',
        () async {
      final generator = const PdfGenerator(
        includeCombined: true,
        includeDeclaration: false,
        includePoa: true,
        includeSupplementary: false,
        includeNotes: false,
      );

      final bytes = await generator.generate(
        directive: directive,
        agents: const [],
        prefs: prefs,
        additional: additional,
        guardian: guardian,
        medications: const [],
        witnesses: const [],
      );

      expect(bytes, isA<Uint8List>());
      expect(bytes, isNotEmpty);
    });
  });
}
