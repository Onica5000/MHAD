/// Shared drawing primitives for PA MHAD PDF forms.
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// ---------------------------------------------------------------------------
// Colors
// ---------------------------------------------------------------------------

const kTeal = PdfColor.fromInt(0xFF006B6B);
const kLightGrey = PdfColor.fromInt(0xFFEEEEEE);
const kBlack = PdfColor.fromInt(0xFF000000);
const kDarkGrey = PdfColor.fromInt(0xFF444444);

// ---------------------------------------------------------------------------
// Typography
// ---------------------------------------------------------------------------

pw.TextStyle bodyStyle({double fontSize = 9}) =>
    pw.TextStyle(fontSize: fontSize, color: kBlack);

pw.TextStyle boldStyle({double fontSize = 9}) => pw.TextStyle(
      fontSize: fontSize,
      fontWeight: pw.FontWeight.bold,
      color: kBlack,
    );

pw.TextStyle sectionHeaderStyle() => pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );

pw.TextStyle labelStyle() => pw.TextStyle(
      fontSize: 8,
      color: kDarkGrey,
    );

pw.TextStyle smallBodyStyle() => pw.TextStyle(fontSize: 7.5, color: kBlack);

// ---------------------------------------------------------------------------
// Page setup — US Letter with 0.75 inch margins
// ---------------------------------------------------------------------------

const kPageFormat = PdfPageFormat.letter;
const kMargin = 54.0; // 0.75 inch

pw.EdgeInsets get pageMargins =>
    const pw.EdgeInsets.all(kMargin);

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

/// Teal section header bar (like the original form headers).
pw.Widget sectionHeader(String text) {
  return pw.Container(
    width: double.infinity,
    color: kTeal,
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: pw.Text(text, style: sectionHeaderStyle()),
  );
}

/// Sub-section label in bold (e.g., "Part I. Introduction").
pw.Widget partHeader(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 8, bottom: 4),
    child: pw.Text(text, style: boldStyle(fontSize: 9.5)),
  );
}

/// A labeled blank line for text entry.
pw.Widget blankLine(String label, {double width = double.infinity}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: labelStyle()),
      pw.SizedBox(height: 2),
      pw.Container(
        width: width,
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: kBlack, width: 0.5),
          ),
        ),
        height: 14,
      ),
      pw.SizedBox(height: 4),
    ],
  );
}

/// A labeled filled-in value line for user data.
pw.Widget dataLine(String label, String value, {double width = double.infinity}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: labelStyle()),
      pw.SizedBox(height: 1),
      pw.Container(
        width: width,
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: kBlack, width: 0.5),
          ),
        ),
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Text(
          value.isEmpty ? ' ' : value,
          style: bodyStyle(fontSize: 9),
        ),
      ),
      pw.SizedBox(height: 4),
    ],
  );
}

/// A text area (multiple lines) for longer content.
pw.Widget dataBlock(String label, String value, {int lines = 3}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: boldStyle(fontSize: 8.5)),
      pw.SizedBox(height: 2),
      pw.Container(
        width: double.infinity,
        constraints: const pw.BoxConstraints(minHeight: 36),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: kDarkGrey, width: 0.5),
        ),
        padding: const pw.EdgeInsets.all(4),
        child: pw.Text(
          value.isEmpty ? ' ' : value,
          style: bodyStyle(fontSize: 9),
        ),
      ),
      pw.SizedBox(height: 6),
    ],
  );
}

/// A checkbox row — checked or unchecked.
pw.Widget checkRow(String text, {bool checked = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          checked ? '\u2612' : '\u2610',
          style: pw.TextStyle(fontSize: 10),
        ),
        pw.SizedBox(width: 5),
        pw.Expanded(
          child: pw.Text(text, style: bodyStyle()),
        ),
      ],
    ),
  );
}

