import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/data/database/app_database.dart' show Directive;
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/step_dots.dart';
import 'package:mhad/ui/widgets/design/step_head.dart';
import 'package:mhad/ui/widgets/design/wizard_bottom_bar.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';
import 'package:mhad/ui/wizard/steps/additional_instructions_step.dart';
import 'package:mhad/ui/wizard/steps/allergies_step.dart';
import 'package:mhad/ui/wizard/steps/diagnoses_step.dart';
import 'package:mhad/ui/wizard/steps/guardian_nomination_step.dart';
import 'package:mhad/ui/wizard/steps/medications_step.dart';
import 'package:mhad/ui/wizard/steps/people_i_trust_step.dart';
import 'package:mhad/ui/wizard/steps/personal_info_step.dart';
import 'package:mhad/ui/wizard/steps/procedures_research_step.dart';
import 'package:mhad/ui/wizard/steps/review_and_sign_step.dart';
import 'package:mhad/ui/wizard/steps/treatment_facility_step.dart';
import 'package:mhad/ui/wizard/steps/when_it_kicks_in_step.dart';
import 'package:mhad/ui/wizard/widgets/document_import_tip.dart';
import 'package:mhad/ui/wizard/widgets/document_pipeline_flow.dart';
import 'package:mhad/ui/wizard/widgets/smart_fill_flow.dart';

class WizardScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const WizardScreen({required this.directiveId, super.key});

  @override
  ConsumerState<WizardScreen> createState() => _WizardScreenState();
}

/// Identifiers for the wizard top-bar overflow menu.
/// Each maps to one of the four legacy AppBar action icons that were
/// collapsed into a single `⋮` menu per PROTOTYPE_DIFF_DECISIONS.md § B.4.
enum _WizardMenuAction { smartFill, documentImport, aiChat, close }

class _WizardScreenState extends ConsumerState<WizardScreen> {
  int _stepIndex = 0;
  List<WizardStep>? _steps;
  bool _isSaving = false;
  bool _restoredStep = false;

  /// Re-keyed after Smart Fill to force the step widget to rebuild with the
  /// freshly persisted values.
  GlobalKey _stepKey = GlobalKey();

  Future<void> _persistStep() async {
    await ref
        .read(directiveRepositoryProvider)
        .updateLastStepIndex(widget.directiveId, _stepIndex);
    await _cacheForWebReload();
  }

