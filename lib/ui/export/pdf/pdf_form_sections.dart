/// Parameterized section builders shared by the three form renderers.
///
/// Each builder returns the EXACT widget sequence the pre-globalization
/// renderers produced (verified pixel-identical via tool/pdf_compare.py) —
/// the three renderer files are now thin ordering manifests over these.
/// Form-specific wording comes from [FormText]; everything here is either
/// identical across forms or parameterized by explicit arguments.
library;

import 'package:mhad/constants.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_helpers.dart';

/// The blank rule printed where the declarant's name goes when empty.
const String nameBlank = '___________________________________________';

String declarantNameOrBlank(Directive d) =>
    d.fullName.isNotEmpty ? d.fullName : nameBlank;

// ─── Title & introduction ───────────────────────────────────────────────────

List<pw.Widget> formTitleBlock(List<String> lines) => [
      pw.Center(
        child: lines.length == 1
            ? pw.Text(lines.first, style: boldStyle(fontSize: 13))
            : pw.Column(children: [
                for (final l in lines)
                  pw.Text(l, style: boldStyle(fontSize: 13)),
                pw.SizedBox(height: 8),
              ]),
      ),
      if (lines.length == 1) pw.SizedBox(height: 8),
    ];

List<pw.Widget> introBlock(List<String> paragraphs) => [
      for (var i = 0; i < paragraphs.length; i++) ...[
        pw.Text(paragraphs[i], style: bodyStyle()),
        if (i < paragraphs.length - 1) pw.SizedBox(height: 4),
      ],
    ];

List<pw.Widget> dobBlock(Directive directive) => [
      if (directive.dateOfBirth.isNotEmpty)
        dataLine('Date of Birth', directive.dateOfBirth),
      pw.SizedBox(height: 6),
    ];

List<pw.Widget> diagnosesDoctorBlock(
  Directive directive,
  List<DiagnosisEntry> diagnoses, {
  required bool includePrimaryDoctor,
}) =>
    [
      if (diagnoses.isNotEmpty) diagnosisList(diagnoses),
      if (includePrimaryDoctor &&
          (directive.primaryDoctorName.isNotEmpty ||
              directive.primaryDoctorPhone.isNotEmpty))
        dataLine(
          'Primary Care Doctor',
          [
            directive.primaryDoctorName,
            if (directive.primaryDoctorSpecialty.isNotEmpty)
              '(${directive.primaryDoctorSpecialty})',
            directive.primaryDoctorPhone,
          ].where((s) => s.isNotEmpty).join(' · '),
        ),
    ];

// ─── Effective time (incl. the statutory trigger checkboxes) ────────────────

List<pw.Widget> effectiveTimeSection({
  required String header,
  required String leadIn,
  required Directive directive,
}) =>
    [
      partHeader(header),
      pw.Text(leadIn, style: bodyStyle()),
      pw.SizedBox(height: 4),
      checkRow(
        'When I am deemed incapable of making mental health care decisions. I would '
        'prefer the following doctor(s) to evaluate me for my ability to make mental '
        'health decisions:',
        checked: directive.effectiveCondition.isEmpty,
      ),
      if (directive.effectiveCondition.isEmpty) ...[
        dataLine('Name of Doctor', directive.preferredDoctorName),
        dataLine('Address/Phone Number', directive.preferredDoctorContact),
      ],
      pw.SizedBox(height: 4),
      checkRow(
        'When the following condition is met:',
        checked: directive.effectiveCondition.isNotEmpty,
      ),
      if (directive.effectiveCondition.isNotEmpty)
        dataLine('Condition', directive.effectiveCondition),
      if (directive.triggerTwoProfessionals ||
          directive.triggerCourtOrder ||
          directive.triggerInvoluntaryCommitment) ...[
        pw.SizedBox(height: 4),
        pw.Text('This directive also takes effect when:', style: boldStyle()),
        if (directive.triggerTwoProfessionals)
          checkRow(
            'A psychiatrist and one other qualified professional find '
            'that I lack capacity to make mental health treatment '
            'decisions.',
            checked: true,
          ),
        if (directive.triggerCourtOrder)
          checkRow('A court determines that I lack capacity.', checked: true),
        if (directive.triggerInvoluntaryCommitment)
          checkRow('I am involuntarily committed.', checked: true),
      ],
    ];

// ─── Revocation / Amendments / Termination ──────────────────────────────────

