import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wallet_card.dart';

/// "You did it." — shown after the user signs the directive. Mirrors the
/// prototype's [m-done] screen: editorial italic display, wallet-card
/// preview with QR, and a checklist for sharing with the right people.
class WizardCompleteScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const WizardCompleteScreen({required this.directiveId, super.key});

  @override
  ConsumerState<WizardCompleteScreen> createState() =>
      _WizardCompleteScreenState();
}

class _WizardCompleteScreenState extends ConsumerState<WizardCompleteScreen> {
  Directive? _directive;
  Agent? _primaryAgent;
  Agent? _alternateAgent;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(directiveRepositoryProvider);
    final d = await repo.getDirectiveById(widget.directiveId);
    final agents = await repo.getAgents(widget.directiveId);
    if (!mounted) return;
    setState(() {
      _directive = d;
      _primaryAgent =
          agents.where((a) => a.agentType == 'primary').firstOrNull;
      _alternateAgent =
          agents.where((a) => a.agentType == 'alternate').firstOrNull;
    });
  }

  String _expirationLabel() {
    final d = _directive;
    if (d == null) return '— · ——';
    final exp = d.expirationDate;
    if (exp == null) return '— · ——';
    final dt = DateTime.fromMillisecondsSinceEpoch(exp);
    return DateFormat('MM · yyyy').format(dt);
  }

  String _principalName() {
    final n = _directive?.fullName.trim() ?? '';
    return n.isEmpty ? 'Principal' : n;
  }

  String _agentPhone(Agent? a) {
    if (a == null) return '';
    final pieces = [a.cellPhone, a.homePhone, a.workPhone];
    return pieces.firstWhere((p) => p.isNotEmpty, orElse: () => '');
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.home_outlined),
          tooltip: 'Go to home',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
        children: [
          // Editorial header
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: p.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const SectionLabel('Complete'),
            ],
          ),
          const SizedBox(height: 6),
          EditorialHeading(
            textSpan: TextSpan(
              children: [
                const TextSpan(text: 'You did\n'),
                TextSpan(
                  text: 'it.',
                  style: TextStyle(color: p.primary),
                ),
              ],
            ),
            size: 64,
            height: 0.95,
            letterSpacing: -1.5,
          ),
          const SizedBox(height: 10),
          Text(
            // Updated per Decision 6 + v2 prototype: the directive becomes
            // legally valid only after you and two adult witnesses sign on
            // paper in original ink. Until then, the saved version is a
            // ready-to-print draft.
            'Your directive is ready to print. It becomes legally valid once '
            'you and two adult witnesses sign on paper in original ink.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.5,
              color: p.textMuted,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 26),

          // Wallet card preview
          const SectionLabel('Wallet card'),
          const SizedBox(height: 4),
          WalletCard(
            principalName: _principalName(),
            agentName: _primaryAgent?.fullName.isNotEmpty == true
                ? _primaryAgent!.fullName
                : null,
            agentPhone:
                _agentPhone(_primaryAgent).isEmpty ? null : _agentPhone(_primaryAgent),
            validThrough: _expirationLabel(),
            qrPayload: 'MHAD-${widget.directiveId}',
          ),

          const SizedBox(height: 20),

          // Sharing checklist — the right-side affordance always reads
          // "Send →" and the checkbox is hollow until the user actually
          // sends a copy via the share sheet (and ticks the row themselves).
          // Previously a "Sent ✓" tick auto-flipped on as soon as an agent
          // had a name, which lied about delivery state — we have no
          // send tracking, so the only honest state is "not yet sent."
          const SectionLabel('Share copies with'),
          const SizedBox(height: 4),
          _ShareRow(
            who: 'Your primary agent',
            detail: _primaryAgent?.fullName.isNotEmpty == true
                ? _primaryAgent!.fullName
                : 'Add agent details',
            onTap: () => context
                .push(AppRoutes.shareSheetRoute(widget.directiveId)),
          ),
          _ShareRow(
            who: 'Your alternate agent',
            detail: _alternateAgent?.fullName.isNotEmpty == true
                ? _alternateAgent!.fullName
                : 'Optional',
            onTap: () => context
                .push(AppRoutes.shareSheetRoute(widget.directiveId)),
          ),
          _ShareRow(
            who: 'Your primary care doctor',
            detail: 'Add provider',
            onTap: () => context
                .push(AppRoutes.shareSheetRoute(widget.directiveId)),
          ),
          _ShareRow(
            who: 'Your psychiatrist or therapist',
            detail: 'Add provider',
            onTap: () => context
                .push(AppRoutes.shareSheetRoute(widget.directiveId)),
          ),
          _ShareRow(
            who: 'A trusted family member',
            detail: 'Optional',
            onTap: () => context
                .push(AppRoutes.shareSheetRoute(widget.directiveId)),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                  label: const Text('PDF'),
                  onPressed: () => context.go(
                      AppRoutes.exportRoute(widget.directiveId)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.ios_share, size: 18),
                  label: const Text('Share'),
                  onPressed: () => context.go(
                      AppRoutes.exportRoute(widget.directiveId)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.tonalIcon(
                  icon: const Icon(Icons.account_balance_wallet_outlined,
                      size: 18),
                  label: const Text('Wallet'),
                  onPressed: () => context.go(
                      AppRoutes.exportRoute(widget.directiveId)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),
          const Divider(),
          const SizedBox(height: 16),

          // What to do next — keep the existing checklist content
          const SectionLabel('What to do next'),
          const SizedBox(height: 4),
          DesignCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                _NextStep(
                  number: '1',
                  title: 'Print your directive',
                  description: 'Export the PDF and print it on paper.',
                ),
                _NextStep(
                  number: '2',
                  title: 'Sign with ink',
                  description:
                      'Sign the printed directive with original ink '
                      'signatures in the presence of two adult witnesses.',
                ),
                _NextStep(
                  number: '3',
                  title: 'Have witnesses sign',
                  description:
                      'Both witnesses must sign the printed document. '
                      'They cannot be your agent, healthcare provider, or '
                      'facility employee (unless related).',
                ),
                _NextStep(
                  number: '4',
                  title: 'Distribute copies',
                  description:
                      'Give copies to your agent, doctor, hospital, family, '
                      'and anyone who may need it in a crisis.',
                ),
                _NextStep(
                  number: '5',
                  title: 'Make it findable in a crisis',
                  description:
                      'A directive only helps if the people treating you can '
                      'find it. Carry the wallet card on your person, photograph '
                      'your signed copy on your phone, and tell your agent, '
                      'closest contacts, and primary providers that the '
                      'directive exists and where the originals are. PA does '
                      'not maintain a state MHAD registry — custody by you, '
                      'your agent, and your providers is the only mechanism.',
                  isLast: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // FACTUAL_ANALYSIS C6 / F15+F18 — providers SHALL comply (§ 5837)
          // but may decline instructions against accepted medical practice or
          // when unavailable. Surfaced here for accurate expectations after
          // the signed directive is distributed.
          const InfoBanner(
            icon: Icons.info_outline,
            text:
                'Providers must comply with your directive under PA Act 194 '
                '§ 5837. A provider may decline specific instructions only if '
                'they conflict with accepted medical practice, or when the '
                'provider is not physically available.',
            variant: InfoBannerVariant.info,
          ),
          const SizedBox(height: 12),

          const InfoBanner(
            icon: Icons.backup_outlined,
            text:
                'Export and save a backup now. If you lose your device, your '
                'directive data cannot be recovered without an exported copy.',
            variant: InfoBannerVariant.error,
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Export PDF'),
              onPressed: () =>
                  context.go(AppRoutes.exportRoute(widget.directiveId)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  final String who;
  final String detail;

  /// Tap target — opens the share sheet so the user can actually deliver
  /// the directive. The row no longer carries a `done` flag: we have no
  /// way to verify delivery, so claiming "Sent ✓" was always a lie.
  final VoidCallback? onTap;

  const _ShareRow({
    required this.who,
    required this.detail,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final body = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(color: p.border, width: 1.5),
              borderRadius: BorderRadius.circular(6),
            ),
            // Empty checkbox — the user mentally ticks the row after they
            // confirm the recipient has the document. We intentionally do
            // NOT auto-fill this; we have no delivery confirmation channel.
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  who,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
                Text(
                  detail,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Send →',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: p.primary,
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: onTap == null
          ? body
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(10),
              child: body,
            ),
    );
  }
}

class _NextStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final bool isLast;

  const _NextStep({
    required this.number,
    required this.title,
    required this.description,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                fontFamily: 'DM Sans',
                color: p.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    color: p.textMuted,
                    height: 1.5,
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
