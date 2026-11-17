import 'package:flutter/material.dart';
import 'package:mhad/ui/app_actions.dart';
import 'package:mhad/ui/widgets/design/primary_destinations.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';

/// True while the "More" sheet is on screen — guards against stacking multiple
/// copies when the bottom-nav "More" pill is tapped repeatedly. Mirrors the
/// crisis-sheet guard.
bool _moreSheetOpen = false;

/// Mobile-only "More" bottom sheet: crisis help (pinned first), then the
/// secondary destinations that the persistent [WebSidebar] shows on wide
/// screens but the four-item floating [MhadBottomNav] has no room for —
/// Autofill, Download & print, Get help, and Reset. This brings narrow-screen
/// navigation to parity with the desktop sidebar WITHOUT a hamburger drawer
/// (CLAUDE.md forbids one); it is the same modal-bottom-sheet pattern as
/// [showCrisisSheet].
///
/// [includePrimaryNav]: the wizard hides the bottom nav on phones, so its
/// step header's More opens this sheet WITH the four primary destinations
/// (Home · Learn · Ask · Settings) too — nothing is more than one tap away.
///
/// Navigation uses the global [appRouter] (not `context.go`) so it is safe
/// across the `await`s when a fresh directive must be created first.
Future<void> showMoreSheet(
  BuildContext context,
  WidgetRef ref, {
  bool includePrimaryNav = false,
}) async {
  if (_moreSheetOpen) return;
  _moreSheetOpen = true;
  try {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _MoreSheet(ref: ref, includePrimaryNav: includePrimaryNav),
    );
  } finally {
    _moreSheetOpen = false;
  }
}

class _MoreSheet extends StatelessWidget {
  final WidgetRef ref;
  final bool includePrimaryNav;
  const _MoreSheet({required this.ref, this.includePrimaryNav = false});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignTokens.sheetRadius)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: DesignTokens.pagePadding,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.border,
                    borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              EditorialHeading(text: context.l10n.navMore),
              const SizedBox(height: 4),
              Text(
                context.l10n.moreSheetEverythingElseYouCanDo,
                style: TextStyle(
                  fontSize: 14,
                  color: p.textMuted, height: MhadType.leadingParagraph,
                ),
              ),
              const SizedBox(height: 20),
              // Crisis help, pinned first — the mobile crisis affordance now
              // that the floating 988 button is gone. Opens the full
              // crisis-resources sheet (via the root navigator, since this
              // sheet is dismissed first).
              _MoreRow(
                icon: Icons.health_and_safety_outlined,
                title: context.l10n.homeToolsGridCrisisHelp,
                detail: context.l10n.moreSheetCallOrText98824,
                // Keyboard/screen-reader users land on the first action when
                // the sheet opens (UX audit A3).
                autofocus: true,
                onTap: () {
                  Navigator.of(context).pop();
                  openCrisisHelp();
                },
              ),
              if (includePrimaryNav) ...[
                _PrimaryNavRow(
                  destinations: primaryDestinations(
                    context,
                    aiReady:
                        ref.read(apiKeyProvider).value?.isNotEmpty ?? false,
                  ),
                  onGo: (route) {
                    Navigator.of(context).pop();
                    appRouter.go(route);
                  },
                ),
                const SizedBox(height: 12),
              ],
              _MoreRow(
                icon: Icons.document_scanner_outlined,
                title: context.l10n.navAutofill,
                detail: context.l10n.moreSheetUploadADocumentPhotoOr,
                onTap: () {
                  Navigator.of(context).pop();
                  openForDirective(ref, AppRoutes.uploadRoute);
                },
              ),
              _MoreRow(
                icon: Icons.print_outlined,
                title: context.l10n.navDownloadPrint,
                detail: context.l10n.moreSheetPreviewAndExportYourDirective,
                onTap: () {
                  Navigator.of(context).pop();
                  openForDirective(ref, AppRoutes.exportRoute);
                },
              ),
              _MoreRow(
                icon: Icons.support_agent_outlined,
                title: context.l10n.moreSheetGetHelp,
                detail: context.l10n.webSidebarPeerSupportAdvocatesReferrals,
                onTap: () {
                  Navigator.of(context).pop();
                  openGetHelp();
                },
              ),
              const SizedBox(height: 4),
              _MoreRow(
                icon: Icons.delete_sweep_outlined,
                title: context.l10n.moreSheetReset,
                detail: context.l10n.moreSheetEraseThisSessionAndStart,
                destructive: true,
                onTap: () {
                  Navigator.of(context).pop();
                  confirmAndResetSession(ref);
                },
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(context.l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Home · Learn · Ask · Settings as four equal tiles (one row, one height),
/// shown when the sheet stands in for the hidden bottom nav.
class _PrimaryNavRow extends StatelessWidget {
  final List<PrimaryDestination> destinations;
  final ValueChanged<String> onGo;
  const _PrimaryNavRow({required this.destinations, required this.onGo});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Row(
      children: [
        for (var i = 0; i < destinations.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              button: true,
              label: destinations[i].label,
              child: Material(
                color: p.surface,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: p.border),
                  borderRadius:
                      BorderRadius.circular(DesignTokens.iconTileRadius),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => onGo(destinations[i].route),
                  child: SizedBox(
                    height: 76,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ExcludeSemantics(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: p.primaryLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(destinations[i].icon,
                                      size: 18, color: p.onPrimaryLight),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  destinations[i].label,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: p.text,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MoreRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final bool destructive;
  final VoidCallback onTap;
  final bool autofocus;

  const _MoreRow({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
    this.destructive = false,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = destructive
        ? (dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight)
        : p.surface;
    final border = destructive
        ? (dark
            ? SemanticColors.errorBorderDark
            : SemanticColors.errorBorderLight)
        : p.border;
    final iconBg = destructive
        ? (dark
            ? SemanticColors.errorAccentDark
            : SemanticColors.errorAccentLight)
        : p.primaryLight;
    final iconFg = destructive ? Colors.white : p.onPrimaryLight;
    final titleColor = destructive
        ? (dark ? SemanticColors.errorTextDark : SemanticColors.errorTextLight)
        : p.text;
    final detailColor = destructive
        ? titleColor.withValues(alpha: 0.85)
        : p.textMuted;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        child: InkWell(
          onTap: onTap,
          autofocus: autofocus,
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        detail,
                        style: TextStyle(
                          fontSize: 12,
                          color: detailColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward, size: 16, color: detailColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
