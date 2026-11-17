import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/ai_assistant.dart' show AssistantContext;
import 'package:mhad/ai/ai_context_builder.dart';
import 'package:mhad/ai/crisis_detector.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/ai/handoff/handoff_task.dart';
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/ai/ai_handoff_panel.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_support_banner.dart';

/// Three suggested questions per wizard step — questions only, no legal
/// claims (the AI answers them with the verified PA facts in the prompt).
/// They replace the API path's AI-generated step tips while it is hidden.
List<String> stepQuestions(AppLocalizations l, WizardStep step) =>
    switch (step) {
      WizardStep.aboutYou => [
          l.aiStepQAboutYou1, l.aiStepQAboutYou2, l.aiStepQAboutYou3,
        ],
      WizardStep.whenItKicksIn => [
          l.aiStepQWhenItKicksIn1, l.aiStepQWhenItKicksIn2,
          l.aiStepQWhenItKicksIn3,
        ],
      WizardStep.peopleITrust => [
          l.aiStepQPeopleITrust1, l.aiStepQPeopleITrust2,
          l.aiStepQPeopleITrust3,
        ],
      WizardStep.guardianNomination => [
          l.aiStepQGuardian1, l.aiStepQGuardian2, l.aiStepQGuardian3,
        ],
      WizardStep.whereIWantCare => [
          l.aiStepQWhereIWantCare1, l.aiStepQWhereIWantCare2,
          l.aiStepQWhereIWantCare3,
        ],
      WizardStep.diagnoses => [
          l.aiStepQDiagnoses1, l.aiStepQDiagnoses2, l.aiStepQDiagnoses3,
        ],
      WizardStep.medications => [
          l.aiStepQMedications1, l.aiStepQMedications2, l.aiStepQMedications3,
        ],
      WizardStep.allergies => [
          l.aiStepQAllergies1, l.aiStepQAllergies2, l.aiStepQAllergies3,
        ],
      WizardStep.proceduresResearch => [
          l.aiStepQProcedures1, l.aiStepQProcedures2, l.aiStepQProcedures3,
        ],
      WizardStep.anythingElse => [
          l.aiStepQAnythingElse1, l.aiStepQAnythingElse2,
          l.aiStepQAnythingElse3,
        ],
      WizardStep.reviewAndSign => [
          l.aiStepQReview1, l.aiStepQReview2, l.aiStepQReview3,
        ],
    };

/// AI help for one wizard step, by copy and paste — the desktop side panel
/// and (in a bottom sheet) the phone helper. ONE widget for both, so the
/// wizard no longer sends phones away to a separate assistant page.
class AiStepHelper extends ConsumerStatefulWidget {
  final String formType;
  final WizardStep step;
  final String stepName;
  final int directiveId;

  const AiStepHelper({
    required this.formType,
    required this.step,
    required this.stepName,
    required this.directiveId,
    super.key,
  });

  @override
  ConsumerState<AiStepHelper> createState() => _AiStepHelperState();
}

class _AiStepHelperState extends ConsumerState<AiStepHelper> {
  final _question = TextEditingController();
  Map<String, String>? _filled;

  @override
  void initState() {
    super.initState();
    _question.addListener(_onChanged);
    _loadFilled();
  }

  @override
  void didUpdateWidget(AiStepHelper old) {
    super.didUpdateWidget(old);
    if (old.step != widget.step) {
      _question.clear();
      _loadFilled();
    }
  }

  Future<void> _loadFilled() async {
    final filled = await buildAiFilledFields(
        ref.read(directiveRepositoryProvider), widget.directiveId);
    if (mounted) setState(() => _filled = filled);
  }

  @override
  void dispose() {
    _question.removeListener(_onChanged);
    _question.dispose();
    super.dispose();
  }

  void _onChanged() {
    // The local crisis check still runs on anything typed into MHAD.
    if (looksLikeCrisis(_question.text)) {
      ref.read(crisisSupportShownProvider.notifier).state = true;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, size: 18, color: p.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Semantics(
                header: true,
                child: Text(context.l10n.aiStepHelpTitle,
                    style: t.titleMedium),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(context.l10n.aiStepHelpSubtitle, style: t.bodySmall),
        const SizedBox(height: 16),
        for (final q in stepQuestions(context.l10n, widget.step))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _QuestionChip(
              text: q,
              selected: _question.text == q,
              onTap: () => _question.text = q,
            ),
          ),
        const SizedBox(height: 8),
        TextField(
          controller: _question,
          minLines: 1,
          maxLines: 4,
          decoration:
              InputDecoration(labelText: context.l10n.askAiQuestionLabel),
        ),
        const SizedBox(height: 12),
        const CrisisSupportBanner(),
        AiHandoffPanel(
          kind: HandoffTaskKind.ask,
          title: context.l10n.aiStepHelpPanelTitle,
          subtitle: context.l10n.aiStepHelpPanelSubtitle,
          enabled: _question.text.trim().isNotEmpty,
          buildTask: (_) => HandoffTask(
            kind: HandoffTaskKind.ask,
            // The same instructions the in-app chat sends, with this step and
            // what's filled so far (values PII-stripped by the builder).
            instructions: LlmAssistant.systemPromptFor(AssistantContext(
              formType: widget.formType,
              stepName: widget.stepName,
              filledFields: _filled,
            )),
            ref: 'd${widget.directiveId}',
            question: PiiStripper.strip(_question.text),
          ),
        ),
      ],
    );
  }
}

/// A suggested question: full-width, tappable, fills the question box.
class _QuestionChip extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _QuestionChip(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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

/// Opens [AiStepHelper] in a bottom sheet (phones): the step's AI help
/// without leaving the wizard.
Future<void> showAiStepHelperSheet(
  BuildContext context, {
  required String formType,
  required WizardStep step,
  required String stepName,
  required int directiveId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: AiStepHelper(
          formType: formType,
          step: step,
          stepName: stepName,
          directiveId: directiveId,
        ),
      ),
    ),
  );
}
