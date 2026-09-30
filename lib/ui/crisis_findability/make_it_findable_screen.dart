import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/action_row.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

/// "Make it findable in a crisis" — addresses the #1 evidence-based failure
/// mode for psychiatric advance directives (the "transmitter/receiver problem":
/// a directive that exists but isn't reachable by the care team in a crisis is
/// inert). A short, actionable checklist that ties together the app's existing
/// share / export / wallet-card flows plus PA-specific guidance.
///
/// Reached from Home's tools grid (`/findable/:directiveId`). The action rows
/// route to the export hub, where share, print, and the wallet card live.
class MakeItFindableScreen extends ConsumerWidget {
  final int directiveId;
  const MakeItFindableScreen({required this.directiveId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    void toExport() => context.push(AppRoutes.exportRoute(directiveId));

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: Column(
        children: [
          WizardHeader(
            backLabel: context.l10n.back,
            onBack: () => Navigator.of(context).maybePop(),
            actionLabel: '',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                SectionLabel(context.l10n.makeItFindableCrisisReadiness),
                const SizedBox(height: 6),
                EditorialHeading(
                  text: context.l10n.makeItFindableMakeItFindableInA,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.makeItFindableADirectiveOnlyHelpsIf,
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 14,
                    height: 1.5,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                SectionLabel(context.l10n.makeItFindableDoTheseNow),
                const SizedBox(height: 8),
                ActionRow(
                  icon: Icons.group_outlined,
                  tone: ActionRowTone.primary,
                  title: context.l10n.makeItFindableShareItWithYourAgent,
                  subtitle:
                      context.l10n.makeItFindableTheyShouldEachHaveA,
                  onTap: toExport,
                ),
                const SizedBox(height: 10),
                ActionRow(
                  icon: Icons.medical_services_outlined,
                  tone: ActionRowTone.primary,
                  title: context.l10n.makeItFindableGiveACopyToYour,
                  subtitle:
                      context.l10n.makeItFindableAskYourPsychiatristTherapistPrimary,
                  onTap: toExport,
                ),
                const SizedBox(height: 10),
                ActionRow(
                  icon: Icons.account_balance_wallet_outlined,
                  tone: ActionRowTone.primary,
                  title: context.l10n.makeItFindablePrintAndCarryTheWallet,
                  subtitle:
                      context.l10n.makeItFindableAPocketCardThatTells,
                  onTap: toExport,
                ),
                const SizedBox(height: 16),
                InfoBanner(
                  icon: Icons.place_outlined,
                  variant: InfoBannerVariant.info,
                  text:
                      context.l10n.makeItFindablePennsylvaniaHasNoStatewideDirective,
                ),
                const SizedBox(height: 12),
                InfoBanner(
                  icon: Icons.verified_outlined,
                  variant: InfoBannerVariant.success,
                  text:
                      context.l10n.makeItFindableUnderPaAct194A,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.makeItFindableThisIsGeneralInformationAbout,
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    height: 1.45,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