List<pw.Widget> revocationSection({
  required String header,
  required String revocation,
  required String amendments,
}) =>
    [
      partHeader(header),
      pw.Text(revocation, style: bodyStyle()),
      pw.SizedBox(height: 4),
      pw.Text(amendments, style: bodyStyle()),
      pw.SizedBox(height: 6),
    ];

List<pw.Widget> terminationSection({
  required String header,
  required String paragraph,
}) =>
    [
      partHeader(header),
      pw.Text(paragraph, style: bodyStyle()),
    ];

// ─── Treatment facility + room preferences ──────────────────────────────────

List<pw.Widget> facilitySection(DirectivePref? prefs) => [
      if (prefs != null) ...[
        checkRow(
          'I have a preference for a treatment facility.',
          checked: prefs.treatmentFacilityPref == 'prefer' ||
              prefs.preferredFacilityName.isNotEmpty,
        ),
        checkRow(
          'I have a facility I wish to avoid.',
          checked: prefs.treatmentFacilityPref == 'avoid' ||
              prefs.avoidFacilityName.isNotEmpty,
        ),
        checkRow(
          'I have no preference regarding treatment facility.',
          checked: prefs.treatmentFacilityPref == 'noPreference' &&
              prefs.preferredFacilityName.isEmpty &&
              prefs.avoidFacilityName.isEmpty,
        ),
      ],
      pw.SizedBox(height: 4),
      pw.Text(
        'In the event that I require commitment to a psychiatric treatment facility, '
        'I would prefer to be admitted to the following facility:',
        style: bodyStyle(),
      ),
      pw.SizedBox(height: 2),
      if (prefs != null && prefs.preferredFacilityName.isNotEmpty)
        facilityList(prefs.preferredFacilityName)
      else ...[
        blankLine('Name of facility'),
        blankLine('Address'),
        blankLine('City, State, Zip Code'),
      ],
      pw.SizedBox(height: 4),
      pw.Text(
        'In the event that I require commitment to a psychiatric treatment facility, '
        'I do not wish to be committed to the following facility:',
        style: bodyStyle(),
      ),
      pw.SizedBox(height: 2),
      if (prefs != null && prefs.avoidFacilityName.isNotEmpty)
        facilityList(prefs.avoidFacilityName)
      else ...[
        blankLine('Name of facility'),
        blankLine('Address'),
        blankLine('City, State, Zip Code'),
      ],
      pw.Text(
        'I understand that my physician may have to place me in a facility that is not my preference.',
        style: smallBodyStyle(),
      ),
    ];

List<pw.Widget> roomPreferencesBlock(DirectivePref? prefs) {
  final formatted = formatRoomPreferences(prefs);
  if (formatted == null) return const [];
  return [
    pw.SizedBox(height: 8),
    pw.Text('Room and environment preferences:', style: boldStyle()),
    pw.SizedBox(height: 2),
    pw.Text(formatted, style: bodyStyle()),
  ];
}

// ─── Medications ────────────────────────────────────────────────────────────

/// How the medication-preferences section words its consent rows.
enum MedsSectionVariant {
  /// "…that my treating physician recommends" — no agent rows (Declaration).
  declaration,

  /// Declaration wording + the "designated an agent" checkbox (Combined II.2).
  combined,

  /// "…that my agent agrees to" wording (POA D.2).
  poa,
}

List<pw.Widget> currentMedsBlock(List<MedicationEntry> current) => [
      if (current.isNotEmpty) ...[
        medTable(
          'Medications I am currently taking (for reference):',
          current
              .map(
                (m) => {
                  'medication':
                      medicationWithDosage(m.medicationName, m.dosage),
                  'reason': m.reason,
                },
              )
              .toList(),
          false,
        ),
        pw.SizedBox(height: 4),
      ],
    ];

