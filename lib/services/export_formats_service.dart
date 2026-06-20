import 'package:mhad/constants.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/services/instruction_fields.dart';

/// Additional machine-readable export formats beyond the FHIR JSON produced by
/// [FhirExportService] — a flat CSV and a FHIR R4 Consent in XML. Both are
/// pure-Dart string builders (no plugins), so they work identically on Android,
/// Windows and web.
///
/// These complement the human-readable PDF: CSV is for spreadsheets / quick
/// scanning, FHIR XML is for EHRs that ingest XML rather than JSON.
class ExportFormatsService {
  ExportFormatsService._();

  // ── CSV ────────────────────────────────────────────────────────────────

  /// A flat `Section,Item,Detail` CSV of the whole directive. RFC-4180 quoting.
  static String exportAsCsv({
    required Directive directive,
    required List<Agent> agents,
    required List<MedicationEntry> medications,
    required DirectivePref? prefs,
    required AdditionalInstructionsTableData? additional,
    List<WitnessesData>? witnesses,
    GuardianNomination? guardian,
    List<DiagnosisEntry>? diagnoses,
  }) {
    final rows = <List<String>>[
      ['Section', 'Item', 'Detail'],
    ];
    void row(String section, String item, String detail) {
      if (detail.trim().isEmpty) return;
      rows.add([section, item, detail.trim()]);
    }

    row('Directive', 'Form type', directive.formType);
    row('Directive', 'Status', directive.status);
    row('Directive', 'Full name', directive.fullName);
    row('Directive', 'Date of birth', directive.dateOfBirth);
    row('Directive', 'Effective condition', directive.effectiveCondition);
    if (directive.executionDate != null && directive.executionDate != 0) {
      row(
        'Directive',
        'Executed',
        DateTime.fromMillisecondsSinceEpoch(directive.executionDate!)
            .toIso8601String(),
      );
    }

    for (final a in agents) {
      if (a.fullName.isEmpty) continue;
      final section = 'Agent (${a.agentType})';
      row(section, a.fullName,
          [a.relationship, a.cellPhone].where((s) => s.isNotEmpty).join(' · '));
      row(section, 'Address', a.fullAddress);
    }

    for (final m in medications) {
      final kind = switch (m.entryType) {
        'exception' => 'Avoid',
        'preferred' => 'Preferred',
        _ => 'Limitation',
      };
      row('Medication · $kind', m.medicationName, m.reason);
    }

    if (prefs != null) {
      row('Procedures', 'ECT consent', prefs.ectConsent);
      row('Procedures', 'Drug-trial consent', prefs.drugTrialConsent);
    }

    if (diagnoses != null) {
      for (final d in diagnoses) {
        row('Diagnosis', d.name, d.icdCode);
      }
    }

    if (additional != null) {
      for (final n in additionalInstructionNotesCsv(additional)) {
        row('Instructions', n.label, n.value);
      }
    }

    if (witnesses != null) {
      for (final w in witnesses) {
        if (w.fullName.isEmpty) continue;
        final section = 'Witness ${w.witnessNumber}';
        row(section, w.fullName, '');
        row(section, 'Address', w.fullAddress);
        row(section, 'Phone', w.phone);
      }
    }

    if (guardian != null && guardian.nomineeFullName.isNotEmpty) {
      row('Guardian', guardian.nomineeFullName, guardian.nomineeRelationship);
      row('Guardian', 'Address', guardian.fullNomineeAddress);
      row('Guardian', 'Phone', guardian.nomineePhone);
    }

    return rows.map((r) => r.map(_csvCell).join(',')).join('\r\n');
  }

  static String _csvCell(String value) {
    final needsQuote =
        value.contains(',') || value.contains('"') || value.contains('\n') ||
            value.contains('\r');
    final escaped = value.replaceAll('"', '""');
    return needsQuote ? '"$escaped"' : escaped;
  }

  // ── FHIR R4 Consent · XML ────────────────────────────────────────────────

