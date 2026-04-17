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

/// Parse a consent value that may be 'yes', 'no', 'agentDecides', or
/// 'conditional:...' and compare against a target.
/// For 'conditional:...' values, [isConsentYes] returns true (user consented
/// with conditions), [isConsentConditional] returns true, [isConsentNo] false.
bool isConsentYes(String value) =>
    value == 'yes' || value.startsWith('conditional:');
bool isConsentNo(String value) => value == 'no';
bool isConsentAgent(String value) => value == 'agentDecides';
bool isConsentConditional(String value) => value.startsWith('conditional:');
String consentConditionText(String value) =>
    value.startsWith('conditional:') ? value.substring('conditional:'.length) : '';

/// A checkbox row — checked or unchecked.
/// Uses drawn box + ASCII 'X'. Explicit white fill is required because
/// the pdf package defaults to the current graphics fill color (black),
/// which would make unchecked boxes appear filled.
pw.Widget checkRow(String text, {bool checked = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 10,
          height: 10,
          margin: const pw.EdgeInsets.only(top: 0.5),
          decoration: pw.BoxDecoration(
            color: checked ? PdfColors.black : PdfColors.white,
            border: pw.Border.all(color: kBlack, width: 1.0),
          ),
          child: checked
              ? pw.Center(
                  child: pw.Text(
                    'X',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                )
              : pw.SizedBox(),
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

// ---------------------------------------------------------------------------
// Tagged "other" field parsing
// ---------------------------------------------------------------------------

/// Content parsed from the AdditionalInstructions.other field which stores
/// de-escalation, triggers, and reproductive health info with tagged prefixes.
class ParsedOtherContent {
  final String deEscalation;
  final String triggers;
  final String reproductiveHealth;
  final String ectGuidance;
  final String experimentalGuidance;
  final String drugTrialGuidance;
  final String otherText;

  const ParsedOtherContent({
    this.deEscalation = '',
    this.triggers = '',
    this.reproductiveHealth = '',
    this.ectGuidance = '',
    this.experimentalGuidance = '',
    this.drugTrialGuidance = '',
    this.otherText = '',
  });
}

/// Parse tagged entries from `other` field.
ParsedOtherContent parseOtherField(String raw) {
  if (raw.isEmpty) return const ParsedOtherContent();
  const deescTag = '[DE-ESCALATION] ';
  const trigTag = '[TRIGGERS] ';
  const reproTag = '[REPRODUCTIVE] ';
  const ectTag = '[ECT GUIDANCE] ';
  const expTag = '[EXPERIMENTAL GUIDANCE] ';
  const drugTag = '[DRUG TRIAL GUIDANCE] ';

  String deesc = '';
  String trig = '';
  String repro = '';
  String ectGuidance = '';
  String expGuidance = '';
  String drugGuidance = '';
  final otherLines = <String>[];

  for (final line in raw.split('\n')) {
    if (line.startsWith(deescTag)) {
      deesc = line.substring(deescTag.length);
    } else if (line.startsWith(trigTag)) {
      trig = line.substring(trigTag.length);
    } else if (line.startsWith(reproTag)) {
      repro = line.substring(reproTag.length);
    } else if (line.startsWith(ectTag)) {
      ectGuidance = line.substring(ectTag.length);
    } else if (line.startsWith(expTag)) {
      expGuidance = line.substring(expTag.length);
    } else if (line.startsWith(drugTag)) {
      drugGuidance = line.substring(drugTag.length);
    } else {
      otherLines.add(line);
    }
  }

  return ParsedOtherContent(
    deEscalation: deesc.trim(),
    triggers: trig.trim(),
    reproductiveHealth: repro.trim(),
    ectGuidance: ectGuidance.trim(),
    experimentalGuidance: expGuidance.trim(),
    drugTrialGuidance: drugGuidance.trim(),
    otherText: otherLines.join('\n').trim(),
  );
}

// ---------------------------------------------------------------------------
// Signing on behalf section (appears at end of each form)
// ---------------------------------------------------------------------------

/// "If the principal is unable to sign..." block per official form.
pw.Widget signOnBehalfBlock(String formTypeDescription) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.SizedBox(height: 10),
      pw.Text(
        'If the principal making this $formTypeDescription is unable to sign '
        'this document, another individual may sign on behalf of and at the '
        'direction of the principal. An agent or a person signing on behalf '
        'of the principal may not also be a witness.',
        style: bodyStyle(),
      ),
      pw.SizedBox(height: 6),
      blankLine('Signature of person signing on my behalf'),
      blankLine('Name of Person'),
      blankLine('Address'),
      twoCol(blankLine('City, State, Zip Code'), blankLine('Phone Number')),
    ],
  );
}

// ---------------------------------------------------------------------------
// Witness block — full details per official form
// ---------------------------------------------------------------------------

/// Full witness detail block: Name, Address, City/State/Zip, Phone.
pw.Widget witnessDetailBlock(String label, String? name, String? address,
    {String? phone, int? signatureDate}) {
  final dateStr = signatureDate != null
      ? formatExecDate(signatureDate)
      : '____________________';
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      dataLine('Name of Witness', name ?? ''),
      dataLine('Address', address ?? ''),
      dataLine('Phone Number', phone ?? ''),
      dataLine('Date Signed', dateStr),
      pw.SizedBox(height: 6),
    ],
  );
}

/// Renders a list of ICD-10 diagnoses.
pw.Widget diagnosisList(List<dynamic> diagnoses) {
  if (diagnoses.isEmpty) return pw.SizedBox.shrink();

  final psychiatric = diagnoses.where((d) => d.icdCode.startsWith('F')).toList();
  final medical = diagnoses.where((d) => !d.icdCode.startsWith('F')).toList();

  pw.Widget buildGroup(String title, List<dynamic> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('$title:', style: boldStyle(fontSize: 9)),
        pw.SizedBox(height: 2),
        ...items.map((d) => pw.Padding(
              padding: const pw.EdgeInsets.only(left: 8, bottom: 1),
              child: pw.Text(
                '\u2022 ${d.icdCode} — ${d.name}',
                style: bodyStyle(),
              ),
            )),
        pw.SizedBox(height: 4),
      ],
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (psychiatric.isNotEmpty)
        buildGroup('Psychiatric Diagnoses (ICD-10)', psychiatric),
      if (medical.isNotEmpty)
        buildGroup('Medical Diagnoses (ICD-10)', medical),
      pw.SizedBox(height: 2),
    ],
  );
}

// ---------------------------------------------------------------------------
// Month name helper
// ---------------------------------------------------------------------------

String monthName(int month) {
  const months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
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

/// Split "Name | Location" format from treatment facility.
String facilityName(String raw) {
  final parts = raw.split(' | ');
  return parts.first;
}

String facilityLocation(String raw) {
  final parts = raw.split(' | ');
  return parts.length > 1 ? parts[1] : '';
}

/// Render a list of facilities from a newline-delimited "Name | Location" string.
pw.Widget facilityList(String raw) {
  final entries = raw
      .split('\n')
      .where((l) => l.trim().isNotEmpty)
      .toList();
  if (entries.isEmpty) return pw.SizedBox.shrink();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: entries.map((entry) {
      final name = facilityName(entry);
      final loc = facilityLocation(entry);
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 3),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            dataLine('Name', name),
            if (loc.isNotEmpty) dataLine('Address', loc),
          ],
        ),
      );
    }).toList(),
  );
}
