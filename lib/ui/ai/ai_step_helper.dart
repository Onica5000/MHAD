import 'package:mhad/ai/handoff/handoff_task.dart' show directiveHandoffRef;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/ai_assistant.dart' show AssistantContext;
import 'package:mhad/ai/ai_context_builder.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/ai/ai_question_handoff.dart';
import 'package:mhad/ui/theme/app_theme.dart';

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
  Map<String, String>? _filled;

  @override
  void initState() {
    super.initState();
    _loadFilled();
  }

  @override
  void didUpdateWidget(AiStepHelper old) {
    super.didUpdateWidget(old);
    if (old.step != widget.step) _loadFilled();
  }

  Future<void> _loadFilled() async {
    final filled = await buildAiFilledFields(
        ref.read(directiveRepositoryProvider), widget.directiveId);
    if (mounted) setState(() => _filled = filled);
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
        AiQuestionHandoff(
          suggestions: stepQuestions(context.l10n, widget.step),
          ref: directiveHandoffRef(widget.directiveId),
          panelTitle: context.l10n.aiStepHelpPanelTitle,
          panelSubtitle: context.l10n.aiStepHelpPanelSubtitle,
          // The same instructions the in-app chat sends, with this step and
          // what's filled so far (values PII-stripped by the builder).
          instructions: (q) => LlmAssistant.systemPromptFor(
              question: q,
              referenceBudget: LlmAssistant.handoffReferenceChars,
              AssistantContext(
            formType: widget.formType,
            stepName: widget.stepName,
            filledFields: _filled,
          )),
        ),
      ],
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
  return showAiSheet(
    context,
    child: AiStepHelper(
      formType: formType,
      step: step,
      stepName: stepName,
      directiveId: directiveId,
    ),
  );
}

/// The one bottom-sheet frame for AI help on phones (step help, Learn).
Future<void> showAiSheet(BuildContext context, {required Widget child}) {
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
        child: child,
      ),
    ),
  );
}
