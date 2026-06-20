/// Shared drawing primitives for PA MHAD PDF forms.
library;

import 'dart:convert';

import 'package:mhad/constants.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
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

/// Resolves the four nominee display fields for the Guardian section based
/// on the `guardian_relation` choice. The Phase-2 GuardianNominationStep
/// blanks the persisted nominee columns for the three non-"different"
/// branches, so PDF generators must fall back to the named agent (or skip
/// rendering entirely for "noPreference") to avoid emitting an empty
/// nominee block. See PROTOTYPE_DIFF_DECISIONS § E.4 and the senior-code-
/// review finding "PDFs gate guardian on nomineeFullName".
class GuardianDisplay {
  final String fullName;
  final String address;
  final String phone;
  final String relationship;

  /// True when the resolved nominee is meaningful and should be rendered.
  /// False for `noPreference` (court decides) or unresolved `sameAs*` with
  /// no matching agent on file.
  final bool hasNominee;

  const GuardianDisplay({
    required this.fullName,
    required this.address,
    required this.phone,
    required this.relationship,
    required this.hasNominee,
  });

  static const empty = GuardianDisplay(
    fullName: '',
    address: '',
    phone: '',
    relationship: '',
    hasNominee: false,
  );
}

/// Compute the effective Guardian display from the persisted row + agents.
///
/// Behavior by `guardianRelation`:
/// * `different` → use the stored nominee fields verbatim.
/// * `sameAsPrimary` / `sameAsAlternate` → resolve to that agent's name +
///   contact + relationship + address. If the agent isn't on file, falls
///   through to the no-nominee state.
/// * `noPreference` (or any unknown value) → empty / hasNominee = false.
GuardianDisplay resolveGuardianDisplay(
  GuardianNomination? guardian,
  List<Agent> agents,
) {
  if (guardian == null) return GuardianDisplay.empty;
    Agent? agentByType(String type) => agents.agentByType(type);
    String pickPhone(Agent a) => a.bestPhone;

  switch (guardian.guardianRelation) {
    case 'sameAsPrimary':
      final a = agentByType('primary');
      if (a == null || a.fullName.isEmpty) return GuardianDisplay.empty;
      return GuardianDisplay(
        fullName: a.fullName,
        address: a.fullAddress,
        phone: pickPhone(a),
        relationship: a.relationship,
        hasNominee: true,
      );
    case 'sameAsAlternate':
      final a = agentByType('alternate');
      if (a == null || a.fullName.isEmpty) return GuardianDisplay.empty;
      return GuardianDisplay(
        fullName: a.fullName,
        address: a.fullAddress,
        phone: pickPhone(a),
        relationship: a.relationship,
        hasNominee: true,
      );
    case 'different':
      if (guardian.nomineeFullName.isEmpty) return GuardianDisplay.empty;
      return GuardianDisplay(
        fullName: guardian.nomineeFullName,
        address: guardian.fullNomineeAddress,
        phone: guardian.nomineePhone,
        relationship: guardian.nomineeRelationship,
        hasNominee: true,
      );
    case 'noPreference':
    default:
      return GuardianDisplay.empty;
  }
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
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: kBlack, width: 0.5)),
        ),
        padding: const pw.EdgeInsets.only(bottom: 2),
        child: pw.Text(value.isEmpty ? ' ' : value, style: bodyStyle()),
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

/// Formats the medication side effects the user CONFIRMED they are experiencing
/// (from the `directive_prefs.side_effects_json` checklist) into a directive
/// block so the care team can see and handle them. Returns `[]` when none are
/// confirmed. Informational only — never a treatment instruction.
List<pw.Widget> experiencedSideEffectsBlocks(String? sideEffectsJson) {
  if (sideEffectsJson == null || sideEffectsJson.isEmpty) return const [];
  List<dynamic> items;
  try {
    final m = jsonDecode(sideEffectsJson) as Map<String, dynamic>;
    items = (m['items'] as List?) ?? const [];
  } catch (_) {
    return const [];
  }
  final lines = <String>[];
  for (final raw in items.whereType<Map<String, dynamic>>()) {
    if (raw['experiencing'] != true) continue;
    final effect = (raw['effect'] ?? '').toString().trim();
    if (effect.isEmpty) continue;
    final med = (raw['med'] ?? '').toString().trim();
    final adl = (raw['adl'] ?? '').toString().trim();
    final serious = raw['serious'] == true;
    final buf = StringBuffer('• $effect');
    if (med.isNotEmpty) buf.write(' ($med)');
    if (adl.isNotEmpty) buf.write(' — may affect: $adl');
    if (serious) buf.write(' — flagged to discuss with my doctor');
    lines.add(buf.toString());
  }
  if (lines.isEmpty) return const [];
  return [
    dataBlock(
      'Medication side effects I am currently experiencing:',
      lines.join('\n'),
      lines: lines.length.clamp(1, 12),
    ),
  ];
}

