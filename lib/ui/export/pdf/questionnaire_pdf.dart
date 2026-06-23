import 'dart:typed_data';

import 'package:mhad/data/audio_questionnaire_content.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_helpers.dart';

/// The PDF's default font (Helvetica) can't draw a few Unicode glyphs the
/// shared content uses (em/en dashes, the • bullet) — they render blank. The
/// on-screen version handles them fine; for print we substitute ASCII.
String _safe(String s) => s
    .replaceAll('—', '-') // em dash
    .replaceAll('–', '-') // en dash
    .replaceAll('•', '-'); // bullet

/// Builds a printable PDF of the spoken questionnaire — the read-aloud script
/// for recording an audio file that autofills the directive. Printed via the
/// `printing` package (browser print sheet on web).
Future<Uint8List> buildAudioQuestionnairePdf() async {
  final doc = pw.Document();

  // A drawn bullet dot (avoids the • glyph the base font can't render).
  pw.Widget bullet(String text, {double fontSize = 11}) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3, left: 6),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Container(
              width: 3,
              height: 3,
              margin: const pw.EdgeInsets.only(top: 5, right: 7),
              decoration: const pw.BoxDecoration(
                color: PdfColors.black,
                shape: pw.BoxShape.circle,
              ),
            ),
            pw.Expanded(
              child: pw.Text(_safe(text), style: bodyStyle(fontSize: fontSize)),
            ),
          ],
        ),
      );

  List<pw.Widget> section(AudioQSection s) => [
        pw.SizedBox(height: 11),
        pw.Text('${s.number}.  ${s.title}', style: boldStyle(fontSize: 12.5)),
        if (s.appliesWhen != null)
          pw.Text(
            '(${_safe(s.appliesWhen!)})',
            style: pw.TextStyle(
              fontSize: 9.5,
              color: kDarkGrey,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        pw.SizedBox(height: 3),
        for (final p in s.prompts) bullet(p),
        if (s.example != null) ...[
          pw.SizedBox(height: 3),
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              'Example: ${_safe(s.example!)}',
              style: pw.TextStyle(
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
                color: kDarkGrey,
              ),
            ),
          ),
        ],
        if (s.note != null) ...[
          pw.SizedBox(height: 3),
          pw.Text('Note: ${_safe(s.note!)}', style: smallBodyStyle()),
        ],
      ];

  doc.addPage(
    pw.MultiPage(
      pageFormat: kPageFormat,
      margin: const pw.EdgeInsets.fromLTRB(54, 48, 54, 44),
      build: (context) => [
        pw.Text(audioQTitle,
            style: sectionHeaderStyle().copyWith(fontSize: 20)),
        pw.Text(
          'Read aloud to record an audio file that autofills your PA Mental '
          'Health Advance Directive.',
          style: smallBodyStyle(),
        ),
        pw.SizedBox(height: 8),
        pw.Text(_safe(audioQIntro), style: bodyStyle()),
        for (final s in audioQSections) ...section(s),
        pw.SizedBox(height: 14),
        pw.Text(
          'What the recording can NOT fill - do these in the app',
          style: boldStyle(fontSize: 12.5),
        ),
        pw.SizedBox(height: 4),
        for (final item in audioQCantDo) bullet(_safe(item), fontSize: 10),
        pw.SizedBox(height: 10),
        pw.Text(
          'Worth saying out loud - autofill now captures these',
          style: boldStyle(fontSize: 12.5),
        ),
        pw.SizedBox(height: 4),
        for (final item in audioQNowCaptured) bullet(_safe(item), fontSize: 10),
        pw.SizedBox(height: 4),
        bullet(_safe(audioQFormTypeNote), fontSize: 10),
        pw.SizedBox(height: 10),
        pw.Text(
          _safe(audioQClosing),
          style: pw.TextStyle(
            fontSize: 10.5,
            fontStyle: pw.FontStyle.italic,
            color: kBlack,
          ),
        ),
      ],
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(fontSize: 8, color: kDarkGrey),
        ),
      ),
    ),
  );

  return doc.save();
}
