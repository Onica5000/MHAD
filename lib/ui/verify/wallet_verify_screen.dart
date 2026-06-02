import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:url_launcher/url_launcher.dart';

/// Wallet QR verifier view — what a paramedic / ER nurse sees when they
/// scan the QR code on the principal's wallet card. Mirrors prototype
/// `ScrVerify` (mobile-extra.jsx L1658-1777).
///
/// Surfaced from the directive card overflow menu as "Preview QR view"
/// so the principal can rehearse what the receiver experiences in a
/// crisis. The screen is read-only and intentionally dark-themed (`p.text`
/// as scaffold) so it does NOT look like the principal's home — it should
/// feel like a different surface.
///
/// Data sources (real, pulled from the repository):
///   - Principal: directive.fullName / dateOfBirth / city / state
///   - Agent: primary agent's fullName + cellPhone (else home/work)
///   - Treatment flags:
///       * Severe allergies (avoid) — DirectiveAllergies where severity='severe'
///       * ECT consent — DirectivePrefs.ectConsent
///       * Drug trials — DirectivePrefs.drugTrialConsent
///       * Restraints / additional — inferred from prefs.roomPreferences
///   - Signed / expires — directive.executionDate / expirationDate
class WalletVerifyScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const WalletVerifyScreen({required this.directiveId, super.key});

  @override
  ConsumerState<WalletVerifyScreen> createState() => _WalletVerifyScreenState();
}

