import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
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

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    final ok = await canLaunchUrl(uri);
    if (!ok) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _tel(BuildContext context, String number) async {
    await _open(context, 'tel:${number.replaceAll(RegExp(r'[^0-9+]'), '')}');
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrFacilitator (gap-analysis.jsx L1254-1338) has CrisisBar
      // + in-body Back chevron — the editorial "You don't have to do this
      // alone." 32pt headline owns the visual title.
      body: Column(children: [
        const CrisisTopBar(compact: true),
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          const SectionLabel('Get help · evidence-based'),
          const SizedBox(height: 6),
          const EditorialHeading(
            text: "You don't have to do this alone.",
            size: 32,
          ),
          const SizedBox(height: 6),
          Text(
            'People who fill this out with help finish it about 20× more '
            'often (Swanson et al. 2006). Pick the kind of support that '
            'fits today.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: p.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),

          // Pathway 1 — Referral to PA partners
          _PathwayCard(
            primary: true,
            tag: '♥ Peer specialist / advocate referral',
            title: 'Talk to someone trained',
            body:
                'Pennsylvania peer specialists and rights advocates help '
                'walk you through the form. Free; no booking system inside '
                'this app — call or visit a partner below.',
            meta: const ['~45 min', 'Free', 'PA-based'],
          ),
          const SizedBox(height: 8),
          _ReferralRow(
            label: 'PA Mental Health Consumers\' Association',
            sub: 'Statewide peer support · 1-800-887-6422',
            onCall: () => _tel(context, '1-800-887-6422'),
            onWeb: () => _open(context, 'https://www.pmhca.org/'),
          ),
          _ReferralRow(
            label: 'Mental Health Association in PA',
            sub: 'Advocacy + education · 1-866-578-3659',
            onCall: () => _tel(context, '1-866-578-3659'),
            onWeb: () => _open(context, 'https://www.mhapa.org/'),
          ),
          _ReferralRow(
            label: 'PA Protection & Advocacy',
            sub: 'Your rights under Act 194 · 1-800-692-7443',
            onCall: () => _tel(context, '1-800-692-7443'),
            onWeb: () => _open(context, 'https://www.disabilityrightspa.org/'),
          ),
          _ReferralRow(
            label: 'National Resource Center on PAD',
            sub: 'State-specific PAD information',
            onCall: null,
            onWeb: () => _open(context, 'https://nrc-pad.org/states/pennsylvania-faq/'),
          ),

          const SizedBox(height: 18),

          // Pathway 2 — print + review in person
          _PathwayCard(
            tag: '👥 Someone I already trust',
            title: 'Print + review it together',
            body:
                'Print or screen-share your draft and walk through it with a '
                'friend, family member, or peer. They can\'t change anything '
                'in your app — that stays in your hands.',
            meta: const ['In person', 'You stay in control'],
          ),

          const SizedBox(height: 18),

          // Pathway 3 — email draft to clinician
          _PathwayCard(
            tag: '🧠 My care team',
            title: 'Email a draft to my clinician',
            body:
                'Generate the PDF in Export, then send it via your phone\'s '
                'email app. Ask your therapist or psychiatrist for comments. '
                'You\'ll transcribe their suggestions back into the form '
                'yourself — this app doesn\'t connect to their EHR.',
            meta: const ['Email composer', 'Manual transcribe back'],
          ),

          const SizedBox(height: 18),
          const InfoBanner(
            icon: Icons.info_outline,
            variant: InfoBannerVariant.info,
            text:
                'Prefer to do it yourself? That\'s fine — keep going from '
                'where you left off.',
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
                  fontFamily: 'JetBrains Mono',
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
                  fontFamily: 'DM Sans',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: primary ? cs.onPrimary : cs.onSurface,
                )),
            const SizedBox(height: 6),
            Text(body,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13.5,
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
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(m,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontFamilyFallback: const [
                            'Consolas',
                            'Menlo',
                            'Courier New',
                            'monospace'
                          ],
                          fontSize: 10.5,
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
                          fontFamily: 'DM Sans',
                          fontSize: 13.5,
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
                  tooltip: 'Call',
                  onPressed: onCall,
                ),
              if (onWeb != null)
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  tooltip: 'Open website',
                  onPressed: onWeb,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
