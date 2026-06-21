/// Domain-specific PDF builders for PA MHAD forms: pieces that consume
/// directive data (guardian/consent/medication/diagnosis/facility/witness/
/// room preferences) and turn it into form sections. They build on the
/// presentation primitives in `pdf_layout.dart`. Both are re-exported by
/// `pdf_helpers.dart`.
library;

import 'dart:convert';

import 'package:mhad/constants.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/export/pdf/pdf_layout.dart';
import 'package:pdf/widgets.dart' as pw;

/// Resolves the four nominee display fields for the Guardian section based
/// on the `guardian_relation` choice. The Phase-2 GuardianNominationStep
/// blanks the persisted nominee columns for the three non-"different"
/// branches, so PDF generators must fall back to the named agent (or skip
/// rendering entirely for "noPreference") to avoid emitting an empty
/// nominee block. See PROTOTYPE_DIFF_DECISIONS § E.4 and the senior-code-
/// review finding "PDFs gate guardian on nomineeFullName".
class GuardianDisplay {
  final String fullName;
  final String address;       // street only (line 1 + line 2)
  final String cityStateZip;  // "City, State ZIP"
  final String phone;
  final String relationship;

  /// True when the resolved nominee is meaningful and should be rendered.
  /// False for `noPreference` (court decides) or unresolved `sameAs*` with
  /// no matching agent on file.
  final bool hasNominee;

  const GuardianDisplay({
    required this.fullName,
    required this.address,
    this.cityStateZip = '',
    required this.phone,
    required this.relationship,
    required this.hasNominee,
  });

  static const empty = GuardianDisplay(
    fullName: '',
    address: '',
    cityStateZip: '',
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
        address: a.streetAddress,
        cityStateZip: a.cityStateZip,
        phone: pickPhone(a),
        relationship: a.relationship,
        hasNominee: true,
      );
    case 'sameAsAlternate':
      final a = agentByType('alternate');
      if (a == null || a.fullName.isEmpty) return GuardianDisplay.empty;
      return GuardianDisplay(
        fullName: a.fullName,
        address: a.streetAddress,
        cityStateZip: a.cityStateZip,
        phone: pickPhone(a),
        relationship: a.relationship,
        hasNominee: true,
      );
    case 'different':
      if (guardian.nomineeFullName.isEmpty) return GuardianDisplay.empty;
      return GuardianDisplay(
        fullName: guardian.nomineeFullName,
        address: guardian.nomineeStreetAddress,
        cityStateZip: guardian.nomineeCityStateZip,
        phone: guardian.nomineePhone,
        relationship: guardian.nomineeRelationship,
        hasNominee: true,
      );
    case 'noPreference':
    default:
      return GuardianDisplay.empty;
  }
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
  String? cityStateZip,
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
      dataLine('City, State, Zip Code', cityStateZip ?? ''),
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
      .where((d) => d.icdCode.isNotEmpty && d.icdCode.startsWith('F'))
      .toList();
  final medical = diagnoses
      .where((d) => d.icdCode.isNotEmpty && !d.icdCode.startsWith('F'))
      .toList();
  final uncoded = diagnoses.where((d) => d.icdCode.isEmpty).toList();

  pw.Widget buildGroup(String title, List<dynamic> items,
      {bool showCode = true}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('$title:', style: boldStyle(fontSize: 9)),
        pw.SizedBox(height: 2),
        ...items.map(
          (d) => pw.Padding(
            padding: const pw.EdgeInsets.only(left: 8, bottom: 1),
            child: pw.Text(
              showCode
                  ? '• ${d.icdCode} — ${d.name}'
                  : '• ${d.name}',
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
      if (uncoded.isNotEmpty)
        buildGroup('Other Diagnoses', uncoded, showCode: false),
      pw.SizedBox(height: 2),
    ],
  );
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

/// Splits [meds] into the four Act-194 categories used by all PDF builders.
({
  List<MedicationEntry> current,
  List<MedicationEntry> exceptions,
  List<MedicationEntry> limitations,
  List<MedicationEntry> preferred,
}) categorizeMedications(List<MedicationEntry> meds) => (
      current: meds
          .where((m) => m.entryType == MedicationEntryType.current.name)
          .toList(),
      exceptions: meds
          .where((m) => m.entryType == MedicationEntryType.exception.name)
          .toList(),
      limitations: meds
          .where((m) => m.entryType == MedicationEntryType.limitation.name)
          .toList(),
      preferred: meds
          .where((m) => m.entryType == MedicationEntryType.preferred.name)
          .toList(),
    );

/// Returns the best available phone number for an agent, or empty string.
String agentBestPhone(Agent? agent) => agent?.bestPhone ?? '';

/// Appends a dosage to a medication name for display — `"Lisinopril (10 mg
/// daily)"` — or just the name when no dosage was given. Used for the
/// currently-taking section, the only one that captures a dosage.
String medicationWithDosage(String name, String dosage) {
  final d = dosage.trim();
  return d.isEmpty ? name : '$name ($d)';
}