  /// On web, snapshot the full directive to SharedPreferences so the user
  /// can resume after a page reload within the TTL window.
  Future<void> _cacheForWebReload() async {
    if (!kIsWeb) return;
    try {
      final repo = ref.read(directiveRepositoryProvider);
      final snap = await repo.snapshotDirective(widget.directiveId);
      if (snap.isNotEmpty) {
        await WebSessionCache.saveDirective(snap);
      }
    } catch (e) {
      debugPrint('Web cache save failed: $e');
    }
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

        // Restore last step on first load (clamp to valid range — the enum
        // shrunk from 15 to 9 in the redesign, so saved indices from older
        // sessions may overshoot).
        if (!_restoredStep) {
          _restoredStep = true;
          final saved = directive.lastStepIndex;
          if (saved > 0) {
            _stepIndex = saved.clamp(0, steps.length - 1);
          }
        }

        final currentStep = steps[_stepIndex];
        final isLastStep = _stepIndex == steps.length - 1;
        final p = Theme.of(context).mhadPalette;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || _isSaving) return;
            await _saveAndExit(context);
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(currentStep.displayName),
              backgroundColor: p.card,
              // Per PROTOTYPE_DIFF_DECISIONS.md § B.4 — collapse the four
              // legacy action icons (Smart Fill / Document Import / AI Chat /
              // Close) into a single overflow menu so the wizard chrome
              // matches the prototype's minimal "Back ... Save & exit" row
              // without losing the four functional destinations.
              actions: [
                PopupMenuButton<_WizardMenuAction>(
                  tooltip: 'More actions',
                  icon: const Icon(Icons.more_vert, size: 22),
                  onSelected: (action) =>
                      _handleMenuAction(context, action, directive, formType, currentStep),
                  itemBuilder: (ctx) {
                    final isPrivate =
                        !kIsWeb && ref.read(privacyModeNotifierProvider).isPrivate;
                    final closeLabel = isPrivate
                        ? 'Save & exit wizard'
                        : 'Exit wizard';
                    return [
                      const PopupMenuItem(
                        value: _WizardMenuAction.smartFill,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.auto_awesome, size: 20),
                          title: Text('Smart Fill'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: _WizardMenuAction.documentImport,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.file_upload_outlined, size: 20),
                          title: Text('Import a document'),
                        ),
                      ),
                      const PopupMenuItem(
                        value: _WizardMenuAction.aiChat,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.smart_toy_outlined, size: 20),
                          title: Text('Ask the AI'),
                        ),
                      ),
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: _WizardMenuAction.close,
                        enabled: !_isSaving,
                        child: ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.close, size: 20),
                          title: Text(closeLabel),
                        ),
                      ),
                    ];
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                const CrisisTopBar(compact: true),
                Container(
                  color: p.card,
                  padding: const EdgeInsets.only(top: 8),
                  child: StepDots(
                    current: _stepIndex + 1,
                    total: steps.length,
                  ),
                ),
                StepHead(
                  stepNumber: _stepIndex + 1,
                  totalSteps: steps.length,
                  title: currentStep.displayName,
                  subtitle: currentStep.subtitle,
                ),
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
            bottomNavigationBar: WizardBottomBar(
              primaryLabel: isLastStep ? 'Finish & export' : 'Continue',
              primaryIcon:
                  isLastStep ? Icons.check_rounded : Icons.arrow_forward,
              primaryLoading: _isSaving,
              onPrimary: () => _goNext(context, isLastStep),
              secondaryLabel: _stepIndex > 0 ? 'Back' : null,
              onSecondary: _stepIndex > 0
                  ? () async {
                      FocusScope.of(context).unfocus();
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
                        await _persistStep();
                      }
                    }
                  : null,
              showGradient: false,
            ),
          ),
        );
      },
    );
  }

  /// Dispatches the four overflow-menu actions to their respective handlers.
  /// Doc-import shows its own bottom sheet because [DocumentImportButton]
  /// owns that flow; we trigger it via a synthetic invocation here.
  Future<void> _handleMenuAction(
    BuildContext context,
    _WizardMenuAction action,
    Directive directive,
    FormType formType,
    WizardStep currentStep,
  ) async {
    switch (action) {
      case _WizardMenuAction.smartFill:
        await _smartFill(context, directive.id, formType.name);
      case _WizardMenuAction.documentImport:
        // Mirrors DocumentImportButton's behavior: route to AI setup first if
        // no key is configured, then launch the document-pipeline flow.
        final apiKey = ref.read(apiKeyProvider).valueOrNull;
        if (apiKey == null || apiKey.isEmpty) {
          if (!context.mounted) return;
          context.push(AppRoutes.aiSetup);
          return;
        }
        if (!context.mounted) return;
        await showDocumentPipelineFlow(
          context,
          directiveId: directive.id,
          formType: formType.name,
        );
      case _WizardMenuAction.aiChat:
        final fields = <String, String>{};
        void add(String k, String v) {
          if (v.isNotEmpty) fields[k] = v;
        }
        add('State', directive.state);
        add('Effective Condition', directive.effectiveCondition);
        if (!context.mounted) return;
        await context.push(
          AppRoutes.assistant,
          extra: AssistantContext(
            formType: formType.name,
            stepName: currentStep.displayName,
            filledFields: fields.isEmpty ? null : fields,
          ),
        );
      case _WizardMenuAction.close:
        if (_isSaving) return;
        await _saveAndExit(context);
    }
  }

  Widget _buildStep(WizardStep step, int directiveId, FormType formType) {
    return switch (step) {
      WizardStep.aboutYou =>
        PersonalInfoStep(key: _stepKey, directiveId: directiveId),
      WizardStep.whenItKicksIn =>
        WhenItKicksInStep(key: _stepKey, directiveId: directiveId),
      WizardStep.peopleITrust =>
        PeopleITrustStep(key: _stepKey, directiveId: directiveId),
      WizardStep.guardianNomination =>
        GuardianNominationStep(key: _stepKey, directiveId: directiveId),
      WizardStep.whereIWantCare =>
        TreatmentFacilityStep(key: _stepKey, directiveId: directiveId),
      // Phase 3 — Diagnoses now its own dedicated step (was embedded in step 2).
      WizardStep.diagnoses =>
        DiagnosesStep(key: _stepKey, directiveId: directiveId),
      WizardStep.medications => MedicationsStep(
          key: _stepKey,
          directiveId: directiveId,
          formType: formType,
        ),
      // Phase 3 — net-new Allergies step. Backward-nudge model: Severe entries
      // suggest returning to step 7 (Medications · Avoid).
      WizardStep.allergies =>
        AllergiesStep(key: _stepKey, directiveId: directiveId),
      WizardStep.proceduresResearch =>
        ProceduresResearchStep(key: _stepKey, directiveId: directiveId),
      WizardStep.anythingElse =>
        AdditionalInstructionsStep(key: _stepKey, directiveId: directiveId),
      WizardStep.reviewAndSign => ReviewAndSignStep(
          key: _stepKey,
          directiveId: directiveId,
          formType: formType,
        ),
    };
  }

  Future<void> _smartFill(
      BuildContext context, int directiveId, String formTypeName) async {
    final apiKey = ref.read(apiKeyProvider).valueOrNull;
    if (apiKey == null || apiKey.isEmpty) {
      if (!context.mounted) return;
      final goSetup = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.auto_awesome, size: 36),
          title: const Text('AI Not Set Up'),
          content: const Text(
            'Smart Fill uses AI to generate personalized suggestions based on '
            'your conditions and medications.\n\n'
            'You need a free Gemini API key to use this feature. It takes '
            'about 30 seconds to set up.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not Now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Set Up AI'),
            ),
          ],
        ),
      );
      if (goSetup == true && context.mounted) {
        context.push(AppRoutes.aiSetup);
      }
      return;
    }
    final applied = await showSmartFillFlow(
      context,
      directiveId: directiveId,
      formType: formTypeName,
    );
    if (applied == true && mounted) {
      ref.invalidate(directiveByIdProvider(directiveId));
      setState(() {
        _stepKey = GlobalKey();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Smart Fill suggestions applied. Review your form to confirm.'),
          ),
        );
      }
    }
  }

  Future<void> _goNext(BuildContext context, bool isLastStep) async {
    FocusScope.of(context).unfocus();

    setState(() => _isSaving = true);
    try {
      final state = _stepKey.currentState;
      bool stepValid = true;
      if (state != null && state is WizardStepMixin) {
        try {
          stepValid = await (state as WizardStepMixin).validateAndSave();
        } catch (e) {
          debugPrint('Step save error (non-blocking): $e');
        }
      }
      if (!stepValid && mounted && context.mounted) {
        final isPrivate = ref.read(privacyModeNotifierProvider).isPrivate;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPrivate
                ? 'Some fields are incomplete — you can come back to finish later.'
                : 'Some fields are incomplete — complete them before exporting.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      await _cacheForWebReload();

      if (mounted) {
        if (isLastStep) {
          if (kIsWeb) WebSessionCache.clear();
          if (context.mounted) {
            context.go(AppRoutes.wizardCompleteRoute(widget.directiveId));
          }
        } else {
          setState(() => _stepIndex++);
          await _persistStep();
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveAndExit(BuildContext context) async {
    final isPrivate = ref.read(privacyModeNotifierProvider).isPrivate;
    if (kIsWeb || !isPrivate) {
      await _exitWebWizard(context);
    } else {
      await _saveAndExitNative(context);
    }
  }

  Future<void> _exitWebWizard(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: Icon(Icons.warning_amber_rounded,
            color: Theme.of(context).colorScheme.error, size: 40),
        title: const Text('Exit Without Saving?'),
        content: Text(
            kIsWeb
                ? 'The web app does not save your progress permanently. '
                  'If you leave now, your work on this step will be lost.\n\n'
                  'Your session data is kept in memory for 10 minutes '
                  'in case the browser closes unexpectedly, but you '
                  'should export or print your document before leaving.'
                : 'You are in Public Mode — your data is stored in memory '
                  'only and will be lost when the app closes.\n\n'
                  'Export or print your document before leaving. '
                  'To save across sessions, use Private Mode instead.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    if (context.mounted) {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _saveAndExitNative(BuildContext context) async {
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
