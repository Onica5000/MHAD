import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/ai_check/ai_consistency_screen.dart';
import 'package:mhad/ui/assistant/assistant_screen.dart';
import 'package:mhad/ui/clinician/clinician_view_screen.dart';
import 'package:mhad/ui/crisis_plan/crisis_plan_screen.dart';
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
import 'package:mhad/ui/share/share_sheet_screen.dart';
import 'package:mhad/ui/agent_accept/agent_accept_screen.dart';
import 'package:mhad/ui/verify/wallet_verify_screen.dart';
import 'package:mhad/ui/mode_selection/mode_selection_screen.dart';
import 'package:mhad/ui/ulysses/ulysses_clause_screen.dart';
import 'package:mhad/ui/wizard/form_type_selection_screen.dart';
import 'package:mhad/ui/wizard/wizard_complete_screen.dart';
import 'package:mhad/ui/wizard/wizard_screen.dart';

abstract class AppRoutes {
  static const home = '/';
  static const disclaimer = '/disclaimer';
  static const modeSelection = '/mode';
  static const formTypeSelection = '/form-type';
  static const wizard = '/wizard/:directiveId';
  static const education = '/education';
  static const assistant = '/assistant';
  static const export = '/export/:directiveId';
  static const aiSetup = '/ai-setup';
  static const wizardComplete = '/wizard-complete/:directiveId';

  static String wizardCompleteRoute(int directiveId) =>
      '/wizard-complete/$directiveId';
  static const privacyPolicy = '/privacy-policy';
  static const settings = '/settings';

  static String wizardRoute(int directiveId) => '/wizard/$directiveId';
  static String exportRoute(int directiveId) => '/export/$directiveId';

  // Phase 4 — net-new screens per v2 prototype artboards. All reachable via
  // existing surfaces (Home Tools tile, Settings → My directive, etc.).
  static const accessibility = '/accessibility';
  static const facilitator = '/facilitator';
  static const legalToggle = '/legal-toggle/:directiveId';
  static const clinicianView = '/clinician/:directiveId';
  static const crisisPlan = '/crisis-plan/:directiveId';
  static const ulysses = '/ulysses/:directiveId';
  static const revocation = '/revoke/:directiveId';
  static const aiCheck = '/ai-check/:directiveId';
  static const pastDirective = '/past/:directiveId';
  static const shareSheet = '/share/:directiveId';
  // Batch 4 — wallet-QR verifier preview (what an EMS/clinician sees on
  // scan). The screen is read-only and reachable from the directive card
  // overflow menu so the principal can rehearse the receiver experience.
  static const walletVerify = '/verify/:directiveId';
  // Batch 5 — manual agent-acceptance log (m-agentaccept repurposed per
  // user decision: principal records that each agent verbally accepted
  // in person; no online flow).
  static const agentAccept = '/agent-accept/:directiveId';

  static String legalToggleRoute(int directiveId) =>
      '/legal-toggle/$directiveId';
  static String clinicianViewRoute(int directiveId) =>
      '/clinician/$directiveId';
  static String crisisPlanRoute(int directiveId) =>
      '/crisis-plan/$directiveId';
  static String ulyssesRoute(int directiveId) => '/ulysses/$directiveId';
  static String revocationRoute(int directiveId) => '/revoke/$directiveId';
  static String aiCheckRoute(int directiveId) => '/ai-check/$directiveId';
  static String pastDirectiveRoute(int directiveId) => '/past/$directiveId';
  static String shareSheetRoute(int directiveId) => '/share/$directiveId';
  static String walletVerifyRoute(int directiveId) => '/verify/$directiveId';
  static String agentAcceptRoute(int directiveId) =>
      '/agent-accept/$directiveId';
}

/// Initializes the global [appRouter] with the loaded service notifiers.
/// Must be called from [main()] before [runApp()].
void initRouter(
    DisclaimerNotifier disclaimerNotifier,
    PrivacyModeNotifier privacyModeNotifier) {
  appRouter = _buildRouter(disclaimerNotifier, privacyModeNotifier);
}

/// The single GoRouter instance used by [MhadApp].
/// Defaults to "disclaimer accepted, mode already selected" — correct for
/// widget tests that do not call [initRouter].
GoRouter appRouter = _buildRouter(
  DisclaimerNotifier(initialValue: true),
  _defaultPrivacyMode(),
);

PrivacyModeNotifier _defaultPrivacyMode() {
  final n = PrivacyModeNotifier();
  n.setPublicMode(); // tests always run in public mode
  return n;
}

GoRouter _buildRouter(
    DisclaimerNotifier disclaimer, PrivacyModeNotifier privacy) =>
    GoRouter(
      initialLocation: AppRoutes.home,
      refreshListenable: Listenable.merge([disclaimer, privacy]),
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
          path: AppRoutes.home,
          builder: (_, _) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoutes.formTypeSelection,
          builder: (_, _) => const FormTypeSelectionScreen(),
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
          path: AppRoutes.wizardComplete,
          builder: (context, state) {
            final directiveId =
                int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (directiveId == null) return const HomeScreen();
            return WizardCompleteScreen(directiveId: directiveId);
          },
        ),
        GoRoute(
          path: AppRoutes.aiSetup,
          builder: (_, _) => const AiSetupScreen(),
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
          path: AppRoutes.legalToggle,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return PlainLegalToggleScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.clinicianView,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return ClinicianViewScreen(directiveId: id);
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
          path: AppRoutes.shareSheet,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return ShareSheetScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.walletVerify,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return WalletVerifyScreen(directiveId: id);
          },
        ),
        GoRoute(
          path: AppRoutes.agentAccept,
          builder: (_, state) {
            final id = int.tryParse(state.pathParameters['directiveId'] ?? '');
            if (id == null) return const HomeScreen();
            return AgentAcceptScreen(directiveId: id);
          },
        ),
      ],
      errorBuilder: (_, _) => const HomeScreen(),
    );
