/// Low-level drawing primitives for PA MHAD PDF forms: colors, typography,
/// page setup, and generic labeled-line / table / page-chrome widgets. These
/// take only strings, numbers, and pw widgets — no MHAD domain types. The
/// domain builders that consume directive data live in
/// `pdf_section_builders.dart`. Both are re-exported by `pdf_helpers.dart`.
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Draft export modes. A draft prints a light per-page watermark so a copy
/// can be sent out while the user keeps the signed paper original.
enum DraftMode {
  /// No watermark — the normal copy.
  finalCopy,

  /// Plain draft.
  draftGeneral,

  /// Draft that signals a signed, witnessed original exists.
  draftSignedAvailable,
}

/// Short marker label for the chosen [DraftMode], matching the watermark so the
/// header/metadata agree with what the user ticked. Empty for a final copy, so
/// a "Final copy" prints with NO "DRAFT — UNSIGNED" marker. The print-type
/// checkboxes — not the saved directive status — decide this.
String draftLabel(DraftMode mode) => switch (mode) {
      DraftMode.finalCopy => '',
      DraftMode.draftGeneral => 'DRAFT — UNSIGNED',
      DraftMode.draftSignedAvailable => 'DRAFT — signed copy on file',
    };

/// A very light, rotated full-page watermark for draft exports. Returns an
/// empty widget for [DraftMode.finalCopy]. Used as a MultiPage background, so
/// it repeats on every page behind the form content.
pw.Widget draftWatermark(DraftMode mode) {
  final text = switch (mode) {
    DraftMode.finalCopy => '',
    DraftMode.draftGeneral => 'DRAFT — not the signed copy',
    DraftMode.draftSignedAvailable =>
      'DRAFT — a signed, witnessed original exists',
  };
  if (text.isEmpty) return pw.SizedBox();
  return pw.FullPage(
    ignoreMargins: true,
    child: pw.Center(
      child: pw.Transform.rotate(
        angle: 0.7,
        child: pw.Opacity(
          opacity: 0.07,
          child: pw.Text(
            text,
            style: pw.TextStyle(
              fontSize: 26,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
            ),
          ),
        ),
      ),
    ),
  );
}

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

// Body text is sized to match the official PA MHAD form (~11pt) for
// readability; earlier builds used 9pt to cram everything into 6 fixed pages.
// With MultiPage flow the content paginates naturally, so we can use the
// larger, more legible size.
pw.TextStyle bodyStyle({double fontSize = 11}) =>
    pw.TextStyle(fontSize: fontSize, color: kBlack);

pw.TextStyle boldStyle({double fontSize = 11}) => pw.TextStyle(
  fontSize: fontSize,
  fontWeight: pw.FontWeight.bold,
  color: kBlack,
);

/// Large teal "Part" header — matches the official form (e.g. "Part II.
/// Mental Health Declaration" is rendered as teal *text*, not a filled bar).
pw.TextStyle sectionHeaderStyle() =>
    pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: kTeal);

pw.TextStyle labelStyle() => pw.TextStyle(fontSize: 9.5, color: kDarkGrey);

pw.TextStyle smallBodyStyle() => pw.TextStyle(fontSize: 9, color: kBlack);

// ---------------------------------------------------------------------------
// Page setup — US Letter with 0.75 inch margins
// ---------------------------------------------------------------------------

const kPageFormat = PdfPageFormat.letter;
const kMargin = 54.0; // 0.75 inch

pw.EdgeInsets get pageMargins => const pw.EdgeInsets.all(kMargin);

// ---------------------------------------------------------------------------
// Building blocks
// ---------------------------------------------------------------------------

/// Large teal "Part" header — teal text matching the official form (the
/// original prints these as teal text, not a white-on-teal filled bar).
pw.Widget sectionHeader(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 6, bottom: 4),
    child: pw.Text(text, style: sectionHeaderStyle()),
  );
}

/// Teal sub-section label (e.g., "A. Treatment preferences") — the official
/// form prints the A./B./C. headers in teal bold, like the Part headers.
pw.Widget partHeader(String text) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 8, bottom: 3),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: kTeal,
      ),
    ),
  );
}