class _WalletVerifyScreenState extends ConsumerState<WalletVerifyScreen> {
  Directive? _directive;
  Agent? _primaryAgent;
  DirectivePref? _prefs;
  List<DirectiveAllergy> _allergies = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(directiveRepositoryProvider);
    final d = await repo.getDirectiveById(widget.directiveId);
    final agents = await repo.getAgents(widget.directiveId);
    final prefs = await repo.getPreferences(widget.directiveId);
    final allergies = await repo.getAllergies(widget.directiveId);
    if (!mounted) return;
    setState(() {
      _directive = d;
      _primaryAgent =
          agents.where((a) => a.agentType == 'primary').firstOrNull;
      _prefs = prefs;
      _allergies = allergies;
      _loading = false;
    });
  }

  String _agentPhone(Agent? a) {
    if (a == null) return '';
    for (final p in [a.cellPhone, a.homePhone, a.workPhone]) {
      if (p.isNotEmpty) return p;
    }
    return '';
  }

  String _initials(String name) {
    final parts =
        name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '—';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Dark inverted scaffold — looks distinctly different from the
    // principal's phone. The success/warn/crisis tone colors switch to
    // their dark variants so legibility stays high.
    final scaffoldBg = p.text;
    final cardBg = p.scaffoldBackground;
    final fg = p.scaffoldBackground;

    if (_loading) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(p.scaffoldBackground),
          ),
        ),
      );
    }
    final d = _directive;
    if (d == null) {
      return Scaffold(
        backgroundColor: scaffoldBg,
        body: Center(
          child: Text(
            'Directive not found.',
            style: TextStyle(color: p.scaffoldBackground),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top brand row + close.
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'm',
                      style: TextStyle(
                        fontFamily: 'Instrument Serif',
                        fontFamilyFallback: const ['Georgia', 'serif'],
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                        color: p.text,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PA MHAD · FROM WALLET QR',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontFamilyFallback: const [
                              'Consolas',
                              'Menlo',
                              'Courier New',
                              'monospace',
                            ],
                            fontSize: 9.5,
                            letterSpacing: 0.6,
                            color: fg.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          'Provider view',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: fg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: fg, size: 22),
                    tooltip: 'Close preview',
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),

            // Status banner.
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
              child: _StatusBanner(directive: d),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 22),
                children: [
                  // Principal card.
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius:
                          BorderRadius.circular(DesignTokens.cardRadius),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Principal'),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: p.primary,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                _initials(d.fullName),
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: p.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d.fullName.isEmpty
                                        ? '— unnamed —'
                                        : d.fullName,
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: p.text,
                                    ),
                                  ),
                                  Text(
                                    _principalMeta(d),
                                    style: TextStyle(
                                      fontFamily: 'JetBrains Mono',
                                      fontFamilyFallback: const [
                                        'Consolas',
                                        'Menlo',
                                        'Courier New',
                                        'monospace',
                                      ],
                                      fontSize: 11,
                                      letterSpacing: 0.3,
                                      color: p.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_primaryAgent != null) ...[
                          const SizedBox(height: 14),
                          Divider(
                              color: p.border,
                              height: 1,
                              thickness: 1),
                          const SizedBox(height: 14),
                          const SectionLabel('Call first'),
                          const SizedBox(height: 6),
                          _CallFirstRow(
                            agent: _primaryAgent!,
                            phone: _agentPhone(_primaryAgent),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SectionLabel(
                    'Treatment flags',
                    style: TextStyle(color: fg),
                  ),
                  const SizedBox(height: 4),
                  ..._buildFlags(context, dark),
                  const SizedBox(height: 12),
                  // Open full directive button (placeholder — would launch
                  // the PDF preview / signed copy if available).
                  Material(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Opens the full PDF in a real scan.'),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.description_outlined,
                                size: 15, color: p.text),
                            const SizedBox(width: 8),
                            Text(
                              'Open full directive',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                                color: p.text,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'READ FROM THE QR ITSELF · NO INTERNET NEEDED · '
                    "SIGNED BY THE HOLDER'S DEVICE",
                    textAlign: TextAlign.center,
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
                      color: fg.withValues(alpha: 0.55),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _principalMeta(Directive d) {
    final parts = <String>[];
    if (d.dateOfBirth.isNotEmpty) parts.add('DOB ${d.dateOfBirth}');
    final loc = [
      if (d.city.isNotEmpty) d.city,
      if (d.state.isNotEmpty) d.state,
    ].join(', ');
    if (loc.isNotEmpty) parts.add(loc.toUpperCase());
    return parts.join(' · ');
  }

  /// Compose treatment-flag list from real preferences + allergies.
  List<Widget> _buildFlags(BuildContext context, bool dark) {
    final out = <Widget>[];

    // Severe allergies → crisis flags ("Avoid: X")
    for (final a in _allergies.where((x) => x.severity == 'severe')) {
      out.add(_FlagRow(
        tone: _FlagTone.crisis,
        title: 'Avoid: ${a.substance}',
        sub: a.reactions.isEmpty
            ? 'Severe — see directive § Allergies'
            : 'Severe — ${a.reactions}',
      ));
    }

    // ECT consent ≠ yes → caution flag (clinicians need to know)
    final ect = _prefs?.ectConsent ?? 'no';
    if (ect == 'no') {
      out.add(const _FlagRow(
        tone: _FlagTone.crisis,
        title: 'No ECT consent on file',
        sub: 'Cannot proceed without principal/agent',
      ));
    } else if (ect == 'agentDecides') {
      out.add(_FlagRow(
        tone: _FlagTone.warn,
        title: 'ECT requires agent consent',
        sub: _primaryAgent?.fullName.isNotEmpty == true
            ? _primaryAgent!.fullName
            : 'Primary agent',
      ));
    }

    // Drug trials → caution flag
    final dt = _prefs?.drugTrialConsent ?? 'no';
    if (dt == 'agentDecides') {
      out.add(_FlagRow(
        tone: _FlagTone.warn,
        title: 'Drug trials require agent consent',
        sub: _primaryAgent?.fullName.isNotEmpty == true
            ? _primaryAgent!.fullName
            : 'Primary agent',
      ));
    } else if (dt == 'no') {
      out.add(const _FlagRow(
        tone: _FlagTone.crisis,
        title: 'No drug trials',
        sub: 'Principal refuses experimental drug studies',
      ));
    }

    // Room preferences → ok-tone flag if user explicitly listed any
    final roomPref = _prefs?.roomPreferences ?? '';
    if (roomPref.isNotEmpty) {
      final chips = roomPref.split(',').take(2).join(', ');
      out.add(_FlagRow(
        tone: _FlagTone.ok,
        title: 'Care preferences on file',
        sub: chips,
      ));
    }

    if (out.isEmpty) {
      out.add(_FlagRow(
        tone: _FlagTone.ok,
        title: 'No flagged treatment restrictions',
        sub: 'See full directive for details',
      ));
    }
    // Spacing between flags.
    return List<Widget>.generate(
      out.length * 2 - 1,
      (i) => i.isEven
          ? out[i ~/ 2]
          : const SizedBox(height: 6),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final Directive directive;
  const _StatusBanner({required this.directive});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final dateFmt = DateFormat('MMM d, y');
    final signed = directive.executionDate == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(directive.executionDate!);
    final expires = directive.expirationDate == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!);
    final isActive = directive.status == 'complete' &&
        (expires == null || expires.isAfter(DateTime.now()));

    final bg = isActive
        ? (dark ? SemanticColors.successBgDark : SemanticColors.successBgLight)
        : (dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight);
    final border = isActive
        ? (dark
            ? SemanticColors.successBorderDark
            : SemanticColors.successBorderLight)
        : (dark
            ? SemanticColors.errorBorderDark
            : SemanticColors.errorBorderLight);
    final text = isActive
        ? (dark
            ? SemanticColors.successTextDark
            : SemanticColors.successTextLight)
        : (dark
            ? SemanticColors.errorTextDark
            : SemanticColors.errorTextLight);

    final dateLine = [
      if (signed != null) 'Signed ${dateFmt.format(signed)}',
      if (expires != null) 'expires ${dateFmt.format(expires)}',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: text,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              isActive ? Icons.check : Icons.priority_high,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isActive ? 'Signed & in effect' : 'Not active',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: text,
                  ),
                ),
                if (dateLine.isNotEmpty)
                  Text(
                    dateLine,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      color: text.withValues(alpha: 0.85),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'ACT 194',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontFamilyFallback: const [
                  'Consolas',
                  'Menlo',
                  'Courier New',
                  'monospace',
                ],
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
                color: text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallFirstRow extends StatelessWidget {
  final Agent agent;
  final String phone;
  const _CallFirstRow({required this.agent, required this.phone});

  Future<void> _dial(BuildContext context) async {
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No phone number on file for this agent.')),
      );
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: p.primaryTint,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: () => _dial(context),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: p.primary.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.phone, size: 16, color: p.onPrimary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      [
                        agent.fullName.isEmpty ? 'Primary agent' : agent.fullName,
                        if (agent.relationship.isNotEmpty)
                          agent.relationship,
                        'primary agent',
                      ].join(' — '),
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      phone.isEmpty ? '(no phone on file)' : phone,
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontFamilyFallback: const [
                          'Consolas',
                          'Menlo',
                          'Courier New',
                          'monospace',
                        ],
                        fontSize: 11.5,
                        letterSpacing: 0.4,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, size: 16, color: p.primary),
            ],
          ),
        ),
      ),
    );
  }
}

