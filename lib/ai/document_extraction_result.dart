/// Structured data extracted from a user-provided document (photo, PDF, text)
/// by the AI. Each field is nullable — only fields the AI could confidently
/// extract are populated.
class DocumentExtractionResult {
  // ── Medications ──────────────────────────────────────────────────────────
  final List<ExtractedMedication> medicationsToAvoid;
  final List<ExtractedMedication> medicationsPreferred;
  // Medications the person takes with restricted use conditions (e.g., "only
  // as last resort", "only in inpatient setting"). Maps to the 'limitation'
  // MedicationEntryType — distinct from preferred and avoid.
  final List<ExtractedMedication> medicationsLimited;

  // ── Diagnoses ────────────────────────────────────────────────────────────
  // Mental health diagnoses — written to DiagnosisEntries (step 6), not to
  // the effectiveCondition text field.
  final List<ExtractedDiagnosis> diagnoses;

  // ── Allergies ────────────────────────────────────────────────────────────
  // Drug, food, material, or other allergies — written to DirectiveAllergies
  // (step 8). Severe drug allergies also cross-populate medications_to_avoid.
  final List<ExtractedAllergy> allergies;

  // ── Treatment facility ───────────────────────────────────────────────────
  final String? preferredFacility;
  final String? avoidFacility;

  // ── Conditions / effective condition ─────────────────────────────────────
  final String? effectiveCondition;

  // ── Agent authority ──────────────────────────────────────────────────────
  // Free-text limitations on what the agent is or is not authorized to do.
  // Maps to DirectivePrefs.agentAuthorityLimitations.
  final String? agentAuthorityLimitations;

  // ── Additional instructions ─────────────────────────────────────────────
  final String? healthHistory;
  final String? dietary;
  final String? religious;
  final String? activities;
  final String? crisisIntervention;
  final String? petCustody;
  final String? childrenCustody;
  final String? familyNotification;
  final String? recordsDisclosure;
  final String? other;

  // ── Personal information (PII) ───────────────────────────────────────────
  // Autofill is the ONE place the AI is allowed to read/return PII, so the
  // declarant and the people they designate can be filled from an uploaded
  // document. The hardcoded PII rule still applies everywhere else (AI
  // suggestions, chat, context — see ai_pii_policy.dart / buildAiFilledFields).
  final ExtractedPersonalInfo personalInfo;

  const DocumentExtractionResult({
    this.medicationsToAvoid = const [],
    this.medicationsPreferred = const [],
    this.medicationsLimited = const [],
    this.diagnoses = const [],
    this.allergies = const [],
    this.preferredFacility,
    this.avoidFacility,
    this.effectiveCondition,
    this.agentAuthorityLimitations,
    this.healthHistory,
    this.dietary,
    this.religious,
    this.activities,
    this.crisisIntervention,
    this.petCustody,
    this.childrenCustody,
    this.familyNotification,
    this.recordsDisclosure,
    this.other,
    this.personalInfo = const ExtractedPersonalInfo(),
  });

  bool get isEmpty =>
      medicationsToAvoid.isEmpty &&
      medicationsPreferred.isEmpty &&
      medicationsLimited.isEmpty &&
      diagnoses.isEmpty &&
      allergies.isEmpty &&
      preferredFacility == null &&
      avoidFacility == null &&
      effectiveCondition == null &&
      agentAuthorityLimitations == null &&
      healthHistory == null &&
      dietary == null &&
      religious == null &&
      activities == null &&
      crisisIntervention == null &&
      petCustody == null &&
      childrenCustody == null &&
      familyNotification == null &&
      recordsDisclosure == null &&
      other == null &&
      personalInfo.isEmpty;

