import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/ui/export/pdf/notes_pdf.dart';
import 'package:mhad/ui/export/pdf/pdf_generator.dart';
import 'package:mhad/ui/export/pdf/supplementary_pdf.dart';

// ─── Structural helpers ──────────────────────────────────────────────────────

/// Counts PDF page objects ("/Type /Page", excluding the "/Type /Pages" tree
/// root) in the raw bytes. A structural assertion stronger than "non-empty": it
/// verifies the generator actually emitted a page tree of the expected shape.
/// package:pdf writes object dictionaries in plaintext (only the content
/// streams are Flate-compressed), so these markers are scannable.
int _pageCount(Uint8List bytes) =>
    RegExp(r'/Type\s*/Page(?![s])').allMatches(String.fromCharCodes(bytes)).length;

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
      county: 'Philadelphia',
      state: 'PA',
      zip: '19103',
      phone: '215-555-1234',
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

Agent _makeAgent() => const Agent(
      id: 1,
      directiveId: 1,
      agentType: 'primary',
      fullName: 'Mary Agent',
      relationship: 'Sister',
      address: '99 Agent Ave',
      address2: '',
      city: 'Pittsburgh',
      state: 'PA',
      zip: '15201',
      homePhone: '412-555-0001',
      workPhone: '',
      cellPhone: '412-555-0002',
      acceptanceNotes: '',
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
      // Phase 2 — schema v8 additions.
      roomPreferences: '',
      roomPreferencesNote: '',
      // Schema v16 addition.
      roommateGenderMatch: '',
      // Phase 4 — schema v10 additions.
      crisisPlanJson: '',
      selfBindingEnabled: false,
      sideEffectsJson: '',
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
      // Phase 2 — schema v8 addition. 'different' = explicit named nominee
      // (matches the inline-expansion branch in guardian_nomination_step.dart).
      guardianRelation: 'different',
    );

MedicationEntry _makeMedication() => const MedicationEntry(
      id: 1,
      directiveId: 1,
      entryType: 'exception',
      medicationName: 'Medication A',
      reason: 'Adverse reaction',
      dosage: '',
      sortOrder: 0,
    );

WitnessesData _makeWitness(int number) => WitnessesData(
      id: number,
      directiveId: 1,
      witnessNumber: number,
      fullName: 'Witness $number',
      address: '$number Witness Way',
      address2: '',
      city: 'Philadelphia',
      state: 'PA',
      zip: '19103',
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

    test('returns a single MultiPage (content may flow across printed pages)',
        () {
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
      const generator = PdfGenerator(
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
      const generator = PdfGenerator(
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
      const generator = PdfGenerator(
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
      const generator = PdfGenerator(
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
      const generator = PdfGenerator(
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
      const generator = PdfGenerator(
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
      const generator = PdfGenerator(
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
      const generator = PdfGenerator(
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

    test('each form type produces a structurally valid PDF (%PDF- header)',
        () async {
      const generators = [
        PdfGenerator(
          includeCombined: true,
          includeDeclaration: false,
          includePoa: false,
          includeSupplementary: false,
          includeNotes: false,
        ),
        PdfGenerator(
          includeCombined: false,
          includeDeclaration: true,
          includePoa: false,
          includeSupplementary: false,
          includeNotes: false,
        ),
        PdfGenerator(
          includeCombined: false,
          includeDeclaration: false,
          includePoa: true,
          includeSupplementary: false,
          includeNotes: false,
        ),
      ];
      for (final g in generators) {
        final bytes = await generate(g);
        // PDF files begin with the magic number "%PDF-": a real validity check
        // beyond "non-empty" (catches a generator that emits garbage bytes).
        expect(String.fromCharCodes(bytes.take(5)), '%PDF-',
            reason: 'output should be a valid PDF document');
      }
    });

    test('each form type emits a page tree and a valid %%EOF trailer',
        () async {
      const generators = [
        PdfGenerator(
          includeCombined: true,
          includeDeclaration: false,
          includePoa: false,
          includeSupplementary: false,
          includeNotes: false,
        ),
        PdfGenerator(
          includeCombined: false,
          includeDeclaration: true,
          includePoa: false,
          includeSupplementary: false,
          includeNotes: false,
        ),
        PdfGenerator(
          includeCombined: false,
          includeDeclaration: false,
          includePoa: true,
          includeSupplementary: false,
          includeNotes: false,
        ),
      ];
      for (final g in generators) {
        final bytes = await generate(g);
        // Structure beyond the header: a real page tree, and a complete file
        // (truncated/aborted output would lack the %%EOF trailer).
        expect(_pageCount(bytes), greaterThanOrEqualTo(1),
            reason: 'every form type must render at least one page');
        expect(String.fromCharCodes(bytes).trimRight(), endsWith('%%EOF'),
            reason: 'a complete PDF ends with the %%EOF trailer');
      }
    });

    test('optional supplementary + notes sections add pages to the document',
        () async {
      final combinedOnly = await generate(const PdfGenerator(
        includeCombined: true,
        includeDeclaration: false,
        includePoa: false,
        includeSupplementary: false,
        includeNotes: false,
      ));
      final withExtras = await generate(const PdfGenerator(
        includeCombined: true,
        includeDeclaration: false,
        includePoa: false,
        includeSupplementary: true,
        includeNotes: true,
      ));
      // A monotonic structural invariant (not a brittle exact-page golden):
      // turning on the supplementary + notes sections must yield strictly more
      // page objects than the form alone.
      expect(_pageCount(withExtras), greaterThan(_pageCount(combinedOnly)),
          reason: 'supplementary + notes each contribute at least one page');
    });

    test('generates without error when optional data is null', () async {
      const generator = PdfGenerator(
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
      const generator = PdfGenerator(
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

    test('attachment pages appear only when attachment data exists', () async {
      const generator = PdfGenerator(
        includeCombined: true,
        includeDeclaration: false,
        includePoa: false,
        includeSupplementary: false,
        includeNotes: false,
      );

      // No allergies / crisis plan / self-binding → no attachment pages.
      final withoutAttachments = await generator.generate(
        directive: directive,
        agents: agents,
        prefs: prefs,
        additional: additional,
        guardian: guardian,
        medications: const [],
        witnesses: const [],
      );

      // An allergy → the attachments MultiPage is appended.
      final withAttachments = await generator.generate(
        directive: directive,
        agents: agents,
        prefs: prefs,
        additional: additional,
        guardian: guardian,
        medications: const [],
        witnesses: const [],
        allergies: const [
          DirectiveAllergy(
            id: 1,
            directiveId: 1,
            kind: 'drug',
            substance: 'Penicillin',
            code: '',
            codeSource: 'manual',
            severity: 'severe',
            reactions: 'Hives',
            notes: '',
            sortOrder: 0,
          ),
        ],
      );

      expect(_pageCount(withAttachments),
          greaterThan(_pageCount(withoutAttachments)),
          reason: 'allergy data must add the attachments page(s)');

      // A crisis plan alone also triggers the attachment (via prefs).
      final crisisPrefs = prefs.copyWith(
        crisisPlanJson: '{"helps":["dim lights"]}',
      );
      final withCrisisPlan = await generator.generate(
        directive: directive,
        agents: agents,
        prefs: crisisPrefs,
        additional: additional,
        guardian: guardian,
        medications: const [],
        witnesses: const [],
      );
      expect(_pageCount(withCrisisPlan),
          greaterThan(_pageCount(withoutAttachments)),
          reason: 'a crisis plan must add the attachments page(s)');
    });
  });
}
