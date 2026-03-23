import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';
import 'package:mhad/ui/wizard/steps/personal_info_step.dart';
import 'package:mhad/ui/wizard/steps/effective_condition_step.dart';
import 'package:mhad/ui/wizard/steps/treatment_facility_step.dart';
import 'package:mhad/ui/wizard/steps/medications_step.dart';
import 'package:mhad/ui/wizard/steps/ect_step.dart';
import 'package:mhad/ui/wizard/steps/experimental_studies_step.dart';
import 'package:mhad/ui/wizard/steps/drug_trials_step.dart';
import 'package:mhad/ui/wizard/steps/additional_instructions_step.dart';
import 'package:mhad/ui/wizard/steps/agent_designation_step.dart';
import 'package:mhad/ui/wizard/steps/alternate_agent_step.dart';
import 'package:mhad/ui/wizard/steps/agent_authority_step.dart';
import 'package:mhad/ui/wizard/steps/guardian_nomination_step.dart';
import 'package:mhad/ui/wizard/steps/review_step.dart';
import 'package:mhad/ui/wizard/steps/execution_step.dart';
import 'package:mhad/ui/wizard/widgets/document_import_button.dart';
import 'package:mhad/ui/wizard/widgets/document_import_tip.dart';
import 'package:mhad/ui/wizard/widgets/smart_fill_flow.dart';

class WizardScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const WizardScreen({required this.directiveId, super.key});

  @override
  ConsumerState<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends ConsumerState<WizardScreen> {
  int _stepIndex = 0;
  List<WizardStep>? _steps;
  bool _isSaving = false;
  bool _restoredStep = false;

  // A plain GlobalKey so we can cast currentState to WizardStepMixin
  final _stepKey = GlobalKey();

  void _persistStep() {
    ref
        .read(directiveRepositoryProvider)
        .updateLastStepIndex(widget.directiveId, _stepIndex);
  }

  @override
  Widget build(BuildContext context) {
    final directiveAsync =
        ref.watch(directiveByIdProvider(widget.directiveId));

    return directiveAsync.when(
      loading: () => Scaffold(
        body: Center(
          child: Semantics(
            label: 'Loading',
            child: const CircularProgressIndicator(),
          ),
        ),
      ),
      error: (e, _) {
        debugPrint('Error loading directive: $e');
        return Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Semantics(
                    liveRegion: true,
                    child: const Text(
                      'Unable to load this directive.\nPlease go back and try again.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      data: (directive) {
        if (directive == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Not found')),
            body: const Center(child: Text('Directive not found.')),
          );
        }

        final formType = FormType.values.firstWhere(
          (e) => e.name == directive.formType,
          orElse: () => FormType.combined,
        );

        _steps ??= formType.steps;
        final steps = _steps!;

        // Restore last step on first load
        if (!_restoredStep) {
          _restoredStep = true;
          final saved = directive.lastStepIndex;
          if (saved > 0 && saved < steps.length) {
            _stepIndex = saved;
          }
        }

        final currentStep = steps[_stepIndex];
        final isLastStep = _stepIndex == steps.length - 1;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || _isSaving) return;
            await _saveAndExit(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(currentStep.displayName),
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Save & exit',
                onPressed: _isSaving ? null : () => _saveAndExit(context),
              ),
              actions: [
                Tooltip(
                  message: 'Smart Fill — pick conditions & meds, AI fills the rest',
                  child: IconButton(
                    icon: const Icon(Icons.auto_awesome),
                    onPressed: () async {
                      final applied = await showSmartFillFlow(
                        context,
                        directiveId: directive.id,
                        formType: formType.name,
                      );
                      if (applied == true && mounted) {
                        // Rebuild to pick up new data
                        setState(() {});
                      }
                    },
                  ),
                ),
                DocumentImportButton(
                  directiveId: directive.id,
                  formType: formType.name,
                ),
              ],
            ),
            body: Column(
              children: [
                _ProgressBar(
                    current: _stepIndex + 1, total: steps.length),
                if (_stepIndex == 0) const DocumentImportTip(),
                Expanded(
                  child: _buildStep(
                    currentStep,
                    directive.id,
                    formType,
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton.small(
              heroTag: 'assistant_fab',
              tooltip: 'AI Assistant',
              onPressed: () {
                final fields = <String, String>{};
                void add(String k, String v) {
                  if (v.isNotEmpty) fields[k] = v;
                }
                add('Full Name', directive.fullName);
                add('Date of Birth', directive.dateOfBirth);
                add('Address', directive.address);
                add('City', directive.city);
                add('State', directive.state);
                add('ZIP', directive.zip);
                add('Phone', directive.phone);
                add('Effective Condition',
                    directive.effectiveCondition);

                context.push(
                  AppRoutes.assistant,
                  extra: AssistantContext(
                    formType: formType.name,
                    stepName: currentStep.displayName,
                    filledFields:
                        fields.isEmpty ? null : fields,
                  ),
                );
              },
              child: const Icon(Icons.smart_toy_outlined),
            ),
            bottomNavigationBar: _BottomBar(
              stepIndex: _stepIndex,
              totalSteps: steps.length,
              isSaving: _isSaving,
              isLastStep: isLastStep,
              onBack: _stepIndex > 0
                  ? () async {
                      FocusScope.of(context).unfocus();
                      // Auto-save current step data on back navigation (best-effort)
                      final state = _stepKey.currentState;
                      if (state is WizardStepMixin) {
                        try {
                          await (state as WizardStepMixin).validateAndSave();
                        } catch (e) {
                          debugPrint('Auto-save on back failed: $e');
                        }
                      }
                      if (mounted) {
                        setState(() => _stepIndex--);
                        _persistStep();
                      }
                    }
                  : null,
              onNext: () => _goNext(context, isLastStep),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStep(WizardStep step, int directiveId, FormType formType) {
    return switch (step) {
      WizardStep.personalInfo =>
        PersonalInfoStep(key: _stepKey, directiveId: directiveId),
      WizardStep.effectiveCondition =>
        EffectiveConditionStep(key: _stepKey, directiveId: directiveId),
      WizardStep.treatmentFacility =>
        TreatmentFacilityStep(key: _stepKey, directiveId: directiveId),
      WizardStep.medications =>
        MedicationsStep(key: _stepKey, directiveId: directiveId, formType: formType),
      WizardStep.ect =>
        EctStep(key: _stepKey, directiveId: directiveId),
      WizardStep.experimentalStudies =>
        ExperimentalStudiesStep(key: _stepKey, directiveId: directiveId),
      WizardStep.drugTrials =>
        DrugTrialsStep(key: _stepKey, directiveId: directiveId),
      WizardStep.additionalInstructions =>
        AdditionalInstructionsStep(key: _stepKey, directiveId: directiveId),
      WizardStep.agentDesignation =>
        AgentDesignationStep(key: _stepKey, directiveId: directiveId),
      WizardStep.alternateAgent =>
        AlternateAgentStep(key: _stepKey, directiveId: directiveId),
      WizardStep.agentAuthority =>
        AgentAuthorityStep(key: _stepKey, directiveId: directiveId),
      WizardStep.guardianNomination =>
        GuardianNominationStep(key: _stepKey, directiveId: directiveId),
      WizardStep.review =>
        ReviewStep(key: _stepKey, directiveId: directiveId, formType: formType),
      WizardStep.execution =>
        ExecutionStep(key: _stepKey, directiveId: directiveId, formType: formType),
    };
  }

  Future<void> _goNext(BuildContext context, bool isLastStep) async {
    FocusScope.of(context).unfocus();
    final state = _stepKey.currentState;
    if (state == null) return;

    setState(() => _isSaving = true);
    try {
      bool success = true;
      if (state is WizardStepMixin) {
        success = await (state as WizardStepMixin).validateAndSave();
      }
      if (success && mounted) {
        if (isLastStep) {
          if (context.mounted) {
            context.go(AppRoutes.wizardCompleteRoute(widget.directiveId));
          }
        } else {
          setState(() => _stepIndex++);
          _persistStep();
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAndExit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save & Exit'),
        content: const Text(
            'Your progress on this step will be saved. '
            'You can return to continue later.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final state = _stepKey.currentState;
    setState(() => _isSaving = true);
    try {
      if (state is WizardStepMixin) {
        await (state as WizardStepMixin).validateAndSave();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        if (context.mounted) {
          context.go(AppRoutes.home);
        }
      }
    }
  }
}

class _ProgressBar extends StatelessWidget {
  final int current;
  final int total;
  const _ProgressBar({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = ((current / total) * 100).round();
    return Semantics(
      label: 'Step $current of $total, $percent% complete',
      value: '$percent%',
      liveRegion: true,
      child: Column(
        children: [
          LinearProgressIndicator(
            value: current / total,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            minHeight: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Step $current of $total',
                    style: Theme.of(context).textTheme.labelSmall),
                Text('$percent% complete',
                    style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int stepIndex;
  final int totalSteps;
  final bool isSaving;
  final bool isLastStep;
  final VoidCallback? onBack;
  final VoidCallback onNext;

  const _BottomBar({
    required this.stepIndex,
    required this.totalSteps,
    required this.isSaving,
    required this.isLastStep,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (onBack != null)
              Semantics(
                button: true,
                label: 'Back to step $stepIndex',
                child: OutlinedButton.icon(
                  onPressed: isSaving ? null : onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
            const Spacer(),
            Semantics(
              button: true,
              label: isSaving
                  ? 'Saving'
                  : isLastStep
                      ? 'Finish directive'
                      : 'Next, go to step ${stepIndex + 2} of $totalSteps',
              child: FilledButton.icon(
                onPressed: isSaving ? null : onNext,
                icon: isSaving
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: Semantics(
                          label: 'Loading',
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                label: Text(isLastStep ? 'Finish' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
