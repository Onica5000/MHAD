import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart' show AssistantContext;
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
                // pattern; below the 1000px breakpoint we collapse to the
                // existing mobile-first column. The rail is read-only in
                // this first pass: jumping mid-wizard would skip
                // validation of intermediate steps.
                final isWide = constraints.maxWidth >= 1000;
                final mainColumn = Column(
                  children: [
                    const CrisisTopBar(compact: true),
                    // Prototype `WizardHeader` (ds.jsx L251-263): thin row
                    // with chevron+Back left and "Save & exit" right.
                    // Replaces the legacy Material AppBar. The Back action
                    // delegates to the same back-step path the bottom bar
                    // uses (validate, save, decrement); Save & exit runs
                    // the existing `_saveAndExit` flow.
                    WizardHeader(
                      onBack: _stepIndex > 0
                          ? () async {
                              FocusScope.of(context).unfocus();
                              final state = _stepKey.currentState;
                              if (state is WizardStepMixin) {
                                try {
                                  await (state as WizardStepMixin)
                                      .validateAndSave();
                                } catch (e) {
                                  debugPrint('Auto-save on back failed: $e');
                                }
                              }
                              if (mounted) {
                                setState(() => _stepIndex--);
                                await _persistStep();
                              }
                            }
                          : () => _saveAndExit(context),
                      backLabel: _stepIndex > 0 ? 'Back' : 'Exit',
                      onAction: () => _saveAndExit(context),
                    ),
                    if (!isWide)
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
                    // Prototype `w-wiz-mobile`: the desktop AI rail collapses to
                    // a slim peeking "Need help?" bar above the bottom bar when
                    // the rail can't fit. Only shown on narrow widths.
                    if (!isWide)
                      _WizardAiBar(
                        onAsk: () => _openStepAi(
                          context,
                          formType,
                          currentStep.displayName,
                        ),
                      ),
                  ],
                );
                if (!isWide) return mainColumn;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _WideStepRail(
                      steps: steps,
                      currentIndex: _stepIndex,
                    ),
                    Container(width: 1, color: p.border),
                    Expanded(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: mainColumn,
                      ),
                    ),
                    // Prototype `w-wizard` right rail (320px): a contextual AI
                    // helper beside the form. On narrow widths it collapses to
                    // the peeking "Need help?" bar above the bottom bar (see
                    // bottomNavigationBar).
                    Container(width: 1, color: p.border),
                    _WizardAiRail(
                      onAsk: () => _openStepAi(
                        context,
                        formType,
                        currentStep.displayName,
                      ),
                    ),
                  ],
                );
              },
            ),
            // Bottom action bar — always shows BOTH a left affordance and
            // the primary Continue / Finish CTA so the wizard never appears
            // to be navigation-less. On step 1 the left button is "Exit"
            // (save-and-return-to-home) instead of "Back to previous step"
            // since there is no previous step; on step 2+ it's "Back" and
            // decrements `_stepIndex` after auto-saving.
            bottomNavigationBar: WizardBottomBar(
              // Last step is now pure Review (prototype `ScrReview`,
              // mobile.jsx L802-878). The primary CTA hands off to
              // SignScreen — match the prototype's label "Generate
              // signing packet" instead of the old "Finish & export."
              primaryLabel:
                  isLastStep ? 'Generate signing packet' : 'Continue',
              primaryIcon:
                  isLastStep ? Icons.arrow_forward : Icons.arrow_forward,
              primaryLoading: _isSaving,
              onPrimary: () => _goNext(context, isLastStep),
              secondaryLabel: _stepIndex > 0 ? 'Back' : 'Exit',
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
                  // Step-1 Exit fires the same save-and-exit path the
                  // PopScope + appbar overflow expose, so step-1 users
                  // always have a visible way out of the wizard.
                  : () => _saveAndExit(context),
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

      await _cacheForWebReload();

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

/// Desktop step rail rendered at widths ≥1000px. Matches the prototype's
/// `w-wizard` left column (web-wizard-steps.jsx). Read-only in this pass:
/// it shows progress with completed / current / pending dot states but
/// does not let the user jump arbitrarily (which would skip per-step
/// validation). Navigation still happens via Continue / Back at the
/// bottom bar.
/// Desktop right rail (prototype `w-wizard`, 320px): a contextual AI helper
/// beside the form. Tapping opens the full assistant with this step's context.
class _WizardAiRail extends StatelessWidget {
  final VoidCallback onAsk;
  const _WizardAiRail({required this.onAsk});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      width: 320,
      color: p.card,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      child: SingleChildScrollView(
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
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Stuck on this step? Ask in plain language — the assistant knows '
              'what you’re filling in and explains the legal terms.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                height: 1.45,
                color: p.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAsk,
                icon: const Icon(Icons.chat_bubble_outline, size: 16),
                label: const Text('Ask about this step'),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.primaryTint,
                border: Border.all(color: p.primaryLight),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Not legal advice. The assistant helps you understand and '
                'express your wishes — it can’t make decisions for you.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11.5,
                  height: 1.4,
                  color: p.onPrimaryLight,
                ),
              ),
            ),
          ],
        ),
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
  const _WideStepRail({
    required this.steps,
    required this.currentIndex,
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
