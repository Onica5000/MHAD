import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart'
    show AssistantContext, MessageRole;
import 'package:mhad/data/database/app_database.dart' show Directive;
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/ui/assistant/assistant_send.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/design/step_dots.dart';
import 'package:mhad/ui/widgets/design/step_head.dart';
import 'package:mhad/ui/widgets/design/wizard_bottom_bar.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
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
import 'package:mhad/ui/wizard/widgets/smart_fill_card.dart';
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
// _WizardMenuAction enum removed with the wizard overflow menu
// (2026-06-03). See the `_handleMenuAction` removal note above.

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
    // Best-effort crash-recovery snapshot. It must NEVER block wizard
    // navigation: callers `await` this before advancing the step, so a hung
    // DB read / storage write here would freeze "Continue". Bound every async
    // hop with a timeout — a try/catch alone does not rescue a hang, only a
    // throw. On timeout we simply skip caching this step.
    try {
      final repo = ref.read(directiveRepositoryProvider);
      final snap = await repo
          .snapshotDirective(widget.directiveId)
          .timeout(const Duration(seconds: 3));
      if (snap.isNotEmpty) {
        await WebSessionCache.saveDirective(snap)
            .timeout(const Duration(seconds: 3));
      }
    } catch (e) {
      debugPrint('Web cache save skipped (failed or timed out): $e');
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
            backgroundColor: p.scaffoldBackground,
            // Material AppBar removed 2026-06-03 — prototype ScrWizard*
            // screens use a thin in-body WizardHeader (Back + Save&exit)
            // sitting between the CrisisBar and the StepDots, not a
            // standard Material chrome. The `_handleSmartFillTarget` +
            // `_smartFill` helpers stay wired so the step-1 SmartFillCard
            // tile callbacks still resolve through the same code path.
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Desktop / wide layout — step rail on the left, content
                // column on the right. Matches the prototype's `w-wizard`
                // pattern. The rail is read-only in this first pass: jumping
                // mid-wizard would skip validation of intermediate steps.
                //
                // `shellActive` keys off the TOTAL window width (the
                // desktop-shell signal), NOT this screen's post-sidebar
                // constraints — the persistent WebSidebar eats 232px, so a
                // content-based >=1000 check would leave a dead band
                // (1000–1231px) where the sidebar shows but the wizard still
                // rendered its mobile column. The 320px AI rail needs more
                // room than the 240px step rail + a usable form, so it only
                // appears once the content area is wide enough; below that it
                // collapses to the peeking "Need help?" bar.
                final shellActive =
                    MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint;
                final showAiRail =
                    shellActive && constraints.maxWidth >= 1080;
                final mainColumn = Column(
                  children: [
                    const CrisisTopBar(compact: true),
                    // Prototype `WizardHeader` (ds.jsx L251-263): thin row
                    // with chevron+Back left and "Save & exit" right.
                    // Replaces the legacy Material AppBar. The Back action
                    // delegates to the same back-step path the bottom bar
                    // uses (validate, save, decrement); Save & exit runs
                    // the existing `_saveAndExit` flow.
                    // Single exit-to-home affordance for the whole wizard.
                    // "Back to previous step" lives ONLY on the bottom bar, so
                    // there are no duplicate Back/Exit controls (the header
                    // previously showed both an "Exit" and a "Save & exit").
                    WizardHeader(
                      onBack: () => _saveAndExit(context),
                      backLabel: 'Exit',
                      actionLabel: '',
                    ),
                    if (!shellActive)
                      Container(
                        color: p.scaffoldBackground,
                        padding: const EdgeInsets.only(top: 4),
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
                    // Editorial Smart Fill launcher on step 1 — matches
                    // prototype `ScrWizardAbout::SmartFillCard`
                    // (mobile.jsx::SmartFillCard L480-583) + the "OR BY
                    // HAND" mono divider that separates it from the form
                    // fields. Additive: the wizard `⋮` overflow menu's
                    // Smart Fill + Document Import entries stay reachable
                    // exactly as before.
                    if (_stepIndex == 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                        child: SmartFillCard(
                          onPickTarget: (target) => _handleSmartFillTarget(
                            context,
                            directive,
                            formType,
                            target,
                          ),
                        ),
                      ),
                    if (_stepIndex == 0)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                  height: 1, color: p.border),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'OR BY HAND',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontFamilyFallback: const [
                                  'Consolas',
                                  'Menlo',
                                  'Courier New',
                                  'monospace',
                                ],
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: p.textMuted,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Container(
                                  height: 1, color: p.border),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: _buildStep(
                        currentStep,
                        directive.id,
                        formType,
                      ),
                    ),
                    // Prototype `w-wiz-mobile`: the AI rail collapses to a slim
                    // peeking "Need help?" bar whenever the full 320px rail
                    // isn't shown — i.e. on mobile AND in the desktop band
                    // that's too narrow for the rail.
                    if (!showAiRail)
                      _WizardAiBar(
                        onAsk: () => _openStepAi(
                          context,
                          formType,
                          currentStep.displayName,
                        ),
                      ),
                    // Narrow (mobile) keeps a bottom Back/Continue bar. With the
                    // desktop shell active the navigation lives under the step
                    // rail instead, so the Scaffold has no bottomNavigationBar.
                    if (!shellActive)
                      WizardBottomBar(
                        primaryLabel: isLastStep
                            ? 'Generate signing packet'
                            : 'Continue',
                        primaryIcon: Icons.arrow_forward,
                        primaryLoading: _isSaving,
                        onPrimary: () => _goNext(context, isLastStep),
                        secondaryLabel: _stepIndex > 0 ? 'Back' : null,
                        onSecondary: _stepIndex > 0 ? _goBack : null,
                        showGradient: false,
                      ),
                  ],
                );
                if (!shellActive) return mainColumn;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WideStepRail(
                      steps: steps,
                      currentIndex: _stepIndex,
                      onNext: () => _goNext(context, isLastStep),
                      onBack: _stepIndex > 0 ? _goBack : null,
                      nextLabel:
                          isLastStep ? 'Generate signing packet' : 'Next',
                      nextLoading: _isSaving,
                    ),
                    Container(width: 1, color: p.border),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: mainColumn,
                      ),
                    ),
                    // Prototype `w-wizard` right rail (320px): a contextual AI
                    // helper beside the form. Only shown when the content area
                    // is wide enough; otherwise the peeking "Need help?" bar
                    // inside mainColumn takes its place.
                    if (showAiRail) ...[
                      Container(width: 1, color: p.border),
                      _WizardAiRail(
                        formType: formType.name,
                        step: currentStep,
                        stepName: currentStep.displayName,
                        directiveId: directive.id,
                        onOpenFull: () => _openStepAi(
                          context,
                          formType,
                          currentStep.displayName,
                        ),
                        onSnapId: () => showDocumentPipelineFlow(
                          context,
                          directiveId: directive.id,
                          formType: formType.name,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            // No Scaffold bottomNavigationBar: on wide screens navigation
            // lives under the step rail (`_WideStepRail`); on narrow screens
            // a `WizardBottomBar` is appended inside the body column above.
          ),
        );
      },
    );
  }

  /// Dispatches the four overflow-menu actions to their respective handlers.
  /// Doc-import shows its own bottom sheet because [DocumentImportButton]
  /// owns that flow; we trigger it via a synthetic invocation here.
  /// Dispatch a [SmartFillTarget] from the editorial step-1 SmartFillCard.
  /// All four targets currently route to the same document-import pipeline
  /// (the existing AI extractor already infers field types from the image);
  /// the target is passed through as a hint so a follow-up pass can route
  /// to dedicated prompts per target. The "ID" tile additionally routes
  /// to the standalone smart-fill flow which can be filled from a typed
  /// summary instead of a photo.
  Future<void> _handleSmartFillTarget(
    BuildContext context,
    Directive directive,
    FormType formType,
    SmartFillTarget target,
  ) async {
    switch (target) {
      case SmartFillTarget.id:
        // "Photo of ID" is the prototype's recommended start — gives the
        // user a choice between snap-to-fill and the typed smart-fill flow.
        await _smartFill(context, directive.id, formType.name);
      case SmartFillTarget.rx:
      case SmartFillTarget.conditions:
      case SmartFillTarget.other:
        // Open the snap-to-fill page regardless of whether AI is set up. The
        // page renders fine without a key and shows a "Set up AI" banner;
        // dropping a file then prompts for setup. (Previously this pre-diverted
        // to AI setup, so web users without a key never saw the page at all —
        // which is why snap-to-fill appeared "missing".)
        if (!context.mounted) return;
        await showDocumentPipelineFlow(
          context,
          directiveId: directive.id,
          formType: formType.name,
        );
    }
  }

  // _handleMenuAction / _WizardMenuAction enum removed with the
  // overflow menu (2026-06-03). The Smart Fill and Document Import
  // destinations are now reached through `_handleSmartFillTarget`
  // (called by SmartFillCard tiles); Ask the AI is on the bottom nav;
  // Save & exit is on the bottom bar (step 1) and PopScope (other steps).

  /// Opens the AI assistant pre-loaded with this step's context. Used by both
  /// the desktop right rail and the narrow peeking bar (prototype w-wizard /
  /// w-wiz-mobile).
  void _openStepAi(BuildContext context, FormType formType, String stepName) {
    context.push(
      AppRoutes.assistant,
      extra: AssistantContext(
        formType: formType.name,
        stepName: stepName,
      ),
    );
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
      // suggest returning to step 7 (Medications · Avoid). The hook lets the
      // SnackBar action move the wizard back one step instead of being
      // intercepted by the wizard's PopScope (which would Save & Exit).
      WizardStep.allergies => AllergiesStep(
          key: _stepKey,
          directiveId: directiveId,
          onGoToPrevStep: _stepIndex > 0
              ? () => setState(() => _stepIndex--)
              : null,
        ),
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

      if (mounted) {
        if (isLastStep) {
          if (kIsWeb) WebSessionCache.clear();
          if (context.mounted) {
            // Prototype split (2026-06-04): Review → Sign → Done.
            // The wizard's last step ends at Review; "Continue" hands
            // off to the dedicated SignScreen at /sign/:id rather than
            // jumping straight to the Done celebration.
            context.go(AppRoutes.signRoute(widget.directiveId));
          }
        } else {
          // Advance FIRST, then persist + web-cache in the background. The
          // resume-index write and crash-recovery snapshot are best-effort —
          // they must never gate "Continue" (a hung await here was freezing
          // navigation on web).
          setState(() => _stepIndex++);
          unawaited(_persistStep());
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Back to the previous step. Saves the current step first (best-effort),
  /// then decrements immediately — persistence runs in the background so it can
  /// never block navigation.
  Future<void> _goBack() async {
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
      unawaited(_persistStep());
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

/// Desktop step rail rendered at widths ≥1000px. Matches the prototype's
/// `w-wizard` left column (web-wizard-steps.jsx). Read-only in this pass:
/// it shows progress with completed / current / pending dot states but
/// does not let the user jump arbitrarily (which would skip per-step
/// validation). Navigation still happens via Continue / Back at the
/// bottom bar.
/// Desktop right rail (prototype `w-wizard`, 320px): a contextual AI helper
/// beside the form. Tapping opens the full assistant with this step's context.
/// Desktop right rail (prototype `w-wizard`, 320px): a per-step AI helper with
/// a live "heads-up" + suggested-question chips, an inline mini-chat, and
/// step-specific affordances (Step-1 ID snap-fill, Care-step facility search).
/// When no API key is configured it shows a clear warning that these features
/// are unavailable until AI is set up.
class _WizardAiRail extends ConsumerStatefulWidget {
  final String formType;
  final WizardStep step;
  final String stepName;
  final int directiveId;
  final VoidCallback onOpenFull;
  final VoidCallback onSnapId;
  const _WizardAiRail({
    required this.formType,
    required this.step,
    required this.stepName,
    required this.directiveId,
    required this.onOpenFull,
    required this.onSnapId,
  });

  @override
  ConsumerState<_WizardAiRail> createState() => _WizardAiRailState();
}

class _WizardAiRailState extends ConsumerState<_WizardAiRail> {
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
    final result = await sendAssistantMessage(
      ref,
      text: text,
      assistantContext: AssistantContext(
        formType: widget.formType,
        stepName: widget.stepName,
      ),
      requestConsent: () => showAiConsentDialog(context),
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
                  fontFamily: 'DM Sans',
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
                        fontFamily: 'DM Sans',
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
            '● GEMINI · PII STRIPPED',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
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
              onAsk: _send,
            ),
            if (widget.step == WizardStep.aboutYou)
              _RailSnapId(onTap: widget.onSnapId),
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
              'Not legal advice.',
              style: TextStyle(
                fontFamily: 'DM Sans',
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
            fontFamily: 'DM Sans',
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
  final void Function(String) onAsk;
  const _RailHeadsUp({
    required this.formType,
    required this.stepName,
    required this.onAsk,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final async = ref.watch(wizardRailSuggestionsProvider(
      (formType: formType, stepName: stepName, answersDigest: ''),
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
              fontFamily: 'DM Sans',
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
                        fontFamily: 'DM Sans',
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
                  fontFamily: 'JetBrains Mono',
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
                            fontFamily: 'DM Sans',
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

/// Step-1 "snap your ID" affordance — routes into the AI document pipeline,
/// which fills name / DOB / address from a photo (artboard `WebWizard` step 1).
class _RailSnapId extends StatelessWidget {
  final VoidCallback onTap;
  const _RailSnapId({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: p.primaryTint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: p.primaryLight),
          ),
          child: Row(
            children: [
              Icon(Icons.add_a_photo_outlined, size: 18, color: p.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Snap your ID',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: p.onPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Fills name, DOB & address. Read, then discarded.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        height: 1.3,
                        color: p.onPrimaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, size: 14, color: p.primary),
            ],
          ),
        ),
      ),
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
        style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13),
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
              fontFamily: 'DM Sans',
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
            fontFamily: 'DM Sans',
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
              style: const TextStyle(fontFamily: 'DM Sans', fontSize: 13),
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

/// Narrow-width collapse of [_WizardAiRail] (prototype `w-wiz-mobile`): a slim
/// tappable "Need help?" bar above the bottom action bar.
class _WizardAiBar extends StatelessWidget {
  final VoidCallback onAsk;
  const _WizardAiBar({required this.onAsk});

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
                    fontFamily: 'DM Sans',
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

class _WideStepRail extends StatelessWidget {
  final List<WizardStep> steps;
  final int currentIndex;
  // Navigation lives directly under the step list on wide screens (there is
  // no bottom bar in the desktop layout).
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final String nextLabel;
  final bool nextLoading;
  const _WideStepRail({
    required this.steps,
    required this.currentIndex,
    required this.onNext,
    required this.onBack,
    required this.nextLabel,
    required this.nextLoading,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      width: 240,
      color: p.card,
      padding: const EdgeInsets.fromLTRB(20, 24, 16, 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'YOUR DIRECTIVE',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontFamilyFallback: const [
                  'Consolas',
                  'Menlo',
                  'Courier New',
                  'monospace',
                ],
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: p.textMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${currentIndex + 1} / ${steps.length}',
              style: TextStyle(
                fontFamily: 'Instrument Serif',
                fontFamilyFallback: const ['Georgia', 'serif'],
                fontStyle: FontStyle.italic,
                fontSize: 36,
                fontWeight: FontWeight.w400,
                letterSpacing: -0.5,
                height: 1,
                color: p.primary,
              ),
            ),
            const SizedBox(height: 18),
            for (var i = 0; i < steps.length; i++)
              _RailStepRow(
                index: i + 1,
                title: steps[i].displayName,
                state: i < currentIndex
                    ? _RailStepState.done
                    : i == currentIndex
                        ? _RailStepState.current
                        : _RailStepState.pending,
              ),
            // Back / Next directly under the "Your directive" list.
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: nextLoading ? null : onNext,
                icon: nextLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.arrow_forward, size: 18),
                label: Text(nextLabel),
                style: FilledButton.styleFrom(
                  iconAlignment: IconAlignment.end,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
            if (onBack != null) ...[
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Back'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum _RailStepState { done, current, pending }

class _RailStepRow extends StatelessWidget {
  final int index;
  final String title;
  final _RailStepState state;
  const _RailStepRow({
    required this.index,
    required this.title,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dotBg = switch (state) {
      _RailStepState.done => p.primary,
      _RailStepState.current => p.primary,
      _RailStepState.pending => Colors.transparent,
    };
    final dotBorder = switch (state) {
      _RailStepState.done => p.primary,
      _RailStepState.current => p.primary,
      _RailStepState.pending => p.border,
    };
    final dotFg = switch (state) {
      _RailStepState.done => p.onPrimary,
      _RailStepState.current => p.onPrimary,
      _RailStepState.pending => p.textMuted,
    };
    final titleColor = switch (state) {
      _RailStepState.done => p.textMuted,
      _RailStepState.current => p.text,
      _RailStepState.pending => p.textMuted,
    };
    final titleWeight = state == _RailStepState.current
        ? FontWeight.w700
        : FontWeight.w500;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: dotBg,
              border: Border.all(color: dotBorder, width: 1.5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: state == _RailStepState.done
                ? Icon(Icons.check, size: 14, color: dotFg)
                : Text(
                    '$index',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: dotFg,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13.5,
                fontWeight: titleWeight,
                color: titleColor,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
