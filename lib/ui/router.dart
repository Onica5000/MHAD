import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/admin/admin_update_screen.dart';
import 'package:mhad/ui/ai_check/ai_consistency_screen.dart';
import 'package:mhad/ui/assistant/assistant_screen.dart';
import 'package:mhad/ui/audio_guide/audio_guide_screen.dart';
import 'package:mhad/ui/crisis_findability/make_it_findable_screen.dart';
import 'package:mhad/ui/crisis_plan/crisis_plan_screen.dart';
import 'package:mhad/ui/side_effects/side_effects_screen.dart';
import 'package:mhad/ui/disclaimer/disclaimer_screen.dart';
import 'package:mhad/ui/education/education_screen.dart';
import 'package:mhad/ui/export/export_screen.dart';
import 'package:mhad/ui/facilitator/facilitator_screen.dart';
import 'package:mhad/ui/home/home_screen.dart';
import 'package:mhad/ui/past/past_directive_detail_screen.dart';
import 'package:mhad/ui/revocation/revocation_screen.dart';
import 'package:mhad/ui/settings/accessibility_settings_screen.dart';
import 'package:mhad/ui/settings/ai_setup_screen.dart';
import 'package:mhad/ui/settings/settings_screen.dart';
import 'package:mhad/ui/settings/privacy_policy_screen.dart';
import 'package:mhad/ui/permissions/permissions_overview_screen.dart';
import 'package:mhad/ui/mode_selection/mode_selection_screen.dart';
import 'package:mhad/ui/onboarding/onboarding_screen.dart';
import 'package:mhad/ui/ulysses/ulysses_clause_screen.dart';
import 'package:mhad/ui/wizard/sign_screen.dart';
import 'package:mhad/ui/wizard/wizard_screen.dart';
import 'package:mhad/ui/wizard/widgets/document_pipeline_flow.dart';
import 'package:mhad/domain/model/directive.dart';

abstract class AppRoutes {
  static const home = '/';
  static const disclaimer = '/disclaimer';
  static const onboarding = '/onboarding';
  static const modeSelection = '/mode';
  static const wizard = '/wizard/:directiveId';
  static const education = '/education';
  static const assistant = '/assistant';
  static const export = '/export/:directiveId';
  static const aiSetup = '/ai-setup';
  static const audioGuide = '/audio-guide';
  // Post-wizard sign-on-paper screen — prototype ScrSign (mobile.jsx
  // L884-981). Sits between the wizard's Review step and the Done
  // celebration. Lands stamp executionDate so the directive flips from
  // draft to complete on arrival.
  static const sign = '/sign/:directiveId';
  // Standalone snap-to-fill / upload-to-fill page (prototype WebSnapFill).
  // Reached from onboarding's "Upload a document to autofill" — lets a user
  // autofill a freshly-created directive BEFORE entering the wizard.
  static const upload = '/upload/:directiveId';

  static String uploadRoute(int directiveId) => '/upload/$directiveId';

  static String signRoute(int directiveId) => '/sign/$directiveId';
  static const privacyPolicy = '/privacy-policy';
  static const settings = '/settings';

  static String wizardRoute(int directiveId) => '/wizard/$directiveId';

  /// A specific wizard step, encoded as a query param so the step is part of
  /// the URL/history: browser & system Back/Forward move between steps, and a
  /// refresh resumes the same step. The path stays `/wizard/:id`, so the
  /// WizardScreen state is preserved across step changes.
  static String wizardStepRoute(int directiveId, int step) =>
      '/wizard/$directiveId?step=$step';
  static String exportRoute(int directiveId) => '/export/$directiveId';