  /// Merge another extraction result into this one (for multi-page documents).
  /// Medications and diagnoses are deduplicated by name. Text fields are
  /// concatenated.
  DocumentExtractionResult merge(DocumentExtractionResult other) {
    return DocumentExtractionResult(
      medicationsToAvoid: _mergeMeds(medicationsToAvoid, other.medicationsToAvoid),
      medicationsPreferred: _mergeMeds(medicationsPreferred, other.medicationsPreferred),
      medicationsLimited: _mergeMeds(medicationsLimited, other.medicationsLimited),
      diagnoses: _mergeDiagnoses(diagnoses, other.diagnoses),
      allergies: _mergeAllergies(allergies, other.allergies),
      preferredFacility: _mergeText(preferredFacility, other.preferredFacility),
      avoidFacility: _mergeText(avoidFacility, other.avoidFacility),
      effectiveCondition: _mergeText(effectiveCondition, other.effectiveCondition),
      agentAuthorityLimitations:
          _mergeText(agentAuthorityLimitations, other.agentAuthorityLimitations),
      healthHistory: _mergeText(healthHistory, other.healthHistory),
      dietary: _mergeText(dietary, other.dietary),
      religious: _mergeText(religious, other.religious),
      activities: _mergeText(activities, other.activities),
      crisisIntervention: _mergeText(crisisIntervention, other.crisisIntervention),
      petCustody: _mergeText(petCustody, other.petCustody),
      childrenCustody: _mergeText(childrenCustody, other.childrenCustody),
      familyNotification: _mergeText(familyNotification, other.familyNotification),
      recordsDisclosure: _mergeText(recordsDisclosure, other.recordsDisclosure),
      other: _mergeText(this.other, other.other),
      personalInfo: personalInfo.merge(other.personalInfo),
    );
  }

  static String? _mergeText(String? a, String? b) {
    if (a == null || a.isEmpty) return b;
    if (b == null || b.isEmpty) return a;
    if (a == b) return a;
    return '$a\n$b';
  }

  static List<ExtractedMedication> _mergeMeds(
      List<ExtractedMedication> a, List<ExtractedMedication> b) {
    final merged = [...a];
    for (final med in b) {
      final exists = merged.any(
          (m) => m.name.toLowerCase() == med.name.toLowerCase());
      if (!exists) merged.add(med);
    }
    return merged;
  }

  static List<ExtractedDiagnosis> _mergeDiagnoses(
      List<ExtractedDiagnosis> a, List<ExtractedDiagnosis> b) {
    final merged = [...a];
    for (final d in b) {
      final exists = merged.any((x) => x.name.toLowerCase() == d.name.toLowerCase());
      if (!exists) merged.add(d);
    }
    return merged;
  }

  static List<ExtractedAllergy> _mergeAllergies(
      List<ExtractedAllergy> a, List<ExtractedAllergy> b) {
    final merged = [...a];
    for (final al in b) {
      final exists = merged.any(
          (x) => x.substance.toLowerCase() == al.substance.toLowerCase());
      if (!exists) merged.add(al);
    }
    return merged;
  }

  /// Build a human-readable summary of what was extracted (for the review UI).
  Map<String, String> toDisplayMap() {
    final map = <String, String>{};
    if (effectiveCondition != null) {
      map['Effective Condition'] = effectiveCondition!;
    }
    if (medicationsToAvoid.isNotEmpty) {
      map['Medications to Avoid'] =
          medicationsToAvoid.map((m) => m.display).join('\n');
    }
    if (medicationsPreferred.isNotEmpty) {
      map['Preferred Medications'] =
          medicationsPreferred.map((m) => m.display).join('\n');
    }
    if (medicationsLimited.isNotEmpty) {
      map['Restricted Use Medications'] =
          medicationsLimited.map((m) => m.display).join('\n');
    }
    if (diagnoses.isNotEmpty) {
      map['Diagnoses'] = diagnoses.map((d) => d.display).join('\n');
    }
    if (allergies.isNotEmpty) {
      map['Allergies'] = allergies.map((a) => a.display).join('\n');
    }
    if (preferredFacility != null) {
      map['Preferred Facility'] = preferredFacility!;
    }
    if (avoidFacility != null) {
      map['Facility to Avoid'] = avoidFacility!;
    }
    if (healthHistory != null) map['Health History'] = healthHistory!;
    if (dietary != null) map['Dietary Needs'] = dietary!;
    if (religious != null) map['Religious/Cultural'] = religious!;
    if (activities != null) map['Helpful Activities'] = activities!;
    if (crisisIntervention != null) {
      map['Crisis Intervention'] = crisisIntervention!;
    }
    if (agentAuthorityLimitations != null) {
      map['Agent Authority Limitations'] = agentAuthorityLimitations!;
    }
    if (other != null) map['Other Instructions'] = other!;
    return map;
  }

