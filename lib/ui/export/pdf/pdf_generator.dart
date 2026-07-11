import 'dart:typed_data';

import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'combined_pdf.dart';
import 'pdf_helpers.dart';
import 'declaration_pdf.dart';
import 'legal_language_pdf.dart';
import 'notes_pdf.dart';
import 'pdf_theme.dart';
import 'poa_pdf.dart';
import 'supplementary_pdf.dart';

/// Generates a PA MHAD PDF document from user data.
class PdfGenerator {
  /// Which form types to include in the generated PDF.
  final bool includeCombined;
  final bool includeDeclaration;
  final bool includePoa;
  final bool includeSupplementary;
  final bool includeNotes;

  /// Draft watermark mode applied to the form pages.
  final DraftMode draftMode;

  /// When true, produce the informational legal-language (statutory-voice)
  /// rendering instead of the official form. NOT the signed document — the
  /// canonical form is authoritative.
  final bool legalLanguage;

  const PdfGenerator({
    required this.includeCombined,
    required this.includeDeclaration,
    required this.includePoa,
    this.includeSupplementary = false,
    this.includeNotes = false,
    this.draftMode = DraftMode.finalCopy,
    this.legalLanguage = false,
  });

  Future<Uint8List> generate({
    required Directive directive,
    required List<Agent> agents,
    required DirectivePref? prefs,
    required AdditionalInstructionsTableData? additional,
    required GuardianNomination? guardian,
    required List<MedicationEntry> medications,
    required List<WitnessesData> witnesses,
    List<DiagnosisEntry> diagnoses = const [],
  }) async {
    final theme = await loadEditorialTheme();

    // Metadata marker follows the chosen print type (draftMode), so a "Final
    // copy" export has clean metadata even while the directive is a draft.
    final label = draftLabel(draftMode);
    final subjectSuffix = label.isEmpty ? '' : ' ($label)';

    final pdf = pw.Document(
      title: 'PA Mental Health Advance Directive$subjectSuffix',
      author: directive.fullName.isEmpty ? 'PA MHAD App' : directive.fullName,
      subject: 'Pennsylvania Mental Health Advance Directive — Act 194 of 2004'
          '$subjectSuffix',
      // Strengthened metadata for search/index/accessibility:
      keywords: 'PA MHAD, Pennsylvania, Mental Health Advance Directive, '
          'Act 194 of 2004, 20 Pa.C.S. Ch. 58, '
          '${_formTypeLabel(directive.formType)}',
      creator: 'PA MHAD App (Flutter) — https://github.com/Onica5000/MHAD',
      producer: 'pdf (Dart) via PA MHAD App',
      // Default to showing the document outline in viewers — most PA forms
      // are page-by-page, but the outline mode helps long Combined PDFs.
      pageMode: PdfPageMode.outlines,
      theme: theme,
    );

    final pages = <pw.Page>[];

    // Legal-language (informational) rendering replaces the form entirely —
    // the user picked it as an alternate view, not the signable document.
    if (legalLanguage) {
      pages.addAll(buildLegalLanguagePages(
        directive: directive,
        agents: agents,
        draftMode: draftMode,
      ));
      for (final page in pages) {
        pdf.addPage(page);
      }
      return pdf.save();
    }

    if (includeCombined) {
      pages.addAll(buildCombinedPages(
        directive: directive,
        agents: agents,
        prefs: prefs,
        additional: additional,
        guardian: guardian,
        medications: medications,
        witnesses: witnesses,
        diagnoses: diagnoses,
        draftMode: draftMode,
      ));
    }

    if (includeDeclaration) {
      pages.addAll(buildDeclarationPages(
        directive: directive,
        prefs: prefs,
        additional: additional,
        guardian: guardian,
        medications: medications,
        witnesses: witnesses,
        diagnoses: diagnoses,
        draftMode: draftMode,
      ));
    }

    if (includePoa) {
      pages.addAll(buildPoaPages(
        directive: directive,
        agents: agents,
        prefs: prefs,
        additional: additional,
        guardian: guardian,
        medications: medications,
        witnesses: witnesses,
        diagnoses: diagnoses,
        draftMode: draftMode,
      ));
    }

    if (includeSupplementary) {
      pages.addAll(buildSupplementaryPages());
    }

    if (includeNotes) {
      pages.addAll(buildNotesPages());
    }

    for (final page in pages) {
      pdf.addPage(page);
    }

    return pdf.save();
  }

  static String _formTypeLabel(String formType) =>
      formTypeFromName(formType)?.displayName ?? formType;
}