/// Parse a consent value that may be 'yes', 'no', 'agentDecides', or
/// 'conditional:...'. [isConsentConditional] returns true for 'conditional:...'
/// values (the user consented with conditions); [isConsentNo] / [isConsentAgent]
/// match 'no' / 'agentDecides'.
bool isConsentNo(String value) => value == consentNo;
bool isConsentAgent(String value) => value == consentAgentDecides;
bool isConsentConditional(String value) => value.startsWith(consentConditionalPrefix);
String consentConditionText(String value) => value.startsWith(consentConditionalPrefix)
    ? value.substring(consentConditionalPrefix.length)
    : '';

/// Indented free-form detail printed under a guardianship "yes" condition
/// (the user's qualification of that condition). Renders nothing when empty.
pw.Widget guardianNote(String note) {
  if (note.trim().isEmpty) return pw.SizedBox();
  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: 22, top: 1, bottom: 2),
    child: pw.Text('— ${note.trim()}', style: smallBodyStyle()),
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
/// studies, drug trials) that PA law (20 Pa.C.S. §5805(c)(4)) requires the
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
pw.Widget witnessDetailBlock(
  String label,
  String? name,
  String? address, {
  String? phone,
  int? signatureDate,
}) {
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

  final psychiatric = diagnoses
      .where((d) => d.icdCode.startsWith('F'))
      .toList();
  final medical = diagnoses.where((d) => !d.icdCode.startsWith('F')).toList();

  pw.Widget buildGroup(String title, List<dynamic> items) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('$title:', style: boldStyle(fontSize: 9)),
        pw.SizedBox(height: 2),
        ...items.map(
          (d) => pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8, bottom: 1),
            child: pw.Text(
              '\u2022 ${d.icdCode} — ${d.name}',
              style: bodyStyle(),
            ),
          ),
        ),
        pw.SizedBox(height: 4),
      ],
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (psychiatric.isNotEmpty)
        buildGroup('Psychiatric Diagnoses (ICD-10)', psychiatric),
      if (medical.isNotEmpty) buildGroup('Medical Diagnoses (ICD-10)', medical),
      pw.SizedBox(height: 2),
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
  final entries = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
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

/// Human-readable room & environment preferences for the PDF — the selected
/// chips, the same-gender-roommate match (schema 16), and the free-text note.
/// Returns null when nothing is set, so callers can skip the block entirely.
String? formatRoomPreferences(DirectivePref? prefs) {
  if (prefs == null) return null;
  const labels = <String, String>{
    'singleRoom': 'Single room',
    'windowIfPossible': 'Window if possible',
    'quietFloor': 'Quiet floor',
    'sameGenderRoommate': 'Same-gender roommate',
    'noRoommate': 'No roommate',
    'transAffirmingStaff': 'Trans-affirming staff',
    'lowStimulationUnit': 'Low-stimulation unit',
  };
  final ids = prefs.roomPreferences
      .split(',')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty);
  final chips = <String>[];
  for (final id in ids) {
    var label = labels[id] ?? id;
    if (id == 'sameGenderRoommate') {
      final match = _roommateMatchLabel(prefs.roommateGenderMatch);
      if (match != null) label = '$label (match with: $match)';
    }
    chips.add(label);
  }
  final note = prefs.roomPreferencesNote.trim();
  final parts = <String>[
    if (chips.isNotEmpty) chips.join(', '),
    if (note.isNotEmpty) note,
  ];
  return parts.isEmpty ? null : parts.join('. ');
}

String? _roommateMatchLabel(String raw) {
  final v = raw.trim();
  if (v.isEmpty) return null;
  switch (v) {
    case 'women':
      return 'Women';
    case 'men':
      return 'Men';
    case 'sameAsIdentity':
      return 'Same as my gender identity';
  }
  if (v.startsWith('specify:')) {
    final t = v.substring('specify:'.length).trim();
    return t.isEmpty ? null : t;
  }
  return v;
}
