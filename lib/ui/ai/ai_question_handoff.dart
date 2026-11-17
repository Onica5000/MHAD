import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/crisis_detector.dart';
import 'package:mhad/ai/handoff/handoff_task.dart';
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/ai/ai_handoff_panel.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_support_banner.dart';

/// The general suggested questions — ONE list, shared by the Ask AI page and
/// Learn (they were the in-app chat's suggestions).
List<String> generalAiQuestions(AppLocalizations l) => [
      l.assistantSuggestWalkMeThroughFillingOut,
      l.assistantSuggestWhatIsAMentalHealth,
      l.assistantSuggestWhatSTheDifferenceBetween,
      l.assistantSuggestWhoCanBeMyAgent,
      l.assistantSuggestWhatMedicationsShouldIList,
      l.assistantSuggestWhatDoesEctMean,
      l.assistantSuggestHowLongIsTheDirective,
    ];

/// Ask a question by copy and paste: suggested questions, a question box, the
/// 988 banner when needed, and the handoff card. ONE widget behind every
/// "ask" surface — the Ask AI page, the wizard's step helper, Learn — so they
/// look and behave the same (the user asked for duplicated functions to be
/// dealt with; there used to be three different AI chats).
///
/// [instructions] builds the task instructions when the person copies (the
/// same system prompt the in-app chat sends, plus any page context).
class AiQuestionHandoff extends ConsumerStatefulWidget {
  final List<String> suggestions;
  final String Function() instructions;

  /// Identifies the context (e.g. `general`, `d12`, `learn`).
  final String ref;
  final String panelTitle;
  final String? panelSubtitle;

  const AiQuestionHandoff({
    required this.suggestions,
    required this.instructions,
    required this.ref,
    required this.panelTitle,
    this.panelSubtitle,
    super.key,
  });

  @override
  ConsumerState<AiQuestionHandoff> createState() => _AiQuestionHandoffState();
}

class _AiQuestionHandoffState extends ConsumerState<AiQuestionHandoff> {
  final _question = TextEditingController();

  @override
  void initState() {
    super.initState();
    _question.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(AiQuestionHandoff old) {
    super.didUpdateWidget(old);
    // A new context (e.g. the next wizard step) starts with an empty box.
    if (old.ref != widget.ref || old.suggestions != widget.suggestions) {
      if (!widget.suggestions.contains(_question.text)) return;
      _question.clear();
    }
  }

  @override
  void dispose() {
    _question.removeListener(_onChanged);
    _question.dispose();
    super.dispose();
  }

  void _onChanged() {
    // The local crisis check runs on anything typed into MHAD (free, no AI).
    if (looksLikeCrisis(_question.text)) {
      ref.read(crisisSupportShownProvider.notifier).state = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.suggestions.isNotEmpty) ...[
          Text(context.l10n.assistantSuggestedQuestions, style: t.titleSmall),
          const SizedBox(height: 8),
          for (final q in widget.suggestions)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SuggestedQuestion(
                text: q,
                selected: _question.text == q,
                onTap: () => _question.text = q,
              ),
            ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: _question,
          minLines: 1,
          maxLines: 5,
          decoration:
              InputDecoration(labelText: context.l10n.askAiQuestionLabel),
        ),
        const SizedBox(height: 12),
        const CrisisSupportBanner(),
        AiHandoffPanel(
          kind: HandoffTaskKind.ask,
          title: widget.panelTitle,
          subtitle: widget.panelSubtitle,
          enabled: _question.text.trim().isNotEmpty,
          buildTask: (_) => HandoffTask(
            kind: HandoffTaskKind.ask,
            instructions: widget.instructions(),
            ref: widget.ref,
            question: PiiStripper.strip(_question.text),
          ),
        ),
      ],
    );
  }
}

/// A suggested question: full-width, tappable, fills the question box.
class _SuggestedQuestion extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _SuggestedQuestion(
      {required this.text, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? p.primaryLight : p.surface,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: selected ? p.primary : p.border),
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(text,
                      style: Theme.of(context).textTheme.bodyMedium),
                ),
                const SizedBox(width: 8),
                Icon(Icons.north_west, size: 16, color: p.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