  // Phase 4 — net-new screens per v2 prototype artboards, reachable via
  // existing surfaces (Home Tools tile, wizard steps, row actions).
  // (The orphaned /legal-toggle screen was deleted 2026-07-11 — its
  // Plain⇄Legal feature lives in the export screen's "Document language"
  // segmented control.)
  static const accessibility = '/accessibility';
  static const facilitator = '/facilitator';
  static const crisisPlan = '/crisis-plan/:directiveId';
  static const ulysses = '/ulysses/:directiveId';
  static const sideEffects = '/side-effects/:directiveId';
  static const revocation = '/revoke/:directiveId';
  // "Make it findable in a crisis" checklist (crisis-readiness).
  static const findable = '/findable/:directiveId';
  static const aiCheck = '/ai-check/:directiveId';
  static const pastDirective = '/past/:directiveId';
  // Batch 6 — in-app privacy & permissions overview.
  static const permissions = '/permissions';
  // Hidden admin tool (AI-drafted data updates). Reached only via a hidden
  // long-press on Settings → About, behind a passphrase. Not in any nav.
  static const admin = '/admin';

  static String crisisPlanRoute(int directiveId) =>
      '/crisis-plan/$directiveId';
  static String ulyssesRoute(int directiveId) => '/ulysses/$directiveId';
  static String sideEffectsRoute(int directiveId) =>
      '/side-effects/$directiveId';
  static String revocationRoute(int directiveId) => '/revoke/$directiveId';
  static String findableRoute(int directiveId) => '/findable/$directiveId';
  static String aiCheckRoute(int directiveId) => '/ai-check/$directiveId';
  static String pastDirectiveRoute(int directiveId) => '/past/$directiveId';
}

/// Initializes the global [appRouter] with the loaded service notifiers.
/// Must be called from [main()] before [runApp()].
void initRouter(
    DisclaimerNotifier disclaimerNotifier,
    OnboardingNotifier onboardingNotifier,
    PrivacyModeNotifier privacyModeNotifier) {
  appRouter =
      _buildRouter(disclaimerNotifier, onboardingNotifier, privacyModeNotifier);
}

/// Root navigator key — lets the global crisis button (rendered above the
/// router in MhadApp's builder) open the crisis sheet through a real Navigator.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// The single GoRouter instance used by [MhadApp].
/// Defaults to "disclaimer accepted, intro seen, mode already selected" —
/// correct for widget tests that do not call [initRouter].
GoRouter appRouter = _buildRouter(
  DisclaimerNotifier(initialValue: true),
  OnboardingNotifier(initialValue: true),
  _defaultPrivacyMode(),
);

PrivacyModeNotifier _defaultPrivacyMode() {
  final n = PrivacyModeNotifier();
  n.setPublicMode(); // tests always run in public mode
  return n;
}

Widget _withDirectiveId(GoRouterState state, Widget Function(int) build) {
  final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
  if (id == null) return const HomeScreen();
  return build(id);
}

