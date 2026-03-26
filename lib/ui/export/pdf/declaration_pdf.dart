/// Mental Health Declaration-Only PDF layout.
/// Matches the official PA MHAD Declaration form pages 33-38 (Disabilities Law Project 2005).
library;

import 'package:mhad/data/database/app_database.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_helpers.dart';

List<pw.Page> buildDeclarationPages({
  required Directive directive,
  required DirectivePref? prefs,
  required AdditionalInstructionsTableData? additional,
  required GuardianNomination? guardian,
  required List<MedicationEntry> medications,
  required List<WitnessesData> witnesses,
  List<DiagnosisEntry> diagnoses = const [],
}) {
  const formTitle = 'Mental Health Declaration';

  final exceptions =
      medications.where((m) => m.entryType == 'exception').toList();
  final limitations =
      medications.where((m) => m.entryType == 'limitation').toList();
  final preferred =
      medications.where((m) => m.entryType == 'preferred').toList();

  final parsed = additional != null ? parseOtherField(additional.other) : const ParsedOtherContent();

  return [
    // ---- Page 1: Introduction + Effective Condition + Treatment Facility + Meds
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
            'I, ${directive.fullName.isNotEmpty ? directive.fullName : '___________________________________________'}, '
            'having capacity to make mental health decisions, '
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
          if (directive.dateOfBirth.isNotEmpty)
            dataLine('Date of Birth', directive.dateOfBirth),
          pw.SizedBox(height: 6),

          if (diagnoses.isNotEmpty) diagnosisList(diagnoses),

          // A. When this Declaration becomes effective
          partHeader('A. When this Declaration becomes effective'),
          pw.Text(
            'This Declaration becomes effective at the following designated time:',
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

          // B. Treatment preferences — 1. Treatment facility
          partHeader('B. Treatment preferences'),
          pw.Text('1. Choice of treatment facility.',
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
          pageFooter('Page 1'),
        ],
      ),
    ),

    // ---- Page 2: Medications + ECT + Experimental + Drug Trials -----------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),

          // 2. Medications
          pw.Text('2. Preferences regarding medications for psychiatric treatment.',
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
              'the following exceptions, limitations and/or preferences:',
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
            if (exceptions.isNotEmpty || limitations.isNotEmpty || preferred.isNotEmpty)
              pw.Text(
                'The exception, limitation, or preference, applies to generic, brand name and '
                'trade name equivalents unless otherwise stated. I understand that dosage '
                'instructions are not binding on my physician.',
                style: smallBodyStyle(),
              ),
            checkRow(
              'I do not consent to the use of any medications.',
              checked: prefs.medicationConsent == 'no',
            ),
          ],
          pw.SizedBox(height: 6),

          // 3. ECT
          pw.Text('3. Preferences regarding electroconvulsive therapy (ECT).',
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
              'I do not consent to the administration of electroconvulsive therapy.',
              checked: isConsentNo(prefs.ectConsent),
            ),
          ],
          pw.SizedBox(height: 6),

          // 4. Experimental studies
          pw.Text('4. Preferences for experimental studies.',
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
              'I do not consent to participation in experimental studies.',
              checked: isConsentNo(prefs.experimentalConsent),
            ),
          ],
          pw.SizedBox(height: 6),

          // 5. Drug trials
          pw.Text('5. Preferences for drug trials.',
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
              'I do not consent to participation in any drug trials.',
              checked: isConsentNo(prefs.drugTrialConsent),
            ),
          ],

          pw.Spacer(),
          pageFooter('Page 2'),
        ],
      ),
    ),

    // ---- Page 3: Additional Instructions ----------------------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pageHeader(formTitle),
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
            if (parsed.deEscalation.isNotEmpty)
              dataBlock('De-escalation techniques:', parsed.deEscalation),
            if (parsed.triggers.isNotEmpty)
              dataBlock('Crisis triggers:', parsed.triggers),
            if (parsed.reproductiveHealth.isNotEmpty)
              dataBlock('Reproductive health preferences:', parsed.reproductiveHealth),
            if (parsed.otherText.isNotEmpty)
              dataBlock('Other matters of importance:', parsed.otherText),
          ],
          pw.Spacer(),
          pageFooter('Page 3'),
        ],
      ),
    ),

    // ---- Page 4: Revocation + Termination + Guardian -------------------------
    pw.Page(
      pageFormat: kPageFormat,
      margin: pageMargins,
      build: (ctx) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pageHeader(formTitle),

            // C. Revocation and Amendments
            partHeader('C. Revocation and Amendments'),
            pw.Text(
              'This Declaration may be revoked in whole or in part at any time, either '
              'orally or in writing, as long as I have not been found to be incapable of '
              'making mental health decisions. My revocation will be effective upon '
              'communication to my attending physician or other mental health care provider, '
              'either by me or a witness to my revocation, of the intent to revoke. If I '
              'choose to revoke a particular instruction contained in this Declaration in '
              'the manner specified, I understand that the other instructions contained in '
              'this Declaration will remain effective until:\n'
              '(1) I revoke this Declaration in its entirety;\n'
              '(2) I make a new Mental Health Advance Directive; or\n'
              '(3) Two years after the date this document was executed.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'I may make changes to this Advance Directive at any time, as long as I have '
              'capacity to make mental health care decisions. Any changes will be made in '
              'writing and be signed and witnessed by two individuals in the same way the '
              'original document was executed. Any changes will be effective as soon the '
              'changes are communicated to my attending physician or other mental health '
              'care provider, either by me or a witness to my amendments.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 6),

            // D. Termination
            partHeader('D. Termination'),
            pw.Text(
              'I understand that this Declaration will automatically terminate two years '
              'from the date of execution, unless I am deemed incapable of making mental '
              'health care decisions at the time that this Declaration would expire.',
              style: bodyStyle(),
            ),
            pw.SizedBox(height: 6),

            // E. Guardian
            partHeader('E. Preference as to a court-appointed guardian'),
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
              'The appointment of a guardian of my person will not give the guardian '
              'the power to revoke, suspend or terminate this Declaration.',
              checked: guardian == null || !guardian.guardianCanRevoke,
            ),
            checkRow(
              'Upon appointment of a guardian, I authorize the guardian to revoke, '
              'suspend or terminate this Declaration.',
              checked: guardian != null && guardian.guardianCanRevoke,
            ),
            pw.Spacer(),
            pageFooter('Page 4'),
          ],
        );
      },
    ),

    // ---- Page 5: Execution ------------------------------------------------
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

            // F. Execution
            partHeader('F. Execution'),
            pw.Text(
              'I am making this Declaration on the $dateStr.',
              style: bodyStyle(),
            ),
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
            signOnBehalfBlock('Declaration'),

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
