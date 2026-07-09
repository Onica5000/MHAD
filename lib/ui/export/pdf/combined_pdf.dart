/// Combined Mental Health Declaration and Power of Attorney — ordering
/// manifest over the shared section builders (`pdf_form_sections.dart`) and
/// per-form prose (`pdf_form_text.dart`).
/// Matches the official PA MHAD form pages 25-32 (Disabilities Law Project 2005).
library;

import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_form_sections.dart';
import 'pdf_form_text.dart';
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
  DraftMode draftMode = DraftMode.finalCopy,
}) {
  const ft = FormText(FormType.combined);

  // Draft indicator: appended to the header-bar form title (not the big
  // page-1 form title) so an unsigned export is unmistakable when printed.
  // Driven by the chosen print type (draftMode), NOT the saved status.
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
        // ---- Part I (Introduction) ----
        ...formTitleBlock(ft.titleLines),
        sectionHeader('Part I. Introduction'),
        pw.SizedBox(height: 4),
        ...introBlock(ft.introParagraphs(name)),
        ...dobBlock(directive),
        ...diagnosesDoctorBlock(directive, diagnoses,
            includePrimaryDoctor: true),

        ...effectiveTimeSection(
          header: ft.effectiveHeader,
          leadIn: ft.effectiveLeadIn,
          directive: directive,
        ),
        pw.SizedBox(height: 6),

        ...revocationSection(
          header: ft.revocationHeader,
          revocation: ft.revocationParagraph,
          amendments: ft.amendmentsParagraph,
        ),
        ...terminationSection(
          header: ft.terminationHeader,
          paragraph: ft.terminationParagraph,
        ),
        pw.SizedBox(height: 8),

        // ---- Part II — Treatment Preferences ----
        sectionHeader('Part II. Mental Health Declaration'),
        pw.SizedBox(height: 4),
        partHeader('A. Treatment preferences'),
        pw.SizedBox(height: 4),

        pw.Text('1. Choice of treatment facility.', style: boldStyle()),
        pw.SizedBox(height: 4),
        ...facilitySection(prefs),
        pw.SizedBox(height: 8),
        ...roomPreferencesBlock(prefs),
        if (formatRoomPreferences(prefs) != null) pw.SizedBox(height: 8),

        pw.Text(
          '2. Preferences regarding medications for psychiatric treatment',
          style: boldStyle(),
        ),
        pw.SizedBox(height: 4),
        ...currentMedsBlock(current),
        ...medicationPreferencesSection(
          prefs: prefs,
          exceptions: exceptions,
          limitations: limitations,
          preferred: preferred,
          variant: MedsSectionVariant.combined,
        ),
        pw.SizedBox(height: 8),

        ...procedureConsentSection(
          header: '3. Preferences for electroconvulsive therapy (ECT)',
          kind: ProcedureKind.ect,
          prefs: prefs,
          withDesignatedAgentRow: true,
        ),
        pw.SizedBox(height: 6),
        ...procedureConsentSection(
          header: '4. Preferences for experimental studies',
          kind: ProcedureKind.experimental,
          prefs: prefs,
          withDesignatedAgentRow: true,
        ),
        pw.SizedBox(height: 6),
        ...procedureConsentSection(
          header: '5. Preferences for drug trials',
          kind: ProcedureKind.drugTrial,
          prefs: prefs,
          withDesignatedAgentRow: true,
        ),
        pw.SizedBox(height: 6),

        ...additionalInstructionsSection(
          additional: additional,
          parsed: parsed,
          sideEffectsJson: prefs?.sideEffectsJson,
        ),
        pw.SizedBox(height: 8),

        // ---- Part III — Power of Attorney ----
        sectionHeader('Part III. Mental Health Care Power of Attorney'),
        pw.SizedBox(height: 4),
        pw.Text(ft.poaPartIntro(name)!, style: bodyStyle()),
        pw.SizedBox(height: 8),

        ...agentDesignationSection(
          primaryAgent: primaryAgent,
          declarantName: directive.fullName,
          preamble: ft.agentDesignationPreamble,
        ),
        pw.SizedBox(height: 8),
        ...alternateAgentSection(
          altAgent: altAgent,
          declarantName: directive.fullName,
          gapBeforeAcceptance: 4,
        ),
        pw.SizedBox(height: 8),

        // ---- Part III C (Authority) ----
        partHeader('C. Authority granted to my mental health care agent'),
        pw.Text(ft.authorityPreamble, style: bodyStyle()),
        pw.SizedBox(height: 6),
        if (prefs != null) ...[
          ...hospitalizationAuthorityBlock(prefs),
          ...medicationAuthorityBlock(prefs),
          ...procedureAgentAuthoritySection(
            header: '2. Preferences regarding electroconvulsive therapy (ECT).',
            kind: ProcedureKind.ect,
            prefs: prefs,
            gapAfterHeader: 2,
          ),
          pw.SizedBox(height: 4),
          ...procedureAgentAuthoritySection(
            header: '3. Preferences for experimental studies.',
            kind: ProcedureKind.experimental,
            prefs: prefs,
            gapAfterHeader: 2,
          ),
          pw.SizedBox(height: 4),
          ...procedureAgentAuthoritySection(
            header: '4. Preferences regarding drug trials.',
            kind: ProcedureKind.drugTrial,
            prefs: prefs,
            gapAfterHeader: 2,
          ),
          ...agentLimitationsBlock(prefs),
        ],
        pw.SizedBox(height: 8),

        // ---- Part IV — Guardian ----
        sectionHeader('PART IV. Nominating a Guardian'),
        pw.SizedBox(height: 4),
        partHeader('A. Preference as to a court-appointed guardian'),
        ...guardianSection(
          guardian: guardian,
          agents: agents,
          docNoun: ft.guardianDocNoun,
        ),
        pw.SizedBox(height: 8),

        // ---- Part V — Execution ----
        sectionHeader('PART V. Execution'),
        pw.SizedBox(height: 6),
        ...executionSection(
          directive: directive,
          makingSentence: ft.executionSentence(dateStr),
          signatureLabel: ft.signatureLabel,
          signOnBehalfNoun: ft.signOnBehalfNoun,
          w1: w1,
          w2: w2,
          extraGapAfterSentence: true,
          withWitnessLabel: true,
        ),
      ],
    ),
  ];
}