List<pw.Widget> _sharedMedTables({
  required List<MedicationEntry> exceptions,
  required List<MedicationEntry> limitations,
  required List<MedicationEntry> preferred,
  required String genericNote,
}) =>
    [
      if (exceptions.isNotEmpty)
        medTable(
          'Exceptions:',
          exceptions
              .map((m) => {'medication': m.medicationName, 'reason': m.reason})
              .toList(),
          false,
        ),
      if (limitations.isNotEmpty)
        medTable(
          'I consent to the following medications with these limitations:',
          limitations
              .map(
                (m) => {
                  'medication': m.medicationName,
                  'limitation': m.reason,
                  'reason': '',
                },
              )
              .toList(),
          true,
        ),
      if (preferred.isNotEmpty)
        medTable(
          'I prefer the following medications:',
          preferred
              .map((m) => {'medication': m.medicationName, 'reason': m.reason})
              .toList(),
          false,
        ),
      if (exceptions.isNotEmpty ||
          limitations.isNotEmpty ||
          preferred.isNotEmpty) ...[
        pw.Text(genericNote, style: smallBodyStyle()),
        pw.Text(
          'Note: Narrow therapeutic index (NTI) drugs (e.g., lithium, carbamazepine, '
          'valproic acid) cannot have generics substituted under PA law (35 P.S. §960.3).',
          style: smallBodyStyle(),
        ),
      ],
    ];

List<pw.Widget> medicationPreferencesSection({
  required DirectivePref? prefs,
  required List<MedicationEntry> exceptions,
  required List<MedicationEntry> limitations,
  required List<MedicationEntry> preferred,
  required MedsSectionVariant variant,
}) {
  if (prefs == null) return const [];
  final hasLists =
      exceptions.isNotEmpty || limitations.isNotEmpty || preferred.isNotEmpty;

  // Official pp. 26/34 keep a comma after "preference"; the app's POA note
  // drops it (its official counterpart on p. 41 has a different sentence).
  final genericNote = variant == MedsSectionVariant.poa
      ? 'The exception, limitation, or preference applies to generic, brand name and '
          'trade name equivalents unless otherwise stated. I understand that dosage '
          'instructions are not binding on my physician.'
      : 'The exception, limitation, or preference, applies to generic, brand name and '
          'trade name equivalents unless otherwise stated. I understand that dosage '
          'instructions are not binding on my physician.';

  final tables = _sharedMedTables(
    exceptions: exceptions,
    limitations: limitations,
    preferred: preferred,
    genericNote: genericNote,
  );

  // Conditional medication consent (audit defect #6): unlike ECT /
  // experimental / drug trials, the medication field had no
  // 'conditional:' printing, so a conditional value (reachable via AI
  // autofill) would silently vanish. Mirrors the procedure sections.
  final conditionalRows = isConsentConditional(prefs.medicationConsent)
      ? <pw.Widget>[
          checkRow(
            'I consent to medications under the following conditions:',
            checked: true,
          ),
          dataBlock(
            'Conditions:',
            consentConditionText(prefs.medicationConsent),
          ),
        ]
      : const <pw.Widget>[];

  switch (variant) {
    case MedsSectionVariant.declaration:
    case MedsSectionVariant.combined:
      return [
        checkRow(
          'I consent to the medications that my treating physician recommends.',
          checked: prefs.medicationConsent == consentYes && !hasLists,
        ),
        checkRow(
          variant == MedsSectionVariant.combined
              ? 'I consent to the medications that my treating physician recommends with '
                  'the following exceptions, limitations, and/or preferences:'
              : 'I consent to the medications that my treating physician recommends with '
                  'the following exceptions, limitations and/or preferences:',
          checked: prefs.medicationConsent == consentYes && hasLists,
        ),
        ...tables,
        ...conditionalRows,
        if (variant == MedsSectionVariant.combined)
          checkRow(
            'I have designated an agent under the Power of Attorney portion of this '
            'document to make decisions related to medication.',
            checked: prefs.medicationConsent == consentAgentDecides,
          ),
        checkRow(
          'I do not consent to the use of any medications.',
          checked: prefs.medicationConsent == consentNo,
        ),
      ];
    case MedsSectionVariant.poa:
      return [
        checkRow(
          'I consent to the medications that my agent agrees to after consultation '
          'with my treating physician and any other persons my agent considers appropriate.',
          checked: (prefs.medicationConsent == consentYes ||
                  prefs.medicationConsent == consentAgentDecides) &&
              !hasLists,
        ),
        checkRow(
          'I consent to the medications that my agent agrees to, with the following '
          'exceptions, limitations, and/or preferences:',
          checked: (prefs.medicationConsent == consentYes ||
                  prefs.medicationConsent == consentAgentDecides) &&
              hasLists,
        ),
        ...tables,
        ...conditionalRows,
        checkRow(
          'My agent is not authorized to consent to the use of any medications.',
          checked: prefs.medicationConsent == consentNo,
        ),
      ];
  }
}

