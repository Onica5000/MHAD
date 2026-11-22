import 'dart:typed_data';

import 'package:mhad/data/audio_questionnaire_content.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_helpers.dart';

/// The PDF's default font (Helvetica) can't draw a few Unicode glyphs the
/// shared content uses (em/en dashes, the • bullet) — they render blank. The
/// on-screen version handles them fine; for print we substitute ASCII.
String _safe(String s) => s
    .replaceAll('—', '-') // em dash
    .replaceAll('–', '-') // en dash
    .replaceAll('•', '-') // bullet
    .replaceAll(RegExp('[‘’]'), "'") // curly single quotes (the ARB style)
    .replaceAll(RegExp('[“”]'), '"') // curly double quotes
    .replaceAll('…', '...'); // ellipsis

/// The printable voice questionnaire — the same script as the page, grouped
/// into the three recordings, for [form] (every section when null), in the
/// language of [l]. Printed via the `printing` package (the browser's print
/// sheet on the web).
Future<Uint8List> buildAudioQuestionnairePdf(AppLocalizations l,
    {FormType? form}) async {
  final q = AudioQuestionnaire(l, form: form);
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

  List<pw.Widget> section(AudioQSection s) {
    final step = q.stepLabel(s);
    final forms = q.formsLabel(s);
    return [
      pw.SizedBox(height: 9),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(child: pw.Text(_safe(s.title), style: boldStyle(fontSize: 12.5))),
          if (step != null)
            pw.Text(_safe(step), style: pw.TextStyle(fontSize: 9, color: kDarkGrey)),
        ],
      ),
      if (forms != null)
        pw.Text('(${_safe(forms)})',
            style: pw.TextStyle(
                fontSize: 9.5, color: kDarkGrey, fontStyle: pw.FontStyle.italic)),
      pw.SizedBox(height: 3),
      for (final p in s.prompts) bullet(p.text),
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
            _safe(l.audioGuideExample(s.example!)),
            style: pw.TextStyle(
                fontSize: 10, fontStyle: pw.FontStyle.italic, color: kDarkGrey),
          ),
        ),
      ],
      if (s.note != null) ...[
        pw.SizedBox(height: 3),
        pw.Text(_safe(l.audioQNote(s.note!)), style: smallBodyStyle()),
      ],
    ];
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: kPageFormat,
      margin: const pw.EdgeInsets.fromLTRB(54, 48, 54, 44),
      build: (context) => [
        pw.Text(_safe(q.title), style: sectionHeaderStyle().copyWith(fontSize: 20)),
        pw.Text(_safe(l.audioQPrintSubtitle), style: smallBodyStyle()),
        pw.SizedBox(height: 8),
        pw.Text(_safe(q.intro), style: bodyStyle()),
        pw.SizedBox(height: 4),
        pw.Text(_safe(q.formNote),
            style: pw.TextStyle(fontSize: 10.5, fontStyle: pw.FontStyle.italic)),
        for (final part in q.parts) ...[
          pw.SizedBox(height: 14),
          pw.Text(_safe(q.partTitle(part)),
              style: sectionHeaderStyle().copyWith(fontSize: 14)),
          pw.Text(_safe(q.partHow(part)), style: smallBodyStyle()),
          for (final s in q.sectionsIn(part)) ...section(s),
        ],
        pw.SizedBox(height: 14),
        pw.Text(_safe(l.audioGuideWhatTheRecordingCanT), style: boldStyle(fontSize: 12.5)),
        pw.Text(_safe(l.audioGuideSetTheseInTheApp), style: smallBodyStyle()),
        pw.SizedBox(height: 4),
        for (final item in q.cantDo) bullet(item, fontSize: 10),
        pw.SizedBox(height: 10),
        pw.Text(
          _safe(q.closing),
          style: pw.TextStyle(
              fontSize: 10.5, fontStyle: pw.FontStyle.italic, color: kBlack),
        ),
      ],
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          l.pdfPreviewPageOf(context.pageNumber, context.pagesCount),
          style: pw.TextStyle(fontSize: 8, color: kDarkGrey),
        ),
      ),
    ),
  );

  return doc.save();
}
