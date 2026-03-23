/// Mental Health Declaration-Only PDF layout.
/// Layout based on the official PA MHAD Declaration form (Disabilities Law Project 2005).
library;

import 'package:mhad/data/database/app_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_helpers.dart';

List<pw.Page> buildDeclarationPages({
  required Directive directive,
  required DirectivePref? prefs,
  required AdditionalInstructionsTableData? additional,
  required GuardianNomination? guardian,
  required List<MedicationEntry> medications,
  required List<WitnessesData> witnesses,
}) {
  const formTitle = 'Mental Health Declaration';

  final exceptions =
      medications.where((m) => m.entryType == 'exception').toList();
  final limitations =
      medications.where((m) => m.entryType == 'limitation').toList();
  final preferred =
      medications.where((m) => m.entryType == 'preferred').toList();

  return [
    // ---- Page 1: Introduction + Treatment preferences sections 1-2 --------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          pw.Center(
            child: pw.Text(
              'MENTAL HEALTH CARE DECLARATION FORM',
              style: boldStyle(fontSize: 13),
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'I, ${directive.fullName}, having capacity to make mental health decisions, '
            'willfully and voluntarily make this Declaration regarding my mental health care. '
            'I understand that mental health care includes any care, treatment, service or '
            'procedure to maintain, diagnose, treat or provide for mental health, including '
            'any medication program and therapeutic treatment. Electroconvulsive therapy may '
            'be administered only if I have specifically consented to it in this document. '
            'I will be the subject of laboratory trials or research only if specifically '
            'provided for in this document. Mental health care does not include psychosurgery '
            'or termination of parental rights. I understand that my incapacity will be '
            'determined by examination by a psychiatrist and one of the following: another '
            'psychiatrist, psychologist, family physician, attending physician or mental '
            'health treatment professional. Whenever possible, one of the decision makers '
            'will be one of my treating professionals.',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 8),

          sectionHeader('A. When This Declaration Becomes Effective'),
          pw.SizedBox(height: 4),
          checkRow(
            'When I am deemed incapable of making mental health care decisions.',
            checked: true,
          ),
          blankLine('Preferred doctor(s) for evaluation'),
          pw.Text(
            'Effective condition: ${directive.effectiveCondition}',
            style: bodyStyle(),
          ),
          pw.SizedBox(height: 8),

          sectionHeader('B. Treatment Preferences — 1. Choice of Treatment Facility'),
          pw.SizedBox(height: 4),
          if (prefs != null && prefs.treatmentFacilityPref == 'prefer' &&
              prefs.preferredFacilityName.isNotEmpty) ...[
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
          pw.SizedBox(height: 8),

          sectionHeader('2. Preferences Regarding Medications'),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'I consent to the medications that my treating physician recommends.',
              checked: prefs.medicationConsent == 'yes',
            ),
            if (exceptions.isNotEmpty || limitations.isNotEmpty || preferred.isNotEmpty) ...[
              checkRow(
                'I consent to the medications that my treating physician recommends '
                'with the following exceptions, limitations, and/or preferences:',
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
                'The exception, limitation, or preference applies to generic, brand name '
                'and trade name equivalents unless otherwise stated.',
                style: smallBodyStyle(),
              ),
            ],
            checkRow(
              'I do not consent to the use of any medications.',
              checked: prefs.medicationConsent == 'no',
            ),
          ],
          pw.Spacer(),
          pageFooter('Page 1'),
        ],
      ),
    ),

    // ---- Page 2: ECT, Experimental, Drug Trials, Additional, Guardian ------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
          sectionHeader('3. Preferences for Electroconvulsive Therapy (ECT)'),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'I consent to the administration of electroconvulsive therapy.',
              checked: prefs.ectConsent == 'yes',
            ),
            checkRow(
              'I do not consent to the administration of electroconvulsive therapy.',
              checked: prefs.ectConsent == 'no',
            ),
          ],
          pw.SizedBox(height: 6),

          sectionHeader('4. Preferences for Experimental Studies'),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'I consent to participation in experimental studies if my treating physician '
              'believes that the potential benefits to me outweigh the possible risks to me.',
              checked: prefs.experimentalConsent == 'yes',
            ),
            checkRow(
              'I do not consent to participation in experimental studies.',
              checked: prefs.experimentalConsent == 'no',
            ),
          ],
          pw.SizedBox(height: 6),

          sectionHeader('5. Preferences for Drug Trials'),
          pw.SizedBox(height: 4),
          if (prefs != null) ...[
            checkRow(
              'I consent to participation in drug trials if my treating physician believes '
              'that the potential benefits to me outweigh the possible risks to me.',
              checked: prefs.drugTrialConsent == 'yes',
            ),
            checkRow(
              'I do not consent to participation in any drug trials.',
              checked: prefs.drugTrialConsent == 'no',
            ),
          ],
          pw.SizedBox(height: 6),

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
              dataBlock('Limitations on the release or disclosure of mental health records:',
                  additional.recordsDisclosure),
            if (additional.petCustody.isNotEmpty)
              dataBlock('Temporary care and custody of pets:', additional.petCustody),
            if (additional.other.isNotEmpty)
              dataBlock('Other matters of importance:', additional.other),
          ],
          pw.Spacer(),
          pageFooter('Page 2'),
        ],
      ),
    ),

    // ---- Page 3: Revocation + Termination + Guardian + Execution -----------
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
            sectionHeader('C. Revocations and Amendments'),
            pw.SizedBox(height: 4),
            pw.Text(
              'This Declaration may be revoked in whole or in part at any time, either '
              'orally or in writing, as long as I have not been found to be incapable of '
              'making mental health decisions. My revocation will be effective upon '
              'communication to my attending physician or other mental health care provider. '
              'This Declaration will automatically expire two years from the date of '
              'execution, unless I am deemed incapable of making mental health care '
              'decisions at the time that this Declaration would expire.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 8),

            sectionHeader('D. Termination'),
            pw.SizedBox(height: 4),
            pw.Text(
              'I understand that this Declaration will automatically terminate two years '
              'from the date of execution, unless I am deemed incapable of making mental '
              'health care decisions at the time that this Declaration would expire.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 8),

            sectionHeader('E. Preference as to a Court-Appointed Guardian'),
            pw.SizedBox(height: 4),
            pw.Text(
              'I understand that I may nominate a guardian of my person for consideration '
              'by the court if incapacity proceedings are commenced under 20 Pa.C.S. § 5511.',
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
              'power to revoke, suspend or terminate this Declaration.',
              checked: true,
            ),
            pw.SizedBox(height: 8),

            sectionHeader('F. Execution'),
            pw.SizedBox(height: 4),
            pw.Text(
              'I am making this Declaration on the $dateStr.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 8),
            signatureBlock('Principal Signature', name: directive.fullName),
            dataLine('My Name', directive.fullName),
            dataLine('Address', [directive.address, directive.address2, directive.city, directive.state]
                .where((s) => s.isNotEmpty)
                .join(', ')),
            dataLine('Phone Number', directive.phone),
            pw.SizedBox(height: 8),
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