// ─── ECT / experimental studies / drug trials ───────────────────────────────

/// One of the three §5836(c) procedures, carrying its per-kind wording.
enum ProcedureKind { ect, experimental, drugTrial }

extension on ProcedureKind {
  String get consentText => switch (this) {
        ProcedureKind.ect =>
          'I consent to the administration of electroconvulsive therapy.',
        ProcedureKind.experimental =>
          'I consent to participation in experimental studies if my treating physician '
              'believes that the potential benefits to me outweigh the possible risks to me.',
        ProcedureKind.drugTrial =>
          'I consent to participation in drug trials if my treating physician believes '
              'that the potential benefits to me outweigh the possible risks to me.',
      };

  String get conditionalLabel => switch (this) {
        ProcedureKind.ect => 'I consent to ECT under the following conditions:',
        ProcedureKind.experimental =>
          'I consent to experimental studies under the following conditions:',
        ProcedureKind.drugTrial =>
          'I consent to drug trials under the following conditions:',
      };

  String get designatedAgentText => switch (this) {
        ProcedureKind.ect =>
          'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to electroconvulsive therapy.',
        ProcedureKind.experimental =>
          'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to experimental studies.',
        ProcedureKind.drugTrial =>
          'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to drug trials.',
      };

  String get notConsentText => switch (this) {
        ProcedureKind.ect =>
          'I do not consent to the administration of electroconvulsive therapy.',
        ProcedureKind.experimental =>
          'I do not consent to participation in experimental studies.',
        ProcedureKind.drugTrial =>
          'I do not consent to participation in any drug trials.',
      };

  String get agentAuthorizedText => switch (this) {
        ProcedureKind.ect =>
          'My agent is authorized to consent to the administration of '
              'electroconvulsive therapy.',
        ProcedureKind.experimental =>
          'My agent is authorized to consent to my participation in experimental '
              'studies if, after consultation with my treating physician and any other '
              'individuals my agent deems appropriate, my agent believes that the '
              'potential benefits to me outweigh the possible risks to me.',
        ProcedureKind.drugTrial =>
          'My agent is authorized to consent to my participation in drug trials '
              'if, after consultation with my treating physician and any other '
              'individuals my agent deems appropriate, my agent believes that the '
              'potential benefits to me outweigh the possible risks to me.',
      };

  String get agentNotAuthorizedText => switch (this) {
        ProcedureKind.ect =>
          'My agent is not authorized to consent to the administration of '
              'electroconvulsive therapy.',
        ProcedureKind.experimental =>
          'My agent is not authorized to consent to my participation in '
              'experimental studies.',
        ProcedureKind.drugTrial =>
          'My agent is not authorized to consent to my participation in drug trials.',
      };

  /// The bold under-row note from the official POA (p. 41).
  String get initialsNote => switch (this) {
        ProcedureKind.ect =>
          'NOTE: Your agent MAY NOT consent to ECT unless you initial this authorization.',
        ProcedureKind.experimental =>
          'NOTE: Your agent MAY NOT consent to experimental studies unless you initial this authorization.',
        ProcedureKind.drugTrial =>
          'NOTE: Your agent MAY NOT consent to research including drug trials unless you initial this authorization.',
      };

  String consentValue(DirectivePref prefs) => switch (this) {
        ProcedureKind.ect => prefs.ectConsent,
        ProcedureKind.experimental => prefs.experimentalConsent,
        ProcedureKind.drugTrial => prefs.drugTrialConsent,
      };
}

/// The declarant's own consent rows (Declaration B.3-5 and Combined II.3-5;
/// [withDesignatedAgentRow] adds the Combined's initialed agent-designation
/// row, which per §5836(c) — as the official directions require — must be
/// INITIALED, not checked).
List<pw.Widget> procedureConsentSection({
  required String header,
  required ProcedureKind kind,
  required DirectivePref? prefs,
  required bool withDesignatedAgentRow,
}) =>
    [
      pw.Text(header, style: boldStyle()),
      pw.SizedBox(height: 4),
      if (prefs != null) ...[
        checkRow(
          kind.consentText,
          checked: kind.consentValue(prefs) == consentYes,
        ),
        if (isConsentConditional(kind.consentValue(prefs))) ...[
          checkRow(kind.conditionalLabel, checked: true),
          dataBlock('Conditions:', consentConditionText(kind.consentValue(prefs))),
        ],
        if (withDesignatedAgentRow)
          initialRow(
            kind.designatedAgentText,
            highlighted: isConsentAgent(kind.consentValue(prefs)),
          ),
        checkRow(
          kind.notConsentText,
          checked: isConsentNo(kind.consentValue(prefs)),
        ),
      ],
    ];

