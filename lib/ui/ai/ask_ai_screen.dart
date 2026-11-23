import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/ai_assistant.dart' show AssistantContext;
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/ai/ai_question_handoff.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/page_hero.dart';

/// "Ask AI" — the visible AI help since 2026-11-17 (copy-and-paste handoff,
/// no API key): type or pick a question, copy it with the Pennsylvania context
/// into the AI you already use, read the answer there. Replaces the in-app
/// chat while the API path is hidden ([AiConfig.apiModeVisible]).
///
/// [assistantContext] carries the wizard step / form type when opened from
/// the wizard, so the question goes with that context.
class AskAiScreen extends ConsumerStatefulWidget {
  final AssistantContext? assistantContext;
  const AskAiScreen({this.assistantContext, super.key});

  @override
  ConsumerState<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends ConsumerState<AskAiScreen> {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: ListView(
        padding: DesignTokens.pagePadding,
        children: [
          PageHero(
            art: AppArt.aiAssistant,
            eyebrow: context.l10n.askAiEyebrow,
            title: EditorialHeading(text: context.l10n.navAskAi),
            lead: context.l10n.askAiLead,
          ),
          const SizedBox(height: 24),
          AiQuestionHandoff(
            suggestions: generalAiQuestions(context.l10n),
            ref: 'general',
            panelTitle: context.l10n.askAiPanelTitle,
            panelSubtitle: context.l10n.askAiPanelSubtitle,
            // A guided session (facilitator page) opens with its request.
            initialQuestion: widget.assistantContext?.openingPrompt,
            // The same instructions the in-app chat sends (shared builder);
            // wizard context when opened from a step.
            instructions: (q) => LlmAssistant.systemPromptFor(
                widget.assistantContext,
                question: q,
                referenceBudget: LlmAssistant.handoffReferenceChars),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.assistantDisclaimerNotLegalOrMedical(
                appData.phoneOf('paProtectionAdvocacy')),
            style: t.bodySmall,
          ),
        ],
      ),
    );
  }
}