  factory DocumentExtractionResult.fromJson(Map<String, dynamic> json) {
    return DocumentExtractionResult(
      medicationsToAvoid: _parseMeds(json['medications_to_avoid']),
      medicationsPreferred: _parseMeds(json['medications_preferred']),
      medicationsLimited: _parseMeds(json['medications_limited']),
      diagnoses: _parseDiagnoses(json['diagnoses']),
      allergies: _parseAllergies(json['allergies']),
      preferredFacility: _str(json['preferred_facility']),
      avoidFacility: _str(json['avoid_facility']),
      effectiveCondition: _str(json['effective_condition']),
      agentAuthorityLimitations: _str(json['agent_authority_limitations']),
      healthHistory: _str(json['health_history']),
      dietary: _str(json['dietary']),
      religious: _str(json['religious']),
      activities: _str(json['activities']),
      crisisIntervention: _str(json['crisis_intervention']),
      petCustody: _str(json['pet_custody']),
      childrenCustody: _str(json['children_custody']),
      familyNotification: _str(json['family_notification']),
      recordsDisclosure: _str(json['records_disclosure']),
      other: _str(json['other']),
      personalInfo: ExtractedPersonalInfo.fromJson(
          json['personal_info'] is Map<String, dynamic>
              ? json['personal_info'] as Map<String, dynamic>
              : const {}),
    );
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static List<ExtractedMedication> _parseMeds(dynamic v) {
    if (v is! List) return [];
    return v
        .whereType<Map<String, dynamic>>()
        .map((m) => ExtractedMedication(
              name: m['name']?.toString() ?? '',
              reason: m['reason']?.toString() ?? '',
            ))
        .where((m) => m.name.isNotEmpty)
        .toList();
  }

  static List<ExtractedDiagnosis> _parseDiagnoses(dynamic v) {
    if (v is! List) return [];
    return v
        .whereType<Map<String, dynamic>>()
        .map((d) => ExtractedDiagnosis(
              name: d['name']?.toString() ?? '',
              icdCode: _str(d['icd_code']),
            ))
        .where((d) => d.name.isNotEmpty)
        .toList();
  }

  static List<ExtractedAllergy> _parseAllergies(dynamic v) {
    if (v is! List) return [];
    return v
        .whereType<Map<String, dynamic>>()
        .map((a) => ExtractedAllergy(
              substance: a['substance']?.toString() ?? '',
              kind: a['kind']?.toString() ?? 'drug',
              severity: a['severity']?.toString() ?? 'moderate',
              reactions: _str(a['reactions']),
              notes: _str(a['notes']),
            ))
        .where((a) => a.substance.isNotEmpty)
        .toList();
  }
}

class ExtractedMedication {
  final String name;
  final String reason;

  const ExtractedMedication({required this.name, this.reason = ''});

  String get display => reason.isNotEmpty ? '$name — $reason' : name;
}

class ExtractedDiagnosis {
  final String name;
  final String? icdCode;

  const ExtractedDiagnosis({required this.name, this.icdCode});

  String get display => icdCode != null && icdCode!.isNotEmpty
      ? '$name [$icdCode]'
      : name;
}

class ExtractedAllergy {
  final String substance;
  final String kind; // drug | food | material | other
  final String severity; // mild | moderate | severe
  final String? reactions;
  final String? notes;

  const ExtractedAllergy({
    required this.substance,
    this.kind = 'drug',
    this.severity = 'moderate',
    this.reactions,
    this.notes,
  });

