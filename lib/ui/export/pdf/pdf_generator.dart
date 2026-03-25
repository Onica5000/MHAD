import 'dart:typed_data';
import 'package:mhad/data/database/app_database.dart';
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
    final pdf = pw.Document(
      title: 'PA Mental Health Advance Directive',
      author: directive.fullName,
      subject: 'Pennsylvania Mental Health Advance Directive — Act 194 of 2004',
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
}
