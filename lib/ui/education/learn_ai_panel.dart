import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mhad/ui/widgets/design/crisis_support_banner.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart'
    show AssistantContext, ChatMessage, MessageRole;
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/assistant/assistant_send.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';

/// Right-side AI assistant rail on the wide Learn page, so users can ask
/// questions while reading. Shares the global conversation state with the
/// full AI Assistant screen.
class LearnAiPanel extends ConsumerStatefulWidget {
  const LearnAiPanel({super.key});

  /// The panel's fixed width.
  static const double width = 340;

  /// The panel joins the desktop Learn page only when the reading column
  /// keeps at least this much beside it (the wizard's AI rail follows the
  /// same rule): at ~1000-1170px windows it squeezed the article grid
  /// into tiny tiles. Below that, Ask the AI stays in the sidebar.
  static const double minReadingWidth = 600;

  @override
  ConsumerState<LearnAiPanel> createState() => _LearnAiPanelState();
}

class _LearnAiPanelState extends ConsumerState<LearnAiPanel> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    final result = await sendAssistantMessage(
      ref,
      l10n: context.l10n,
      text: text,
      // No directive context on the Learn page — just a general "learning"
      // session. PII is stripped downstream regardless.
      assistantContext: const AssistantContext(stepName: 'Learning'),
      requestConsent: () =>
          showAiConsentDialog(context, provider: ref.read(activeProviderProvider)),
      onSent: _scrollToBottom,
    );
    if (!mounted) return;
    if (result.needsKey) {
      _inputCtrl.text = text;
      unawaited(context.push(AppRoutes.aiSetup));
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
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final messages = ref.watch(conversationProvider);
    final isSending = ref.watch(isSendingProvider);
    final hasKey = ref.watch(apiKeyProvider).value?.isNotEmpty ?? false;

    return Container(
      width: LearnAiPanel.width,
      decoration: BoxDecoration(
        color: p.card,
        border: Border(left: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: p.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      context.l10n.learnAiPanelAskTheAi,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Mirror the wizard step rail's AI-panel header — the active
            // provider + "PII STRIPPED" badge — for a consistent AI panel
            // across the app. (The "not advice" line moves down by the input.)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                context.l10n.learnAiPanelPiiStripped(ref.watch(activeProviderProvider).name.toUpperCase()),
                style: TextStyle(
                  fontSize: 12, letterSpacing: MhadType.trackingLabel,
                  color: hasKey ? p.primary : p.textMuted,
                ),
              ),
            ),
            const Divider(height: 1),
            const CrisisSupportBanner(),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          hasKey
                              ? context.l10n.learnAiPanelAskAQuestionToGet
                              : context.l10n.learnAiPanelSetUpTheFreeAi,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14, height: MhadType.leadingParagraph,
                            color: p.textMuted,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length + (isSending ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == messages.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('…',
                                style: TextStyle(color: p.textMuted)),
                          );
                        }
                        return _LearnChatBubble(message: messages[i]);
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: hasKey
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputCtrl,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: isSending ? null : _send,
                            decoration: InputDecoration(
                              hintText: context.l10n.learnAiPanelAskAQuestion,
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: context.l10n.assistantSend,
                          onPressed:
                              isSending ? null : () => _send(_inputCtrl.text),
                          icon: const Icon(Icons.send, size: 18),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.aiSetup),
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: Text(context.l10n.learnAiPanelSetUpAiAssistant),
                      ),
                    ),
            ),
            // Disclaimer by the input, mirroring the wizard step rail.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Text(
                context.l10n.learnAiPanelNotLegalOrMedicalAdvice,
                style: TextStyle(
                  fontSize: 12,
                  color: p.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact chat bubble for the Learn-page AI rail.
class _LearnChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _LearnChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final isUser = message.role == MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? p.primary : p.surface,
          border: isUser ? null : Border.all(color: p.border),
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 14, height: MhadType.leadingParagraph,
            color: isUser ? p.onPrimary : p.text,
          ),
        ),
      ),
    );
  }
}
