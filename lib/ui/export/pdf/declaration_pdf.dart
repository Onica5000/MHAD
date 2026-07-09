/// Mental Health Declaration-Only — ordering manifest over the shared section
/// builders (`pdf_form_sections.dart`) and per-form prose (`pdf_form_text.dart`).
/// Matches the official PA MHAD Declaration form pages 33-38 (Disabilities Law
/// Project 2005).
library;

import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_form_sections.dart';
import 'pdf_form_text.dart';
import 'pdf_helpers.dart';

List<pw.Page> buildDeclarationPages({
  required Directive directive,
  required DirectivePref? prefs,
  required AdditionalInstructionsTableData? additional,
  required GuardianNomination? guardian,
  required List<MedicationEntry> medications,
  required List<WitnessesData> witnesses,
  List<DiagnosisEntry> diagnoses = const [],
  DraftMode draftMode = DraftMode.finalCopy,
}) {
  const ft = FormText(FormType.declaration);

  // Marker follows the chosen print type (draftMode), not the saved status.
  final label = draftLabel(draftMode);
  final formTitle =
      label.isEmpty ? ft.headerTitle : '${ft.headerTitle}  ·  $label';

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
            includePrimaryDoctor: true),

        // A. When this Declaration becomes effective
        ...effectiveTimeSection(
          header: ft.effectiveHeader,
          leadIn: ft.effectiveLeadIn,
          directive: directive,
        ),
        pw.SizedBox(height: 8),

        // B. Treatment preferences
        partHeader('B. Treatment preferences'),
        pw.Text('1. Choice of treatment facility', style: boldStyle()),
        pw.SizedBox(height: 4),
        ...facilitySection(prefs),
        ...roomPreferencesBlock(prefs),
        pw.SizedBox(height: 8),

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
          variant: MedsSectionVariant.declaration,
        ),
        pw.SizedBox(height: 6),

        ...procedureConsentSection(
          header: '3. Preferences regarding electroconvulsive therapy (ECT).',
          kind: ProcedureKind.ect,
          prefs: prefs,
          withDesignatedAgentRow: false,
        ),
        pw.SizedBox(height: 6),
        ...procedureConsentSection(
          header: '4. Preferences for experimental studies.',
          kind: ProcedureKind.experimental,
          prefs: prefs,
          withDesignatedAgentRow: false,
        ),
        pw.SizedBox(height: 6),
        ...procedureConsentSection(
          header: '5. Preferences for drug trials.',
          kind: ProcedureKind.drugTrial,
          prefs: prefs,
          withDesignatedAgentRow: false,
        ),
        pw.SizedBox(height: 8),

        ...additionalInstructionsSection(
          additional: additional,
          parsed: parsed,
          sideEffectsJson: prefs?.sideEffectsJson,
        ),
        pw.SizedBox(height: 8),

        // C. Revocation and Amendments / D. Termination
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

        // E. Guardian — the Declaration form has no `agents` parameter
        // (Declaration-only skips the People I Trust step), so the
        // `sameAsPrimary` / `sameAsAlternate` choices cannot resolve here;
        // the helper falls through to blank lines for the court to fill in.
        partHeader('E. Preference as to a court-appointed guardian'),
        ...guardianSection(
          guardian: guardian,
          agents: const [],
          docNoun: ft.guardianDocNoun,
          nomineeUsesTwoCol: false,
        ),
        pw.SizedBox(height: 8),

        // F. Execution
        partHeader('F. Execution'),
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