// Shared layout metrics for every labeled fill-in line so blank lines, data
// lines, and signature lines are spaced identically (label ALWAYS above the
// line, same gap above and below). See [blankLine] / [dataLine] /
// [signatureBlock].
const double _kLineLabelGap = 2; // label → line
const double _kLineTrailing = 6; // line → next field
const double _kLineHeight = 16; // empty entry / signature line height

/// A labeled blank line for text entry. Label above the line.
pw.Widget blankLine(String label, {double width = double.infinity}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: labelStyle()),
      pw.SizedBox(height: _kLineLabelGap),
      pw.Container(
        width: width,
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: kBlack, width: 0.5)),
        ),
        height: _kLineHeight,
      ),
      pw.SizedBox(height: _kLineTrailing),
    ],
  );
}

/// A labeled filled-in value line for user data. Label above the line.
pw.Widget dataLine(
  String label,
  String value, {
  double width = double.infinity,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: labelStyle()),
      pw.SizedBox(height: _kLineLabelGap),
      pw.Container(
        width: width,
        // Same writing-line height as [blankLine] / [signatureBlock] so a blank
        // OR short filled line always occupies a uniform _kLineHeight; longer
        // values still grow (minHeight, not a fixed height). The value sits on
        // the line (bottom-aligned) regardless of its height.
        constraints: const pw.BoxConstraints(minHeight: _kLineHeight),
        alignment: pw.Alignment.bottomLeft,
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: kBlack, width: 0.5)),
        ),
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: value.isEmpty ? null : pw.Text(value, style: bodyStyle()),
      ),
      pw.SizedBox(height: _kLineTrailing),
    ],
  );
}

/// A text area (multiple lines) for longer content.
pw.Widget dataBlock(String label, String value, {int lines = 3}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: boldStyle(fontSize: 10.5)),
      pw.SizedBox(height: 2),
      pw.Container(
        width: double.infinity,
        constraints: const pw.BoxConstraints(minHeight: 30),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: kDarkGrey, width: 0.5),
        ),
        padding: const pw.EdgeInsets.all(5),
        child: pw.Text(value.isEmpty ? ' ' : value, style: bodyStyle()),
      ),
      pw.SizedBox(height: 6),
    ],
  );
}

/// A checkbox row — checked or unchecked.
/// Uses pw.CustomPaint with a raw-graphics closure (CustomPainter is a
/// typedef, not a class) to draw directly via PDF graphics operators.
pw.Widget checkRow(String text, {bool checked = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 1.5),
          child: pw.SizedBox(
            width: 12,
            height: 12,
            child: pw.CustomPaint(
              size: const PdfPoint(12, 12),
              painter: (PdfGraphics canvas, PdfPoint size) {
                final w = size.x;
                final h = size.y;
                const pad = 1.5;

                canvas.setFillColor(PdfColors.white);
                canvas.drawRect(0, 0, w, h);
                canvas.fillPath();

                canvas.setStrokeColor(PdfColors.black);
                canvas.setLineWidth(0.75);
                canvas.drawRect(0, 0, w, h);
                canvas.strokePath();

                if (checked) {
                  canvas.setLineWidth(1.2);
                  canvas.moveTo(pad, pad);
                  canvas.lineTo(w - pad, h - pad);
                  canvas.strokePath();
                  canvas.moveTo(pad, h - pad);
                  canvas.lineTo(w - pad, pad);
                  canvas.strokePath();
                }
              },
            ),
          ),
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(child: pw.Text(text, style: bodyStyle())),
      ],
    ),
  );
}

/// An initials row — used for the three authorizations (ECT, experimental
/// studies, drug trials) that PA law (20 Pa.C.S. §5836(c)) requires the
/// declarant to initial rather than merely check. The box is always printed
/// empty; the declarant must physically write their initials at signing.
/// [highlighted] draws a light background to visually guide the signer when
/// the user has digitally chosen to grant this authority.
pw.Widget initialRow(String text, {bool highlighted = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(
              width: 36,
              height: 16,
              child: pw.CustomPaint(
                size: const PdfPoint(36, 16),
                painter: (PdfGraphics canvas, PdfPoint size) {
                  if (highlighted) {
                    canvas.setFillColor(PdfColors.yellow100);
                    canvas.drawRect(0, 0, size.x, size.y);
                    canvas.fillPath();
                  } else {
                    canvas.setFillColor(PdfColors.white);
                    canvas.drawRect(0, 0, size.x, size.y);
                    canvas.fillPath();
                  }
                  canvas.setStrokeColor(PdfColors.black);
                  canvas.setLineWidth(0.75);
                  canvas.drawRect(0, 0, size.x, size.y);
                  canvas.strokePath();
                },
              ),
            ),
            pw.SizedBox(height: 1),
            pw.Text('INITIALS', style: pw.TextStyle(fontSize: 6, color: kDarkGrey)),
          ],
        ),
        pw.SizedBox(width: 6),
        pw.Expanded(child: pw.Text(text, style: bodyStyle())),
      ],
    ),
  );
}