/// The agent-authority rows (POA D.3-5 and Combined III.C.2-4): an initials
/// row per §5836(c) with the official bold NOTE, then the not-authorized
/// checkbox.
List<pw.Widget> procedureAgentAuthoritySection({
  required String header,
  required ProcedureKind kind,
  required DirectivePref? prefs,
  double gapAfterHeader = 4,
}) =>
    [
      pw.Text(header, style: boldStyle()),
      pw.SizedBox(height: gapAfterHeader),
      if (prefs != null) ...[
        initialRow(
          kind.agentAuthorizedText,
          highlighted: isConsentAgent(kind.consentValue(prefs)),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 20),
          child: pw.Text(
            kind.initialsNote,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: kBlack,
            ),
          ),
        ),
        checkRow(
          kind.agentNotAuthorizedText,
          checked: !isConsentAgent(kind.consentValue(prefs)),
        ),
      ],
    ];

// ─── Additional instructions ────────────────────────────────────────────────

List<pw.Widget> additionalInstructionsSection({
  required AdditionalInstructionsTableData? additional,
  required ParsedOtherContent parsed,
  required String? sideEffectsJson,
}) =>
    [
      pw.Text('6. Additional instructions or information.', style: boldStyle()),
      pw.Text(
        'Examples of other instructions or information that may be included:',
        style: smallBodyStyle(),
      ),
      pw.SizedBox(height: 4),
      if (additional != null) ...[
        if (additional.activities.isNotEmpty)
          dataBlock(
            'Activities that help or worsen symptoms:',
            additional.activities,
          ),
        if (additional.crisisIntervention.isNotEmpty)
          dataBlock(
            'Type of intervention preferred in the event of a crisis:',
            additional.crisisIntervention,
          ),
        if (additional.healthHistory.isNotEmpty)
          dataBlock(
            'Mental and physical health history:',
            additional.healthHistory,
          ),
        if (additional.dietary.isNotEmpty)
          dataBlock('Dietary requirements:', additional.dietary),
        if (additional.religious.isNotEmpty)
          dataBlock('Religious preferences:', additional.religious),
        if (additional.childrenCustody.isNotEmpty)
          dataBlock(
            'Temporary custody of children:',
            additional.childrenCustody,
          ),
        if (additional.familyNotification.isNotEmpty)
          dataBlock('Family notification:', additional.familyNotification),
        if (additional.recordsDisclosure.isNotEmpty)
          dataBlock(
            'Limitations on the release or disclosure of mental health records:',
            additional.recordsDisclosure,
          ),
        if (additional.petCustody.isNotEmpty)
          dataBlock(
            'Temporary care and custody of pets:',
            additional.petCustody,
          ),
        if (parsed.deEscalation.isNotEmpty)
          dataBlock('De-escalation techniques:', parsed.deEscalation),
        if (parsed.triggers.isNotEmpty)
          dataBlock('Crisis triggers:', parsed.triggers),
        if (parsed.reproductiveHealth.isNotEmpty)
          dataBlock(
            'Reproductive health preferences:',
            parsed.reproductiveHealth,
          ),
        if (parsed.ectGuidance.isNotEmpty)
          dataBlock('ECT guidance notes:', parsed.ectGuidance),
        if (parsed.experimentalGuidance.isNotEmpty)
          dataBlock(
            'Experimental studies guidance:',
            parsed.experimentalGuidance,
          ),
        if (parsed.drugTrialGuidance.isNotEmpty)
          dataBlock('Drug trials guidance:', parsed.drugTrialGuidance),
        if (parsed.otherText.isNotEmpty)
          dataBlock('Other matters of importance:', parsed.otherText),
      ],
      ...experiencedSideEffectsBlocks(sideEffectsJson),
    ];

// ─── Agent designation ──────────────────────────────────────────────────────

