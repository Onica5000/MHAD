/// Combined Mental Health Declaration and Power of Attorney PDF layout.
/// Layout based on the official PA MHAD form (Disabilities Law Project 2005).
library;

import 'package:mhad/data/database/app_database.dart';
import 'package:pdf/pdf.dart';
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

  // ---------------------------------------------------------------------------
  // Pages
  // ---------------------------------------------------------------------------

  return [
    // ---- Page 1: Title + Part I + Part II sections 1–2 --------------------
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

          sectionHeader('PART I. INTRODUCTION'),
          pw.SizedBox(height: 4),
          pw.Text(
            'I, ${directive.fullName}, having capacity to make mental health decisions, '
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
          pw.SizedBox(height: 6),

          partHeader('A. When this Combined Mental Health Declaration and Power of Attorney becomes effective'),
          pw.Text(
            'This Combined Mental Health Declaration and Power of Attorney becomes '
            'effective at the following designated time:',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          checkRow(
            'When I am deemed incapable of making mental health care decisions.',
            checked: directive.effectiveCondition.isNotEmpty
                ? directive.effectiveCondition.toLowerCase().contains('incapab') ||
                    directive.effectiveCondition.toLowerCase().contains('incapac') ||
                    directive.effectiveCondition.toLowerCase().contains('deemed')
                : true,
          ),
          dataLine('Preferred doctor(s) for evaluation', ''),
          pw.SizedBox(height: 2),
          pw.Text(
            'Effective condition: ${directive.effectiveCondition}',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),

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
            'will remain effective until: (1) I revoke this Power of Attorney in its '
            'entirety; (2) I make a new combined Mental Health Care Declaration and Power '
            'of Attorney; or (3) Two years from the date this document was executed.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),

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

    // ---- Page 2: Part II — Treatment Preferences --------------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          sectionHeader('PART II. MENTAL HEALTH DECLARATION — A. Treatment Preferences'),
          pw.SizedBox(height: 6),

          // Treatment facility
          partHeader('1. Choice of Treatment Facility'),
          if (prefs != null && prefs.preferredFacilityName.isNotEmpty) ...[
            checkRow(
              'In the event that I require commitment to a psychiatric treatment facility, '
              'I would prefer to be admitted to the following facility:',
              checked: true,
            ),
            dataLine('Name of facility', _facilityName(prefs.preferredFacilityName)),
            if (_facilityLocation(prefs.preferredFacilityName).isNotEmpty)
              dataLine('Location', _facilityLocation(prefs.preferredFacilityName)),
          ] else
            checkRow(
              'In the event that I require commitment to a psychiatric treatment facility, '
              'I would prefer to be admitted to the following facility:',
            ),
          if (prefs != null && prefs.avoidFacilityName.isNotEmpty) ...[
            checkRow(
              'In the event that I require commitment to a psychiatric treatment facility, '
              'I do not wish to be committed to the following facility:',
              checked: true,
            ),
            dataLine('Name of facility', _facilityName(prefs.avoidFacilityName)),
            if (_facilityLocation(prefs.avoidFacilityName).isNotEmpty)
              dataLine('Location', _facilityLocation(prefs.avoidFacilityName)),
          ] else
            checkRow(
              'In the event that I require commitment to a psychiatric treatment facility, '
              'I do not wish to be committed to the following facility:',
            ),
          pw.Text(
            'I understand that my physician may have to place me in a facility that is not my preference.',
            style: smallBodyStyle(),
          ),
          pw.SizedBox(height: 8),

          // Medications
          partHeader('2. Preferences Regarding Medications for Psychiatric Treatment'),
          if (prefs != null) ...[
            checkRow(
              'I consent to the medications that my treating physician recommends.',
              checked: prefs.medicationConsent == 'yes',
            ),
            if (exceptions.isNotEmpty || limitations.isNotEmpty || preferred.isNotEmpty) ...[
              checkRow(
                'I consent to the medications that my treating physician recommends '
                'with the following exceptions, limitations, and/or preferences:',
                checked: exceptions.isNotEmpty ||
                    limitations.isNotEmpty ||
                    preferred.isNotEmpty,
              ),
              pw.SizedBox(height: 4),
              if (exceptions.isNotEmpty)
                medTable(
                  'Exceptions (medications I do NOT consent to):',
                  exceptions
                      .map((m) => {
                            'medication': m.medicationName,
                            'reason': m.reason,
                          })
                      .toList(),
                  false,
                ),
              if (limitations.isNotEmpty)
                medTable(
                  'I consent to the following medications with these limitations:',
                  limitations
                      .map((m) => {
                            'medication': m.medicationName,
                            'limitation': m.reason,
                            'reason': '',
                          })
                      .toList(),
                  true,
                ),
              if (preferred.isNotEmpty)
                medTable(
                  'I prefer the following medications:',
                  preferred
                      .map((m) => {
                            'medication': m.medicationName,
                            'reason': m.reason,
                          })
                      .toList(),
                  false,
                ),
              pw.Text(
                'The exception, limitation, or preference, applies to generic, brand name and '
                'trade name equivalents unless otherwise stated. I understand that dosage '
                'instructions are not binding on my physician.',
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
          sectionHeader('PART II. MENTAL HEALTH DECLARATION — A. Treatment Preferences (continued)'),
          pw.SizedBox(height: 6),

          // ECT
          partHeader('3. Preferences for Electroconvulsive Therapy (ECT)'),
          if (prefs != null) ...[
            checkRow(
              'I consent to the administration of electroconvulsive therapy.',
              checked: prefs.ectConsent == 'yes',
            ),
            checkRow(
              'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to electroconvulsive therapy.',
              checked: prefs.ectConsent == 'agentDecides',
            ),
            checkRow(
              'I do not consent to the administration of electroconvulsive therapy.',
              checked: prefs.ectConsent == 'no',
            ),
          ],
          pw.SizedBox(height: 6),

          // Experimental
          partHeader('4. Preferences for Experimental Studies'),
          if (prefs != null) ...[
            checkRow(
              'I consent to participation in experimental studies if my treating physician '
              'believes that the potential benefits to me outweigh the possible risks to me.',
              checked: prefs.experimentalConsent == 'yes',
            ),
            checkRow(
              'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to experimental studies.',
              checked: prefs.experimentalConsent == 'agentDecides',
            ),
            checkRow(
              'I do not consent to participation in experimental studies.',
              checked: prefs.experimentalConsent == 'no',
            ),
          ],
          pw.SizedBox(height: 6),

          // Drug trials
          partHeader('5. Preferences for Drug Trials'),
          if (prefs != null) ...[
            checkRow(
              'I consent to participation in drug trials if my treating physician believes '
              'that the potential benefits to me outweigh the possible risks to me.',
              checked: prefs.drugTrialConsent == 'yes',
            ),
            checkRow(
              'I have designated an agent under the Power of Attorney portion of this '
              'document to make decisions related to drug trials.',
              checked: prefs.drugTrialConsent == 'agentDecides',
            ),
            checkRow(
              'I do not consent to participation in any drug trials.',
              checked: prefs.drugTrialConsent == 'no',
            ),
          ],
          pw.SizedBox(height: 6),

          // Additional instructions
          sectionHeader('6. Additional Instructions or Information'),
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
              dataBlock(
                  'Limitations on the release or disclosure of mental health records:',
                  additional.recordsDisclosure),
            if (additional.petCustody.isNotEmpty)
              dataBlock('Temporary care and custody of pets:', additional.petCustody),
            if (additional.other.isNotEmpty)
              dataBlock('Other matters of importance:', additional.other),
          ],
          pw.Spacer(),
          pageFooter('Page 3'),
        ],
      ),
    ),

    // ---- Page 4: Part III — Power of Attorney (Agent) ----------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          sectionHeader('PART III. MENTAL HEALTH CARE POWER OF ATTORNEY'),
          pw.SizedBox(height: 6),
          pw.Text(
            'I, ${directive.fullName}, having the capacity to make mental health decisions, '
            'authorize my designated health care agent to make certain decisions on my behalf '
            'regarding my mental health care. If I have not expressed a choice in this document '
            'or in the accompanying Declaration, I authorize my agent to make the decision that '
            'my agent determines is the decision I would make if I were competent to do so.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 8),

          partHeader('A. Designation of Agent'),
          pw.Text(
            'I hereby designate and appoint the following person as my agent to make mental '
            'health care decisions for me as authorized in this document. This authorization '
            'applies only to mental health decisions that are not addressed in the '
            'accompanying signed Declaration.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          if (primaryAgent != null) ...[
            dataLine('Name of designated person', primaryAgent.fullName),
            dataLine('Address', primaryAgent.address),
            twoCol(
              blankLine('City, State, Zip Code'),
              dataLine(
                'Phone Number',
                [primaryAgent.homePhone, primaryAgent.workPhone, primaryAgent.cellPhone]
                    .firstWhere((p) => p.isNotEmpty, orElse: () => ''),
              ),
            ),
          ] else ...[
            blankLine('Name of designated person'),
            blankLine('Address'),
            twoCol(blankLine('City, State, Zip Code'), blankLine('Phone Number')),
          ],
          pw.SizedBox(height: 4),
          pw.Text(
            'Agent\'s acceptance: I hereby accept designation as mental health care agent '
            'for ${directive.fullName}.',
            style: bodyStyle(),
          ),
          signatureBlock(
            'Agent\'s Signature',
            name: primaryAgent?.fullName ?? '',
          ),

          pw.SizedBox(height: 8),
          partHeader('B. Designation of Alternative Agent'),
          pw.Text(
            'In the event that my first agent is unavailable or unable to serve as my '
            'mental health care agent, I hereby designate and appoint the following '
            'individual as my alternative mental health care agent:',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          if (altAgent != null) ...[
            dataLine('Name of designated person', altAgent.fullName),
            dataLine('Address', altAgent.address),
            twoCol(
              blankLine('City, State, Zip Code'),
              dataLine(
                'Phone Number',
                [altAgent.homePhone, altAgent.workPhone, altAgent.cellPhone]
                    .firstWhere((p) => p.isNotEmpty, orElse: () => ''),
              ),
            ),
          ] else ...[
            blankLine('Name of designated person'),
            blankLine('Address'),
            twoCol(blankLine('City, State, Zip Code'), blankLine('Phone Number')),
          ],
          pw.Text(
            'Alternative Agent\'s acceptance: I hereby accept designation as alternative '
            'mental health care agent for ${directive.fullName}.',
            style: bodyStyle(),
          ),
          signatureBlock(
            'Alternate Agent\'s Signature',
            name: altAgent?.fullName ?? '',
          ),

          pw.Spacer(),
          pageFooter('Page 4'),
        ],
      ),
    ),

    // ---- Page 5: Part III C — Authority + Part IV + Part V (Execution) ----
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          partHeader('C. Authority Granted to My Mental Health Care Agent'),
          pw.Text(
            'I hereby grant to my agent full power and authority to make mental health '
            'care decisions for me consistent with the instructions and limitations set '
            'forth in this document.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            pw.Text('1. Medications:', style: boldStyle(fontSize: 8.5)),
            checkRow(
              'My agent is authorized to consent to the use of any medications after '
              'consultation with my treating psychiatrist.',
              checked: prefs.agentCanConsentMedication,
            ),
            checkRow(
              'My agent is not authorized to consent to the use of any medications.',
              checked: !prefs.agentCanConsentMedication,
            ),
            pw.SizedBox(height: 4),
            pw.Text('2. Electroconvulsive Therapy (ECT):', style: boldStyle(fontSize: 8.5)),
            checkRow(
              'My agent is authorized to consent to the administration of electroconvulsive therapy.',
              checked: prefs.ectConsent == 'agentDecides',
            ),
            checkRow(
              'My agent is not authorized to consent to the administration of electroconvulsive therapy.',
              checked: prefs.ectConsent != 'agentDecides',
            ),
            pw.SizedBox(height: 4),
            pw.Text('3. Experimental Studies:', style: boldStyle(fontSize: 8.5)),
            checkRow(
              'My agent is authorized to consent to my participation in experimental studies.',
              checked: prefs.experimentalConsent == 'agentDecides',
            ),
            checkRow(
              'My agent is not authorized to consent to my participation in experimental studies.',
              checked: prefs.experimentalConsent != 'agentDecides',
            ),
            pw.SizedBox(height: 4),
            pw.Text('4. Drug Trials:', style: boldStyle(fontSize: 8.5)),
            checkRow(
              'My agent is authorized to consent to my participation in drug trials.',
              checked: prefs.drugTrialConsent == 'agentDecides',
            ),
            checkRow(
              'My agent is not authorized to consent to my participation in drug trials.',
              checked: prefs.drugTrialConsent != 'agentDecides',
            ),
            if (prefs.agentAuthorityLimitations.isNotEmpty) ...[
              pw.SizedBox(height: 4),
              dataBlock('Additional limitations on agent authority:', prefs.agentAuthorityLimitations),
            ],
          ],
          pw.SizedBox(height: 8),
          sectionHeader('PART IV. NOMINATING A GUARDIAN'),
          pw.SizedBox(height: 4),
          pw.Text(
            'I understand that I may nominate a guardian of my person for consideration by '
            'the court if incapacity proceedings are commenced under 20 Pa.C.S. § 5511. '
            'I understand that the court will appoint a guardian in accordance with my most '
            'recent nomination except for good cause or disqualification.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          if (guardian != null && guardian.nomineeFullName.isNotEmpty) ...[
            dataLine('Name of Person', guardian.nomineeFullName),
            dataLine('Address', guardian.nomineeAddress),
            twoCol(
              dataLine('Relationship', guardian.nomineeRelationship),
              dataLine('Phone Number', guardian.nomineePhone),
            ),
          ] else ...[
            blankLine('Name of Person'),
            blankLine('Address'),
            twoCol(blankLine('City, State, Zip Code'), blankLine('Phone Number')),
          ],
          checkRow(
            'The appointment of a guardian of my person will not give the guardian the '
            'power to revoke, suspend or terminate this Combined Mental Health Care '
            'Declaration and Power of Attorney.',
            checked: true,
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
        final execDate = directive.executionDate != null
            ? DateTime.fromMillisecondsSinceEpoch(directive.executionDate!)
            : null;
        final dateStr = execDate != null
            ? '${execDate.day}th day of '
                '${_monthName(execDate.month)}, ${execDate.year}'
            : '_____ day of ______________, _______';

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pageHeader(formTitle),
            sectionHeader('PART V. EXECUTION'),
            pw.SizedBox(height: 6),
            pw.Text(
              'I am making this Combined Mental Health Care Declaration and Power of '
              'Attorney on the $dateStr.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 8),
            signatureBlock('Principal Signature', name: directive.fullName),
            dataLine('My Name', directive.fullName),
            dataLine('Address', [directive.address, directive.address2, directive.city, directive.state]
                .where((s) => s.isNotEmpty)
                .join(', ')),
            dataLine('Phone Number', directive.phone),
            pw.SizedBox(height: 12),
            pw.Text('Witnesses:', style: boldStyle()),
            pw.Text(
              'Your document must be signed and dated by you in the presence of two '
              'witnesses. Each witness must be at least 18 years old. The witnesses may '
              'not be your agent or a person signing on your behalf.',
              style: smallBodyStyle(),
            ),
            pw.SizedBox(height: 8),
            twoCol(
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  signatureBlock('Witness 1 Signature', name: w1?.fullName ?? ''),
                  if (w1 != null) dataLine('Address', w1.address),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  signatureBlock('Witness 2 Signature', name: w2?.fullName ?? ''),
                  if (w2 != null) dataLine('Address', w2.address),
                ],
              ),
            ),
            pw.Spacer(),
            pw.Text(
              'Prepared using the PA MHAD app. This document is not a substitute for legal counsel.',
              style: pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF888888)),
            ),
            pw.SizedBox(height: 2),
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

/// Split "Name | Location" format from treatment facility.
String _facilityName(String raw) {
  final parts = raw.split(' | ');
  return parts.first;
}

String _facilityLocation(String raw) {
  final parts = raw.split(' | ');
  return parts.length > 1 ? parts[1] : '';
}

String _monthName(int month) {
  const months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[month];
}
