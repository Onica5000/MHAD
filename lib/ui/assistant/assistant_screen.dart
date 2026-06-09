import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/design/bottom_nav.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';

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

    final assistant = ref.read(aiAssistantProvider);
    if (assistant == null) {
      _openSetup();
      return;
    }

    // Per-session AI consent gate
    if (!ref.read(aiConsentGivenProvider)) {
      final accepted = await showAiConsentDialog(context);
      if (!accepted || !mounted) return;
      ref.read(aiConsentGivenProvider.notifier).state = true;
    }

    final history = ref.read(conversationProvider);
    final isSending = ref.read(isSendingProvider);
    if (isSending) return;

    // Check rate limits before sending
    final tracker = ref.read(geminiRateTrackerProvider);
    final blockReason = tracker.blockReason;
    if (blockReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(blockReason),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    // Strip PII from conversation history before sending to external API
    var strippedHistory = history
        .map((m) => ChatMessage(
              role: m.role,
              content: PiiStripper.strip(m.content),
            ))
        .toList();

    // Check if PII was found in the user's message or history
    final strippedUserText = PiiStripper.strip(text);
    final historyHadPii = history.any(
        (m) => PiiStripper.strip(m.content) != m.content);
    if (strippedUserText != text || historyHadPii) {
      _piiTimer?.cancel();
      setState(() => _piiStripped = true);
      _piiTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _piiStripped = false);
      });
    }

    // Estimate tokens and auto-trim history to fit within budget.
    // Reserve 80% of context for input (system + history + message),
    // leaving 20% headroom for the AI's response.
    final gemini = assistant as GeminiApiAssistant;
    // Reserve 80% of context for input, leave 20% for AI response
    final maxInputTokens = (GeminiApiAssistant.maxContextTokens * 0.8).toInt();
    var tokens = gemini.estimateTokens(
      userMessage: text,
      chatHistory: strippedHistory,
      context: widget.context,
    );

    // Auto-trim oldest messages if over budget
    int trimmedCount = 0;
    while (tokens.total > maxInputTokens && strippedHistory.length > 2) {
      // Remove the two oldest messages (user + assistant pair)
      strippedHistory = strippedHistory.sublist(2);
      trimmedCount += 2;
      tokens = gemini.estimateTokens(
        userMessage: text,
        chatHistory: strippedHistory,
        context: widget.context,
      );
    }

    _inputCtrl.clear();
    ref.read(conversationProvider.notifier).add(
          ChatMessage(role: MessageRole.user, content: text),
        );
    ref.read(isSendingProvider.notifier).state = true;
    _scrollToBottom();

    // Notify user if messages were trimmed
    if (trimmedCount > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$trimmedCount older messages were trimmed to fit within '
            'the AI\'s context limit. Recent messages are preserved.',
          ),
          duration: const Duration(seconds: 4),
        ),
      );
    }

    try {
      final reply = await assistant.sendMessage(
        text,
        history: strippedHistory,
        context: widget.context,
      );

      // Record successful request with actual token estimate
      tracker.recordRequest(estimatedTokens: tokens.total);

      ref.read(conversationProvider.notifier).add(
            ChatMessage(role: MessageRole.assistant, content: reply),
          );
    } catch (e) {
      debugPrint('AI assistant error: $e');
      ref.read(conversationProvider.notifier).add(
            ChatMessage(
              role: MessageRole.assistant,
              content:
                  'Sorry, I encountered an error: ${FriendlyError.from(e)}',
            ),
          );
    } finally {
      ref.read(isSendingProvider.notifier).state = false;
      _scrollToBottom();
    }
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
      bottomNavigationBar: const MhadBottomNav(),
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
                borderRadius: BorderRadius.circular(9),
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
                    'AI assistant',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: Theme.of(context).mhadPalette.text,
                    ),
                  ),
                  Text(
                    '● ACTIVE · GEMINI 2.5 FLASH · PII STRIPPED BEFORE SEND',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 10,
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
            tooltip: 'Clear conversation',
            onPressed: messages.isEmpty
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Clear conversation?'),
                        content: const Text(
                            'This will erase all messages. This cannot be undone.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Clear'),
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
            tooltip: 'API key settings',
            onPressed: _openSetup,
          ),
        ],
      ),
      body: Column(
        children: [
          const CrisisTopBar(compact: true),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chatColumn = _buildChatColumn(
                  context,
                  messages: messages,
                  isSending: isSending,
                  hasKey: hasKey,
                  apiKeyAsync: apiKeyAsync,
                );
                // Desktop wide layout (>=1000px): keep the chat column on the
                // left and add a purely-presentational context panel on the
                // right. Below 1000px the layout is unchanged (chat column
                // fills width).
                if (constraints.maxWidth >= 1000) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: chatColumn),
                      _AssistantContextPanel(
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
                    'Disclaimer: Not legal advice. For legal questions contact '
                    'PA Protection and Advocacy: $paProtectionAdvocacyPhone',
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
                          'Not legal advice. For legal questions contact PA '
                          'Protection & Advocacy: $paProtectionAdvocacyPhone',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
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
                      const Text(
                        'To use the AI assistant, set up your free Gemini API key.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonal(
                        onPressed: _openSetup,
                        child: const Text('Set Up (Free)'),
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
                        return const _TypingIndicator();
                      }
                      return _MessageBubble(message: messages[i]);
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
                  label: const Text('Personal info removed',
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
    if (ctx.formType != null) {
      switch (ctx.formType) {
        case 'combined':
          parts.add('Combined form');
        case 'declaration':
          parts.add('Declaration');
        case 'poa':
          parts.add('Power of Attorney');
      }
    }
    if (ctx.stepName != null) parts.add(ctx.stepName!);
    return parts.isEmpty ? 'General question' : parts.join(' › ');
  }
}

// ---------------------------------------------------------------------------

class _RateLimitBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                tracker.statusText,
                style: TextStyle(fontSize: 11, color: fg),
              ),
            ),
            Tooltip(
              message: 'Gemini 2.5 Flash free tier:\n'
                  '${GeminiRateTracker.maxRpm} requests/min\n'
                  '${GeminiRateTracker.maxRpd} requests/day\n'
                  '${(GeminiRateTracker.maxTpm / 1000).round()}K tokens/min\n'
                  '${(GeminiApiAssistant.maxContextTokens / 1000).round()}K max context',
              child: Icon(Icons.info_outline, size: 14, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;
    final cs = Theme.of(context).colorScheme;
    final timeStr = DateFormat('h:mm a').format(message.timestamp);
    final isError = !isUser && message.content.startsWith('Sorry, I encountered an error');

    return Semantics(
      label: '${isUser ? 'You' : 'AI Assistant'} at $timeStr: ${message.content}',
      liveRegion: isError,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          mainAxisAlignment:
              isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isUser) ...[
              CircleAvatar(
                radius: 14,
                backgroundColor: cs.primary,
                child: Icon(Icons.smart_toy, size: 16, color: cs.onPrimary),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? cs.primary : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft:
                            Radius.circular(isUser ? 16 : 4),
                        bottomRight:
                            Radius.circular(isUser ? 4 : 16),
                      ),
                    ),
                    child: Text(
                      message.content,
                      style: TextStyle(
                        color: isUser ? cs.onPrimary : cs.onSurface,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 10,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (!isUser && !isError)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        'AI-generated \u00b7 Not legal, medical, or therapeutic advice',
                        style: TextStyle(
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (isUser) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final List<Animation<double>> _dotAnims;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _dotAnims = List.generate(
      3,
      (i) => CurvedAnimation(
        parent: _ctrl,
        curve: Interval(i * 200 / 600, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: 'AI is typing',
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            ExcludeSemantics(
              child: CircleAvatar(
                radius: 14,
                backgroundColor: cs.primary,
                child: Icon(Icons.smart_toy, size: 16, color: cs.onPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _Dot(animation: _dotAnims[i]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Animation<double> animation;
  const _Dot({required this.animation});

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          shape: BoxShape.circle,
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
                  hintText: 'Ask a question about your directive...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
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
                        label: 'Loading',
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.onPrimary),
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              tooltip: 'Send',
            ),
          ],
        ),
      ),
    );
  }
}

/// Desktop-only right-hand context panel shown beside the chat at >=1000px.
///
/// Purely presentational: surfaces the current [AssistantContext] (form type
/// + step) when the chat was opened from a wizard step, plus a short list of
/// example prompts that fire the existing send path via [onPromptTap]. When
/// there is no wizard context it falls back to a static "What I can help
/// with" card so the panel is never empty. No send/history state lives here.
class _AssistantContextPanel extends StatelessWidget {
  final AssistantContext? context;
  final String? contextLabel;
  final ValueChanged<String> onPromptTap;

  const _AssistantContextPanel({
    required this.context,
    required this.contextLabel,
    required this.onPromptTap,
  });

  static const _examplePrompts = [
    'What is a Mental Health Advance Directive?',
    'Who can be my agent?',
    'How long is the directive valid?',
    'Can I change my directive later?',
  ];

  @override
  Widget build(BuildContext buildContext) {
    final p = Theme.of(buildContext).mhadPalette;
    final hasContext = context != null;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(left: BorderSide(color: p.border)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          if (hasContext) ...[
            // "Context the AI sees" — structured key/value list mirroring the
            // Claude Design `WebAI` right panel.
            const SectionLabel('Context the AI sees'),
            const SizedBox(height: 8),
            _ContextKV(label: 'Form type', value: _ctxFormType(context!)),
            _ContextKV(
                label: 'Current step',
                value: context!.stepName ?? 'General question'),
            _ContextKV(
                label: 'Filled fields',
                value: '${context!.filledFields?.length ?? 0}'),
            const _ContextKV(label: 'PII', value: 'Stripped before send'),
            const SizedBox(height: 16),
            const SectionLabel('Suggested prompts'),
          ] else ...[
            const SectionLabel('What I can help with'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.card,
                border: Border.all(color: p.border),
                borderRadius:
                    BorderRadius.circular(DesignTokens.cardRadius),
              ),
              child: Text(
                'Ask about form types, agents, treatment preferences, or '
                'anything in the PA MHAD booklet. Try one of these:',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12.5,
                  height: 1.45,
                  color: p.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          for (final prompt in _examplePrompts) ...[
            _ContextPromptTile(text: prompt, onTap: () => onPromptTap(prompt)),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          const SectionLabel('Privacy'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.primaryTint,
              border: Border.all(color: p.primary.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: p.primary),
                    const SizedBox(width: 6),
                    Text(
                      'PII REDACTION ON',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontFamilyFallback: const ['Consolas', 'monospace'],
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: p.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Names, addresses, phone numbers, and dates are replaced '
                  'with placeholders before sending to Gemini. Suggestions '
                  'come back with placeholders filled in locally.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    height: 1.45,
                    color: p.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _ctxFormType(AssistantContext ctx) {
    switch (ctx.formType) {
      case 'combined':
        return 'Combined';
      case 'declaration':
        return 'Declaration';
      case 'poa':
        return 'Power of attorney';
      case null:
        return '—';
      default:
        return ctx.formType!;
    }
  }
}

/// One "Context the AI sees" key/value row (label left, value right).
class _ContextKV extends StatelessWidget {
  final String label;
  final String value;
  const _ContextKV({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: p.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextPromptTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _ContextPromptTile({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      label: text,
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      height: 1.3,
                      color: p.text,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, size: 11, color: p.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ValueChanged<String> onPromptTap;
  const _EmptyState({required this.onPromptTap});

  static const _suggestions = [
    'Walk me through filling out my directive step by step',
    'What is a Mental Health Advance Directive?',
    'What\'s the difference between Combined, Declaration, and POA?',
    'Who can be my agent?',
    'What medications should I list?',
    'What does ECT mean?',
    'How long is the directive valid?',
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
          'Ask me anything about your\nPA Mental Health Advance Directive',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 24),
        Text(
          'Suggested questions:',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ..._suggestions.map((s) => _SuggestionChip(
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
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant),
              borderRadius: BorderRadius.circular(12),
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