  String get display {
    final sev = severity[0].toUpperCase() + severity.substring(1);
    final base = '$substance ($sev)';
    return reactions != null && reactions!.isNotEmpty ? '$base — $reactions' : base;
  }
}

/// A designated person extracted from a document (agent, alternate agent, or
/// guardian nominee). Address is split into components matching the app's form
/// (line 1 / city / state / ZIP), so autofill populates each field correctly.
class ExtractedPerson {
  final String? name;
  final String? relationship;
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? state;
  final String? zip;
  final String? phone;

  const ExtractedPerson({
    this.name,
    this.relationship,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.state,
    this.zip,
    this.phone,
  });

  bool get isEmpty =>
      (name == null || name!.isEmpty) &&
      (relationship == null || relationship!.isEmpty) &&
      (addressLine1 == null || addressLine1!.isEmpty) &&
      (city == null || city!.isEmpty) &&
      (phone == null || phone!.isEmpty);

  ExtractedPerson merge(ExtractedPerson? o) {
    if (o == null) return this;
    return ExtractedPerson(
      name: DocumentExtractionResult._mergeText(name, o.name),
      relationship:
          DocumentExtractionResult._mergeText(relationship, o.relationship),
      addressLine1:
          DocumentExtractionResult._mergeText(addressLine1, o.addressLine1),
      addressLine2:
          DocumentExtractionResult._mergeText(addressLine2, o.addressLine2),
      city: DocumentExtractionResult._mergeText(city, o.city),
      state: DocumentExtractionResult._mergeText(state, o.state),
      zip: DocumentExtractionResult._mergeText(zip, o.zip),
      phone: DocumentExtractionResult._mergeText(phone, o.phone),
    );
  }

  /// Parse a person object, or return null when the object is absent/empty so
  /// downstream code can skip it cleanly.
  static ExtractedPerson? maybe(dynamic v) {
    if (v is! Map<String, dynamic>) return null;
    final p = ExtractedPerson(
      name: DocumentExtractionResult._str(v['name']),
      relationship: DocumentExtractionResult._str(v['relationship']),
      addressLine1: DocumentExtractionResult._str(v['address_line1']),
      addressLine2: DocumentExtractionResult._str(v['address_line2']),
      city: DocumentExtractionResult._str(v['city']),
      state: DocumentExtractionResult._str(v['state']),
      zip: DocumentExtractionResult._str(v['zip']),
      phone: DocumentExtractionResult._str(v['phone']),
    );
    return p.isEmpty ? null : p;
  }
}

/// PII extracted for autofill: the declarant's own details plus the people
/// they designate. Witnesses are intentionally absent — they're captured on
/// paper at signing, not stored/edited in-app.
/// Address is split into components (line1 / line2 / city / county / state / ZIP)
/// so each form field is populated correctly rather than the whole address
/// landing in a single text box.
class ExtractedPersonalInfo {
  final String? fullName;
  final String? dateOfBirth;
  // Declarant address — split to match the Personal Info step's five fields.
  final String? addressLine1;
  final String? addressLine2;
  final String? city;
  final String? county; // PA-specific official field
  final String? state;
  final String? zip;
  final String? phone;
  // Primary care doctor (Diagnoses step, step 6).
  final String? primaryDoctorName;
  final String? primaryDoctorPhone;
  // Preferred evaluating doctor (When it Kicks In step, step 2) — the doctor
  // the person wants to certify their capacity. Distinct from primary doctor.
  final String? preferredEvaluatingDoctorName;
  final String? preferredEvaluatingDoctorContact;
  final ExtractedPerson? agent;
  final ExtractedPerson? alternateAgent;
  final ExtractedPerson? guardian;

  const ExtractedPersonalInfo({
    this.fullName,
    this.dateOfBirth,
    this.addressLine1,
    this.addressLine2,
    this.city,
    this.county,
    this.state,
    this.zip,
    this.phone,
    this.primaryDoctorName,
    this.primaryDoctorPhone,
    this.preferredEvaluatingDoctorName,
    this.preferredEvaluatingDoctorContact,
    this.agent,
    this.alternateAgent,
    this.guardian,
  });

