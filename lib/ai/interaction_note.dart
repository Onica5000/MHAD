/// One plain-language "ask your doctor or pharmacist about this" note covering
/// a possible interaction between two or more of the user's CURRENT medications.
///
/// Informational only. Per the clinical policy the AI never tells the user to
/// start, stop, change, or combine medications — each note only flags something
/// worth raising with their care team, grounded in the FDA label's official
/// "Drug Interactions" text (via openFDA) so it is not a model guess.
class InteractionNote {
  /// The medications (as the user entered them) this note involves.
  final List<String> meds;

  /// The possible interaction, in plain language, framed as something to ask
  /// about — never as a recommendation to act.
  final String note;

  const InteractionNote({required this.meds, required this.note});

  Map<String, dynamic> toJson() => {'meds': meds, 'note': note};

  factory InteractionNote.fromJson(Map<String, dynamic> m) => InteractionNote(
        meds: ((m['meds'] as List?) ?? const [])
            .map((e) => e.toString().trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        note: (m['note'] ?? '').toString().trim(),
      );
}
