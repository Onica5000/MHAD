import 'dart:typed_data';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart' show rootBundle;
import 'package:mhad/data/database/app_database.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'combined_pdf.dart';
import 'declaration_pdf.dart';
import 'notes_pdf.dart';
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

  const PdfGenerator({
    required this.includeCombined,
    required this.includeDeclaration,
    required this.includePoa,
    this.includeSupplementary = false,
    this.includeNotes = false,
  });

  /// Loads the editorial typeface trio (DM Sans regular + bold, Instrument
  /// Serif italic) and returns a `pw.ThemeData` so every page inherits the
  /// same typography the app uses on screen. Falls back to the default
  /// Helvetica theme if asset loading fails (e.g. inside unit tests that
  /// do not initialise the Flutter test binding).
  Future<pw.ThemeData?> _loadEditorialTheme() async {
    try {
      final dmRegular = pw.Font.ttf(
          await rootBundle.load('assets/fonts/DMSans-Regular.ttf'));
      final dmBold = pw.Font.ttf(
          await rootBundle.load('assets/fonts/DMSans-Bold.ttf'));
      final serifItalic = pw.Font.ttf(
          await rootBundle.load('assets/fonts/InstrumentSerif-Italic.ttf'));
      // boldItalic falls back to italic; that's fine for legal-form copy.
      return pw.ThemeData.withFont(
        base: dmRegular,
        bold: dmBold,
        italic: serifItalic,
      );
    } catch (e) {
      debugPrint('PDF theme: editorial fonts unavailable, '
          'falling back to default Helvetica: $e');
      return null;
    }
  }

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
    final theme = await _loadEditorialTheme();

    final isDraft = directive.status == 'draft';
    final subjectSuffix = isDraft ? ' (DRAFT — UNSIGNED)' : '';

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

  static String _formTypeLabel(String formType) {
    switch (formType) {
      case 'combined':
        return 'Combined Declaration and Power of Attorney';
      case 'declaration':
        return 'Declaration Only';
      case 'poa':
        return 'Power of Attorney Only';
      default:
        return formType;
    }
  }
}
