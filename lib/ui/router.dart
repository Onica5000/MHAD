import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/onboarding_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/admin/admin_update_screen.dart';
import 'package:mhad/ui/ai_check/ai_consistency_screen.dart';
import 'package:mhad/ui/assistant/assistant_screen.dart';
import 'package:mhad/ui/crisis_plan/crisis_plan_screen.dart';
import 'package:mhad/ui/side_effects/side_effects_screen.dart';
import 'package:mhad/ui/disclaimer/disclaimer_screen.dart';
import 'package:mhad/ui/education/education_screen.dart';
import 'package:mhad/ui/export/export_screen.dart';
import 'package:mhad/ui/facilitator/facilitator_screen.dart';
import 'package:mhad/ui/home/home_screen.dart';
import 'package:mhad/ui/legal_toggle/plain_legal_toggle_screen.dart';
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
  static String exportRoute(int directiveId) => '/export/$directiveId';

  // Phase 4 — net-new screens per v2 prototype artboards. All reachable via
  // existing surfaces (Home Tools tile, Settings → My directive, etc.).
  static const accessibility = '/accessibility';
  static const facilitator = '/facilitator';
  static const legalToggle = '/legal-toggle/:directiveId';
  static const crisisPlan = '/crisis-plan/:directiveId';
  static const ulysses = '/ulysses/:directiveId';
  static const sideEffects = '/side-effects/:directiveId';
  static const revocation = '/revoke/:directiveId';
  static const aiCheck = '/ai-check/:directiveId';
  static const pastDirective = '/past/:directiveId';
  // Batch 6 — in-app privacy & permissions overview.
  static const permissions = '/permissions';
  // Hidden admin tool (AI-drafted data updates). Reached only via a hidden
  // long-press on Settings → About, behind a passphrase. Not in any nav.
  static const admin = '/admin';

  static String legalToggleRoute(int directiveId) =>
      '/legal-toggle/$directiveId';
  static String crisisPlanRoute(int directiveId) =>
      '/crisis-plan/$directiveId';
  static String ulyssesRoute(int directiveId) => '/ulysses/$directiveId';
  static String sideEffectsRoute(int directiveId) =>
      '/side-effects/$directiveId';
  static String revocationRoute(int directiveId) => '/revoke/$directiveId';
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

GoRouter _buildRouter(DisclaimerNotifier disclaimer,
        OnboardingNotifier onboarding, PrivacyModeNotifier privacy) =>
    GoRouter(
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
          builder: (context, state) {
            final directiveId =
                int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (directiveId == null) return const HomeScreen();
            return WizardScreen(directiveId: directiveId);
          },
        ),
        GoRoute(
          path: AppRoutes.education,
          builder: (context, state) {
            final filterIds = state.extra as List<String>?;
            return EducationScreen(filterIds: filterIds);
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
          builder: (context, state) {
            final directiveId =
                int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (directiveId == null) return const HomeScreen();
            return ExportScreen(directiveId: directiveId);
          },
        ),
        GoRoute(
          path: AppRoutes.upload,
          builder: (context, state) {
            final directiveId =
                int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (directiveId == null) return const HomeScreen();
            return PipelineScreen(
              directiveId: directiveId,
              formType: FormType.combined.name,
              mode: PipelineMode.standalone,
            );
          },
        ),
        GoRoute(
          path: AppRoutes.sign,
          builder: (context, state) {
            final directiveId =
                int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (directiveId == null) return const HomeScreen();
            return SignScreen(directiveId: directiveId);
          },
        ),
        GoRoute(
          path: AppRoutes.aiSetup,
          builder: (_, state) =>
              AiSetupScreen(returnRoute: state.uri.queryParameters['return']),
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
          path: AppRoutes.legalToggle,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return PlainLegalToggleScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.crisisPlan,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return CrisisPlanScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.sideEffects,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return SideEffectsScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.ulysses,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return UlyssesClauseScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.revocation,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return RevocationScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.aiCheck,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return AiConsistencyScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.pastDirective,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return PastDirectiveDetailScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.permissions,
          builder: (_, _) => const PermissionsOverviewScreen(),
        ),
      ],
      errorBuilder: (_, _) => const HomeScreen(),
    );