/// A signature block: label above the line (uniform with [blankLine] /
/// [dataLine]), then optional filled-in Name / Address lines.
pw.Widget signatureBlock(String label, {String? name, String? address}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: labelStyle()),
      pw.SizedBox(height: _kLineLabelGap),
      pw.Container(
        width: double.infinity,
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: kBlack, width: 0.5)),
        ),
        height: _kLineHeight,
      ),
      pw.SizedBox(height: _kLineTrailing),
      if (name != null && name.isNotEmpty) dataLine('Name', name),
      if (address != null && address.isNotEmpty) dataLine('Address', address),
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
      // Effective-date / term caption under the header bar. The incapacity
      // exception is stated in full in the document body; this line carries
      // the statutory metadata the header was missing.
      pw.Padding(
        padding: const pw.EdgeInsets.only(top: 2),
        child: pw.Text(
          'Pennsylvania Act 194 of 2004 · effective January 29, 2005 · '
          'valid two years from execution unless you are incapable when it '
          'would expire (then it remains in effect until capacity returns).',
          style: pw.TextStyle(fontSize: 6, color: kDarkGrey),
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
          pw.Text(
            footerText,
            style: pw.TextStyle(fontSize: 6.5, color: kDarkGrey),
          ),
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
      pw.Expanded(
        child: pw.Padding(
          padding: const pw.EdgeInsets.only(right: 8),
          child: left,
        ),
      ),
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
          child: pw.Text('Medication', style: boldStyle(fontSize: 10)),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text('Reason', style: boldStyle(fontSize: 10)),
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
          child: pw.Text('Medication', style: boldStyle(fontSize: 10)),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text('Limitation', style: boldStyle(fontSize: 10)),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text('Reason', style: boldStyle(fontSize: 10)),
        ),
      ],
    ),
  );
}

pw.Widget medTableRow(String medication, String reason) {
  return pw.Container(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: kLightGrey, width: 0.5)),
    ),
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(medication, style: bodyStyle(fontSize: 10)),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text(reason, style: bodyStyle(fontSize: 10)),
        ),
      ],
    ),
  );
}

pw.Widget medTableRowThree(
  String medication,
  String limitation,
  String reason,
) {
  return pw.Container(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: kLightGrey, width: 0.5)),
    ),
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          flex: 3,
          child: pw.Text(medication, style: bodyStyle(fontSize: 10)),
        ),
        pw.Expanded(
          flex: 3,
          child: pw.Text(limitation, style: bodyStyle(fontSize: 10)),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text(reason, style: bodyStyle(fontSize: 10)),
        ),
      ],
    ),
  );
}

pw.Widget medTable(
  String label,
  List<Map<String, String>> rows,
  bool threeCol,
) {
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
            ...rows.map(
              (r) => threeCol
                  ? medTableRowThree(
                      r['medication'] ?? '',
                      r['limitation'] ?? '',
                      r['reason'] ?? '',
                    )
                  : medTableRow(r['medication'] ?? '', r['reason'] ?? ''),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 4),
    ],
  );
}

// ---------------------------------------------------------------------------
// Month name helper
// ---------------------------------------------------------------------------

String monthName(int month) {
  const months = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month];
}

/// Format execution date string per official form.
String formatExecDate(int? executionDateMs) {
  if (executionDateMs == null) {
    return '________ day of (month)_____________, (year)_______________';
  }
  final d = DateTime.fromMillisecondsSinceEpoch(executionDateMs);
  return '${d.day} day of ${monthName(d.month)}, ${d.year}';
}
