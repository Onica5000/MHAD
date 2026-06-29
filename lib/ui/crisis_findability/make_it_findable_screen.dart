import 'package:flutter/material.dart';
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
            backLabel: 'Back',
            onBack: () => Navigator.of(context).maybePop(),
            actionLabel: '',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                const SectionLabel('Crisis readiness'),
                const SizedBox(height: 6),
                const EditorialHeading(
                  text: 'Make it findable in a crisis.',
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  'A directive only helps if the people treating you can find it '
                  'when you cannot speak for yourself. Take a few minutes now to '
                  'put copies where they will be looked for.',
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 14,
                    height: 1.5,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 18),
                const SectionLabel('Do these now'),
                const SizedBox(height: 8),
                ActionRow(
                  icon: Icons.group_outlined,
                  tone: ActionRowTone.primary,
                  title: 'Share it with your agent and a trusted person',
                  subtitle:
                      'They should each have a copy before any crisis — not '
                      'only you.',
                  onTap: toExport,
                ),
                const SizedBox(height: 10),
                ActionRow(
                  icon: Icons.medical_services_outlined,
                  tone: ActionRowTone.primary,
                  title: 'Give a copy to your care team',
                  subtitle:
                      'Ask your psychiatrist, therapist, primary-care doctor, '
                      'and any facility to add it to your medical record.',
                  onTap: toExport,
                ),
                const SizedBox(height: 10),
                ActionRow(
                  icon: Icons.account_balance_wallet_outlined,
                  tone: ActionRowTone.primary,
                  title: 'Print and carry the wallet card',
                  subtitle:
                      'A pocket card that tells responders you have a directive '
                      'and how to reach your agent.',
                  onTap: toExport,
                ),
                const SizedBox(height: 16),
                const InfoBanner(
                  icon: Icons.place_outlined,
                  variant: InfoBannerVariant.info,
                  text:
                      'Pennsylvania has no statewide directive registry, so the '
                      'people in your life are the registry: make sure your '
                      'agent, a trusted person, and your providers all know you '
                      'have a directive and where to find it.',
                ),
                const SizedBox(height: 12),
                const InfoBanner(
                  icon: Icons.verified_outlined,
                  variant: InfoBannerVariant.success,
                  text:
                      'Under PA Act 194, a valid directive your care team can '
                      'find is meant to be followed. Findability is what makes '
                      'it work.',
                ),
                const SizedBox(height: 16),
                Text(
                  'This is general information about keeping your directive '
                  'accessible, not legal advice.',
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