GoRouter _buildRouter(DisclaimerNotifier disclaimer,
        OnboardingNotifier onboarding, PrivacyModeNotifier privacy) =>
    GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: AppRoutes.home,
      refreshListenable: Listenable.merge([disclaimer, onboarding, privacy]),
      redirect: (context, state) {
        final loc = state.matchedLocation;

        // Step 1 — Must accept disclaimer first (shown once ever)
        if (!disclaimer.accepted) {
          return loc == AppRoutes.disclaimer ? null : AppRoutes.disclaimer;
        }
        // Disclaimer accepted: bounce away from disclaimer screen
        if (loc == AppRoutes.disclaimer) return AppRoutes.modeSelection;

        // Step 2 — Must select public/private mode each launch.
        // On web, auto-select public mode (private mode isn't available)
        // so the user goes straight to home and data persists on reload.
        if (!privacy.isSelected) {
          if (kIsWeb) {
            privacy.setPublicMode();
            return AppRoutes.home;
          }
          return loc == AppRoutes.modeSelection ? null : AppRoutes.modeSelection;
        }
        // Mode selected: bounce away from mode-selection screen
        if (loc == AppRoutes.modeSelection) return AppRoutes.home;

        // Step 3 — First-touch "In your words" intro. A real route gate (not
        // an overlay over Home) so nothing renders between the disclaimer and
        // the intro. The intro's CTAs navigate on explicitly, so we don't
        // force a bounce off /onboarding here once it's complete.
        if (!onboarding.completed && loc != AppRoutes.onboarding) {
          return AppRoutes.onboarding;
        }

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.disclaimer,
          builder: (_, _) => DisclaimerScreen.gate(notifier: disclaimer),
        ),
        GoRoute(
          path: AppRoutes.modeSelection,
          builder: (_, _) => ModeSelectionScreen(notifier: privacy),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (_, _) => OnboardingScreen(notifier: onboarding),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.wizard,
          builder: (_, state) =>
              _withDirectiveId(state, (id) => WizardScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.education,
          builder: (context, state) {
            // extra is either a bare List<String> of section ids (wizard Help,
            // default title) or a (ids, title) record for a labelled deep-link.
            final extra = state.extra;
            if (extra is ({List<String> ids, String title})) {
              return EducationScreen(
                  filterIds: extra.ids, filterTitle: extra.title);
            }
            return EducationScreen(filterIds: extra as List<String>?);
          },
        ),
        GoRoute(
          path: AppRoutes.assistant,
          builder: (context, state) {
            final assistantContext = state.extra as AssistantContext?;
            return AssistantScreen(context: assistantContext);
          },
        ),
        GoRoute(
          path: AppRoutes.export,
          builder: (_, state) =>
              _withDirectiveId(state, (id) => ExportScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.upload,
          builder: (_, state) => _withDirectiveId(
            state,
            (id) => PipelineScreen(
              directiveId: id,
              formType: FormType.combined.name,
              mode: PipelineMode.standalone,
            ),
          ),
        ),
        GoRoute(
          path: AppRoutes.sign,
          builder: (_, state) =>
              _withDirectiveId(state, (id) => SignScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.aiSetup,
          builder: (_, state) =>
              AiSetupScreen(returnRoute: state.uri.queryParameters['return']),
        ),
        GoRoute(
          path: AppRoutes.audioGuide,
          builder: (_, _) => const AudioGuideScreen(),
        ),
        GoRoute(
          path: AppRoutes.privacyPolicy,
          builder: (_, _) => const PrivacyPolicyScreen(),
        ),
        GoRoute(
          path: AppRoutes.settings,
          builder: (_, _) => const SettingsScreen(),
        ),

        // Phase 4 — net-new artboards from v2 prototype.
        GoRoute(
          path: AppRoutes.accessibility,
          builder: (_, _) => const AccessibilitySettingsScreen(),
        ),
        GoRoute(
          path: AppRoutes.facilitator,
          builder: (_, _) => const FacilitatorScreen(),
        ),
        GoRoute(
          path: AppRoutes.admin,
          builder: (_, _) => const AdminUpdateScreen(),
        ),
        GoRoute(
          path: AppRoutes.crisisPlan,
          builder: (_, state) =>
              _withDirectiveId(state, (id) => CrisisPlanScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.sideEffects,
          builder: (_, state) =>
              _withDirectiveId(state, (id) => SideEffectsScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.ulysses,
          builder: (_, state) => _withDirectiveId(
              state, (id) => UlyssesClauseScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.revocation,
          builder: (_, state) =>
              _withDirectiveId(state, (id) => RevocationScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.findable,
          builder: (_, state) => _withDirectiveId(
              state, (id) => MakeItFindableScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.aiCheck,
          builder: (_, state) => _withDirectiveId(
              state, (id) => AiConsistencyScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.pastDirective,
          builder: (_, state) => _withDirectiveId(
              state, (id) => PastDirectiveDetailScreen(directiveId: id)),
        ),
        GoRoute(
          path: AppRoutes.permissions,
          builder: (_, _) => const PermissionsOverviewScreen(),
        ),
      ],
      errorBuilder: (_, _) => const HomeScreen(),
    );
