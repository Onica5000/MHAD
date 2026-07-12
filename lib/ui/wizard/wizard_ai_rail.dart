import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart' show AssistantContext, MessageRole;
import 'package:mhad/ai/ai_context_builder.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/assistant/assistant_send.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';

/// Desktop right rail (prototype `w-wizard`, 320px): a per-step AI helper with
/// a live "heads-up" + suggested-question chips, an inline mini-chat, and
/// step-specific affordances (Step-1 ID snap-fill, Care-step facility search).
/// When no API key is configured it shows a clear warning that these features
/// are unavailable until AI is set up.
class WizardAiRail extends ConsumerStatefulWidget {
  final String formType;
  final WizardStep step;
  final String stepName;
  final int directiveId;
  final VoidCallback onOpenFull;
  const WizardAiRail({
    required this.formType,
    required this.step,
    required this.stepName,
    required this.directiveId,
    required this.onOpenFull,
    super.key,
  });

  @override
  ConsumerState<WizardAiRail> createState() => _WizardAiRailState();
}

class _WizardAiRailState extends ConsumerState<WizardAiRail> {
  final _inputCtrl = TextEditingController();
  final _facilityCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _facilityCtrl.dispose();
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
    final filled = await buildAiFilledFields(
        ref.read(directiveRepositoryProvider), widget.directiveId);
    if (!mounted) return;
    final result = await sendAssistantMessage(
      ref,
      text: text,
      assistantContext: AssistantContext(
        formType: widget.formType,
        stepName: widget.stepName,
        filledFields: filled.isEmpty ? null : filled,
      ),
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

  void _askFacility() {
    final q = _facilityCtrl.text.trim();
    if (q.isEmpty) return;
    _facilityCtrl.clear();
    _send('I\'m looking for a PA inpatient facility ("$q"). What should I know, '
        'and how do I record a preferred or avoided facility on this step?');
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final hasKey = ref.watch(apiKeyProvider).whenOrNull(
              data: (k) => k != null && k.isNotEmpty,
            ) ??
        false;

    return Container(
      width: 320,
      color: p.card,
      padding: const EdgeInsets.fromLTRB(20, 24, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: p.primary),
              const SizedBox(width: 8),
              Text(
                'AI assistant',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: p.text,
                ),
              ),
              const Spacer(),
              if (hasKey)
                InkWell(
                  onTap: widget.onOpenFull,
                  borderRadius: BorderRadius.circular(6),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    child: Text(
                      'Full view',
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: p.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
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
          const SizedBox(height: 14),
          if (!hasKey)
            Expanded(
              child: SingleChildScrollView(
                child: _RailNoAiCard(
                  onSetUp: () => context.push(AppRoutes.aiSetup),
                ),
              ),
            )
          else ...[
            _RailHeadsUp(
              formType: widget.formType,
              stepName: widget.stepName,
              directiveId: widget.directiveId,
              onAsk: _send,
            ),
            if (widget.step == WizardStep.whereIWantCare)
              _RailFacilitySearch(
                controller: _facilityCtrl,
                onSubmit: _askFacility,
              ),
            const SizedBox(height: 10),
            Divider(color: p.border, height: 1),
            Expanded(child: _RailChat(scrollController: _scrollCtrl)),
            _RailInput(
              controller: _inputCtrl,
              onSend: () => _send(_inputCtrl.text),
            ),
            const SizedBox(height: 6),
            Text(
              'Not legal or medical advice.',
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 10.5,
                color: p.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shown in the rail when no API key is configured: a clear warning that the
/// AI features (heads-up, suggested questions, photo auto-fill, chat) are
/// unavailable until AI is set up, plus a one-tap setup CTA.
class _RailNoAiCard extends StatelessWidget {
  final VoidCallback onSetUp;
  const _RailNoAiCard({required this.onSetUp});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const InfoBanner(
          icon: Icons.info_outline,
          variant: InfoBannerVariant.warning,
          text: 'AI help is off. The step heads-up, suggested questions, '
              'photo auto-fill, and the chat below aren\'t available until you '
              'set up AI.',
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onSetUp,
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Set up AI'),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your API key stays on this device and is only used to answer your '
          'questions. You can fill out the whole wizard without it.',
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 11.5,
            height: 1.4,
            color: p.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Live, step-contextual heads-up note + suggested-question chips, generated by
/// Gemini ([wizardRailSuggestionsProvider]). Silent (collapses) on failure or
/// while there's nothing to show.
class _RailHeadsUp extends ConsumerWidget {
  final String formType;
  final String stepName;
  final int directiveId;
  final void Function(String) onAsk;
  const _RailHeadsUp({
    required this.formType,
    required this.stepName,
    required this.directiveId,
    required this.onAsk,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final async = ref.watch(wizardRailSuggestionsProvider(
      (formType: formType, stepName: stepName, directiveId: directiveId),
    ));

    Widget card(Widget child) => Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.primaryTint,
            border: Border.all(color: p.primaryLight),
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        );

    return async.when(
      loading: () => card(Row(
        children: [
          SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(strokeWidth: 2, color: p.primary),
          ),
          const SizedBox(width: 10),
          Text(
            'Reading this step…',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 12,
              color: p.onPrimaryLight,
            ),
          ),
        ],
      )),
      error: (_, _) => const SizedBox.shrink(),
      data: (s) {
        if (s == null) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (s.headsUp.isNotEmpty)
              card(Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: p.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.headsUp,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 12.5,
                        height: 1.4,
                        color: p.onPrimaryLight,
                      ),
                    ),
                  ),
                ],
              )),
            if (s.chips.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                'SUGGESTED FOR THIS STEP',
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace',
                  ],
                  fontSize: 9,
                  letterSpacing: 0.6,
                  color: p.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final c in s.chips)
                    InkWell(
                      onTap: () => onAsk(c),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: p.surface,
                          border: Border.all(color: p.border),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          c,
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: p.text,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Care-step facility search — feeds the query into the rail chat so the
/// assistant can help (we have no PA facility directory to search directly).
class _RailFacilitySearch extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;
  const _RailFacilitySearch({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        onSubmitted: (_) => onSubmit(),
        style: const TextStyle(fontFamily: kSansFamily, fontSize: 13),
        decoration: InputDecoration(
          isDense: true,
          hintText: 'Find a PA facility by name or county…',
          prefixIcon: Icon(Icons.search, size: 18, color: p.textMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

/// The rail's inline mini-chat — renders the shared assistant conversation
/// ([conversationProvider]) so it stays in sync with the full assistant view.
class _RailChat extends ConsumerWidget {
  final ScrollController scrollController;
  const _RailChat({required this.scrollController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final messages = ref.watch(conversationProvider);
    final isSending = ref.watch(isSendingProvider);

    if (messages.isEmpty && !isSending) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Text(
            'Ask anything about this step — answers appear here, and in the '
            'full assistant.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 12,
              height: 1.4,
              color: p.textMuted,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: messages.length + (isSending ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= messages.length) {
          return _RailBubble(text: 'Thinking…', isUser: false, muted: true);
        }
        final m = messages[i];
        return _RailBubble(
          text: m.content,
          isUser: m.role == MessageRole.user,
        );
      },
    );
  }
}

class _RailBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final bool muted;
  const _RailBubble({
    required this.text,
    required this.isUser,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isUser ? p.primary : p.surface,
          borderRadius: BorderRadius.circular(12),
          border: isUser ? null : Border.all(color: p.border),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 12.5,
            height: 1.4,
            fontStyle: muted ? FontStyle.italic : FontStyle.normal,
            color: isUser
                ? p.onPrimary
                : (muted ? p.textMuted : p.text),
          ),
        ),
      ),
    );
  }
}

class _RailInput extends ConsumerWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _RailInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final isSending = ref.watch(isSendingProvider);
    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: p.border),
      ),
      padding: const EdgeInsets.only(left: 14, right: 4),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isSending,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(fontFamily: kSansFamily, fontSize: 13),
              decoration: const InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Ask about this step…',
              ),
            ),
          ),
          IconButton(
            onPressed: isSending ? null : onSend,
            visualDensity: VisualDensity.compact,
            tooltip: 'Send',
            icon: isSending
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child:
                        CircularProgressIndicator(strokeWidth: 2, color: p.primary),
                  )
                : Icon(Icons.arrow_upward, size: 18, color: p.primary),
          ),
        ],
      ),
    );
  }
}

/// Narrow-width collapse of [WizardAiRail] (prototype `w-wiz-mobile`): a slim
/// tappable "Need help?" bar above the bottom action bar.
class WizardAiBar extends StatelessWidget {
  final VoidCallback onAsk;
  const WizardAiBar({required this.onAsk, super.key});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: p.primaryTint,
      child: InkWell(
        onTap: onAsk,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: p.primaryLight)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: p.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Need help with this step? Ask the AI',
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.onPrimaryLight,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_up, size: 18, color: p.primary),
            ],
          ),
        ),
      ),
    );
  }
}