/// A signature block with a line and label below.
pw.Widget signatureBlock(String label, {String? name, String? address}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 8),
      pw.Container(
        width: double.infinity,
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(color: kBlack, width: 0.5),
          ),
        ),
        height: 28,
      ),
      pw.Text(label, style: labelStyle()),
      if (name != null && name.isNotEmpty) ...[
        pw.SizedBox(height: 3),
        dataLine('Name', name),
      ],
      if (address != null && address.isNotEmpty) ...[
        dataLine('Address', address),
      ],
      pw.SizedBox(height: 6),
    ],
  );
}

/// Horizontal divider.
pw.Widget divider() {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Divider(color: kDarkGrey, thickness: 0.5),
  );
}

/// Page header widget shown at the top of every page.
pw.Widget pageHeader(String formTitle) {
  return pw.Column(
    children: [
      pw.Container(
        width: double.infinity,
        color: kTeal,
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'PENNSYLVANIA MENTAL HEALTH ADVANCE DIRECTIVE',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
            pw.Text(
              formTitle,
              style: pw.TextStyle(fontSize: 7, color: PdfColors.white),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 4),
    ],
  );
}

/// Page footer (page number + legal notice).
pw.Widget pageFooter(String footerText) {
  return pw.Column(
    children: [
      pw.Divider(color: kDarkGrey, thickness: 0.3),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Disabilities Law Project 2005. All Rights Reserved.',
            style: pw.TextStyle(fontSize: 6.5, color: kDarkGrey),
          ),
          pw.Text(footerText, style: pw.TextStyle(fontSize: 6.5, color: kDarkGrey)),
        ],
      ),
    ],
  );
}

/// Two-column row layout helper.
pw.Widget twoCol(pw.Widget left, pw.Widget right) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(child: pw.Padding(
        padding: const pw.EdgeInsets.only(right: 8),
        child: left,
      )),
      pw.Expanded(child: right),
    ],
  );
}

/// Three-column row for medication tables.
pw.Widget medTableHeader() {
  return pw.Container(
    color: kLightGrey,
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text('Medication', style: boldStyle(fontSize: 8)),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text('Reason', style: boldStyle(fontSize: 8)),
        ),
      ],
    ),
  );
}

pw.Widget medTableHeaderThree() {
  return pw.Container(
    color: kLightGrey,
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text('Medication', style: boldStyle(fontSize: 8)),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text('Limitation', style: boldStyle(fontSize: 8)),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text('Reason', style: boldStyle(fontSize: 8)),
        ),
      ],
    ),
  );
}

pw.Widget medTableRow(String medication, String reason) {
  return pw.Container(
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: kLightGrey, width: 0.5),
      ),
    ),
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(medication, style: bodyStyle(fontSize: 8)),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text(reason, style: bodyStyle(fontSize: 8)),
        ),
      ],
    ),
  );
}

pw.Widget medTableRowThree(
    String medication, String limitation, String reason) {
  return pw.Container(
    decoration: const pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: kLightGrey, width: 0.5),
      ),
    ),
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(medication, style: bodyStyle(fontSize: 8)),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(limitation, style: bodyStyle(fontSize: 8)),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text(reason, style: bodyStyle(fontSize: 8)),
        ),
      ],
    ),
  );
}

pw.Widget medTable(
    String label, List<Map<String, String>> rows, bool threeCol) {
  if (rows.isEmpty) return pw.SizedBox();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: boldStyle(fontSize: 8.5)),
      pw.SizedBox(height: 2),
      pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: kDarkGrey, width: 0.5),
        ),
        child: pw.Column(
          children: [
            threeCol ? medTableHeaderThree() : medTableHeader(),
            ...rows.map((r) => threeCol
                ? medTableRowThree(
                    r['medication'] ?? '',
                    r['limitation'] ?? '',
                    r['reason'] ?? '',
                  )
                : medTableRow(r['medication'] ?? '', r['reason'] ?? '')),
          ],
        ),
      ),
      pw.SizedBox(height: 4),
    ],
  );
}
