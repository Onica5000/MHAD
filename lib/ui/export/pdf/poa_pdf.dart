/// Mental Health Power of Attorney PDF layout.
/// Layout based on the official PA MHAD POA form (Disabilities Law Project 2005).
library;

import 'package:mhad/data/database/app_database.dart';
import 'package:pdf/pdf.dart';
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
  final preferred =
      medications.where((m) => m.entryType == 'preferred').toList();

  return [
    // ---- Page 1: Introduction + Agent + Alt Agent + Effective Condition ----
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
            'I, ${directive.fullName}, having the capacity to make mental health decisions, '
            'authorize my designated health care agent to make certain decisions on my behalf '
            'regarding my mental health care. If I have not expressed a choice in this '
            'document, I authorize my agent to make the decision that my agent determines is '
            'the decision I would make if I were competent to do so.\n\n'
            'I understand that mental health care includes any care, treatment, service or '
            'procedure to maintain, diagnose, treat or provide for mental health, including '
            'any medication program and therapeutic treatment. Electroconvulsive therapy may '
            'be administered only if I have specifically consented to it in this document. '
            'I will be the subject of laboratory trials or research only if specifically '
            'provided for in this document. Mental health care does not include psychosurgery '
            'or termination of parental rights.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 8),

          sectionHeader('A. Designation of Agent'),
          pw.SizedBox(height: 4),
          pw.Text(
            'I hereby designate and appoint the following person as my agent to make '
            'mental health care decisions for me as authorized in this document.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 4),
          if (primaryAgent != null) ...[
            dataLine('Name of designated person', primaryAgent.fullName),
            dataLine('Address', primaryAgent.address),
            twoCol(
              blankLine('City, State, Zip Code'),
              dataLine('Phone Number',
                  [primaryAgent.homePhone, primaryAgent.workPhone, primaryAgent.cellPhone]
                      .firstWhere((p) => p.isNotEmpty, orElse: () => '')),
            ),
          ] else ...[
            blankLine('Name of designated person'),
            blankLine('Address'),
            twoCol(blankLine('City, State, Zip Code'), blankLine('Phone Number')),
          ],
          pw.Text(
            'Agent\'s acceptance: I hereby accept designation as mental health care '
            'agent for ${directive.fullName}.',
            style: bodyStyle(),
          ),
          signatureBlock('Agent\'s Signature', name: primaryAgent?.fullName ?? ''),
          pw.SizedBox(height: 6),

          sectionHeader('B. Designation of Alternative Agent'),
          pw.SizedBox(height: 4),
          if (altAgent != null) ...[
            dataLine('Name of designated person', altAgent.fullName),
            dataLine('Address', altAgent.address),
            twoCol(
              blankLine('City, State, Zip Code'),
              dataLine('Phone Number',
                  [altAgent.homePhone, altAgent.workPhone, altAgent.cellPhone]
                      .firstWhere((p) => p.isNotEmpty, orElse: () => '')),
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
          signatureBlock('Alternate Agent\'s Signature', name: altAgent?.fullName ?? ''),
          pw.SizedBox(height: 6),

          sectionHeader('C. When This Power of Attorney Becomes Effective'),
          pw.SizedBox(height: 4),
          checkRow(
            'When I am deemed incapable of making mental health care decisions.',
            checked: true,
          ),
          pw.Text(
            'Effective condition: ${directive.effectiveCondition}',
            style: bodyStyle(),
          ),
          pw.Spacer(),
          pageFooter('Page 1'),
        ],
      ),
    ),

    // ---- Page 2: Authority (D) — Treatment Preferences --------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          sectionHeader('D. Authority Granted to My Mental Health Care Agent'),
          pw.SizedBox(height: 4),
          pw.Text(
            'I hereby grant to my agent full power and authority to make mental health '
            'care decisions for me consistent with the instructions and limitations set '
            'forth in this Power of Attorney.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 6),

          partHeader('(a). Choice of Treatment Facility'),
          if (prefs != null && prefs.preferredFacilityName.isNotEmpty) ...[
            checkRow(
              'I would prefer to be admitted to the following facility:',
              checked: true,
            ),
            dataLine('Name of facility', prefs.preferredFacilityName),
          ] else
            checkRow('I would prefer to be admitted to the following facility:'),
          if (prefs != null && prefs.avoidFacilityName.isNotEmpty) ...[
            checkRow(
              'I do not wish to be committed to the following facility:',
              checked: true,
            ),
            dataLine('Name of facility', prefs.avoidFacilityName),
          ] else
            checkRow('I do not wish to be committed to the following facility:'),
          pw.Text(
            'I understand that my physician may have to place me in a facility that is not my preference.',
            style: smallBodyStyle(),
          ),
          pw.SizedBox(height: 6),

          partHeader('(b). Preferences Regarding Medications'),
          if (prefs != null) ...[
            checkRow(
              'I consent to the medications that my agent agrees to after consultation '
              'with my treating physician and any other persons my agent considers appropriate.',
              checked: prefs.medicationConsent == 'yes' ||
                  prefs.medicationConsent == 'agentDecides',
            ),
            if (exceptions.isNotEmpty || limitations.isNotEmpty || preferred.isNotEmpty) ...[
              checkRow(
                'I consent to the medications that my agent agrees to, with the following '
                'exceptions or limitations:',
                checked: true,
              ),
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
                  'Limitations:',
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
                  'Preferred:',
                  preferred
                      .map((m) => {'medication': m.medicationName, 'reason': m.reason})
                      .toList(),
                  false,
                ),
              pw.Text(
                'The exception or limitation applies to generic, brand name and trade name '
                'equivalents unless otherwise stated.',
                style: smallBodyStyle(),
              ),
            ],
            checkRow(
              'My agent is not authorized to consent to the use of any medications.',
              checked: prefs.medicationConsent == 'no',
            ),
          ],
          pw.SizedBox(height: 6),

          partHeader('(c). Electroconvulsive Therapy (ECT)'),
          if (prefs != null) ...[
            checkRow(
              'My agent is authorized to consent to the administration of electroconvulsive therapy.\n'
              'NOTE: Your agent MAY NOT consent to ECT unless you initial this authorization.',
              checked: prefs.ectConsent == 'agentDecides',
            ),
            checkRow(
              'My agent is not authorized to consent to the administration of electroconvulsive therapy.',
              checked: prefs.ectConsent == 'no' || prefs.ectConsent == 'yes',
            ),
          ],
          pw.SizedBox(height: 6),

          partHeader('(d). Experimental Studies'),
          if (prefs != null) ...[
            checkRow(
              'My agent is authorized to consent to my participation in experimental studies.\n'
              'NOTE: Your agent MAY NOT consent to experimental studies unless you initial this authorization.',
              checked: prefs.experimentalConsent == 'agentDecides',
            ),
            checkRow(
              'My agent is not authorized to consent to my participation in experimental studies.',
              checked: prefs.experimentalConsent != 'agentDecides',
            ),
          ],
          pw.SizedBox(height: 6),

          partHeader('(e). Drug Trials'),
          if (prefs != null) ...[
            checkRow(
              'My agent is authorized to consent to my participation in drug trials.\n'
              'NOTE: Your agent MAY NOT consent to research including drug trials unless you initial this authorization.',
              checked: prefs.drugTrialConsent == 'agentDecides',
            ),
            checkRow(
              'My agent is not authorized to consent to my participation in drug trials.',
              checked: prefs.drugTrialConsent != 'agentDecides',
            ),
          ],
          pw.Spacer(),
          pageFooter('Page 2'),
        ],
      ),
    ),

    // ---- Page 3: Additional Instructions + Revocation + Guardian + Execution
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
            ? '${execDate.day}th day of ${_monthName(execDate.month)}, ${execDate.year}'
            : '_____ day of ______________, _______';

        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pageHeader(formTitle),
            sectionHeader('(f). Additional Instructions or Information'),
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
            pw.SizedBox(height: 6),
            sectionHeader('E. Revocation and Amendments'),
            pw.SizedBox(height: 4),
            pw.Text(
              'This Power of Attorney may be revoked in whole or in part at any time, '
              'either orally or in writing, as long as I have not been found to be '
              'incapable of making mental health decisions. My revocation will be '
              'effective upon communication to my attending physician or other mental '
              'health care provider. This Power of Attorney will automatically expire '
              'two years from the date of execution.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 6),
            sectionHeader('G. Preference as to a Court-Appointed Guardian'),
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
            ],
            checkRow(
              'The appointment of a guardian of my person will not give the guardian '
              'the power to revoke, suspend or terminate this Power of Attorney.',
              checked: true,
            ),
            pw.SizedBox(height: 8),
            sectionHeader('H. Execution'),
            pw.SizedBox(height: 4),
            pw.Text(
              'I am making this Mental Health Care Power of Attorney on the $dateStr.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 6),
            signatureBlock('Principal Signature', name: directive.fullName),
            dataLine('My Name', directive.fullName),
            dataLine('Address', [directive.address, directive.address2, directive.city, directive.state]
                .where((s) => s.isNotEmpty)
                .join(', ')),
            dataLine('Phone Number', directive.phone),
            pw.SizedBox(height: 6),
            twoCol(
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                signatureBlock('Witness 1 Signature', name: w1?.fullName ?? ''),
                if (w1 != null) dataLine('Address', w1.address),
              ]),
              pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                signatureBlock('Witness 2 Signature', name: w2?.fullName ?? ''),
                if (w2 != null) dataLine('Address', w2.address),
              ]),
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

String _monthName(int month) {
  const months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[month];
}
