import 'package:flutter/material.dart';
import 'package:mhad/data/app_data/app_data.dart' show appData;
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/router.dart';

/// One of the app's four primary destinations.
class PrimaryDestination {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// Where a tap goes.
  final String route;

  /// Locations on which this destination is the current one.
  final Set<String> activeOn;

  const PrimaryDestination({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.activeOn,
  });

  bool isActiveOn(String location) => activeOn.contains(location);
}

/// The four primary destinations, in order: Home · Learn · Ask · Settings.
///
/// ONE definition, read by the phone bottom nav ([MhadBottomNav]) and by the
/// More sheet when the nav is hidden (the wizard), so the two can never
/// drift apart. Ask goes straight to the assistant when an AI key is set
/// ([aiReady]), otherwise to AI setup.
List<PrimaryDestination> primaryDestinations(
  BuildContext context, {
  required bool aiReady,
}) =>
    [
      PrimaryDestination(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: context.l10n.home,
        route: AppRoutes.home,
        activeOn: const {AppRoutes.home},
      ),
      PrimaryDestination(
        icon: Icons.menu_book_outlined,
        activeIcon: Icons.menu_book,
        label: context.l10n.navLearn,
        route: AppRoutes.education,
        activeOn: const {AppRoutes.education},
      ),
      PrimaryDestination(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome,
        label: context.l10n.navAsk,
        route: (aiReady || !appData.ai.apiModeVisible)
            ? AppRoutes.assistant
            : AppRoutes.aiSetup,
        activeOn: const {AppRoutes.assistant, AppRoutes.aiSetup},
      ),
      PrimaryDestination(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: context.l10n.navSettings,
        route: AppRoutes.settings,
        activeOn: const {AppRoutes.settings},
      ),
    ];
