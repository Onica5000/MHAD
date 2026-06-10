import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
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

  /// Build an RFC 6068 mailto: URI. Previously this used `Uri(scheme:
  /// 'mailto', query: ...)` which produces `mailto:?subject=...&to=...` —
  /// non-conformant because `to=` belongs in the path (`mailto:<addr>`),
  /// not the query, and many mail clients silently dropped it. We also
  /// stop auto-filling recipients from `agent.cellPhone` (the Agents
  /// table has no email column — phone numbers are not email addresses).
  /// The user picks recipients in their mail app.
  Future<void> _email(BuildContext context, List<Agent> agents) async {
    const subject = 'My Mental Health Advance Directive';
    const body = 'Attached when you open this in your mail app — generate '
        'the PDF in Export first and attach it manually.';
    final uri = Uri.parse(
      'mailto:?subject=${Uri.encodeComponent(subject)}'
      '&body=${Uri.encodeComponent(body)}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sms(BuildContext context) async {
    const body = 'I want to share my Mental Health Advance Directive with '
        "you. Let me know how you'd like to receive it.";
    // Properly percent-encode the body per RFC 5724 (sms: URI).
    final uri = Uri.parse('sms:?body=${Uri.encodeComponent(body)}');
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
      // Prototype ScrShare (mobile-extra.jsx L634-746) is rendered as a
      // bottom sheet over a blurred preview; we adapt that as a full
      // screen with CrisisBar at the top + an in-body 'Back' chevron
      // (no Material AppBar chrome).
      body: Column(children: [
        const CrisisTopBar(compact: true),
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(
          child: agentsAsync.when(
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
                  const SizedBox(height: 4),
                  // Editorial italic title — matches prototype ScrShare
                  // (mobile-extra.jsx L659): "Who needs a copy?" in
                  // 30pt serif italic
                  Text(
                    'Who needs a copy?',
                    style: TextStyle(
                      fontFamily: 'Instrument Serif',
                      fontFamilyFallback: const ['Georgia', 'serif'],
                      fontStyle: FontStyle.italic,
                      fontSize: 30,
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                      letterSpacing: -0.5,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Everything sends straight from your '
                    '${kIsWeb ? 'browser' : 'phone'} — your '
                    'mail or messages app, a QR, or print. Nothing goes '
                    'through our servers.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      color: p.textMuted,
                      height: 1.45,
                    ),
                  ),
                  // Suggested-recipients pill carousel — matches prototype
                  // L666-690. Surfaces the directive's stored agents with
                  // big avatar circles; a dashed "+" pill at the end for
                  // adding someone manually. Tapping an agent pre-fills
                  // the email recipient when Email is the next channel.
                  if (agents.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const SectionLabel('From your contacts & care team'),
                    Text(
                      'SESSION ONLY · NOT STORED',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontFamilyFallback: const [
                          'Consolas',
                          'Menlo',
                          'Courier New',
                          'monospace',
                        ],
                        fontSize: 10.5,
                        letterSpacing: 0.3,
                        color: p.textMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _SuggestedRecipients(
                      agents: agents,
                      onAdd: () => _email(context, agents),
                    ),
                  ],
                  const SizedBox(height: 18),
                  const SectionLabel('Send via'),
                  const SizedBox(height: 8),
                  // 4-column grid (Email · Text · QR · Print) per prototype
                  // L693-711. The existing 5th channel ("System share")
                  // keeps its tile beneath as a 5th below the grid since
                  // it remains functionally useful but isn't in the
                  // prototype's 4-up.
                  GridView.count(
                    crossAxisCount: 4,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 0.85,
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _systemShare,
                      icon: const Icon(Icons.ios_share, size: 18),
                      label: const Text('Other apps (system share)'),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const SectionLabel('They get'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: p.surface,
                      border: Border.all(color: p.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        _GetRow(
                            label: 'Full directive PDF',
                            value: '6 pages'),
                        _DashedDivider(),
                        _GetRow(
                            label: 'Wallet-card summary',
                            value: '1 page'),
                        _DashedDivider(),
                        _GetRow(
                            label: 'Emergency QR (works offline)',
                            value: 'Self-contained'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Privacy reassurance footer — matches prototype L732-738.
                  // Replaces the prior `InfoBanner` widget with the
                  // prototype's surface-toned lock-line.
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: p.surface,
                      border: Border.all(color: p.border),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 13, color: p.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'No tracking links, no expiry, no read '
                            "receipts — we can't see who you send it "
                            'to. The QR holds the summary itself, so '
                            'it works even with no signal.',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              color: p.textMuted,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
        ),
      ]),
    );
  }
}

/// Channel tile in the prototype's 4-up grid (Email · Text · QR · Print).
/// Matches `ScrShare` L701-711: surface-toned card with a 36pt rounded
/// primaryLight icon chip on top and a 11.5pt label beneath.
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
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: p.onPrimaryLight),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: p.text,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontally scrolling row of suggested-recipient pills. Each pill is
/// a 56pt avatar with the agent's initials + the agent's first name +
/// a monospace role label. The last tile is a dashed "+" "Add" affordance
/// that opens the email composer (mirrors the prototype's quick-add).
class _SuggestedRecipients extends StatelessWidget {
  final List<Agent> agents;
  final VoidCallback onAdd;
  const _SuggestedRecipients({required this.agents, required this.onAdd});

  static String _initials(String name) {
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  static String _firstName(String name) {
    final t = name.trim();
    if (t.isEmpty) return 'Agent';
    return t.split(RegExp(r'\s+')).first;
  }

  static String _roleFor(Agent a) {
    if (a.agentType == 'primary') return 'AGENT';
    if (a.agentType == 'alternate') return 'ALT';
    return a.agentType.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return SizedBox(
      height: 100,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 4),
        children: [
          for (final a in agents) ...[
            _RecipientPill(
              initials: _initials(a.fullName),
              name: _firstName(a.fullName),
              role: _roleFor(a),
              isPrimary: a.agentType == 'primary',
            ),
            const SizedBox(width: 10),
          ],
          // Trailing "+" Add pill — dashed border, neutral, opens the
          // email composer so the user can pick a recipient in their
          // mail app.
          GestureDetector(
            onTap: onAdd,
            child: SizedBox(
              width: 76,
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: p.surface,
                      border: Border.all(
                        color: p.border,
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.add, size: 22, color: p.textMuted),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Add',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: p.text,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipientPill extends StatelessWidget {
  final String initials;
  final String name;
  final String role;
  final bool isPrimary;
  const _RecipientPill({
    required this.initials,
    required this.name,
    required this.role,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return SizedBox(
      width: 76,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isPrimary ? p.primary : p.primaryLight,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: isPrimary ? p.onPrimary : p.onPrimaryLight,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: p.text,
              height: 1.1,
            ),
          ),
          Text(
            role,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontFamilyFallback: const [
                'Consolas',
                'Menlo',
                'Courier New',
                'monospace',
              ],
              fontSize: 9.5,
              letterSpacing: 0.5,
              color: p.textMuted,
            ),
          ),
        ],
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
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: p.text,
                )),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontFamilyFallback: const [
                'Consolas',
                'Menlo',
                'Courier New',
                'monospace',
              ],
              fontSize: 10.5,
              color: p.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom-painted dashed horizontal divider — the prototype uses
/// `border-bottom: 1px dashed border-color` between `_GetRow` items.
class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return CustomPaint(
      size: const Size(double.infinity, 1),
      painter: _DashedLinePainter(color: p.border),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    double x = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    while (x < size.width) {
      canvas.drawLine(Offset(x, 0), Offset(x + dashWidth, 0), paint);
      x += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
