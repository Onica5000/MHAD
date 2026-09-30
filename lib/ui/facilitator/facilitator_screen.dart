import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/brand_motif.dart';
import 'package:mhad/ui/widgets/design/spot_illustration.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/utils/launch_utils.dart';
import 'package:mhad/utils/nav_utils.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: Column(children: [
        WizardHeader(
          backLabel: context.l10n.back,
          onBack: () => safeBack(context),
          actionLabel: '',
        ),
        Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          BrandMotif(
            padding: const EdgeInsets.fromLTRB(20, 16, 14, 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(context.l10n.facilitatorGetHelpEvidenceBased),
                      const SizedBox(height: 6),
                      EditorialHeading(
                        text: context.l10n.facilitatorYouDonTHaveTo,
                        size: 32,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${appData.fact('facilitatorCompletionStat')} '
                        'Pick the kind of support that fits today.',
                        style: TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 14,
                          color: p.textMuted,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SpotIllustration(art: SpotArt.shield, size: 72),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Pathway 1 — Referral to PA partners
          _PathwayCard(
            primary: true,
            tag: context.l10n.facilitatorPeerSpecialistAdvocateReferral,
            title: context.l10n.facilitatorTalkToSomeoneTrained,
            body:
                context.l10n.facilitatorPennsylvaniaPeerSpecialistsAndRights,
            meta: const ['~45 min', 'Free', 'PA-based'],
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

          const SizedBox(height: 18),

          // Pathway 2 — print + review in person
          _PathwayCard(
            tag: context.l10n.facilitatorSomeoneIAlreadyTrust,
            title: context.l10n.facilitatorPrintReviewItTogether,
            body:
                context.l10n.facilitatorPrintOrScreenShareYour,
            meta: const ['In person', 'You stay in control'],
          ),

          const SizedBox(height: 18),

          // Pathway 3 — email draft to clinician
          _PathwayCard(
            tag: context.l10n.facilitatorMyCareTeam,
            title: context.l10n.facilitatorEmailADraftToMy,
            body:
                context.l10n.facilitatorGenerateThePdfInExport,
            meta: const ['Email composer', 'Manual transcribe back'],
          ),

          const SizedBox(height: 18),
          InfoBanner(
            icon: Icons.info_outline,
            variant: InfoBannerVariant.info,
            text:
                context.l10n.facilitatorPreferToDoItYourself,
          ),
        ],
      )),
      ]),
    );
  }
}

class _PathwayCard extends StatelessWidget {
  final bool primary;
  final String tag;
  final String title;
  final String body;
  final List<String> meta;
  const _PathwayCard({
    this.primary = false,
    required this.tag,
    required this.title,
    required this.body,
    required this.meta,
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
            Text(tag,
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace'
                  ],
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: primary ? cs.onPrimary : cs.onSurfaceVariant,
                )),
            const SizedBox(height: 6),
            Text(title,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: primary ? cs.onPrimary : cs.onSurface,
                )),
            const SizedBox(height: 6),
            Text(body,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 14,
                  height: 1.45,
                  color: primary ? cs.onPrimary : cs.onSurfaceVariant,
                )),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final m in meta)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primary
                          ? cs.onPrimary.withValues(alpha: 0.15)
                          : cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
                    ),
                    child: Text(m,
                        style: TextStyle(
                          fontFamily: kMonoFamily,
                          fontFamilyFallback: const [
                            'Consolas',
                            'Menlo',
                            'Courier New',
                            'monospace'
                          ],
                          fontSize: 11,
                          letterSpacing: 0.4,
                          color: primary
                              ? cs.onPrimary
                              : cs.onSurfaceVariant,
                        )),
                  ),
              ],
            ),
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
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    Text(sub,
                        style: Theme.of(context).textTheme.bodySmall),
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
