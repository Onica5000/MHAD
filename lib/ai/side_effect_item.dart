/// One row of the "Are you experiencing these side effects?" checklist.
///
/// The AI lists common, well-documented side effects of a medication the user
/// is CURRENTLY taking (informational only — per the clinical policy it never
/// recommends or changes meds). The user verifies whether they experience each
/// one and the note about how it may affect daily activities (ADLs).
class SideEffectItem {
  /// The medication (as the user entered it) this side effect relates to.
  final String med;

  /// The common side effect / symptom, in plain language.
  final String effect;

  /// How it may affect day-to-day activities (driving, work, caring for
  /// others, sleep, etc.). May be empty.
  final String adlImpact;

  /// Whether this is potentially serious and worth raising with a doctor
  /// promptly (the AI flags these; it never says how to treat them).
  final bool serious;

  /// User-verified: are they actually experiencing this? Mutable so the
  /// checklist UI can toggle it.
  bool experiencing;

  SideEffectItem({
    required this.med,
    required this.effect,
    this.adlImpact = '',
    this.serious = false,
    this.experiencing = false,
  });

  Map<String, dynamic> toJson() => {
        'med': med,
        'effect': effect,
        'adl': adlImpact,
        'serious': serious,
        'experiencing': experiencing,
      };

  factory SideEffectItem.fromJson(Map<String, dynamic> m) => SideEffectItem(
        med: (m['med'] ?? '').toString(),
        effect: (m['effect'] ?? '').toString(),
        adlImpact: (m['adl'] ?? '').toString(),
        serious: m['serious'] == true,
        experiencing: m['experiencing'] == true,
      );
}
