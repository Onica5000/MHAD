import 'package:flutter/material.dart';
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
      context.push(AppRoutes.aiSetup);
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
    final hasKey = ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty ?? false;

    return Container(
      width: 340,
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
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: p.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Ask the AI',
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                ],
              ),
            ),
            // Mirror the wizard step rail's AI-panel header — the active
            // provider + "PII STRIPPED" badge — for a consistent AI panel
            // across the app. (The "not advice" line moves down by the input.)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Text(
                '● ${ref.watch(activeProviderProvider).name.toUpperCase()} · PII STRIPPED',
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace',
                  ],
                  fontSize: 9.5,
                  letterSpacing: 0.5,
                  color: hasKey ? p.primary : p.textMuted,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          hasKey
                              ? 'Ask a question to get started — e.g. "What\'s '
                                  'the difference between a declaration and a '
                                  'power of attorney?"'
                              : 'Set up the free AI assistant to ask questions '
                                  'while you read.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 12.5,
                            height: 1.5,
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
                            decoration: const InputDecoration(
                              hintText: 'Ask a question…',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
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
                        label: const Text('Set up AI assistant'),
                      ),
                    ),
            ),
            // Disclaimer by the input, mirroring the wizard step rail.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                'Not legal or medical advice.',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 10.5,
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? p.primary : p.surface,
          border: isUser ? null : Border.all(color: p.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 12.5,
            height: 1.4,
            color: isUser ? p.onPrimary : p.text,
          ),
        ),
      ),
    );
  }
}
