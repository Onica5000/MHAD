import 'package:mhad/ai/handoff/ai_handoff_data.dart';

/// The jobs MHAD can hand to a person's own AI chat by copy and paste. Each
/// one reuses the API path's instructions and parser (lib/ai), so the two
/// paths can never drift apart.
enum HandoffTaskKind {
  /// A question, with context (general, a wizard step, a Learn article).
  /// No answer comes back: the person reads it in their AI.
  ask,

  /// Read an attached document / photo / PDF / recording → form fields (JSON).
  autofill,

  /// Common side effects + possible interactions of current meds (JSON).
  sideEffects,

  /// "Don't know the official name?" → condition names to search (JSON).
  conditionTerms,

  /// Suggested wording for one text field; the person pastes it in.
  fieldWording,

  /// A second-opinion review before signing; read in the AI.
  review,

  /// Preference suggestions after an autofill (JSON).
  smartFill;

  /// The tag the reply must carry (`"mhad_task"`), so an answer meant for
  /// another task is recognised instead of misapplied.
  String get tag => 'mhad-$name';

  /// Whether the person pastes a JSON answer back into MHAD.
  bool get returnsJson => switch (this) {
        autofill || sideEffects || conditionTerms || smartFill => true,
        ask || fieldWording || review => false,
      };
}

/// What the person attaches in the AI before sending (never through MHAD).
enum HandoffAttachment {
  none,
  document,
  audio;

  /// The input kinds an AI service must accept for this attachment.
  List<HandoffInput> get inputs => switch (this) {
        none => const [],
        document => const [HandoffInput.image, HandoffInput.pdf],
        audio => const [HandoffInput.audio],
      };
}

/// One handoff: the task's own instructions plus what MHAD needs to recognise
/// the answer ([ref] — e.g. which directive it is for).
class HandoffTask {
  final HandoffTaskKind kind;

  /// The task instructions, shared with the API path.
  final String instructions;

  /// Identifies what the answer is for (e.g. `d12` = directive 12).
  final String ref;
  final HandoffAttachment attachment;

  /// The person's question (for [HandoffTaskKind.ask]).
  final String? question;

  const HandoffTask({
    required this.kind,
    required this.instructions,
    required this.ref,
    this.attachment = HandoffAttachment.none,
    this.question,
  });

  bool get returnsJson => kind.returnsJson;
}
