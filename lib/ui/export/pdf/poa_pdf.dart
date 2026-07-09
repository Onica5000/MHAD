/// Mental Health Power of Attorney — ordering manifest over the shared
/// section builders (`pdf_form_sections.dart`) and per-form prose
/// (`pdf_form_text.dart`).
/// Matches the official PA MHAD POA form pages 39-45 (Disabilities Law
/// Project 2005). Note: the official POA letters its treatment-preference
/// sub-items (a)-(f); the app numbers them 1-6 to keep all three forms on one
/// numbering system (deliberate, per user direction).
library;

import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_form_sections.dart';
import 'pdf_form_text.dart';
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
  DraftMode draftMode = DraftMode.finalCopy,
}) {
  const ft = FormText(FormType.poa);

  // Marker follows the chosen print type (draftMode), not the saved status.
  final label = draftLabel(draftMode);
  final formTitle =
      label.isEmpty ? ft.headerTitle : '${ft.headerTitle}  ·  $label';

  final primaryAgent = agents.primaryAgent;
  final altAgent = agents.alternateAgent;
  final (:current, :exceptions, :limitations, :preferred) =
      categorizeMedications(medications);
  final parsed = additional != null
      ? parseOtherField(additional.other)
      : const ParsedOtherContent();
  final w1 = witnesses.where((w) => w.witnessNumber == 1).firstOrNull;
  final w2 = witnesses.where((w) => w.witnessNumber == 2).firstOrNull;
  final dateStr = formatExecDate(directive.executionDate);
  final name = declarantNameOrBlank(directive);

  return [
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        pageFormat: kPageFormat,
        margin: pageMargins,
        buildBackground: (ctx) => draftWatermark(draftMode),
      ),
      header: (ctx) => pageHeader(formTitle),
      footer: (ctx) =>
          pageFooter('Page ${ctx.pageNumber} of ${ctx.pagesCount}'),
      build: (ctx) => [
        ...formTitleBlock(ft.titleLines),
        ...introBlock(ft.introParagraphs(name)),
        ...dobBlock(directive),
        ...diagnosesDoctorBlock(directive, diagnoses,
            includePrimaryDoctor: false),

        // A / B. Agent designations (the POA leads with them).
        ...agentDesignationSection(
          primaryAgent: primaryAgent,
          declarantName: directive.fullName,
          preamble: ft.agentDesignationPreamble,
        ),
        pw.SizedBox(height: 6),
        ...alternateAgentSection(
          altAgent: altAgent,
          declarantName: directive.fullName,
          gapBeforeAcceptance: 8,
        ),
        pw.SizedBox(height: 8),

        // C. When this Power of Attorney becomes effective
        ...effectiveTimeSection(
          header: ft.effectiveHeader,
          leadIn: ft.effectiveLeadIn,
          directive: directive,
        ),
        pw.SizedBox(height: 8),

        // D. Authority granted
        partHeader('D. Authority granted to my mental health care agent'),
        pw.Text(ft.authorityPreamble, style: bodyStyle()),
        pw.SizedBox(height: 6),

        pw.Text('Treatment preferences.', style: boldStyle()),
        pw.SizedBox(height: 4),
        pw.Text('1. Choice of treatment facility.', style: boldStyle()),
        pw.SizedBox(height: 4),
        ...facilitySection(prefs),
        pw.SizedBox(height: 8),

        if (prefs != null) ...hospitalizationAuthorityBlock(prefs),

        pw.Text(
          '2. Preferences regarding medications for psychiatric treatment.',
          style: boldStyle(),
        ),
        pw.SizedBox(height: 4),
        ...currentMedsBlock(current),
        ...medicationPreferencesSection(
          prefs: prefs,
          exceptions: exceptions,
          limitations: limitations,
          preferred: preferred,
          variant: MedsSectionVariant.poa,
        ),
        pw.SizedBox(height: 6),

        ...procedureAgentAuthoritySection(
          header: '3. Preferences regarding electroconvulsive therapy (ECT).',
          kind: ProcedureKind.ect,
          prefs: prefs,
        ),
        pw.SizedBox(height: 6),
        ...procedureAgentAuthoritySection(
          header: '4. Preferences for experimental studies.',
          kind: ProcedureKind.experimental,
          prefs: prefs,
        ),
        pw.SizedBox(height: 6),
        ...procedureAgentAuthoritySection(
          header: '5. Preferences regarding drug trials.',
          kind: ProcedureKind.drugTrial,
          prefs: prefs,
        ),
        if (prefs != null) ...agentLimitationsBlock(prefs),
        pw.SizedBox(height: 8),

        ...additionalInstructionsSection(
          additional: additional,
          parsed: parsed,
          sideEffectsJson: prefs?.sideEffectsJson,
        ),
        pw.SizedBox(height: 8),

        // E. Revocation and Amendments / F. Termination
        ...revocationSection(
          header: ft.revocationHeader,
          revocation: ft.revocationParagraph,
          amendments: ft.amendmentsParagraph,
        ),
        ...terminationSection(
          header: ft.terminationHeader,
          paragraph: ft.terminationParagraph,
        ),
        pw.SizedBox(height: 6),

        // G. Guardian
        partHeader('G. Preference as to a court-appointed guardian'),
        ...guardianSection(
          guardian: guardian,
          agents: agents,
          docNoun: ft.guardianDocNoun,
        ),
        pw.SizedBox(height: 8),

        // H. Execution
        partHeader('H. Execution'),
        ...executionSection(
          directive: directive,
          makingSentence: ft.executionSentence(dateStr),
          signatureLabel: ft.signatureLabel,
          signOnBehalfNoun: ft.signOnBehalfNoun,
          w1: w1,
          w2: w2,
          extraGapAfterSentence: false,
          withWitnessLabel: false,
        ),
      ],
    ),
  ];
}
