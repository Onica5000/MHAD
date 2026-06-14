/// Abstract AI assistant interface and shared data models.
library;

enum MessageRole { user, assistant }

/// A web source returned by Gemini's Google-Search grounding ("Verify on the
/// web"). Shown under a grounded reply so the user can check the source.
class GroundingSource {
  final String title;
  final String uri;
  const GroundingSource({required this.title, required this.uri});
}

class ChatMessage {
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  /// True when this reply was produced with web-search grounding (shows a
  /// "Verified with web search" badge + the [sources] below it).
  final bool grounded;

  /// Web sources backing a grounded reply (empty/null otherwise).
  final List<GroundingSource>? sources;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
    this.grounded = false,
    this.sources,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Optional context injected when the assistant is opened from a wizard step.
class AssistantContext {
  /// 'combined', 'declaration', or 'poa'
  final String? formType;

  /// Human-readable name of the wizard step (e.g., 'Medications').
  final String? stepName;

  /// Key–value pairs of fields already filled in for this directive.
  /// Keys are human-readable labels (e.g., 'Full Name', 'City').
  final Map<String, String>? filledFields;

  /// If true, the AI provides facilitator-oriented guidance (for a helper
  /// assisting the user, not the user themselves).
  final bool facilitatorMode;

  const AssistantContext({
    this.formType,
    this.stepName,
    this.filledFields,
    this.facilitatorMode = false,
  });
}

/// Abstract assistant interface — implementations can be swapped without
/// changing the UI layer.
abstract class AiAssistant {
  Future<String> sendMessage(
    String userMessage, {
    required List<ChatMessage> history,
    AssistantContext? context,
  });
}