  /// FHIR R4 Consent resource as XML (mirrors [FhirExportService.exportAsJson]).
  static String exportAsFhirXml({
    required Directive directive,
    required List<Agent> agents,
    required List<MedicationEntry> medications,
    required DirectivePref? prefs,
    required AdditionalInstructionsTableData? additional,
    List<WitnessesData>? witnesses,
    GuardianNomination? guardian,
    List<DiagnosisEntry>? diagnoses,
  }) {
    final b = StringBuffer();
    final updated = DateTime.fromMillisecondsSinceEpoch(directive.updatedAt)
        .toIso8601String();

    b.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    b.writeln('<Consent xmlns="http://hl7.org/fhir">');
    b.writeln('  <id value="mhad-directive-${directive.id}"/>');
    b.writeln('  <meta>');
    b.writeln('    <lastUpdated value="${_xml(updated)}"/>');
    b.writeln('    <profile value="http://hl7.org/fhir/StructureDefinition/'
        'Consent"/>');
    b.writeln('  </meta>');
    b.writeln('  <status value="'
        '${directive.status == 'complete' ? 'active' : 'draft'}"/>');
    b.writeln('  <scope>');
    b.writeln('    <coding>');
    b.writeln('      <system value="http://terminology.hl7.org/CodeSystem/'
        'consentscope"/>');
    b.writeln('      <code value="adr"/>');
    b.writeln('      <display value="Advance Directive"/>');
    b.writeln('    </coding>');
    b.writeln('  </scope>');
    b.writeln('  <category>');
    b.writeln('    <coding>');
    b.writeln('      <system value="http://loinc.org"/>');
    b.writeln('      <code value="83334-6"/>');
    b.writeln('      <display value="Psychiatric advance directive"/>');
    b.writeln('    </coding>');
    b.writeln('  </category>');
    b.writeln('  <dateTime value="${_xml(updated)}"/>');

    if (directive.fullName.isNotEmpty) {
      b.writeln('  <patient>');
      b.writeln('    <display value="${_xml(directive.fullName)}"/>');
      b.writeln('  </patient>');
    }

    b.writeln('  <policyRule>');
    b.writeln('    <text value="Pennsylvania Mental Health Advance Directive '
        '(Act 194 of 2004)"/>');
    b.writeln('  </policyRule>');

    b.writeln('  <provision>');
    for (final med in medications) {
      b.writeln('    <provision>');
      b.writeln('      <type value="'
          '${med.entryType == 'exception' ? 'deny' : 'permit'}"/>');
      b.writeln('      <code>');
      b.writeln('        <text value="${_xml(med.medicationName)}"/>');
      b.writeln('      </code>');
      b.writeln('    </provision>');
    }
    if (prefs != null) {
      b.writeln('    <provision>');
      b.writeln('      <type value="'
          '${prefs.ectConsent == consentYes ? 'permit' : 'deny'}"/>');
      b.writeln('      <code>');
      b.writeln('        <coding>');
      b.writeln('          <system value="http://snomed.info/sct"/>');
      b.writeln('          <code value="35631009"/>');
      b.writeln('          <display value="Electroconvulsive therapy"/>');
      b.writeln('        </coding>');
      b.writeln('      </code>');
      b.writeln('    </provision>');
    }
    if (diagnoses != null) {
      for (final d in diagnoses) {
        b.writeln('    <provision>');
        b.writeln('      <type value="permit"/>');
        b.writeln('      <code>');
        b.writeln('        <coding>');
        b.writeln('          <system value="http://hl7.org/fhir/sid/'
            'icd-10-cm"/>');
        b.writeln('          <code value="${_xml(d.icdCode)}"/>');
        b.writeln('          <display value="${_xml(d.name)}"/>');
        b.writeln('        </coding>');
        b.writeln('      </code>');
        b.writeln('    </provision>');
      }
    }
    for (final a in agents) {
      if (a.fullName.isEmpty) continue;
      final display = [
        '${a.fullName} (${a.agentType})',
        if (a.fullAddress.isNotEmpty) a.fullAddress,
        if (a.bestPhone.isNotEmpty) a.bestPhone,
      ].join(' · ');
      b.writeln('    <actor>');
      b.writeln('      <role>');
      b.writeln('        <coding>');
      b.writeln('          <system value="http://terminology.hl7.org/'
          'CodeSystem/extra-security-role-type"/>');
      b.writeln('          <code value="HPOWATT"/>');
      b.writeln('          <display value="Healthcare Power of Attorney"/>');
      b.writeln('        </coding>');
      b.writeln('      </role>');
      b.writeln('      <reference>');
      b.writeln('        <display value="${_xml(display)}"/>');
      b.writeln('      </reference>');
      b.writeln('    </actor>');
    }
    if (guardian != null && guardian.nomineeFullName.isNotEmpty) {
      final display = [
        '${guardian.nomineeFullName} (${guardian.nomineeRelationship})',
        if (guardian.fullNomineeAddress.isNotEmpty) guardian.fullNomineeAddress,
        if (guardian.nomineePhone.isNotEmpty) guardian.nomineePhone,
      ].join(' · ');
      b.writeln('    <actor>');
      b.writeln('      <role>');
      b.writeln('        <coding>');
      b.writeln('          <system value="http://terminology.hl7.org/'
          'CodeSystem/v3-RoleCode"/>');
      b.writeln('          <code value="GUARD"/>');
      b.writeln('          <display value="Guardian"/>');
      b.writeln('        </coding>');
      b.writeln('      </role>');
      b.writeln('      <reference>');
      b.writeln('        <display value="${_xml(display)}"/>');
      b.writeln('      </reference>');
      b.writeln('    </actor>');
    }
    b.writeln('  </provision>');

    if (additional != null) {
      void note(String label, String value) {
        if (value.isEmpty) return;
        b.writeln('  <note>');
        b.writeln('    <text value="${_xml('$label: $value')}"/>');
        b.writeln('  </note>');
      }

      for (final n in additionalInstructionNotes(additional)) {
        note(n.label, n.value);
      }
    }

    b.writeln('</Consent>');
    return b.toString();
  }

  static String _xml(String value) => value
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&apos;');
}
