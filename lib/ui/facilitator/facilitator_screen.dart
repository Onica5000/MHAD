import 'package:flutter/material.dart';
import 'package:mhad/ui/widgets/design/page_hero.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/utils/launch_utils.dart';
import 'package:mhad/utils/nav_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/ui/router.dart';

/// "Get help" / Facilitator mode (v2 prototype `m-facilitator`, v3 re-spec).
///
/// Per v3: under the no-server constraint, the prototype's three pathways
/// collapse to:
/// 1. **Referral** — phone + website list of PA partners (no booking).
/// 2. **Print + review with someone in person** (no real-time co-edit).
/// 3. **Email draft to a clinician** — uses the system mail composer with
///    the PDF attached.
///
/// The "20× completion uplift" stat is from Swanson et al. 2006 RCT — cite
/// when shown to the user.
class FacilitatorScreen extends StatelessWidget {
  const FacilitatorScreen({super.key});

  Future<void> _open(BuildContext context, String url) =>
      launchOrCopy(context, url, mode: LaunchMode.externalApplication);

  Future<void> _tel(BuildContext context, String number) => launchOrCopy(
    context,
    'tel:${number.replaceAll(RegExp(r'[^0-9+]'), '')}',
    copyValue: number,
    mode: LaunchMode.externalApplication,
  );

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrFacilitator (gap-analysis.jsx L1254-1338) has CrisisBar
      // + in-body Back chevron — the editorial "You don't have to do this
      // alone." 32pt headline owns the visual title.
      body: Column(
        children: [
          WizardHeader(
            backLabel: context.l10n.back,
            onBack: () => safeBack(context),
            actionLabel: '',
          ),
          Expanded(
            child: ListView(
              padding: DesignTokens.pagePadding,
              children: [
                PageHero(
                  art: AppArt.flowFacilitator,
                  eyebrow: context.l10n.facilitatorGetHelpEvidenceBased,
                  title: EditorialHeading(text: context.l10n.facilitatorYouDonTHaveTo),
                  lead: context.l10n.facilitatorPickTheKindOfSupport(
                      appData.fact('facilitatorCompletionStat')),
                ),
                const SizedBox(height: 20),

                // Pathway 1 — Referral to PA partners
                _PathwayCard(
                  primary: true,
                  tag: context.l10n.facilitatorPeerSpecialistAdvocateReferral,
                  title: context.l10n.facilitatorTalkToSomeoneTrained,
                  body: context
                      .l10n
                      .facilitatorPennsylvaniaPeerSpecialistsAndRights,
                  meta: [
                    context.l10n.facilitator45Min,
                    context.l10n.facilitatorFree,
                    context.l10n.facilitatorPaBased,
                  ],
                ),
                const SizedBox(height: 8),
                // Referral partners come from app_data.json (assets/data) so the
                // numbers/links can be updated without touching code.
                for (final partner in appData.referralPartners)
                  _ReferralRow(
                    label: partner.contact.name,
                    sub: partner.sub,
                    onCall: partner.contact.phone == null
                        ? null
                        : () => _tel(context, partner.contact.phone!),
                    onWeb: partner.contact.web == null
                        ? null
                        : () => _open(context, partner.contact.web!),
                  ),

                const SizedBox(height: 20),

                // Pathway 1b — guided session in the app (V4-L12): the AI assistant
                // leads the facilitation interview (reflection → crisis history →
                // who you trust → choices). Two ways in: for yourself, or as the
                // helper sitting with someone.
                _PathwayCard(
                  tag: context.l10n.facilitatorGuidedTag,
                  title: context.l10n.facilitatorGuidedTitle,
                  body: context.l10n.facilitatorGuidedBody,
                  meta: [
                    context.l10n.facilitatorGuidedMetaPace,
                    context.l10n.facilitatorGuidedMetaAi,
                  ],
                  actions: [
                    FilledButton(
                      onPressed: () => context.push(
                        AppRoutes.assistant,
                        extra: AssistantContext(
                          guidedSession: true,
                          openingPrompt:
                              context.l10n.facilitatorGuidedOpeningPrompt,
                        ),
                      ),
                      child: Text(context.l10n.facilitatorGuidedStart),
                    ),
                    OutlinedButton(
                      onPressed: () => context.push(
                        AppRoutes.assistant,
                        extra: AssistantContext(
                          guidedSession: true,
                          facilitatorMode: true,
                          openingPrompt:
                              context.l10n.facilitatorHelperOpeningPrompt,
                        ),
                      ),
                      child: Text(context.l10n.facilitatorHelperStart),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Pathway 2 — print + review in person
                _PathwayCard(
                  tag: context.l10n.facilitatorSomeoneIAlreadyTrust,
                  title: context.l10n.facilitatorPrintReviewItTogether,
                  body: context.l10n.facilitatorPrintOrScreenShareYour,
                  meta: [
                    context.l10n.facilitatorInPerson,
                    context.l10n.facilitatorYouStayInControl,
                  ],
                ),

                const SizedBox(height: 20),

                // Pathway 3 — email draft to clinician
                _PathwayCard(
                  tag: context.l10n.facilitatorMyCareTeam,
                  title: context.l10n.facilitatorEmailADraftToMy,
                  body: context.l10n.facilitatorGenerateThePdfInExport,
                  meta: [
                    context.l10n.facilitatorEmailComposer,
                    context.l10n.facilitatorManualTranscribeBack,
                  ],
                ),

                const SizedBox(height: 20),
                InfoBanner(
                  icon: Icons.info_outline,
                  variant: InfoBannerVariant.info,
                  text: context.l10n.facilitatorPreferToDoItYourself,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PathwayCard extends StatelessWidget {
  final bool primary;
  final String tag;
  final String title;
  final String body;
  final List<String> meta;

  /// Optional buttons under the card body.
  final List<Widget> actions;
  const _PathwayCard({
    this.primary = false,
    required this.tag,
    required this.title,
    required this.body,
    required this.meta,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: primary ? cs.primary : cs.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              tag,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700, letterSpacing: MhadType.trackingLabel,
                color: primary ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: primary ? cs.onPrimary : cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: TextStyle(
                fontSize: 14, height: MhadType.leadingParagraph,
                color: primary ? cs.onPrimary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in meta)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primary
                          ? cs.onPrimary.withValues(alpha: 0.15)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(
                        DesignTokens.chipRadius,
                      ),
                    ),
                    child: Text(
                      m,
                      style: TextStyle(
                        fontSize: 12, letterSpacing: MhadType.trackingLabel,
                        color: primary ? cs.onPrimary : cs.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(spacing: 10, runSpacing: 8, children: actions),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReferralRow extends StatelessWidget {
  final String label;
  final String sub;
  final VoidCallback? onCall;
  final VoidCallback? onWeb;
  const _ReferralRow({
    required this.label,
    required this.sub,
    required this.onCall,
    required this.onWeb,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 4, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(sub, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              if (onCall != null)
                IconButton(
                  icon: const Icon(Icons.phone_outlined),
                  tooltip: context.l10n.facilitatorCall,
                  onPressed: onCall,
                ),
              if (onWeb != null)
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: context.l10n.facilitatorOpenWebsite,
                  onPressed: onWeb,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
