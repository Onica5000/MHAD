/// Abstract AI assistant interface and shared data models.
library;

enum MessageRole { user, assistant }

class ChatMessage {
  final MessageRole role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    DateTime? timestamp,
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
