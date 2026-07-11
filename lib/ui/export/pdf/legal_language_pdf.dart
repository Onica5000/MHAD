import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:pdf/widgets.dart' as pw;
import 'pdf_helpers.dart';

/// Informational "legal-language" (statutory-voice) rendering of the directive.
///
/// This is NOT the signed/valid document — the official PA Act 194 form (the
/// canonical PDF) is the authoritative directive that gets signed and used.
/// This version restates the same data in formal 20 Pa.C.S. Ch. 58 voice for
/// convenience/reference only. The prose mirrors the vetted on-screen
/// Plain⇄Legal toggle.
List<pw.Page> buildLegalLanguagePages({
  required Directive directive,
  required List<Agent> agents,
  DraftMode draftMode = DraftMode.finalCopy,
}) {
  final primary = agents.primaryAgent;
  final alternate = agents.alternateAgent;
  final name = directive.fullName.trim().isEmpty
      ? '(PRINCIPAL NAME)'
      : directive.fullName.toUpperCase();

  String agentClause(Agent a) {
    final rel = a.relationship.trim().isEmpty ? '' : '${a.relationship}, ';
    final addr = a.fullAddress.isEmpty ? '(address)' : a.fullAddress;
    return '${a.fullName.toUpperCase()}, ${rel}residing at $addr';
  }

  final paras = <String>[
    'I, $name, being of sound mind and at least eighteen (18) years of age, do '
        'hereby execute this Mental Health Advance Directive pursuant to the '
        'Mental Health Advance Directive Act of 2004, 20 Pa.C.S. Ch. 58.',
    'This Directive shall become effective upon a written determination by a '
        'psychiatrist and one of the following: another psychiatrist, a licensed '
        'psychologist, a family physician, an attending physician, or a mental '
        'health treatment professional (whenever possible, one of whom is a '
        'treating professional) that I am incapable of making mental health '
        'treatment decisions.',
    if (directive.effectiveCondition.trim().isNotEmpty)
      'I have further stated the following regarding when this Directive takes '
          'effect: "${directive.effectiveCondition.trim()}"',
    if (primary != null && primary.fullName.trim().isNotEmpty)
      'I hereby appoint ${agentClause(primary)} as my mental health care agent, '
          'with the authority enumerated in 20 Pa.C.S. § 5836.',
    if (alternate != null && alternate.fullName.trim().isNotEmpty)
      'Should my agent be unable or unwilling to serve, I appoint '
          '${agentClause(alternate)} as my alternate mental health care agent.',
    'This Directive shall terminate two (2) years from the date of execution '
        'unless, at the time of expiration, I am incapable of making mental '
        'health treatment decisions, in which case it shall remain in effect '
        'until my capacity returns.',
    'I have additionally stated preferences regarding treatment modalities, '
        'medications, treatment facility, and other instructions in the '
        'accompanying official form, which constitutes the complete and '
        'authoritative expression of my wishes.',
  ];

  return [
    pw.MultiPage(
      // Draft watermark applied like the form pages (audit defect #9 — this
      // path previously skipped it, so a draft printed clean).
      pageTheme: pw.PageTheme(
        pageFormat: kPageFormat,
        margin: pageMargins,
        buildBackground: (ctx) => draftWatermark(draftMode),
      ),
      header: (_) => pageHeader('Legal-Language Version (Informational)'),
      footer: (_) =>
          pageFooter('Legal-language version · informational only'),
      build: (context) => [
        sectionHeader('LEGAL-LANGUAGE VERSION — INFORMATIONAL ONLY'),
        pw.SizedBox(height: 6),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: kBlack, width: 0.8),
          ),
          child: pw.Text(
            'This is NOT the document you sign. It restates your directive in '
            'formal statutory voice for reference only and has not been '
            'attorney-reviewed. The official PA MHAD form (your signed copy) is '
            'the authoritative, legally valid directive.',
            style: boldStyle(fontSize: 9),
          ),
        ),
        pw.SizedBox(height: 12),
        for (final para in paras) ...[
          pw.Text(para, style: bodyStyle()),
          pw.SizedBox(height: 12),
        ],
        pw.SizedBox(height: 8),
        pw.Text(
          'Derived from the same data as your official directive. Verify against '
          'counsel before relying on this rendering.',
          style: smallBodyStyle(),
        ),
      ],
    ),
  ];
}
