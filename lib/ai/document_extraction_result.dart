/// Structured data extracted from a user-provided document (photo, PDF, text)
/// by the AI. Each field is nullable — only fields the AI could confidently
/// extract are populated.
class DocumentExtractionResult {
  // ── Medications ──────────────────────────────────────────────────────────
  final List<ExtractedMedication> medicationsToAvoid;
  final List<ExtractedMedication> medicationsPreferred;

  // ── Treatment facility ───────────────────────────────────────────────────
  final String? preferredFacility;
  final String? avoidFacility;

  // ── Conditions / effective condition ─────────────────────────────────────
  final String? effectiveCondition;

  // ── Additional instructions ─────────────────────────────────────────────
  final String? healthHistory;
  final String? dietary;
  final String? religious;
  final String? activities;
  final String? crisisIntervention;
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
    this.preferredFacility,
    this.avoidFacility,
    this.effectiveCondition,
    this.healthHistory,
    this.dietary,
    this.religious,
    this.activities,
    this.crisisIntervention,
    this.other,
    this.personalInfo = const ExtractedPersonalInfo(),
  });

  bool get isEmpty =>
      medicationsToAvoid.isEmpty &&
      medicationsPreferred.isEmpty &&
      preferredFacility == null &&
      avoidFacility == null &&
      effectiveCondition == null &&
      healthHistory == null &&
      dietary == null &&
      religious == null &&
      activities == null &&
      crisisIntervention == null &&
      other == null &&
      personalInfo.isEmpty;

  /// Merge another extraction result into this one (for multi-page documents).
  /// Medications are deduplicated by name. Text fields are concatenated.
  DocumentExtractionResult merge(DocumentExtractionResult other) {
    return DocumentExtractionResult(
      medicationsToAvoid: _mergeMeds(medicationsToAvoid, other.medicationsToAvoid),
      medicationsPreferred: _mergeMeds(medicationsPreferred, other.medicationsPreferred),
      preferredFacility: _mergeText(preferredFacility, other.preferredFacility),
      avoidFacility: _mergeText(avoidFacility, other.avoidFacility),
      effectiveCondition: _mergeText(effectiveCondition, other.effectiveCondition),
      healthHistory: _mergeText(healthHistory, other.healthHistory),
      dietary: _mergeText(dietary, other.dietary),
      religious: _mergeText(religious, other.religious),
      activities: _mergeText(activities, other.activities),
      crisisIntervention: _mergeText(crisisIntervention, other.crisisIntervention),
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
    if (other != null) map['Other Instructions'] = other!;
    return map;
  }

  factory DocumentExtractionResult.fromJson(Map<String, dynamic> json) {
    return DocumentExtractionResult(
      medicationsToAvoid: _parseMeds(json['medications_to_avoid']),
      medicationsPreferred: _parseMeds(json['medications_preferred']),
      preferredFacility: _str(json['preferred_facility']),
      avoidFacility: _str(json['avoid_facility']),
      effectiveCondition: _str(json['effective_condition']),
      healthHistory: _str(json['health_history']),
      dietary: _str(json['dietary']),
      religious: _str(json['religious']),
      activities: _str(json['activities']),
      crisisIntervention: _str(json['crisis_intervention']),
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
}

class ExtractedMedication {
  final String name;
  final String reason;

  const ExtractedMedication({required this.name, this.reason = ''});

  String get display => reason.isNotEmpty ? '$name — $reason' : name;
}

/// A designated person extracted from a document (agent, alternate agent, or
/// guardian nominee). Address is kept as a single line (street, city, state,
/// ZIP as written) — it lands in the form's address line 1, which the user can
/// split if they wish.
class ExtractedPerson {
  final String? name;
  final String? relationship;
  final String? address;
  final String? phone;

  const ExtractedPerson({this.name, this.relationship, this.address, this.phone});

  bool get isEmpty =>
      (name == null || name!.isEmpty) &&
      (relationship == null || relationship!.isEmpty) &&
      (address == null || address!.isEmpty) &&
      (phone == null || phone!.isEmpty);

  ExtractedPerson merge(ExtractedPerson? o) {
    if (o == null) return this;
    return ExtractedPerson(
      name: DocumentExtractionResult._mergeText(name, o.name),
      relationship:
          DocumentExtractionResult._mergeText(relationship, o.relationship),
      address: DocumentExtractionResult._mergeText(address, o.address),
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
      address: DocumentExtractionResult._str(v['address']),
      phone: DocumentExtractionResult._str(v['phone']),
    );
    return p.isEmpty ? null : p;
  }
}

/// PII extracted for autofill: the declarant's own details plus the people
/// they designate. Witnesses are intentionally absent — they're captured on
/// paper at signing, not stored/edited in-app.
class ExtractedPersonalInfo {
  final String? fullName;
  final String? dateOfBirth;
  final String? address;
  final String? phone;
  final String? primaryDoctorName;
  final String? primaryDoctorPhone;
  final ExtractedPerson? agent;
  final ExtractedPerson? alternateAgent;
  final ExtractedPerson? guardian;

  const ExtractedPersonalInfo({
    this.fullName,
    this.dateOfBirth,
    this.address,
    this.phone,
    this.primaryDoctorName,
    this.primaryDoctorPhone,
    this.agent,
    this.alternateAgent,
    this.guardian,
  });

  bool get isEmpty =>
      (fullName == null || fullName!.isEmpty) &&
      (dateOfBirth == null || dateOfBirth!.isEmpty) &&
      (address == null || address!.isEmpty) &&
      (phone == null || phone!.isEmpty) &&
      (primaryDoctorName == null || primaryDoctorName!.isEmpty) &&
      (primaryDoctorPhone == null || primaryDoctorPhone!.isEmpty) &&
      (agent == null || agent!.isEmpty) &&
      (alternateAgent == null || alternateAgent!.isEmpty) &&
      (guardian == null || guardian!.isEmpty);

  ExtractedPersonalInfo merge(ExtractedPersonalInfo o) {
    return ExtractedPersonalInfo(
      fullName: DocumentExtractionResult._mergeText(fullName, o.fullName),
      dateOfBirth:
          DocumentExtractionResult._mergeText(dateOfBirth, o.dateOfBirth),
      address: DocumentExtractionResult._mergeText(address, o.address),
      phone: DocumentExtractionResult._mergeText(phone, o.phone),
      primaryDoctorName: DocumentExtractionResult._mergeText(
          primaryDoctorName, o.primaryDoctorName),
      primaryDoctorPhone: DocumentExtractionResult._mergeText(
          primaryDoctorPhone, o.primaryDoctorPhone),
      agent: (agent ?? const ExtractedPerson()).merge(o.agent).isEmpty
          ? null
          : (agent ?? const ExtractedPerson()).merge(o.agent),
      alternateAgent:
          (alternateAgent ?? const ExtractedPerson()).merge(o.alternateAgent).isEmpty
              ? null
              : (alternateAgent ?? const ExtractedPerson()).merge(o.alternateAgent),
      guardian: (guardian ?? const ExtractedPerson()).merge(o.guardian).isEmpty
          ? null
          : (guardian ?? const ExtractedPerson()).merge(o.guardian),
    );
  }

  factory ExtractedPersonalInfo.fromJson(Map<String, dynamic> j) {
    return ExtractedPersonalInfo(
      fullName: DocumentExtractionResult._str(j['full_name']),
      dateOfBirth: DocumentExtractionResult._str(j['date_of_birth']),
      address: DocumentExtractionResult._str(j['address']),
      phone: DocumentExtractionResult._str(j['phone']),
      primaryDoctorName:
          DocumentExtractionResult._str(j['primary_doctor_name']),
      primaryDoctorPhone:
          DocumentExtractionResult._str(j['primary_doctor_phone']),
      agent: ExtractedPerson.maybe(j['agent']),
      alternateAgent: ExtractedPerson.maybe(j['alternate_agent']),
      guardian: ExtractedPerson.maybe(j['guardian']),
    );
  }
}
