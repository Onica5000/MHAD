import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/ai_assistant.dart' show AssistantContext;
import 'package:mhad/ai/crisis_detector.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/ai/handoff/handoff_task.dart';
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/ai/ai_handoff_panel.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_support_banner.dart';
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
  final _question = TextEditingController();

  @override
  void initState() {
    super.initState();
    _question.addListener(_onChanged);
  }

  @override
  void dispose() {
    _question.removeListener(_onChanged);
    _question.dispose();
    super.dispose();
  }

  void _onChanged() {
    // The crisis safety net still runs on anything typed into MHAD (it is
    // local and free): the 988 banner appears with no AI involved.
    if (looksLikeCrisis(_question.text)) {
      ref.read(crisisSupportShownProvider.notifier).state = true;
    }
    setState(() {});
  }

  List<String> _suggestions(BuildContext context) => [
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
            title: EditorialHeading(text: context.l10n.askAiTitle),
            lead: context.l10n.askAiLead,
          ),
          const SizedBox(height: 24),
          const CrisisSupportBanner(),
          TextField(
            controller: _question,
            minLines: 2,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            decoration: InputDecoration(
              labelText: context.l10n.askAiQuestionLabel,
            ),
          ),
          const SizedBox(height: 16),
          Text(context.l10n.assistantSuggestedQuestions, style: t.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _suggestions(context))
                ActionChip(
                  label: Text(s),
                  onPressed: () => _question.text = s,
                ),
            ],
          ),
          const SizedBox(height: 24),
          AiHandoffPanel(
            kind: HandoffTaskKind.ask,
            title: context.l10n.askAiPanelTitle,
            subtitle: context.l10n.askAiPanelSubtitle,
            enabled: _question.text.trim().isNotEmpty,
            buildTask: (_) => HandoffTask(
              kind: HandoffTaskKind.ask,
              // The same instructions the in-app chat sends (shared builder);
              // its filled-in fields are already PII-stripped there.
              instructions:
                  LlmAssistant.systemPromptFor(widget.assistantContext),
              ref: 'general',
              question: PiiStripper.strip(_question.text),
            ),
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
