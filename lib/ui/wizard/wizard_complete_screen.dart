import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
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
      // Prototype ScrDone (mobile.jsx L985-1076) has NO CrisisBar and NO
      // AppBar — it's a quieter celebration moment. The Material AppBar
      // (with home button) was removed 2026-06-03 to match. Users still
      // reach Home via the floating MhadBottomNav at the bottom; the
      // wallet-card / share / action affordances cover the post-export
      // primary flows.
      backgroundColor: p.scaffoldBackground,
      body: ListView(
        // 60px top matches prototype padding `60px 22px 32px` (L990) —
        // gives the editorial headline breathing room.
        padding: const EdgeInsets.fromLTRB(22, 60, 22, 32),
        children: [
          // Success check badge (artboard WebDone) — a 64px primaryTint
          // rounded square with a primary check, above the editorial header.
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: p.primaryTint,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Icon(Icons.check, size: 34, color: p.primary),
          ),
          const SizedBox(height: 16),
          // Editorial header: "● Packet ready" SectionLabel in primary color
          // (prototype L991) instead of the prior neutral "Complete" pill.
          SectionLabel(
            '● Packet ready',
            style: TextStyle(color: p.primary),
          ),
          const SizedBox(height: 4),
          // Headline matches prototype L992-997 verbatim: "One pen / away."
          // 60pt italic-serif, no primary accent on the second line (the
          // prototype puts the whole thing in p.text).
          Text(
            'One pen\naway.',
            style: TextStyle(
              fontFamily: 'Instrument Serif',
              fontFamilyFallback: const ['Georgia', 'serif'],
              fontStyle: FontStyle.italic,
              fontSize: 60,
              fontWeight: FontWeight.w400,
              letterSpacing: -1.5,
              height: 0.95,
              color: p.text,
            ),
          ),
          const SizedBox(height: 8),
          // Subtitle reworded to match prototype L998-1000 sentence shape:
          // "ready to print" + "becomes legally valid the moment you and
          // two witnesses sign it on paper" + "make sure the right people
          // have a copy."
          Text.rich(
            TextSpan(
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                color: p.textMuted,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'Your directive is ready to print. It '
                    'becomes '),
                TextSpan(
                  text:
                      'legally valid the moment you and two witnesses sign it '
                      'on paper',
                  style: TextStyle(
                    color: p.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text: ' — then make sure the right people have a copy.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Web is an ephemeral anonymous session — once the tab closes there
          // is nothing to come back to. Warn before they leave (artboard
          // WebDone). Native sessions persist, so this is web-only.
          if (kIsWeb)
            const InfoBanner(
              icon: Icons.download_outlined,
              variant: InfoBannerVariant.warning,
              text: 'Download before you close. Nothing is saved on our end — '
                  'once this tab closes, your answers are gone.',
            ),
          const SizedBox(height: 8),

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

          const SizedBox(height: 18),

          // FACTUAL_ANALYSIS C6 / F15+F18 — providers SHALL comply
          // (§ 5837) but may decline instructions against accepted
          // medical practice or when unavailable. Surfaced here for
          // accurate expectations after the signed directive is
          // distributed. Per user direction 2026-06-03 this is the only
          // post-share banner kept (5-step "what to do next" checklist,
          // export-backup banner, and trailing Export-PDF button were
          // dropped to match prototype ScrDone's leaner shape).
          const InfoBanner(
            icon: Icons.info_outline,
            text:
                'Providers must comply with your directive under PA Act 194 '
                '§ 5837. A provider may decline specific instructions only if '
                'they conflict with accepted medical practice, or when the '
                'provider is not physically available.',
            variant: InfoBannerVariant.info,
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

// _NextStep removed 2026-06-03 with the "What to do next" 5-step checklist
// (see build method comment). The post-sign guidance now lives on the
// prototype-matching Sign screen instead.
