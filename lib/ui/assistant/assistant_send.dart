import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';

/// Outcome of [sendAssistantMessage] — lets the caller drive its own UI
/// (snackbars, scroll, PII flash) without the send logic being coupled to any
/// one screen. The actual user/assistant turns are appended to
/// [conversationProvider] inside the helper.
class AssistantSendResult {
  /// A request was actually issued to the model (a reply or error turn was
  /// appended to the conversation).
  final bool sent;

  /// No API key is configured — the caller should route to AI setup.
  final bool needsKey;

  /// Consent was requested and declined (or the dialog was dismissed).
  final bool consentDeclined;

  /// A send was already in flight; this call was a no-op.
  final bool alreadySending;

  /// Non-null when a rate limit blocked the send (human-readable reason).
  final String? blockReason;

  /// True when PII was found and stripped from the message or history.
  final bool piiStripped;

  /// Number of old messages trimmed to fit the context window.
  final int trimmedCount;

  const AssistantSendResult({
    this.sent = false,
    this.needsKey = false,
    this.consentDeclined = false,
    this.alreadySending = false,
    this.blockReason,
    this.piiStripped = false,
    this.trimmedCount = 0,
  });
}

/// Shared "send a message to the assistant" pipeline used by both the full
/// assistant screen and the wizard's inline AI rail, so the two stay in sync:
/// consent gate → rate-limit check → PII strip (message + history) → token
/// trim → append user turn → call the model → append reply/error.
///
/// [requestConsent] is invoked (once per session) when consent hasn't yet been
/// granted; it should show the consent dialog and resolve true if accepted.
/// [onSent] fires right after the user's turn is appended (before the model
/// reply arrives) so the caller can scroll.
Future<AssistantSendResult> sendAssistantMessage(
  WidgetRef ref, {
  required String text,
  required Future<bool> Function() requestConsent,
  AssistantContext? assistantContext,
  VoidCallback? onSent,
}) async {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return const AssistantSendResult();

  final assistant = ref.read(aiAssistantProvider);
  if (assistant == null) return const AssistantSendResult(needsKey: true);

  // Per-session consent gate.
  if (!ref.read(aiConsentGivenProvider)) {
    final accepted = await requestConsent();
    if (!accepted) return const AssistantSendResult(consentDeclined: true);
    ref.read(aiConsentGivenProvider.notifier).state = true;
  }

  if (ref.read(isSendingProvider)) {
    return const AssistantSendResult(alreadySending: true);
  }

  // Rate-limit gate.
  final tracker = ref.read(geminiRateTrackerProvider);
  final blockReason = tracker.blockReason;
  if (blockReason != null) {
    return AssistantSendResult(blockReason: blockReason);
  }

  final history = ref.read(conversationProvider);

  // Strip PII from history before sending to the external API.
  var strippedHistory = history
      .map((m) => ChatMessage(role: m.role, content: PiiStripper.strip(m.content)))
      .toList();
  final strippedUserText = PiiStripper.strip(trimmed);
  final historyHadPii =
      history.any((m) => PiiStripper.strip(m.content) != m.content);
  final piiStripped = strippedUserText != trimmed || historyHadPii;

  // Estimate tokens and auto-trim oldest turns to fit (reserve 20% for the
  // reply). Mirrors the assistant screen's budgeting.
  final gemini = assistant as GeminiApiAssistant;
  // 80% of the ACTIVE provider's context window (reserve 20% for the reply).
  final maxInputTokens = (gemini.contextWindowTokens * 0.8).toInt();
  var tokens = gemini.estimateTokens(
    userMessage: trimmed,
    chatHistory: strippedHistory,
    context: assistantContext,
  );
  var trimmedCount = 0;
  while (tokens.total > maxInputTokens && strippedHistory.length > 2) {
    strippedHistory = strippedHistory.sublist(2);
    trimmedCount += 2;
    tokens = gemini.estimateTokens(
      userMessage: trimmed,
      chatHistory: strippedHistory,
      context: assistantContext,
    );
  }

  ref.read(conversationProvider.notifier).add(
        ChatMessage(role: MessageRole.user, content: trimmed),
      );
  ref.read(isSendingProvider.notifier).state = true;
  onSent?.call();

  try {
    final reply = await assistant.sendMessage(
      trimmed,
      history: strippedHistory,
      context: assistantContext,
    );
    tracker.recordRequest(estimatedTokens: tokens.total);
    ref.read(conversationProvider.notifier).add(
          ChatMessage(role: MessageRole.assistant, content: reply),
        );
  } catch (e) {
    debugPrint('AI assistant error: $e');
    ref.read(conversationProvider.notifier).add(
          ChatMessage(
            role: MessageRole.assistant,
            content: 'Sorry, I encountered an error: ${FriendlyError.from(e)}',
          ),
        );
  } finally {
    ref.read(isSendingProvider.notifier).state = false;
  }

  return AssistantSendResult(
    sent: true,
    piiStripped: piiStripped,
    trimmedCount: trimmedCount,
  );
}

/// "Verify on the web": re-answers [question] with Gemini's Google-Search
/// grounding and appends a grounded assistant turn (with web sources) to the
/// conversation. Same gates as [sendAssistantMessage] (key / consent / rate /
/// in-flight). Does NOT append a user turn — it re-verifies an existing one.
Future<AssistantSendResult> verifyOnWeb(
  WidgetRef ref, {
  required String question,
  required Future<bool> Function() requestConsent,
  AssistantContext? assistantContext,
}) async {
  final q = question.trim();
  if (q.isEmpty) return const AssistantSendResult();

  final assistant = ref.read(aiAssistantProvider);
  if (assistant is! GeminiApiAssistant) {
    return const AssistantSendResult(needsKey: true);
  }

  if (!ref.read(aiConsentGivenProvider)) {
    final accepted = await requestConsent();
    if (!accepted) return const AssistantSendResult(consentDeclined: true);
    ref.read(aiConsentGivenProvider.notifier).state = true;
  }

  if (ref.read(isSendingProvider)) {
    return const AssistantSendResult(alreadySending: true);
  }

  final tracker = ref.read(geminiRateTrackerProvider);
  final blockReason = tracker.blockReason;
  if (blockReason != null) {
    return AssistantSendResult(blockReason: blockReason);
  }

  final history = ref
      .read(conversationProvider)
      .map((m) => ChatMessage(role: m.role, content: PiiStripper.strip(m.content)))
      .toList();

  ref.read(isSendingProvider.notifier).state = true;
  try {
    final res = await assistant.sendGroundedQuery(
      q,
      history: history,
      context: assistantContext,
    );
    tracker.recordRequest(estimatedTokens: (q.length / 4).ceil() + 400);
    ref.read(conversationProvider.notifier).add(
          ChatMessage(
            role: MessageRole.assistant,
            content: res.text,
            grounded: true,
            sources: res.sources,
          ),
        );
  } catch (e) {
    debugPrint('verifyOnWeb error: $e');
    ref.read(conversationProvider.notifier).add(
          ChatMessage(
            role: MessageRole.assistant,
            content:
                'Sorry, I couldn\'t verify that on the web: ${FriendlyError.from(e)}',
          ),
        );
  } finally {
    ref.read(isSendingProvider.notifier).state = false;
  }

  return const AssistantSendResult(sent: true);
}