List<pw.Widget> agentDesignationSection({
  required Agent? primaryAgent,
  required String declarantName,
  required String preamble,
}) =>
    [
      partHeader('A. Designation of agent'),
      pw.Text(preamble, style: bodyStyle()),
      pw.SizedBox(height: 4),
      dataLine('Name of designated person', primaryAgent?.fullName ?? ''),
      if (primaryAgent != null && primaryAgent.relationship.isNotEmpty)
        dataLine('Relationship', primaryAgent.relationship),
      dataLine('Address', primaryAgent?.streetAddress ?? ''),
      twoCol(
        dataLine('City, State, Zip Code', primaryAgent?.cityStateZip ?? ''),
        dataLine('Phone Number', agentBestPhone(primaryAgent)),
      ),
      pw.SizedBox(height: 4),
      pw.Text("Agent's acceptance:", style: boldStyle()),
      pw.Text(
        'I hereby accept designation as mental health care agent for '
        '${declarantName.isNotEmpty ? declarantName : '(insert name of declarant)'}.',
        style: bodyStyle(),
      ),
      signatureBlock("Agent's Signature", name: primaryAgent?.fullName ?? ''),
    ];

List<pw.Widget> alternateAgentSection({
  required Agent? altAgent,
  required String declarantName,
  required double gapBeforeAcceptance,
}) =>
    [
      partHeader('B. Designation of alternative agent'),
      pw.Text(
        'In the event that my first agent is unavailable or unable to serve as my '
        'mental health care agent, I hereby designate and appoint the following '
        'individual as my alternative mental health care agent to make mental health '
        'care decisions for me as authorized in this document:',
        style: bodyStyle(),
      ),
      pw.SizedBox(height: 4),
      dataLine('Name of designated person', altAgent?.fullName ?? ''),
      if (altAgent != null && altAgent.relationship.isNotEmpty)
        dataLine('Relationship', altAgent.relationship),
      dataLine('Address', altAgent?.streetAddress ?? ''),
      twoCol(
        dataLine('City, State, Zip Code', altAgent?.cityStateZip ?? ''),
        dataLine('Phone Number', agentBestPhone(altAgent)),
      ),
      pw.SizedBox(height: gapBeforeAcceptance),
      pw.Text("Alternative Agent's acceptance:", style: boldStyle()),
      pw.Text(
        'I hereby accept designation as alternative mental health care agent for '
        '${declarantName.isNotEmpty ? declarantName : '(insert name of declarant)'}.',
        style: bodyStyle(),
      ),
      signatureBlock(
        "Alternate Agent's Signature",
        name: altAgent?.fullName ?? '',
      ),
    ];

// ─── Agent authority (hospitalization / medications / limitations) ──────────

List<pw.Widget> hospitalizationAuthorityBlock(DirectivePref prefs) => [
      pw.Text('Preferences regarding hospitalization.', style: boldStyle()),
      pw.SizedBox(height: 2),
      checkRow(
        'My agent is authorized to consent to my voluntary admission to a '
        'treatment facility for mental health care.',
        checked: prefs.agentCanConsentHospitalization,
      ),
      checkRow(
        'My agent is not authorized to consent to my voluntary admission to a '
        'treatment facility for mental health care.',
        checked: !prefs.agentCanConsentHospitalization,
      ),
      pw.SizedBox(height: 4),
    ];

List<pw.Widget> medicationAuthorityBlock(DirectivePref prefs) => [
      pw.Text(
        '1. Preferences regarding medications for psychiatric treatment.',
        style: boldStyle(),
      ),
      pw.SizedBox(height: 2),
      checkRow(
        'My agent is authorized to consent to the use of any medications after '
        'consultation with my treating psychiatrist and any other persons my agent '
        'considers appropriate.',
        checked: prefs.agentCanConsentMedication,
      ),
      checkRow(
        'My agent is not authorized to consent to the use of any medications.',
        checked: !prefs.agentCanConsentMedication,
      ),
      pw.SizedBox(height: 4),
    ];

List<pw.Widget> agentLimitationsBlock(DirectivePref prefs) => [
      if (prefs.agentAuthorityLimitations.isNotEmpty) ...[
        pw.SizedBox(height: 4),
        dataBlock(
          'Additional limitations on agent authority:',
          prefs.agentAuthorityLimitations,
        ),
      ],
    ];

// ─── Guardian ───────────────────────────────────────────────────────────────

