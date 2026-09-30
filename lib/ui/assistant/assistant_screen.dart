import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/l10n/model_labels.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ai/ai_provider.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/ui/assistant/assistant_context_panel.dart';
import 'package:mhad/ui/assistant/assistant_message_widgets.dart';
import 'package:mhad/ui/assistant/assistant_send.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';

class AssistantScreen extends ConsumerStatefulWidget {
  /// Optional context from the wizard step that opened the chat.
  final AssistantContext? context;

  const AssistantScreen({this.context, super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _piiStripped = false;
  Timer? _piiTimer;

  @override
  void dispose() {
    _piiTimer?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    _inputCtrl.clear();
    final result = await sendAssistantMessage(
      ref,
      l10n: context.l10n,
      text: text,
      assistantContext: widget.context,
      requestConsent: () =>
          showAiConsentDialog(context, provider: ref.read(activeProviderProvider)),
      onSent: _scrollToBottom,
    );
    if (!mounted) return;

    // No key / declined consent / rate-blocked / busy: restore the text so the
    // user doesn't lose it, and surface why nothing happened.
    if (result.needsKey) {
      _inputCtrl.text = text;
      _openSetup();
      return;
    }
    if (result.consentDeclined || result.alreadySending) {
      _inputCtrl.text = text;
      return;
    }
    if (result.blockReason != null) {
      _inputCtrl.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.blockReason!),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    // The request was issued but the model call failed (error bubble was
    // appended) — offer a one-tap retry instead of making the user retype
    // (2026-07-11 UX audit B3).
    if (result.sendFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.assistantTheReplyFailed),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(label: context.l10n.retry, onPressed: _retrySend),
        ),
      );
    }

