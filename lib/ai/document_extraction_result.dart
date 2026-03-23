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
      other == null;

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