  bool get isEmpty =>
      (fullName == null || fullName!.isEmpty) &&
      (dateOfBirth == null || dateOfBirth!.isEmpty) &&
      (addressLine1 == null || addressLine1!.isEmpty) &&
      (city == null || city!.isEmpty) &&
      (phone == null || phone!.isEmpty) &&
      (primaryDoctorName == null || primaryDoctorName!.isEmpty) &&
      (preferredEvaluatingDoctorName == null ||
          preferredEvaluatingDoctorName!.isEmpty) &&
      (agent == null || agent!.isEmpty) &&
      (alternateAgent == null || alternateAgent!.isEmpty) &&
      (guardian == null || guardian!.isEmpty);

  ExtractedPersonalInfo merge(ExtractedPersonalInfo o) {
    return ExtractedPersonalInfo(
      fullName: DocumentExtractionResult._mergeText(fullName, o.fullName),
      dateOfBirth:
          DocumentExtractionResult._mergeText(dateOfBirth, o.dateOfBirth),
      addressLine1:
          DocumentExtractionResult._mergeText(addressLine1, o.addressLine1),
      addressLine2:
          DocumentExtractionResult._mergeText(addressLine2, o.addressLine2),
      city: DocumentExtractionResult._mergeText(city, o.city),
      county: DocumentExtractionResult._mergeText(county, o.county),
      state: DocumentExtractionResult._mergeText(state, o.state),
      zip: DocumentExtractionResult._mergeText(zip, o.zip),
      phone: DocumentExtractionResult._mergeText(phone, o.phone),
      primaryDoctorName: DocumentExtractionResult._mergeText(
          primaryDoctorName, o.primaryDoctorName),
      primaryDoctorPhone: DocumentExtractionResult._mergeText(
          primaryDoctorPhone, o.primaryDoctorPhone),
      preferredEvaluatingDoctorName: DocumentExtractionResult._mergeText(
          preferredEvaluatingDoctorName, o.preferredEvaluatingDoctorName),
      preferredEvaluatingDoctorContact: DocumentExtractionResult._mergeText(
          preferredEvaluatingDoctorContact, o.preferredEvaluatingDoctorContact),
      agent: (agent ?? const ExtractedPerson()).merge(o.agent).isEmpty
          ? null
          : (agent ?? const ExtractedPerson()).merge(o.agent),
      alternateAgent:
          (alternateAgent ?? const ExtractedPerson()).merge(o.alternateAgent).isEmpty
              ? null
              : (alternateAgent ?? const ExtractedPerson())
                  .merge(o.alternateAgent),
      guardian: (guardian ?? const ExtractedPerson()).merge(o.guardian).isEmpty
          ? null
          : (guardian ?? const ExtractedPerson()).merge(o.guardian),
    );
  }

  factory ExtractedPersonalInfo.fromJson(Map<String, dynamic> j) {
    return ExtractedPersonalInfo(
      fullName: DocumentExtractionResult._str(j['full_name']),
      dateOfBirth: DocumentExtractionResult._str(j['date_of_birth']),
      addressLine1: DocumentExtractionResult._str(j['address_line1']),
      addressLine2: DocumentExtractionResult._str(j['address_line2']),
      city: DocumentExtractionResult._str(j['city']),
      county: DocumentExtractionResult._str(j['county']),
      state: DocumentExtractionResult._str(j['state']),
      zip: DocumentExtractionResult._str(j['zip']),
      phone: DocumentExtractionResult._str(j['phone']),
      primaryDoctorName:
          DocumentExtractionResult._str(j['primary_doctor_name']),
      primaryDoctorPhone:
          DocumentExtractionResult._str(j['primary_doctor_phone']),
      preferredEvaluatingDoctorName:
          DocumentExtractionResult._str(j['preferred_evaluating_doctor_name']),
      preferredEvaluatingDoctorContact: DocumentExtractionResult._str(
          j['preferred_evaluating_doctor_contact']),
      agent: ExtractedPerson.maybe(j['agent']),
      alternateAgent: ExtractedPerson.maybe(j['alternate_agent']),
      guardian: ExtractedPerson.maybe(j['guardian']),
    );
  }
}
