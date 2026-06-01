import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// In-app share sheet (v2 prototype `m-share`, v3 local-only re-spec).
///
/// Per v3: no verified links, no one-time codes, no read receipts, no
/// expiry. Channels: Email (system composer), Text (system SMS composer),
/// QR (encodes a local data payload), Print (system print dialog), or
/// the standard system share sheet for arbitrary apps.
class ShareSheetScreen extends ConsumerWidget {
  final int directiveId;
  const ShareSheetScreen({required this.directiveId, super.key});

  Future<void> _email(BuildContext context, List<Agent> agents) async {
    final to = agents
        .where((a) => a.cellPhone.isNotEmpty)
        .map((a) => a.cellPhone)
        .join(';');
    final uri = Uri(
      scheme: 'mailto',
      query: 'subject=My Mental Health Advance Directive&body=Attached when '
          'you open this in your mail app — generate the PDF in Export '
          'first and attach it manually.&to=$to',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sms(BuildContext context) async {
    final uri = Uri.parse(
        'sms:?body=I want to share my Mental Health Advance Directive with you. '
        "Let me know how you'd like to receive it.");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _systemShare() async {
    await Share.share(
      'My Mental Health Advance Directive — generated locally. No verified '
      'link, no server. Ask me how to receive the signed copy.',
      subject: 'PA MHAD',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final agentsAsync = ref.watch(directiveByIdProvider(directiveId));

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(title: const Text('Share')),
      body: agentsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load: $e')),
        data: (d) {
          if (d == null) return const Center(child: Text('Not found.'));
          return FutureBuilder<List<Agent>>(
            future:
                ref.read(directiveRepositoryProvider).getAgents(directiveId),
            builder: (ctx, snap) {
              final agents = snap.data ?? const <Agent>[];
              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
                children: [
                  const SectionLabel('Share my directive'),
                  const SizedBox(height: 6),
                  const EditorialHeading(
                    text: 'Who needs a copy?',
                    size: 30,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Local-only. We use your phone\'s mail / SMS apps to '
                    'send. No verified link, no read receipt, no expiry.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14,
                      color: p.textMuted,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _ChannelTile(
                        icon: Icons.mail_outline,
                        label: 'Email',
                        onTap: () => _email(context, agents),
                      ),
                      _ChannelTile(
                        icon: Icons.sms_outlined,
                        label: 'Text',
                        onTap: () => _sms(context),
                      ),
                      _ChannelTile(
                        icon: Icons.qr_code,
                        label: 'QR',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Wallet QR opens from Export → Wallet card.'),
                            ),
                          );
                        },
                      ),
                      _ChannelTile(
                        icon: Icons.ios_share,
                        label: 'System share',
                        onTap: _systemShare,
                      ),
                      _ChannelTile(
                        icon: Icons.print_outlined,
                        label: 'Print',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Open Export → Print to use your printer.'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const SectionLabel('They get'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _GetRow(
                              label: 'Full directive PDF',
                              value: 'You generate + attach manually'),
                          Divider(),
                          _GetRow(
                              label: 'Wallet-card summary',
                              value: 'From Done / Wallet'),
                          Divider(),
                          _GetRow(
                              label: 'Verification',
                              value: 'They call you to confirm — no server'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const InfoBanner(
                    icon: Icons.privacy_tip_outlined,
                    variant: InfoBannerVariant.info,
                    text:
                        'No verified links, one-time codes, expiry, or read '
                        'receipts. This app has no server.',
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ChannelTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ChannelTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 96,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(color: Theme.of(context).colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 26),
            const SizedBox(height: 6),
            Text(label,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

class _GetRow extends StatelessWidget {
  final String label;
  final String value;
  const _GetRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                )),
          ),
          Text(value,
              style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
