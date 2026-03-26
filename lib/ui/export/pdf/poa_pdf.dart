/// Mental Health Power of Attorney PDF layout.
/// Matches the official PA MHAD POA form pages 39-46 (Disabilities Law Project 2005).
library;

import 'package:mhad/data/database/app_database.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_helpers.dart';

List<pw.Page> buildPoaPages({
  required Directive directive,
  required List<Agent> agents,
  required DirectivePref? prefs,
  required AdditionalInstructionsTableData? additional,
  required GuardianNomination? guardian,
  required List<MedicationEntry> medications,
  required List<WitnessesData> witnesses,
  List<DiagnosisEntry> diagnoses = const [],
}) {
  const formTitle = 'Mental Health Power of Attorney';

  final primaryAgent =
      agents.where((a) => a.agentType == 'primary').firstOrNull;
  final altAgent =
      agents.where((a) => a.agentType == 'alternate').firstOrNull;

  final exceptions =
      medications.where((m) => m.entryType == 'exception').toList();
  final limitations =
      medications.where((m) => m.entryType == 'limitation').toList();
  final parsed = additional != null ? parseOtherField(additional.other) : const ParsedOtherContent();

  return [
    // ---- Page 1: Introduction + Agent + Alt Agent -------------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          pw.Center(
            child: pw.Text(
              'MENTAL HEALTH POWER OF ATTORNEY',
              style: boldStyle(fontSize: 13),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'I, ${directive.fullName.isNotEmpty ? directive.fullName : '___________________________________________'}, '
            'having the capacity to make mental health decisions, '
            'authorize my designated health care agent to make certain decisions on my behalf '
            'regarding my mental health care. If I have not expressed a choice in this '
            'document, I authorize my agent to make the decision that my agent determines is '
            'the decision I would make if I were competent to do so.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'I understand that mental health care includes any care, treatment, service or '
            'procedure to maintain, diagnose, treat or provide for mental health, including '
            'any medication program and therapeutic treatment. Electroconvulsive therapy may '
            'be administered only if I have specifically consented to it in this document. '
            'I will be the subject of laboratory trials or research only if specifically '
            'provided for in this document. Mental health care does not include psychosurgery '
            'or termination of parental rights.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'I understand that my incapacity will be determined by examination by a '
            'psychiatrist and one of the following: another psychiatrist, psychologist, '
            'family physician, attending physician or mental health treatment professional. '
            'Whenever possible, one of the decision makers shall be one of my treating '
            'professionals.',
            style: bodyStyle(),
          ),
          if (directive.dateOfBirth.isNotEmpty)
            dataLine('Date of Birth', directive.dateOfBirth),
          pw.SizedBox(height: 6),

          if (diagnoses.isNotEmpty) diagnosisList(diagnoses),

          // A. Designation of agent
          partHeader('A. Designation of agent'),
          pw.Text(
            'I hereby designate and appoint the following person as my agent to make '
            'mental health care decisions for me as authorized in this document.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          dataLine('Name of designated person', primaryAgent?.fullName ?? ''),
          if (primaryAgent != null && primaryAgent.relationship.isNotEmpty)
            dataLine('Relationship', primaryAgent.relationship),
          dataLine('Address', primaryAgent?.address ?? ''),
          twoCol(
            blankLine('City, State, Zip Code'),
            dataLine('Phone Number', _agentPhone(primaryAgent)),
          ),
          pw.SizedBox(height: 4),
          pw.Text("Agent's acceptance:", style: boldStyle(fontSize: 9)),
          pw.Text(
            'I hereby accept designation as mental health care agent for '
            '${directive.fullName.isNotEmpty ? directive.fullName : '(insert name of declarant)'}.',
            style: bodyStyle(),
          ),
          signatureBlock("Agent's Signature", name: primaryAgent?.fullName ?? ''),
          pw.SizedBox(height: 6),

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
          pw.Spacer(),
          pageFooter('Page 1'),
        ],
      ),
    ),

    // ---- Page 2: Alt Agent Acceptance + Effective Condition + Authority ----
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),

          // Alt agent acceptance
          pw.Text("Alternative Agent's acceptance:", style: boldStyle(fontSize: 9)),
          pw.Text(
            'I hereby accept designation as alternative mental health care agent for '
            '${directive.fullName.isNotEmpty ? directive.fullName : '(insert name of declarant)'}.',
            style: bodyStyle(),
          ),
          signatureBlock("Alternate Agent's Signature", name: altAgent?.fullName ?? ''),
          pw.SizedBox(height: 8),

          // C. When this Power of Attorney becomes effective
          partHeader('C. When this Power of Attorney becomes effective'),
          pw.Text(
            'This Power of Attorney will become effective at the following designated time:',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          checkRow(
            'When I am deemed incapable of making mental health care decisions. I would '
            'prefer the following doctor(s) to evaluate me for my ability to make mental '
            'health decisions:',
            checked: directive.effectiveCondition.isEmpty,
          ),
          dataLine('Name of Doctor', directive.preferredDoctorName),
          dataLine('Address/Phone Number', directive.preferredDoctorContact),
          pw.SizedBox(height: 4),
          checkRow(
            'When the following condition is met:',
            checked: directive.effectiveCondition.isNotEmpty,
          ),
          if (directive.effectiveCondition.isNotEmpty)
            dataLine('Condition', directive.effectiveCondition),
          pw.SizedBox(height: 8),

          // D. Authority granted
          partHeader('D. Authority granted to my mental health care agent'),
          pw.Text(
            'I hereby grant to my agent full power and authority to make mental health '
            'care decisions for me consistent with the instructions and limitations set '
            'forth in this Power of Attorney. If I have not expressed a choice in this '
            'Power of Attorney, I authorize my agent to make the decision that my agent '
            'determines is the decision I would make if I were competent to do so.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),

          // 1. Treatment preferences — (a) Treatment facility
          pw.Text('1. Treatment preferences.', style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          pw.Text('(a). Choice of treatment facility.',
              style: boldStyle(fontSize: 9)),
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

          pw.Spacer(),
          pageFooter('Page 2'),
        ],
      ),
    ),

    // ---- Page 3: Medications + ECT + Experimental + Drug Trials -----------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),

          // Hospitalization authority
          if (prefs != null) ...[
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
          ],

          // (b). Medications
          pw.Text('(b). Preferences regarding medications for psychiatric treatment.',
              style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'I consent to the medications that my agent agrees to after consultation '
              'with my treating physician and any other persons my agent considers appropriate.',
              checked: (prefs.medicationConsent == 'yes' ||
                  prefs.medicationConsent == 'agentDecides') &&
                  exceptions.isEmpty && limitations.isEmpty,
            ),
            checkRow(
              'I consent to the medications that my agent agrees to, with the following '
              'exceptions or limitations:',
              checked: (prefs.medicationConsent == 'yes' ||
                  prefs.medicationConsent == 'agentDecides') &&
                  (exceptions.isNotEmpty || limitations.isNotEmpty),
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
            if (exceptions.isNotEmpty || limitations.isNotEmpty)
              pw.Text(
                'The exception or limitation applies to generic, brand name and trade name '
                'equivalents unless otherwise stated. I understand that dosage instructions '
                'are not binding on my physician.',
                style: smallBodyStyle(),
              ),
            checkRow(
              'My agent is not authorized to consent to the use of any medications.',
              checked: prefs.medicationConsent == 'no',
            ),
          ],
          pw.SizedBox(height: 6),

          // (c). ECT
          pw.Text('(c). Preferences regarding electroconvulsive therapy (ECT).',
              style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'My agent is authorized to consent to the administration of '
              'electroconvulsive therapy.',
              checked: isConsentAgent(prefs.ectConsent),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                'NOTE: Your agent MAY NOT consent to ECT unless you initial this authorization.',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: kBlack),
              ),
            ),
            checkRow(
              'My agent is not authorized to consent to the administration of '
              'electroconvulsive therapy.',
              checked: !isConsentAgent(prefs.ectConsent),
            ),
          ],
          pw.SizedBox(height: 6),

          // (d). Experimental studies
          pw.Text('(d). Preferences for experimental studies.',
              style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'My agent is authorized to consent to my participation in experimental '
              'studies if, after consultation with my treating physician and any other '
              'individuals my agent deems appropriate, my agent believes that the '
              'potential benefits to me outweigh the possible risks to me.',
              checked: isConsentAgent(prefs.experimentalConsent),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                'NOTE: Your agent MAY NOT consent to experimental studies unless you initial this authorization.',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: kBlack),
              ),
            ),
            checkRow(
              'My agent is not authorized to consent to my participation in '
              'experimental studies.',
              checked: !isConsentAgent(prefs.experimentalConsent),
            ),
          ],
          pw.SizedBox(height: 6),

          // (e). Drug trials
          pw.Text('(e). Preferences regarding drug trials.',
              style: boldStyle(fontSize: 9)),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'My agent is authorized to consent to my participation in drug trials '
              'if, after consultation with my treating physician and any other '
              'individuals my agent deems appropriate, my agent believes that the '
              'potential benefits to me outweigh the possible risks to me.',
              checked: isConsentAgent(prefs.drugTrialConsent),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 20),
              child: pw.Text(
                'NOTE: Your agent MAY NOT consent to research including drug trials unless you initial this authorization.',
                style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: kBlack),
              ),
            ),
            checkRow(
              'My agent is not authorized to consent to my participation in drug trials.',
              checked: !isConsentAgent(prefs.drugTrialConsent),
            ),
          ],
          if (prefs != null && prefs.agentAuthorityLimitations.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            dataBlock('Additional limitations on agent authority:',
                prefs.agentAuthorityLimitations),
          ],

          pw.Spacer(),
          pageFooter('Page 3'),
        ],
      ),
    ),

    // ---- Page 4: Additional Instructions ----------------------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          pw.Text('(f). Additional instructions or information.',
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
          pageFooter('Page 4'),
        ],
      ),
    ),

    // ---- Page 5: Revocation + Termination + Guardian ----------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),

          // E. Revocation and Amendments
          partHeader('E. Revocation and Amendments'),
          pw.Text(
            'This Power of Attorney may be revoked in whole or in part at any time, either '
            'orally or in writing, as long as I have not been found to be incapable of '
            'making mental health decisions. My revocation will be effective upon '
            'communication to my attending physician or other mental health care provider, '
            'either by me or a witness to my revocation, of the intent to revoke. If I '
            'choose to revoke a particular instruction contained in this Power of Attorney '
            'in the manner specified, I understand that the other instructions contained in '
            'this Power of Attorney will remain effective until:\n'
            '(4) I revoke this Power of Attorney in its entirety;\n'
            '(5) I make a new combined Mental Health Care Declaration and Power of Attorney; or\n'
            '(6) Two years from the date this document was executed.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'I may make changes to this Power of Attorney at any time, as long as I have '
            'capacity to make mental health care decisions. Any changes will be made in '
            'writing and be signed and witnessed by two individuals in the same way the '
            'original document was executed. Any changes will be effective as soon the '
            'changes are communicated to my attending physician or other mental health '
            'care provider, either by me, my agent, or a witness to my amendments.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),

          // F. Termination
          partHeader('F. Termination'),
          pw.Text(
            'I understand that this Power of Attorney will automatically terminate two '
            'years from the date of execution unless I am deemed incapable of making '
            'mental health care decisions at the time that the Power of Attorney would expire.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),

          // G. Guardian
          partHeader('G. Preference as to a court-appointed guardian'),
          pw.Text(
            'I understand that I may nominate a guardian of my person for consideration '
            'by the court if incapacity proceedings are commenced under 20 Pa.C.S. '
            '\u00A7 5511. I understand that the court will appoint a guardian in accordance '
            'with my most recent nomination except for good cause or disqualification. '
            'In the event a court decides to appoint a guardian, I desire the following '
            'person to be appointed:',
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
            'power to revoke, suspend or terminate this Power of Attorney.',
            checked: guardian == null || !guardian.guardianCanRevoke,
          ),
          checkRow(
            'Upon appointment of a guardian, I authorize the guardian to revoke, suspend '
            'or terminate this Power of Attorney.',
            checked: guardian != null && guardian.guardianCanRevoke,
          ),

          pw.Spacer(),
          pageFooter('Page 5'),
        ],
      ),
    ),

    // ---- Page 6: Execution ------------------------------------------------
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

            // H. Execution
            partHeader('H. Execution'),
            pw.Text(
              'I am making this Mental Health Care Power of Attorney on the $dateStr.',
              style: bodyStyle(),
            ),
            if (directive.expirationDate != null)
              dataLine('Expiration Date', formatExecDate(directive.expirationDate)),
            pw.SizedBox(height: 8),
            signatureBlock('Principal Signature', name: directive.fullName),
            dataLine('Name of Principal', directive.fullName),
            dataLine('Address',
                [directive.address, directive.address2, directive.city, directive.state, directive.zip]
                    .where((s) => s.isNotEmpty)
                    .join(', ')),
            dataLine('Phone Number', directive.phone),
            pw.SizedBox(height: 10),

            // Witness signatures
            twoCol(
              signatureBlock('Witness Signature', name: ''),
              signatureBlock('Witness Signature', name: ''),
            ),

            // Witness details
            witnessDetailBlock('Witness 1', w1?.fullName, w1?.address,
                phone: w1?.phone, signatureDate: w1?.signatureDate),
            witnessDetailBlock('Witness 2', w2?.fullName, w2?.address,
                phone: w2?.phone, signatureDate: w2?.signatureDate),

            // Signing on behalf
            signOnBehalfBlock('Mental Health Care Power of Attorney'),

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
