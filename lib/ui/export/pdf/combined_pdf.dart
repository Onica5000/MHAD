/// Combined Mental Health Declaration and Power of Attorney PDF layout.
/// Matches the official PA MHAD form pages 25-32 (Disabilities Law Project 2005).
library;

import 'package:mhad/data/database/app_database.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_helpers.dart';

List<pw.Page> buildCombinedPages({
  required Directive directive,
  required List<Agent> agents,
  required DirectivePref? prefs,
  required AdditionalInstructionsTableData? additional,
  required GuardianNomination? guardian,
  required List<MedicationEntry> medications,
  required List<WitnessesData> witnesses,
  List<DiagnosisEntry> diagnoses = const [],
}) {
  const formTitle = 'Combined Declaration & Power of Attorney';

  final primaryAgent =
      agents.where((a) => a.agentType == 'primary').firstOrNull;
  final altAgent =
      agents.where((a) => a.agentType == 'alternate').firstOrNull;

  final exceptions =
      medications.where((m) => m.entryType == 'exception').toList();
  final limitations =
      medications.where((m) => m.entryType == 'limitation').toList();
  final preferred =
      medications.where((m) => m.entryType == 'preferred').toList();

  final parsed = additional != null ? parseOtherField(additional.other) : const ParsedOtherContent();

  // -------------------------------------------------------------------------
  // Pages
  // -------------------------------------------------------------------------

  return [
    // ---- Page 1: Title + Part I (Introduction) ----------------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),

          // Form title
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text(
                  'COMBINED MENTAL HEALTH CARE DECLARATION',
                  style: boldStyle(fontSize: 13),
                ),
                pw.Text(
                  'AND POWER OF ATTORNEY FORM',
                  style: boldStyle(fontSize: 13),
                ),
                pw.SizedBox(height: 8),
              ],
            ),
          ),

          sectionHeader('Part I. Introduction'),
          pw.SizedBox(height: 4),
          pw.Text(
            'I, ${directive.fullName.isNotEmpty ? directive.fullName : '___________________________________________'}, '
            'having capacity to make mental health decisions, '
            'willfully and voluntarily make this Declaration and Power of Attorney '
            'regarding my mental health care. I understand that mental health care includes '
            'any care, treatment, service or procedure to maintain, diagnose, treat or '
            'provide for mental health, including any medication program and therapeutic '
            'treatment. Electroconvulsive therapy may be administered only if I have '
            'specifically consented to it in this document. I will be the subject of '
            'laboratory trials or research only if specifically provided for in this '
            'document. Mental health care does not include psychosurgery or termination '
            'of parental rights. I understand that my incapacity will be determined by '
            'examination by a psychiatrist and one of the following: another psychiatrist, '
            'psychologist, family physician, attending physician or mental health treatment '
            'professional. Whenever possible, one of the decision makers will be one of '
            'my treating professionals.',
            style: bodyStyle(),
          ),
          if (directive.dateOfBirth.isNotEmpty)
            dataLine('Date of Birth', directive.dateOfBirth),
          pw.SizedBox(height: 6),

          // Diagnoses (from wizard diagnoses step)
          if (diagnoses.isNotEmpty) diagnosisList(diagnoses),

          partHeader('A. When this Combined Mental Health Declaration and Power of Attorney becomes effective'),
          pw.Text(
            'This Combined Mental Health Declaration and Power of Attorney becomes '
            'effective at the following designated time:',
            style: bodyStyle(),
          ),
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
          pw.SizedBox(height: 6),

          partHeader('B. Revocation and Amendments'),
          pw.Text(
            'This Combined Mental Health Care Declaration and Power of Attorney may be '
            'revoked in whole or in part at any time, either orally or in writing, as '
            'long as I have not been found to be incapable of making mental health '
            'decisions. My revocation will be effective upon communication to my attending '
            'physician or other mental health care provider, either by me or a witness to '
            'my revocation, of the intent to revoke. If I choose to revoke a particular '
            'instruction contained in this Power of Attorney in the manner specified, I '
            'understand that the other instructions contained in this Power of Attorney '
            'will remain effective until:\n'
            '(1) I revoke this Power of Attorney in its entirety;\n'
            '(2) I make a new combined Mental Health Care Declaration and Power of Attorney; or\n'
            '(3) Two years from the date this document was executed.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'I may make changes to this Advance Directive at any time, as long as I have '
            'capacity to make mental health care decisions. Any changes will be made in '
            'writing and be signed and witnessed by two individuals in the same way as the '
            'original document. Any changes will be effective as soon the changes are '
            'communicated to my attending physician or other mental health care provider, '
            'either by me, my agent, or a witness to my amendments.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),

          partHeader('C. Termination'),
          pw.Text(
            'I understand that this Declaration will automatically terminate two years '
            'from the date of execution, unless I am deemed incapable of making mental '
            'health care decisions at the time that this Declaration would expire.',
            style: bodyStyle(),
          ),
          pw.Spacer(),
          pageFooter('Page 1'),
        ],
      ),
    ),

    // ---- Page 2: Part II — Treatment Preferences (Facility + Medications) --
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          sectionHeader('Part II. Mental Health Declaration'),
          pw.SizedBox(height: 4),
          partHeader('A. Treatment preferences'),
          pw.SizedBox(height: 4),

          // 1. Treatment facility
          pw.Text('1. Choice of treatment facility', style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow('I have a preference for a treatment facility.',
                checked: prefs.treatmentFacilityPref == 'prefer' ||
                    prefs.preferredFacilityName.isNotEmpty),
            checkRow('I have a facility I wish to avoid.',
                checked: prefs.treatmentFacilityPref == 'avoid' ||
                    prefs.avoidFacilityName.isNotEmpty),
            checkRow('I have no preference regarding treatment facility.',
                checked: prefs.treatmentFacilityPref == 'noPreference' &&
                    prefs.preferredFacilityName.isEmpty &&
                    prefs.avoidFacilityName.isEmpty),
          ],
          pw.SizedBox(height: 4),
          pw.Text(
            'In the event that I require commitment to a psychiatric treatment facility, '
            'I would prefer to be admitted to the following facilities:',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 2),
          if (prefs != null && prefs.preferredFacilityName.isNotEmpty)
            facilityList(prefs.preferredFacilityName)
          else ...[
            blankLine('Name of facility'),
            blankLine('Address'),
          ],
          pw.SizedBox(height: 4),
          pw.Text(
            'In the event that I require commitment to a psychiatric treatment facility, '
            'I do not wish to be committed to the following facilities:',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 2),
          if (prefs != null && prefs.avoidFacilityName.isNotEmpty)
            facilityList(prefs.avoidFacilityName)
          else ...[
            blankLine('Name of facility'),
            blankLine('Address'),
          ],
          pw.Text(
            'I understand that my physician may have to place me in a facility that is not my preference.',
            style: smallBodyStyle(),
          ),
          pw.SizedBox(height: 8),

          // 2. Medications
          pw.Text('2. Preferences regarding medications for psychiatric treatment',
              style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'I consent to the medications that my treating physician recommends.',
              checked: prefs.medicationConsent == 'yes' &&
                  exceptions.isEmpty && limitations.isEmpty && preferred.isEmpty,
            ),
            checkRow(
              'I consent to the medications that my treating physician recommends with '
              'the following exceptions, limitations, and/or preferences:',
              checked: prefs.medicationConsent == 'yes' &&
                  (exceptions.isNotEmpty || limitations.isNotEmpty || preferred.isNotEmpty),
            ),
            if (exceptions.isNotEmpty)
              medTable(
                'Exceptions:',
                exceptions.map((m) => {'medication': m.medicationName, 'reason': m.reason}).toList(),
                false,
              ),
            if (limitations.isNotEmpty)
              medTable(
                'I consent to the following medications with these limitations:',
                limitations.map((m) => {'medication': m.medicationName, 'limitation': m.reason, 'reason': ''}).toList(),
                true,
              ),
            if (preferred.isNotEmpty)
              medTable(
                'I prefer the following medications:',
                preferred.map((m) => {'medication': m.medicationName, 'reason': m.reason}).toList(),
                false,
              ),
            if (exceptions.isNotEmpty || limitations.isNotEmpty || preferred.isNotEmpty) ...[
              pw.Text(
                'The exception, limitation, or preference, applies to generic, brand name and '
                'trade name equivalents unless otherwise stated. I understand that dosage '
                'instructions are not binding on my physician.',
                style: smallBodyStyle(),
              ),
              pw.Text(
                'Note: Narrow therapeutic index (NTI) drugs (e.g., lithium, carbamazepine, '
                'valproic acid) cannot have generics substituted under PA law (35 P.S. \u00a7960.3).',
                style: smallBodyStyle(),
              ),
            ],
            checkRow(
              'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to medication.',
              checked: prefs.medicationConsent == 'agentDecides',
            ),
            checkRow(
              'I do not consent to the use of any medications.',
              checked: prefs.medicationConsent == 'no',
            ),
          ],
          pw.Spacer(),
          pageFooter('Page 2'),
        ],
      ),
    ),

    // ---- Page 3: ECT, Experimental, Drug Trials, Additional Instructions ---
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),

          // 3. ECT
          pw.Text('3. Preferences for electroconvulsive therapy (ECT)',
              style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'I consent to the administration of electroconvulsive therapy.',
              checked: prefs.ectConsent == 'yes',
            ),
            if (isConsentConditional(prefs.ectConsent)) ...[
              checkRow(
                'I consent to ECT under the following conditions:',
                checked: true,
              ),
              dataBlock('Conditions:', consentConditionText(prefs.ectConsent)),
            ],
            checkRow(
              'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to electroconvulsive therapy.',
              checked: isConsentAgent(prefs.ectConsent),
            ),
            checkRow(
              'I do not consent to the administration of electroconvulsive therapy.',
              checked: isConsentNo(prefs.ectConsent),
            ),
          ],
          pw.SizedBox(height: 6),

          // 4. Experimental studies
          pw.Text('4. Preferences for experimental studies',
              style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'I consent to participation in experimental studies if my treating physician '
              'believes that the potential benefits to me outweigh the possible risks to me.',
              checked: prefs.experimentalConsent == 'yes',
            ),
            if (isConsentConditional(prefs.experimentalConsent)) ...[
              checkRow(
                'I consent to experimental studies under the following conditions:',
                checked: true,
              ),
              dataBlock('Conditions:', consentConditionText(prefs.experimentalConsent)),
            ],
            checkRow(
              'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to experimental studies.',
              checked: isConsentAgent(prefs.experimentalConsent),
            ),
            checkRow(
              'I do not consent to participation in experimental studies.',
              checked: isConsentNo(prefs.experimentalConsent),
            ),
          ],
          pw.SizedBox(height: 6),

          // 5. Drug trials
          pw.Text('5. Preferences for drug trials',
              style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'I consent to participation in drug trials if my treating physician believes '
              'that the potential benefits to me outweigh the possible risks to me.',
              checked: prefs.drugTrialConsent == 'yes',
            ),
            if (isConsentConditional(prefs.drugTrialConsent)) ...[
              checkRow(
                'I consent to drug trials under the following conditions:',
                checked: true,
              ),
              dataBlock('Conditions:', consentConditionText(prefs.drugTrialConsent)),
            ],
            checkRow(
              'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to drug trials.',
              checked: isConsentAgent(prefs.drugTrialConsent),
            ),
            checkRow(
              'I do not consent to participation in any drug trials.',
              checked: isConsentNo(prefs.drugTrialConsent),
            ),
          ],
          pw.SizedBox(height: 6),

          // 6. Additional instructions
          pw.Text('6. Additional instructions or information.',
              style: boldStyle(fontSize: 9)),
          pw.Text('Examples of other instructions or information that may be included:',
              style: smallBodyStyle()),
          pw.SizedBox(height: 4),
          if (additional != null) ...[
            if (additional.activities.isNotEmpty)
              dataBlock('Activities that help or worsen symptoms:', additional.activities),
            if (additional.crisisIntervention.isNotEmpty)
              dataBlock('Type of intervention preferred in the event of a crisis:',
                  additional.crisisIntervention),
            if (additional.healthHistory.isNotEmpty)
              dataBlock('Mental and physical health history:', additional.healthHistory),
            if (additional.dietary.isNotEmpty)
              dataBlock('Dietary requirements:', additional.dietary),
            if (additional.religious.isNotEmpty)
              dataBlock('Religious preferences:', additional.religious),
            if (additional.childrenCustody.isNotEmpty)
              dataBlock('Temporary custody of children:', additional.childrenCustody),
            if (additional.familyNotification.isNotEmpty)
              dataBlock('Family notification:', additional.familyNotification),
            if (additional.recordsDisclosure.isNotEmpty)
              dataBlock('Limitations on the release or disclosure of mental health records:',
                  additional.recordsDisclosure),
            if (additional.petCustody.isNotEmpty)
              dataBlock('Temporary care and custody of pets:', additional.petCustody),
            // Tagged content from 'other' field
            if (parsed.deEscalation.isNotEmpty)
              dataBlock('De-escalation techniques:', parsed.deEscalation),
            if (parsed.triggers.isNotEmpty)
              dataBlock('Crisis triggers:', parsed.triggers),
            if (parsed.reproductiveHealth.isNotEmpty)
              dataBlock('Reproductive health preferences:', parsed.reproductiveHealth),
            if (parsed.ectGuidance.isNotEmpty)
              dataBlock('ECT guidance notes:', parsed.ectGuidance),
            if (parsed.experimentalGuidance.isNotEmpty)
              dataBlock('Experimental studies guidance:', parsed.experimentalGuidance),
            if (parsed.drugTrialGuidance.isNotEmpty)
              dataBlock('Drug trials guidance:', parsed.drugTrialGuidance),
            if (parsed.otherText.isNotEmpty)
              dataBlock('Other matters of importance:', parsed.otherText),
          ],
          pw.Spacer(),
          pageFooter('Page 3'),
        ],
      ),
    ),

    // ---- Page 4: Part III — Power of Attorney (Agent + Alt Agent) ----------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          sectionHeader('Part III. Mental Health Care Power of Attorney'),
          pw.SizedBox(height: 4),
          pw.Text(
            'I, ${directive.fullName.isNotEmpty ? directive.fullName : '___________________________________________'}, '
            'having the capacity to make mental health decisions, '
            'authorize my designated health care agent to make certain decisions on my behalf '
            'regarding my mental health care. If I have not expressed a choice in this document '
            'or in the accompanying Declaration, I authorize my agent to make the decision that '
            'my agent determines is the decision I would make if I were competent to do so.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 8),

          // A. Designation of agent
          partHeader('A. Designation of agent'),
          pw.Text(
            'I hereby designate and appoint the following person as my agent to make mental '
            'health care decisions for me as authorized in this document. This authorization '
            'applies only to mental health decisions that are not addressed in the '
            'accompanying signed Declaration.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          dataLine('Name of designated person', primaryAgent?.fullName ?? ''),
          if (primaryAgent != null && primaryAgent.relationship.isNotEmpty)
            dataLine('Relationship', primaryAgent.relationship),
          dataLine('Address', primaryAgent?.address ?? ''),
          twoCol(
            blankLine('City, State, Zip Code'),
            dataLine('Phone Number',
                _agentPhone(primaryAgent)),
          ),
          pw.SizedBox(height: 4),
          pw.Text("Agent's acceptance:", style: boldStyle(fontSize: 9)),
          pw.Text(
            'I hereby accept designation as mental health care agent for '
            '${directive.fullName.isNotEmpty ? directive.fullName : '(insert name of declarant)'}.',
            style: bodyStyle(),
          ),
          signatureBlock("Agent's Signature", name: primaryAgent?.fullName ?? ''),

          pw.SizedBox(height: 8),

          // B. Designation of alternative agent
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
          dataLine('Address', altAgent?.address ?? ''),
          twoCol(
            blankLine('City, State, Zip Code'),
            dataLine('Phone Number', _agentPhone(altAgent)),
          ),
          pw.SizedBox(height: 4),
          pw.Text("Alternative Agent's acceptance:", style: boldStyle(fontSize: 9)),
          pw.Text(
            'I hereby accept designation as alternative mental health care agent for '
            '${directive.fullName.isNotEmpty ? directive.fullName : '(insert name of declarant)'}.',
            style: bodyStyle(),
          ),
          signatureBlock("Alternate Agent's Signature", name: altAgent?.fullName ?? ''),

          pw.Spacer(),
          pageFooter('Page 4'),
        ],
      ),
    ),

    // ---- Page 5: Part III C (Authority) + Part IV (Guardian) ---------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          partHeader('C. Authority granted to my mental health care agent'),
          pw.Text(
            'I hereby grant to my agent full power and authority to make mental health '
            'care decisions for me consistent with the instructions and limitations set '
            'forth in this document. If I have not expressed a choice in this Power of '
            'Attorney, or in the accompanying Declaration, I authorize my agent to make '
            'the decision that my agent determines is the decision I would make if I '
            'were competent to do so.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),
          if (prefs != null) ...[
            // Hospitalization
            pw.Text('Preferences regarding hospitalization.',
                style: boldStyle(fontSize: 9)),
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

            // 1. Medications
            pw.Text('1. Preferences regarding medications for psychiatric treatment.',
                style: boldStyle(fontSize: 9)),
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

            // 2. ECT
            pw.Text('2. Preferences regarding electroconvulsive therapy (ECT).',
                style: boldStyle(fontSize: 9)),
            pw.SizedBox(height: 2),
            checkRow(
              'My agent is authorized to consent to the administration of '
              'electroconvulsive therapy.',
              checked: isConsentAgent(prefs.ectConsent),
            ),
            checkRow(
              'My agent is not authorized to consent to the administration of '
              'electroconvulsive therapy.',
              checked: !isConsentAgent(prefs.ectConsent),
            ),
            pw.SizedBox(height: 4),

            // 3. Experimental studies
            pw.Text('3. Preferences for experimental studies.',
                style: boldStyle(fontSize: 9)),
            pw.SizedBox(height: 2),
            checkRow(
              'My agent is authorized to consent to my participation in experimental '
              'studies if, after consultation with my treating physician and any other '
              'individuals my agent deems appropriate, my agent believes that the '
              'potential benefits to me outweigh the possible risks to me.',
              checked: isConsentAgent(prefs.experimentalConsent),
            ),
            checkRow(
              'My agent is not authorized to consent to my participation in '
              'experimental studies.',
              checked: !isConsentAgent(prefs.experimentalConsent),
            ),
            pw.SizedBox(height: 4),

            // 4. Drug trials
            pw.Text('4. Preferences regarding drug trials.',
                style: boldStyle(fontSize: 9)),
            pw.SizedBox(height: 2),
            checkRow(
              'My agent is authorized to consent to my participation in drug trials '
              'if, after consultation with my treating physician and any other '
              'individuals my agent deems appropriate, my agent believes that the '
              'potential benefits to me outweigh the possible risks to me.',
              checked: isConsentAgent(prefs.drugTrialConsent),
            ),
            checkRow(
              'My agent is not authorized to consent to my participation in drug trials.',
              checked: !isConsentAgent(prefs.drugTrialConsent),
            ),
            if (prefs.agentAuthorityLimitations.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              dataBlock('Additional limitations on agent authority:',
                  prefs.agentAuthorityLimitations),
            ],
          ],
          pw.SizedBox(height: 8),

          // Part IV — Guardian
          sectionHeader('PART IV. Nominating a Guardian'),
          pw.SizedBox(height: 4),
          partHeader('A. Preference as to a court-appointed guardian'),
          pw.Text(
            'I understand that I may nominate a guardian of my person for consideration by '
            'the court if incapacity proceedings are commenced under 20 Pa.C.S. \u00A7 5511. '
            'I understand that the court will appoint a guardian in accordance with my most '
            'recent nomination except for good cause or disqualification. In the event a '
            'court decides to appoint a guardian, I desire the following person to be appointed:',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          if (guardian != null && guardian.nomineeFullName.isNotEmpty) ...[
            dataLine('Name of Person', guardian.nomineeFullName),
            if (guardian.nomineeRelationship.isNotEmpty)
              dataLine('Relationship', guardian.nomineeRelationship),
            dataLine('Address', guardian.nomineeAddress),
            twoCol(
              blankLine('City, State, Zip Code'),
              dataLine('Phone Number', guardian.nomineePhone),
            ),
          ] else ...[
            blankLine('Name of Person'),
            blankLine('Address'),
            twoCol(blankLine('City, State, Zip Code'), blankLine('Phone Number')),
          ],
          pw.SizedBox(height: 4),
          checkRow(
            'The appointment of a guardian of my person will not give the guardian the '
            'power to revoke, suspend or terminate this Combined Mental Health Care '
            'Declaration and Power of Attorney.',
            checked: guardian == null || !guardian.guardianCanRevoke,
          ),
          checkRow(
            'Upon appointment of a guardian, I authorize the guardian to revoke, suspend '
            'or terminate this Combined Mental Health Care Declaration and Power of Attorney.',
            checked: guardian != null && guardian.guardianCanRevoke,
          ),

          pw.Spacer(),
          pageFooter('Page 5'),
        ],
      ),
    ),

    // ---- Page 6: Part V — Execution ----------------------------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) {
        final w1 = witnesses.where((w) => w.witnessNumber == 1).firstOrNull;
        final w2 = witnesses.where((w) => w.witnessNumber == 2).firstOrNull;
        final dateStr = formatExecDate(directive.executionDate);

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pageHeader(formTitle),
            sectionHeader('PART V. Execution'),
            pw.SizedBox(height: 6),
            pw.Text(
              'I am making this Combined Mental Health Care Declaration and Power of '
              'Attorney on the $dateStr.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 8),
            if (directive.expirationDate != null)
              dataLine('Expiration Date', formatExecDate(directive.expirationDate)),
            pw.SizedBox(height: 8),
            signatureBlock('My Signature', name: directive.fullName),
            dataLine('My Name', directive.fullName),
            dataLine('Address',
                [directive.address, directive.address2, directive.city, directive.state, directive.zip]
                    .where((s) => s.isNotEmpty)
                    .join(', ')),
            dataLine('Phone Number', directive.phone),
            pw.SizedBox(height: 10),

            // Witness signatures side by side
            pw.Text('Witness Signatures:', style: boldStyle()),
            pw.SizedBox(height: 4),
            twoCol(
              signatureBlock('Witness Signature', name: ''),
              signatureBlock('Witness Signature', name: ''),
            ),

            // Witness 1 details
            witnessDetailBlock('Witness 1', w1?.fullName, w1?.address,
                phone: w1?.phone, signatureDate: w1?.signatureDate),
            // Witness 2 details
            witnessDetailBlock('Witness 2', w2?.fullName, w2?.address,
                phone: w2?.phone, signatureDate: w2?.signatureDate),

            // Signing on behalf
            signOnBehalfBlock(
                'Combined Mental Health Care Declaration and Power of Attorney'),

            pw.Spacer(),
            pw.Text(
              'Disabilities Law Project 2005. All Rights Reserved.',
              style: pw.TextStyle(fontSize: 7, color: kDarkGrey),
            ),
          ],
        );
      },
    ),
  ];
}

/// Get the first non-empty phone from an agent.
String _agentPhone(Agent? agent) {
  if (agent == null) return '';
  return [agent.homePhone, agent.workPhone, agent.cellPhone]
      .firstWhere((p) => p.isNotEmpty, orElse: () => '');
}
