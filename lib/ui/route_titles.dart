import 'package:mhad/l10n/app_localizations.dart';
import 'package:mhad/ui/router.dart';

/// The page name shown in the browser tab for [location], or null for the
/// screens that use the plain app name (Home, the native-only mode screen).
///
/// ONE definition, read by the shell in both layouts. Keyed off the first
/// path segment so parameterised routes (`/wizard/5?step=2`) resolve too.
/// `test/unit/route_titles_test.dart` fails if any GoRoute lacks an entry.
String? routePageName(AppLocalizations l, String location) {
  final path = location.split('?').first;
  if (path == AppRoutes.home || path == AppRoutes.modeSelection) return null;
  final segments = path.split('/').where((s) => s.isNotEmpty);
  final first = segments.isEmpty ? '/' : '/${segments.first}';
  return switch (first) {
    AppRoutes.disclaimer => l.disclaimerBeforeYouBegin,
    AppRoutes.onboarding => l.tabPageWelcome,
    AppRoutes.resumeProgress => l.resumeTitle,
    AppRoutes.education => l.navLearn,
    AppRoutes.assistant => l.navAiAssistant,
    AppRoutes.aiSetup => l.tabPageAiSetup,
    AppRoutes.settings => l.navSettings,
    AppRoutes.accessibility => l.accessibilitySettingsAccessibility,
    AppRoutes.privacyPolicy => l.tabPagePrivacyPolicy,
    AppRoutes.permissions => l.settingsPrivacyPermissions,
    AppRoutes.facilitator => l.moreSheetGetHelp,
    AppRoutes.audioGuide => l.audioQTitle,
    AppRoutes.gettingReady => l.gettingReadyTitle,
    AppRoutes.admin => l.tabPageAdmin,
    '/wizard' => l.homeHeroYourMhad,
    '/sign' => l.tabPageSign,
    '/export' => l.navDownloadPrint,
    '/upload' => l.navAutofill,
    '/crisis-plan' => l.tabPageCrisisPlan,
    '/ulysses' => l.tabPageUlysses,
    '/side-effects' => l.tabPageSideEffects,
    '/revoke' => l.tabPageRevoke,
    '/findable' => l.tabPageFindable,
    '/ai-check' => l.tabPageAiCheck,
    '/past' => l.tabPagePast,
    _ => null,
  };
}

/// Full browser-tab title: "Learn · PA MHAD", or the app name on Home.
String routeTitle(AppLocalizations l, String location) {
  final page = routePageName(l, location);
  return page == null ? l.mainAppTitle : l.tabTitle(page);
}
