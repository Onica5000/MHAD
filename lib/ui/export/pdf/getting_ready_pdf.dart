import 'dart:typed_data';

import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/data/getting_ready_content.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/app_localizations.dart';
import 'package:pdf/widgets.dart' as pw;

import 'pdf_helpers.dart';

/// The base font can't draw a few glyphs the shared text uses; print ASCII.
String _safe(String s) => s
    .replaceAll('—', '-')
    .replaceAll('–', '-')
    .replaceAll('•', '-')
    .replaceAll('·', '-')
    .replaceAll(RegExp('[‘’]'), "'")
    .replaceAll(RegExp('[“”]'), '"')
    .replaceAll('…', '...');

/// The printable "Getting ready" checklist — the same items as the page, for
/// [form] (every form when null), in the language of [l], with empty boxes
/// to tick by hand.
Future<Uint8List> buildGettingReadyPdf(AppLocalizations l, {FormType? form}) async {
  final c = GettingReadyChecklist(l, form: form);
  final doc = pw.Document();

  pw.Widget row(GettingReadyItem item) {
    final tags = [?c.stepTag(item), ?c.formsTag(item)];
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 10,
            height: 10,
            margin: const pw.EdgeInsets.only(top: 1, right: 8),
            decoration: pw.BoxDecoration(border: pw.Border.all(width: 0.8)),
          ),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(_safe(item.text), style: bodyStyle(fontSize: 10.5)),
                if (tags.isNotEmpty)
                  pw.Text(_safe(tags.join(' - ')),
                      style: pw.TextStyle(fontSize: 8.5, color: kDarkGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  doc.addPage(
    pw.MultiPage(
      pageFormat: kPageFormat,
      margin: const pw.EdgeInsets.fromLTRB(54, 48, 54, 44),
      build: (context) => [
        pw.Text(_safe(l.gettingReadyTitle), style: sectionHeaderStyle().copyWith(fontSize: 20)),
        pw.SizedBox(height: 4),
        pw.Text(_safe(l.gettingReadyLead), style: bodyStyle()),
        pw.SizedBox(height: 4),
        pw.Text(_safe(c.formNote),
            style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic, color: kDarkGrey)),
        for (final tier in GettingReadyTier.values) ...[
          pw.SizedBox(height: 14),
          pw.Text(_safe(c.tierTitle(tier)), style: sectionHeaderStyle().copyWith(fontSize: 14)),
          pw.Text(_safe(c.tierLead(tier)), style: smallBodyStyle()),
          pw.SizedBox(height: 6),
          for (final item in c.items(tier)) row(item),
          if (tier == GettingReadyTier.gather)
            pw.Text(_safe(l.grGatherVoice), style: smallBodyStyle()),
        ],
        pw.SizedBox(height: 14),
        pw.Text(
          _safe(l.assistantNotLegalOrMedicalAdvice(appData.phoneOf('paProtectionAdvocacy'))),
          style: pw.TextStyle(fontSize: 9, color: kDarkGrey),
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