    if (result.piiStripped) {
      _piiTimer?.cancel();
      setState(() => _piiStripped = true);
      _piiTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _piiStripped = false);
      });
    }
    if (result.trimmedCount > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.assistantOlderMessagesWereTrimmedTo(result.trimmedCount),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }
    _scrollToBottom();
  }

  /// Pops the failed turn pair and re-sends the same user message.
  Future<void> _retrySend() async {
    final result = await retryLastSend(
      ref,
      l10n: context.l10n,
      assistantContext: widget.context,
      requestConsent: () => showAiConsentDialog(context,
          provider: ref.read(activeProviderProvider)),
      onSent: _scrollToBottom,
    );
    if (!mounted) return;
    if (result.sendFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.assistantStillFailingCheckYourConnection),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(label: context.l10n.retry, onPressed: _retrySend),
        ),
      );
    }
    _scrollToBottom();
  }

  /// "Verify on the web" on a reply — re-answers [question] with Google-Search
  /// grounding and appends a grounded reply (with sources).
  Future<void> _verify(String question) async {
    final result = await verifyOnWeb(
      ref,
      l10n: context.l10n,
      question: question,
      assistantContext: widget.context,
      requestConsent: () =>
          showAiConsentDialog(context, provider: ref.read(activeProviderProvider)),
    );
    if (!mounted) return;
    if (result.needsKey) {
      _openSetup();
      return;
    }
    if (result.consentDeclined || result.alreadySending) return;
    if (result.blockReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.blockReason!),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
    _scrollToBottom();
  }

  void _openSetup() {
    context.push(AppRoutes.aiSetup);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(conversationProvider);
    final isSending = ref.watch(isSendingProvider);
    final apiKeyAsync = ref.watch(apiKeyProvider);
    final hasKey = apiKeyAsync.whenOrNull(
          data: (k) => k != null && k.isNotEmpty,
        ) ??
        false;

    return Scaffold(
      appBar: AppBar(
        // Editorial header chrome — matches prototype `ScrAI`
        // (mobile-extra.jsx::ScrAI L753-767): 36pt rounded sparkle chip
        // in primaryTint + 14.5pt bold title + monospace status pill that
        // includes the "ON" word the previous version was missing.
        titleSpacing: 12,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Theme.of(context).mhadPalette.primaryTint,
                borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.auto_awesome_outlined,
                size: 18,
                color: Theme.of(context).mhadPalette.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n.navAiAssistant,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: Theme.of(context).mhadPalette.text,
                    ),
                  ),
                  Text(
                    hasKey
                        ? context.l10n.assistantActiveTextPiiStrippedBefore(ref.watch(activeModelProvider).toUpperCase().replaceAll('-', ' '))
                        : context.l10n.assistantNotSetUpAddA,
                    style: TextStyle(
                      fontFamily: kMonoFamily,
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 11,
                      letterSpacing: 0.5,
                      color: Theme.of(context).mhadPalette.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: context.l10n.assistantClearConversation2,
            onPressed: messages.isEmpty
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(context.l10n.assistantClearConversation),
                        content: Text(
                            context.l10n.assistantThisWillEraseAllMessages),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(context.l10n.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(context.l10n.assistantClear),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      ref.read(conversationProvider.notifier).clear();
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.key_outlined),
            tooltip: context.l10n.assistantApiKeySettings,
            onPressed: _openSetup,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Builder(
              builder: (context) {
                final chatColumn = _buildChatColumn(
                  context,
                  messages: messages,
                  isSending: isSending,
                  hasKey: hasKey,
                  apiKeyAsync: apiKeyAsync,
                );
                // Desktop wide layout: keep the chat column on the left and
                // add a purely-presentational context panel on the right.
                // Gate on the TOTAL window width (the desktop-shell signal),
                // not this screen's post-sidebar content width — otherwise the
                // 1000–1231px band shows the sidebar but the mobile chat-only
                // layout (the WebSidebar already consumes 232px).
                if (MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: chatColumn),
                      AssistantContextPanel(
                        context: widget.context,
                        contextLabel: widget.context != null
                            ? _contextLabel(widget.context!)
                            : null,
                        onPromptTap: (prompt) {
                          _inputCtrl.text = prompt;
                          _send();
                        },
                      ),
                    ],
                  );
                }
                return chatColumn;
              },
            ),
          ),
        ],
      ),
    );
  }

  /// The existing chat column (consent banner, rate bar, context chip,
  /// messages, input). Extracted verbatim so the wide layout can place it
  /// beside a context panel without changing any send/history logic.
  Widget _buildChatColumn(
    BuildContext context, {
    required List<ChatMessage> messages,
    required bool isSending,
    required bool hasKey,
    required AsyncValue<String?> apiKeyAsync,
  }) {
    return Column(
        children: [
          // First-time consent banner — matches prototype ScrAI L770-784:
          // warning-yellow bg with shield icon. Previously used the red
          // errorContainer styling, which read as alarming for a soft
          // disclosure that's already on every AI response. The shield +
          // warn palette matches the rest of the editorial design system.
          Builder(
            builder: (ctx) {
              final dark = Theme.of(ctx).brightness == Brightness.dark;
              final bg = dark
                  ? SemanticColors.warningBgDark
                  : SemanticColors.warningBgLight;
              final border = dark
                  ? SemanticColors.warningBorderDark
                  : SemanticColors.warningBorderLight;
              final fg = dark
                  ? SemanticColors.warningTextDark
                  : SemanticColors.warningTextLight;
              return Semantics(
                label:
                    context.l10n.assistantDisclaimerNotLegalOrMedical(
                        appData.phoneOf('paProtectionAdvocacy')),
                container: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: bg,
                    border:
                        Border(bottom: BorderSide(color: border)),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      ExcludeSemantics(
                        child: Icon(Icons.shield_outlined, size: 14, color: fg),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.l10n.assistantNotLegalOrMedicalAdvice(appData.phoneOf('paProtectionAdvocacy')),
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Rate limit status bar
          _RateLimitBar(),

          // Context chip (if opened from a wizard step)
          if (widget.context != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.edit_note, size: 16),
                  label: Text(
                    _contextLabel(widget.context!),
                    style: const TextStyle(fontSize: 11),
                  ),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),

          // No API key notice
          if (!hasKey && !apiKeyAsync.isLoading)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      const Icon(Icons.smart_toy_outlined, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.assistantToUseTheAiAssistant,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: _openSetup,
                        child: Text(context.l10n.assistantSetUpFree),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Messages list
          Expanded(
            child: messages.isEmpty
                ? _EmptyState(onPromptTap: (prompt) {
                    _inputCtrl.text = prompt;
                    _send();
                  })
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.all(12),
                    itemCount: messages.length + (isSending ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == messages.length) {
                        return const TypingIndicator();
                      }
                      final m = messages[i];
                      // Offer "Verify on the web" on a plain AI reply (not an
                      // error, not already grounded), re-verifying the user
                      // question that prompted it.
                      String? priorQuestion;
                      if (m.role == MessageRole.assistant &&
                          !m.grounded &&
                          !m.content.startsWith('Sorry,')) {
                        for (var j = i - 1; j >= 0; j--) {
                          if (messages[j].role == MessageRole.user) {
                            priorQuestion = messages[j].content;
                            break;
                          }
                        }
                      }
                      return MessageBubble(
                        message: m,
                        onVerify: priorQuestion == null
                            ? null
                            : () => _verify(priorQuestion!),
                      );
                    },
                  ),
          ),

          // PII stripping indicator
          if (_piiStripped)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Chip(
                  avatar: const Icon(Icons.shield_outlined, size: 14),
                  label: Text(context.l10n.assistantPersonalInfoRemoved,
                      style: TextStyle(fontSize: 11)),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),

          // Input row
          _InputBar(
            controller: _inputCtrl,
            isSending: isSending,
            onSend: _send,
          ),
        ],
      );
  }

  String _contextLabel(AssistantContext ctx) {
    final parts = <String>[];
    final ft = formTypeFromName(ctx.formType);
    if (ft != null) parts.add(ft.shortLabel(context.l10n));
    if (ctx.stepName != null) parts.add(ctx.stepName!);
    return parts.isEmpty ? context.l10n.assistantGeneralQuestion : parts.join(' › ');
  }
}

// ---------------------------------------------------------------------------

class _RateLimitBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The free-tier rate tracker is Gemini-specific; for other providers the
    // user's own account/plan governs limits, so don't show meaningless numbers.
    if (ref.watch(activeProviderProvider) != AiProvider.gemini) {
      return const SizedBox.shrink();
    }
    final tracker = ref.watch(geminiRateTrackerProvider);
    if (!tracker.showStatus) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final isWarning = tracker.showWarning;
    final isDailyLimit = tracker.dailyLimitReached;

    final fg = isDailyLimit
        ? cs.onErrorContainer
        : isWarning
            ? cs.onTertiaryContainer
            : cs.onSurfaceVariant;

    return Material(
      color: isDailyLimit
          ? cs.errorContainer
          : isWarning
              ? cs.tertiaryContainer
              : cs.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Row(
          children: [
            Icon(
              isDailyLimit
                  ? Icons.block
                  : isWarning
                      ? Icons.warning_amber
                      : Icons.speed,
              size: 14,
              color: fg,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                tracker.statusTextFor(context.l10n),
                style: TextStyle(fontSize: 11, color: fg),
              ),
            ),
            Tooltip(
              message: context.l10n.assistantFreeTierRequestsMinRequests(appData.ai.model, GeminiRateTracker.maxRpm, GeminiRateTracker.maxRpd, (GeminiRateTracker.maxTpm / 1000).round(), (GeminiApiAssistant.maxContextTokens / 1000).round()),
              child: Icon(Icons.info_outline, size: 14, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isSending,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: context.l10n.assistantAskAQuestionAboutYour,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  ),
                  // vertical 14 (was 10) brings the single-line height to
                  // ~52 — comfortably over the 48px a11y guideline.
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  isDense: true,
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: isSending ? null : onSend,
              icon: isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: Semantics(
                        label: context.l10n.reviewStepLoading,
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              tooltip: context.l10n.assistantSend,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onPromptTap;
  const _EmptyState({required this.onPromptTap});

  static List<String> _suggestions(BuildContext context) => [
    context.l10n.assistantSuggestWalkMeThroughFillingOut,
    context.l10n.assistantSuggestWhatIsAMentalHealth,
    context.l10n.assistantSuggestWhatSTheDifferenceBetween,
    context.l10n.assistantSuggestWhoCanBeMyAgent,
    context.l10n.assistantSuggestWhatMedicationsShouldIList,
    context.l10n.assistantSuggestWhatDoesEctMean,
    context.l10n.assistantSuggestHowLongIsTheDirective,
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 16),
        Icon(
          Icons.smart_toy_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          context.l10n.assistantAskMeAnythingAboutYour,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 24),
        Text(
          context.l10n.assistantSuggestedQuestions,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ..._suggestions(context).map((s) => _SuggestionChip(
              text: s,
              onTap: () => onPromptTap(s),
            )),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _SuggestionChip({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        label: text,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(text, style: const TextStyle(fontSize: 13)),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
