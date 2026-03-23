import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/privacy_mode_service.dart';
import 'package:mhad/ui/assistant/assistant_screen.dart';
import 'package:mhad/ui/disclaimer/disclaimer_screen.dart';
import 'package:mhad/ui/education/education_screen.dart';
import 'package:mhad/ui/export/export_screen.dart';
import 'package:mhad/ui/home/home_screen.dart';
import 'package:mhad/ui/settings/ai_setup_screen.dart';
import 'package:mhad/ui/settings/privacy_policy_screen.dart';
import 'package:mhad/ui/mode_selection/mode_selection_screen.dart';
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

  static String wizardRoute(int directiveId) => '/wizard/$directiveId';
  static String exportRoute(int directiveId) => '/export/$directiveId';
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

        // Step 2 — Must select public/private mode each launch
        if (!privacy.isSelected) {
          return loc == AppRoutes.modeSelection ? null : AppRoutes.modeSelection;
        }
        // Mode selected: bounce away from mode-selection screen
        if (loc == AppRoutes.modeSelection) return AppRoutes.home;

        return null;
      },
      routes: [
        GoRoute(
          path: AppRoutes.disclaimer,
          builder: (_, _) => DisclaimerScreen(notifier: disclaimer),
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
      ],
      errorBuilder: (_, _) => const HomeScreen(),
    );
