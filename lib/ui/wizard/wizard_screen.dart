import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart' show AssistantContext;
import 'package:mhad/ai/ai_context_builder.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/web_session_cache.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/design/step_dots.dart';
import 'package:mhad/ui/widgets/design/step_head.dart';
import 'package:mhad/ui/widgets/design/wizard_bottom_bar.dart';
import 'package:mhad/ui/wizard/wizard_ai_rail.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';
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
import 'package:mhad/utils/a11y_announce.dart';

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
  // Mirror of the current step, kept in sync from the URL (`?step=N`) on every
  // build. The URL is the source of truth (see build); this field just lets the
  // async navigation handlers read the current index without a context.
  int _stepIndex = 0;
  List<WizardStep>? _steps;
  bool _isSaving = false;
  // Transient "✓ Saved" hint after a successful autosave (UX audit B5) —
  // users otherwise get no feedback that navigation persisted their step.
  bool _showSavedHint = false;
  DateTime? _lastSavedFlash;
  Timer? _savedHintTimer;
  // Set once we've canonicalised the URL with a step param (or arrived with
  // one), so the resume-redirect only fires a single time.
  bool _resumed = false;

  /// Re-keyed after Smart Fill to force the step widget to rebuild with the
  /// freshly persisted values.
  final GlobalKey _stepKey = GlobalKey();

  /// Web only: keeps the crash-recovery cache's freshness timestamp current
  /// while the tab is open, so the 10-minute recovery window starts when the
  /// page is closed/crashes rather than at the last step save.
  Timer? _webCacheHeartbeat;

  @override
  void initState() {
    super.initState();
    // The beforeunload "leave site?" guard is now armed app-wide from
    // main.dart whenever any directive exists in the in-memory DB (UX
    // audit B12) — the wizard no longer owns it, so leaving the wizard
    // for Sign/Export/Assistant stays protected.
    if (kIsWeb) {
      _webCacheHeartbeat = Timer.periodic(
        const Duration(minutes: 1),
        (_) => WebSessionCache.touch(),
      );
    }
  }

  @override
  void dispose() {
    _webCacheHeartbeat?.cancel();
    _savedHintTimer?.cancel();
    super.dispose();
  }

  /// Flashes a transient "✓ Saved" hint (throttled to one per 4s so rapid
  /// step-hopping doesn't strobe) and politely announces it to screen
  /// readers. Called after a successful best-effort autosave.
  void _flashSavedHint() {
    final now = DateTime.now();
    if (_lastSavedFlash != null &&
        now.difference(_lastSavedFlash!) < const Duration(seconds: 4)) {
      return;
    }
    _lastSavedFlash = now;
    _savedHintTimer?.cancel();
    if (!mounted) return;
    announce(context, 'Progress saved');
    setState(() => _showSavedHint = true);
    _savedHintTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showSavedHint = false);
    });
  }

  Future<void> _persistStep(int index) async {
    await ref
        .read(directiveRepositoryProvider)
        .updateLastStepIndex(widget.directiveId, index);
    await _cacheForWebReload();
  }

  /// Navigate to [index] by changing the URL, so the move is a real history
  /// entry (browser/system Back returns here). Persistence runs in the
  /// background and never gates navigation.
  void _goToStep(int index) {
    context.go(AppRoutes.wizardStepRoute(widget.directiveId, index));
    unawaited(_persistStep(index));
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
                      'Unable to load this directive.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Don't dead-end: give the user a way to retry the load
                  // and a way home (2026-07-11 UX audit B1).
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => ref.invalidate(
                            directiveByIdProvider(widget.directiveId)),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                      FilledButton.icon(
                        onPressed: () => context.go(AppRoutes.home),
                        icon: const Icon(Icons.home_outlined),
                        label: const Text('Back to home'),
                      ),
                    ],
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

        // The current step is driven by the URL (`?step=N`) so browser/system
        // Back & Forward move between steps and a refresh resumes the same one.
        // When the param is absent (arriving via `/wizard/:id`), fall back to
        // the persisted resume index and canonicalise the URL once with a
        // history-neutral `replace` (so Back doesn't bounce on the bare URL).
        // Indices are clamped — the enum shrank from 15 to 9 in the redesign,
        // so saved/linked indices from older sessions may overshoot.
        final stepParam = int.tryParse(
            GoRouterState.of(context).uri.queryParameters['step'] ?? '');
        if (stepParam == null) {
          final resume = directive.lastStepIndex.clamp(0, steps.length - 1);
          _stepIndex = resume;
          if (!_resumed) {
            _resumed = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.replace(
                    AppRoutes.wizardStepRoute(widget.directiveId, resume));
              }
            });
          }
        } else {
          _resumed = true;
          _stepIndex = stepParam.clamp(0, steps.length - 1);
        }

        final currentStep = steps[_stepIndex];
        final isLastStep = _stepIndex == steps.length - 1;
        final p = Theme.of(context).mhadPalette;

        return PopScope(
          // Intercept native hardware/gesture back: step backwards through the
          // wizard rather than exiting. Only when already on the first step
          // does back fall through to the confirm-and-exit flow. (On web the
          // browser Back button traverses the per-step URL history directly,
          // so it lands on the previous step without going through here.)
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || _isSaving) return;
            if (_stepIndex > 0) {
              await _goBack();
            } else {
              await _saveAndExit(context);
            }
          },
          child: Scaffold(
            backgroundColor: p.scaffoldBackground,
            // Material AppBar removed 2026-06-03 — prototype ScrWizard*
            // screens use a thin in-body WizardHeader (Back + Save&exit)
            // sitting between the CrisisBar and the StepDots, not a
            // standard Material chrome. Snap-to-fill / upload-to-fill was
            // moved out of step 1 to the standalone `/upload/:id` page
            // (2026-06-13); the wizard now starts straight on the form.
            //
            // Narrow (mobile) Back/Continue navigation lives here in the
            // bottomNavigationBar slot — the Scaffold always lays it out at a
            // bounded screen width and pins it above the keyboard. On wide
            // screens navigation is under the step rail, so this is null.
            bottomNavigationBar:
                MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint
                    ? null
                    : WizardBottomBar(
                        primaryLabel: isLastStep ? 'Preview' : 'Continue',
                        primaryIcon: Icons.arrow_forward,
                        primaryLoading: _isSaving,
                        onPrimary: () => _goNext(context, isLastStep),
                        secondaryLabel: _stepIndex > 0 ? 'Back' : null,
                        onSecondary: _stepIndex > 0 ? _goBack : null,
                        showGradient: false,
                      ),
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
                // When the on-screen keyboard is up on a narrow layout, the
                // peeking "Need help?" bar just steals vertical space from the
                // field being edited — hide it while typing. Wide layouts (which
                // show the full rail, or the peeking bar in the 1000–1080 band)
                // are unaffected.
                final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
                final mainColumn = Column(
                  children: [
                    if (!shellActive)
                      Container(
                        color: p.scaffoldBackground,
                        padding: const EdgeInsets.only(top: 4),
                        child: StepDots(
                          current: _stepIndex + 1,
                          total: steps.length,
                          // Mobile parity with the desktop rail: tap a bar
                          // to jump to that step (UX audit B7).
                          onStepTap: _jumpToStep,
                        ),
                      ),
                    // The single exit-to-home affordance now lives in the
                    // top-right of the StepHead (level with the step numeral),
                    // so the step number rises to where the old "Exit" header
                    // row sat. "Back to previous step" stays on the bottom bar.
                    StepHead(
                      stepNumber: _stepIndex + 1,
                      totalSteps: steps.length,
                      title: currentStep.displayName,
                      subtitle: currentStep.subtitle,
                      onExit: () => _saveAndExit(context),
                    ),
                    Expanded(
                      // Stack so the transient "✓ Saved" chip (UX audit B5)
                      // overlays the step content without shifting layout.
                      child: Stack(
                        children: [
                          _buildStep(
                            currentStep,
                            directive.id,
                            formType,
                          ),
                          Positioned(
                            top: 4,
                            right: 16,
                            child: IgnorePointer(
                              child: AnimatedOpacity(
                                opacity: _showSavedHint ? 1 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: p.card,
                                    border: Border.all(color: p.border),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check,
                                          size: 14, color: p.textMuted),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Saved',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: p.textMuted,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Prototype `w-wiz-mobile`: the AI rail collapses to a slim
                    // peeking "Need help?" bar whenever the full 320px rail
                    // isn't shown — i.e. on mobile AND in the desktop band
                    // that's too narrow for the rail.
                    if (!showAiRail && !(keyboardOpen && !shellActive))
                      WizardAiBar(
                        onAsk: () => _openStepAi(
                          context,
                          formType,
                          currentStep.displayName,
                        ),
                      ),
                    // Narrow (mobile) keeps a bottom Back/Continue bar. With the
                    // desktop shell active the navigation lives under the step
                    // rail instead, so the Scaffold has no bottomNavigationBar.
                    // Narrow (mobile) Back/Continue navigation is the
                    // Scaffold.bottomNavigationBar (see below), not a child of
                    // this Column — a bar with a Spacer-driven Row can hit an
                    // infinite-width measurement inside a Column that also holds
                    // an Expanded, which made it fail to paint (the "no nav
                    // buttons on mobile" bug). The bottomNavigationBar slot is
                    // always laid out at a bounded screen width.
                  ],
                );
                if (!shellActive) return mainColumn;
                // FocusTraversalGroups (UX audit A8): Tab walks the step
                // rail, then the whole form column, then the AI rail — one
                // pane at a time in reading order, instead of an
                // unpredictable interleave across the three columns.
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FocusTraversalGroup(
                      child: _WideStepRail(
                        steps: steps,
                        currentIndex: _stepIndex,
                        onNext: () => _goNext(context, isLastStep),
                        onBack: _stepIndex > 0 ? _goBack : null,
                        nextLabel: isLastStep ? 'Preview' :'Next',
                        nextLoading: _isSaving,
                        onStepTap: _jumpToStep,
                      ),
                    ),
                    Container(width: 1, color: p.border),
                    Expanded(
                      child: FocusTraversalGroup(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: mainColumn,
                        ),
                      ),
                    ),
                    // Prototype `w-wizard` right rail (320px): a contextual AI
                    // helper beside the form. Only shown when the content area
                    // is wide enough; otherwise the peeking "Need help?" bar
                    // inside mainColumn takes its place.
                    if (showAiRail) ...[
                      Container(width: 1, color: p.border),
                      FocusTraversalGroup(
                        child: WizardAiRail(
                          formType: formType.name,
                          step: currentStep,
                          stepName: currentStep.displayName,
                          directiveId: directive.id,
                          onOpenFull: () => _openStepAi(
                            context,
                            formType,
                            currentStep.displayName,
                          ),
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

  // Snap-to-fill / upload-to-fill dispatch (`_handleSmartFillTarget`,
  // `_smartFill`) was removed 2026-06-13 along with the step-1 SmartFillCard;
  // that flow now lives on the standalone `/upload/:id` page, reached from
  // onboarding's "Upload a document to autofill". Ask the AI is on the bottom
  // nav; Save & exit is on the bottom bar (step 1) and PopScope (other steps).

  /// Opens the AI assistant pre-loaded with this step's context. Used by both
  /// the desktop right rail and the narrow peeking bar (prototype w-wizard /
  /// w-wiz-mobile).
  Future<void> _openStepAi(
      BuildContext context, FormType formType, String stepName) async {
    final filled = await buildAiFilledFields(
        ref.read(directiveRepositoryProvider), widget.directiveId);
    if (!context.mounted) return;
    unawaited(context.push(
      AppRoutes.assistant,
      extra: AssistantContext(
        formType: formType.name,
        stepName: stepName,
        filledFields: filled.isEmpty ? null : filled,
      ),
    ));
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
      // Allergies and the medications "Never want" list are kept as separate
      // sections — recording a Severe allergy here no longer cross-fills the
      // Avoid list (the user adds medications they refuse on the Meds step).
      WizardStep.allergies => AllergiesStep(
          key: _stepKey,
          directiveId: directiveId,
        ),
      WizardStep.proceduresResearch =>
        ProceduresResearchStep(key: _stepKey, directiveId: directiveId),
      WizardStep.anythingElse =>
        AdditionalInstructionsStep(key: _stepKey, directiveId: directiveId),
      WizardStep.reviewAndSign => ReviewAndSignStep(
          key: _stepKey,
          directiveId: directiveId,
          formType: formType,
          // Artboard WebReview: "Click any section to edit." Jump straight to
          // the relevant wizard step (always backward from Review, so no
          // forward validation is skipped).
          onEditStep: (target) {
            final idx = formType.steps.indexOf(target);
            if (idx >= 0) _goToStep(idx);
          },
        ),
    };
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
          // Only flash "Saved" when there's no competing "incomplete"
          // snackbar, so the two messages never contradict each other.
          if (stepValid && mounted && !isLastStep) _flashSavedHint();
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
                : 'Some fields are incomplete — you can fill them in before you finish.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      if (mounted) {
        if (isLastStep) {
          if (kIsWeb) unawaited(WebSessionCache.clear());
          if (context.mounted) {
            // Prototype split (2026-06-04): Review → Sign → Done.
            // The wizard's last step ends at Review; "Continue" hands
            // off to the dedicated SignScreen at /sign/:id rather than
            // jumping straight to the Done celebration.
            context.go(AppRoutes.signRoute(widget.directiveId));
          }
        } else {
          // Advance FIRST (URL change), then persist + web-cache in the
          // background. The resume-index write and crash-recovery snapshot are
          // best-effort — they must never gate "Continue" (a hung await here
          // was freezing navigation on web). _goToStep handles both.
          _goToStep(_stepIndex + 1);
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
        if (mounted) _flashSavedHint();
      } catch (e) {
        debugPrint('Auto-save on back failed: $e');
      }
    }
    if (mounted) {
      _goToStep(_stepIndex - 1);
    }
  }

  /// Jump straight to [target] (tapping a step in the "Your directive" rail).
  /// Best-effort saves the current step first — like [_goBack], the save never
  /// blocks navigation, so the user can move freely between steps.
  Future<void> _jumpToStep(int target) async {
    if (target == _stepIndex) return;
    FocusScope.of(context).unfocus();
    final state = _stepKey.currentState;
    if (state is WizardStepMixin) {
      try {
        await (state as WizardStepMixin).validateAndSave();
        if (mounted) _flashSavedHint();
      } catch (e) {
        debugPrint('Auto-save on step-jump failed: $e');
      }
    }
    if (mounted) {
      _goToStep(target);
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
                ? 'The web app does not save your progress permanently.\n\n'
                  'If you leave, close the tab, or the app crashes, your work '
                  'is kept on this device for 10 minutes so you can reopen and '
                  'recover it — then it’s erased. Export or print your document '
                  'to keep a copy.'
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
/// `w-wizard` left column (web-wizard-steps.jsx). Shows progress with
/// completed / current / pending dot states AND lets the user jump to any
/// step via [onStepTap] → `_jumpToStep` (which runs the current step's
/// best-effort validateAndSave first, so jumping can't silently drop
/// entered data). Continue / Back live directly under the step list.
class _WideStepRail extends StatelessWidget {
  final List<WizardStep> steps;
  final int currentIndex;
  // Navigation lives directly under the step list on wide screens (there is
  // no bottom bar in the desktop layout).
  final VoidCallback onNext;
  final VoidCallback? onBack;
  final String nextLabel;
  final bool nextLoading;
  // Jump straight to a step by tapping it in the "Your directive" list.
  final ValueChanged<int> onStepTap;
  const _WideStepRail({
    required this.steps,
    required this.currentIndex,
    required this.onNext,
    required this.onBack,
    required this.nextLabel,
    required this.nextLoading,
    required this.onStepTap,
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
                fontFamily: kMonoFamily,
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
                onTap: i == currentIndex ? null : () => onStepTap(i),
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
  final VoidCallback? onTap;
  const _RailStepRow({
    required this.index,
    required this.title,
    required this.state,
    this.onTap,
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
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
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
                      fontFamily: kMonoFamily,
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
                fontFamily: kSansFamily,
                fontSize: 13.5,
                fontWeight: titleWeight,
                color: titleColor,
                height: 1.2,
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }
}