enum _FlagTone { crisis, warn, ok }

class _FlagRow extends StatelessWidget {
  final _FlagTone tone;
  final String title;
  final String sub;
  const _FlagRow({
    required this.tone,
    required this.title,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    Color bg, border, fg;
    switch (tone) {
      case _FlagTone.crisis:
        bg = dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight;
        border =
            dark ? SemanticColors.errorBorderDark : SemanticColors.errorBorderLight;
        fg = dark ? SemanticColors.errorTextDark : SemanticColors.errorTextLight;
        break;
      case _FlagTone.warn:
        bg = dark ? SemanticColors.warningBgDark : SemanticColors.warningBgLight;
        border = dark
            ? SemanticColors.warningBorderDark
            : SemanticColors.warningBorderLight;
        fg = dark ? SemanticColors.warningTextDark : SemanticColors.warningTextLight;
        break;
      case _FlagTone.ok:
        bg = dark ? SemanticColors.successBgDark : SemanticColors.successBgLight;
        border =
            dark ? SemanticColors.successBorderDark : SemanticColors.successBorderLight;
        fg = dark ? SemanticColors.successTextDark : SemanticColors.successTextLight;
        break;
    }
    final icon = tone == _FlagTone.ok ? Icons.check : Icons.warning_amber_rounded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                if (sub.isNotEmpty)
                  Text(
                    sub,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: fg.withValues(alpha: 0.85),
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