List<pw.Widget> guardianSection({
  required GuardianNomination? guardian,
  required List<Agent> agents,
  required String docNoun,
}) {
  final g = resolveGuardianDisplay(guardian, agents);
  return [
    pw.Text(
      'I understand that I may nominate a guardian of my person for consideration '
      'by the court if incapacity proceedings are commenced under 20 Pa.C.S. '
      '§ 5511. I understand that the court will appoint a guardian in accordance '
      'with my most recent nomination except for good cause or disqualification. '
      'In the event a court decides to appoint a guardian, I desire the following '
      'person to be appointed:',
      style: bodyStyle(),
    ),
    pw.SizedBox(height: 4),
    if (g.hasNominee) ...[
      dataLine('Name of Person', g.fullName),
      if (g.relationship.isNotEmpty) dataLine('Relationship', g.relationship),
      dataLine('Address', g.address),
      twoCol(
        dataLine('City, State, Zip Code', g.cityStateZip),
        dataLine('Phone Number', g.phone),
      ),
    ] else ...[
      blankLine('Name of Person'),
      blankLine('Address'),
      twoCol(
        blankLine('City, State, Zip Code'),
        blankLine('Phone Number'),
      ),
    ],
    pw.SizedBox(height: 4),
    checkRow(
      'The appointment of a guardian of my person will not give the guardian '
      'the power to revoke, suspend or terminate this $docNoun.',
      checked: guardian == null || !guardian.guardianCanRevoke,
    ),
    checkRow(
      'Upon appointment of a guardian, I authorize the guardian to revoke, '
      'suspend or terminate this $docNoun.',
      checked: guardian != null && guardian.guardianCanRevoke,
    ),
    if (guardian != null && guardian.guardianCanRevoke)
      guardianNote(guardian.guardianCanRevokeNote),
    if (guardian != null &&
        (guardian.guardianCanChangeAgent ||
            guardian.guardianMustConsultAgent)) ...[
      pw.SizedBox(height: 4),
      if (guardian.guardianCanChangeAgent)
        checkRow(
          'The guardian may change my designated agent.',
          checked: true,
        ),
      if (guardian.guardianCanChangeAgent)
        guardianNote(guardian.guardianCanChangeAgentNote),
      if (guardian.guardianMustConsultAgent)
        checkRow(
          'The guardian must consult my agent before acting.',
          checked: true,
        ),
      if (guardian.guardianMustConsultAgent)
        guardianNote(guardian.guardianMustConsultAgentNote),
    ],
  ];
}

// ─── Execution / witnesses / sign-on-behalf ─────────────────────────────────

List<pw.Widget> executionSection({
  required Directive directive,
  required String makingSentence,
  required String signatureLabel,
  required String signOnBehalfNoun,
  required WitnessesData? w1,
  required WitnessesData? w2,
  required bool extraGapAfterSentence,
  required bool withWitnessLabel,
}) =>
    [
      pw.Text(makingSentence, style: bodyStyle()),
      if (extraGapAfterSentence) pw.SizedBox(height: 8),
      if (directive.expirationDate != null)
        dataLine('Expiration Date', formatExecDate(directive.expirationDate)),
      pw.SizedBox(height: 8),
      // signatureBlock already prints a "Name" line — no duplicate name field.
      signatureBlock(signatureLabel, name: directive.fullName),
      dataLine(
        'Address',
        [directive.address, directive.address2]
            .where((s) => s.isNotEmpty)
            .join(', '),
      ),
      twoCol(
        dataLine(
          'City, State, Zip Code',
          composeCityStateZip(directive.city, directive.state, directive.zip),
        ),
        dataLine('Phone Number', directive.phone),
      ),
      if (directive.county.isNotEmpty) dataLine('County', directive.county),
      pw.SizedBox(height: 10),
      if (withWitnessLabel) ...[
        pw.Text('Witness Signatures:', style: boldStyle()),
        pw.SizedBox(height: 4),
      ],
      twoCol(
        signatureBlock('Witness Signature', name: ''),
        signatureBlock('Witness Signature', name: ''),
      ),
      witnessDetailBlock(
        'Witness 1',
        w1?.fullName,
        signatureDate: w1?.signatureDate,
      ),
      witnessDetailBlock(
        'Witness 2',
        w2?.fullName,
        signatureDate: w2?.signatureDate,
      ),
      signOnBehalfBlock(signOnBehalfNoun),
    ];
