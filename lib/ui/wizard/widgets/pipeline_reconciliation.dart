/// Reconciliation model for the document pipeline (snap-to-fill / upload).
///
/// The extractor produces candidate values; this layer classifies each by
/// PRIORITY (high = the user must review; low = autofill silently) and KIND
/// (scalar = overwrites one field, so it can CONFLICT with an existing value;
/// listAdd = appended/deduped, so no conflict), and computes conflicts against
/// the directive's current values. Pure + testable — no Flutter, no DB.
library;

enum ReconPriority { high, low }

/// scalar = single-field overwrite candidate (conflict possible);
/// listAdd  = appended to a list (deduped on apply) — never a conflict.
enum ReconKind { scalar, listAdd }

/// One reconcilable candidate field awaiting (or auto-granted) a decision.
class ReconItem {
  final String key;
  final String label;
  final ReconPriority priority;
  final ReconKind kind;

  /// The extracted/imported display value.
  final String extracted;

  /// The directive's current value at this field (scalar fields only); null or
  /// empty when the field isn't set yet.
  final String? existing;

  /// User decision to apply this item. Defaults: low-priority pre-selected
  /// (autofilled silently); high-priority conflicts start UNSELECTED so the
  /// user makes a deliberate choice; high-priority non-conflicts pre-selected.
  bool selected;

  ReconItem({
    required this.key,
    required this.label,
    required this.priority,
    required this.kind,
    required this.extracted,
    required this.existing,
    required this.selected,
  });

  /// A real conflict: a scalar field that already has a (different) value.
  bool get isConflict =>
      kind == ReconKind.scalar &&
      (existing != null && existing!.trim().isNotEmpty) &&
      existing!.trim() != extracted.trim();

  /// The suggested default when conflicting: prefer the more-complete value
  /// (longer, non-empty) — usually the freshly extracted one. The user can
  /// always override. Returns the value the UI should pre-highlight.
  String get suggestedValue {
    if (!isConflict) return extracted;
    final e = extracted.trim();
    final x = existing!.trim();
    return e.length >= x.length ? e : x;
  }
}

/// Field classification keyed by the pipeline's review keys (see
/// `_buildReviewData`). Med/condition keys are prefixes.
ReconPriority reconPriority(String key) {
  if (key.startsWith('med_') ||
      key.startsWith('cond_') ||
      key == 'hh_note' ||
      key == 'facility_prefer' ||
      key == 'facility_avoid' ||
      key == 'crisis') {
    return ReconPriority.high;
  }
  // dietary / religious / activities / other → low (autofill silently).
  return ReconPriority.low;
}

ReconKind reconKind(String key) {
  // Meds and conditions are appended/deduped, never overwrite a single field.
  if (key.startsWith('med_') || key.startsWith('cond_')) {
    return ReconKind.listAdd;
  }
  return ReconKind.scalar;
}

String reconLabel(String key) {
  if (key.startsWith('med_prefer_')) return 'Preferred medication';
  if (key.startsWith('med_avoid_')) return 'Medication to avoid';
  if (key.startsWith('cond_')) return 'Condition';
  switch (key) {
    case 'hh_note':
      return 'Health history';
    case 'facility_prefer':
      return 'Preferred facility';
    case 'facility_avoid':
      return 'Facility to avoid';
    case 'crisis':
      return 'Crisis / de-escalation';
    case 'dietary':
      return 'Dietary';
    case 'religious':
      return 'Religious';
    case 'activities':
      return 'Activities';
    case 'other':
      return 'Other notes';
    default:
      return key;
  }
}

/// Build reconciliation items from the extracted display map (key → value) and
/// the directive's current scalar values (key → value; omit list-add keys).
/// Pure: drives both the grouped UI and the apply step.
List<ReconItem> buildReconItems({
  required Map<String, String> extracted,
  required Map<String, String> existing,
}) {
  final items = <ReconItem>[];
  for (final entry in extracted.entries) {
    final key = entry.key;
    final priority = reconPriority(key);
    final kind = reconKind(key);
    final current = existing[key];
    final conflict = kind == ReconKind.scalar &&
        current != null &&
        current.trim().isNotEmpty &&
        current.trim() != entry.value.trim();
    items.add(ReconItem(
      key: key,
      label: reconLabel(key),
      priority: priority,
      kind: kind,
      extracted: entry.value,
      existing: current,
      // Low-priority and non-conflicting high-priority items are pre-selected;
      // a conflict must be resolved deliberately, so it starts unselected.
      selected: !conflict,
    ));
  }
  return items;
}

/// The three review buckets the UI renders.
class ReconGroups {
  /// Low-priority, applied silently ("we filled these in").
  final List<ReconItem> autoApplied;

  /// High-priority and/or conflicting — need a deliberate decision.
  final List<ReconItem> needsDecision;

  const ReconGroups({required this.autoApplied, required this.needsDecision});

  factory ReconGroups.from(List<ReconItem> items) {
    final auto = <ReconItem>[];
    final decide = <ReconItem>[];
    for (final i in items) {
      if (i.priority == ReconPriority.high || i.isConflict) {
        decide.add(i);
      } else {
        auto.add(i);
      }
    }
    return ReconGroups(autoApplied: auto, needsDecision: decide);
  }
}
