import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_988_pill.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';

/// First-launch legal disclaimer + read-only Settings variant.
///
/// Gate layout — matches the Claude Design web `WebDisclaimer`
/// (web-flow-screens.jsx) per user direction (2026-06-12):
///   * SectionLabel "Before you begin"
///   * Italic serif header "A few things to understand."
///   * Muted lead paragraph (Act 194 framing)
///   * Four editorial icon cards: not-legal-advice, signed-on-paper,
///     nothing-saved (kIsWeb-adaptive), stop-or-change
///   * Tinted acknowledgment row — "I'm 18 or older, and I understand and
///     want to continue." (the 18+ requirement, which the artboard omits, is
///     folded in here)
///   * Footer row: "Read full disclaimer" ghost link + primary "Get started".
///
/// The single check affirms both age (18+) and acknowledgment. The full
/// 8-section legal text (two-year validity, witness eligibility, PA P&A /
/// attorney resources, etc.) is reachable via "Read full disclaimer", which
/// opens the accordion in a modal sheet.
///
/// Read-only variant (Settings → Legal) keeps the 8-section accordion
/// as a scrollable list so users can browse the full disclosure.
class DisclaimerScreen extends StatefulWidget {
  final DisclaimerNotifier? _notifier;
  final bool _readOnly;

  /// First-launch gate variant — user ticks one checkbox before
  /// they can tap Continue.
  const DisclaimerScreen.gate({
    required DisclaimerNotifier notifier,
    super.key,
  })  : _notifier = notifier,
        _readOnly = false;

  /// Read-only variant — the 8-section accordion with an AppBar back
  /// button instead of the accept footer. Used from Settings → Legal.
  const DisclaimerScreen.readOnly({super.key})
      : _notifier = null,
        _readOnly = true;

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  bool _accepted = false;

  Future<void> _accept() async {
    if (widget._notifier == null) return;
    await widget._notifier!.accept();
    await NotificationService.instance.requestPermission();
  }

  void _openFullLegal() {
    final p = Theme.of(context).mhadPalette;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: p.scaffoldBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, controller) {
            return _FullLegalSheet(scrollController: controller);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final readOnly = widget._readOnly;

    if (readOnly) {
      return _ReadOnlyAccordion(palette: p);
    }
    return _GateLayout(
      palette: p,
      accepted: _accepted,
      onAcceptToggle: () => setState(() => _accepted = !_accepted),
      onContinue: _accepted ? _accept : null,
      onOpenFull: _openFullLegal,
    );
  }
}

// ─── Gate layout (prototype-faithful) ───────────────────────────────────

class _GateLayout extends StatelessWidget {
  final MhadPalette palette;
  final bool accepted;
  final VoidCallback onAcceptToggle;
  final VoidCallback? onContinue;
  final VoidCallback onOpenFull;

  const _GateLayout({
    required this.palette,
    required this.accepted,
    required this.onAcceptToggle,
    required this.onContinue,
    required this.onOpenFull,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: palette.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionLabel('Before you begin', palette: palette),
                  const SizedBox(height: 6),
                  Text(
                    'A few things to understand.',
                    style: TextStyle(
                      fontFamily: 'Instrument Serif',
                      fontFamilyFallback: const ['Georgia', 'serif'],
                      fontStyle: FontStyle.italic,
                      fontSize: 36,
                      fontWeight: FontWeight.w400,
                      height: 1.05,
                      letterSpacing: -0.5,
                      color: palette.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'This tool helps you write a Pennsylvania Mental Health '
                    'Advance Directive under Act 194. Please read these '
                    'before continuing.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13.5,
                      color: palette.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      // Card set mirrors the Claude Design web `WebDisclaimer`.
                      // "Not legal advice" is now the first card (it replaced
                      // the old warning banner); the 18+ requirement is
                      // affirmed in the acknowledgment row below; the two-year
                      // validity and the PA P&A / attorney resources live in
                      // the full legal sections ("Read full disclaimer").
                      children: [
                        const _DisclaimerCard(
                          icon: Icons.shield_outlined,
                          title: 'This is not legal advice',
                          body:
                              'We give plain-language help, not legal counsel. '
                              'For complex situations, talk to an attorney or '
                              'advocate.',
                        ),
                        const SizedBox(height: 10),
                        const _DisclaimerCard(
                          icon: Icons.draw_outlined,
                          title:
                              'It becomes valid only when signed on paper',
                          body:
                              'PA law requires your signature plus two '
                              'qualified adult witnesses, in ink, in person. '
                              'The app cannot sign for you.',
                        ),
                        const SizedBox(height: 10),
                        _DisclaimerCard(
                          icon: Icons.lock_outline,
                          title: 'Nothing is saved or sent to us',
                          // Accurate on each platform: web is in-memory only;
                          // native Private Mode stores encrypted on-device.
                          body: kIsWeb
                              ? 'You work anonymously in this browser tab — no '
                                  'account, no cloud, no tracking. Download '
                                  'your PDF before you close it, or your '
                                  'answers are gone.'
                              : 'No account, no cloud, no tracking — nothing '
                                  'goes to our servers. Anything you save '
                                  'stays encrypted on this device, where only '
                                  'you can open it.',
                        ),
                        const SizedBox(height: 10),
                        const _DisclaimerCard(
                          icon: Icons.published_with_changes,
                          title: 'You can stop or change anything, anytime',
                          body:
                              'Skip questions, go back, or revoke later. This '
                              'is your voice — you stay in control.',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _AckRow(
                    palette: palette,
                    checked: accepted,
                    onToggle: onAcceptToggle,
                  ),
                  const SizedBox(height: 16),
                  // Artboard footer: a "Read full disclaimer" ghost link on the
                  // left and the primary "Get started" CTA on the right.
                  Row(
                    children: [
                      TextButton(
                        onPressed: onOpenFull,
                        style: TextButton.styleFrom(
                          foregroundColor: palette.text,
                          textStyle: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Read full disclaimer'),
                      ),
                      const Spacer(),
                      // NOTE: set the height via minimumSize, NOT a wrapping
                      // SizedBox(height:). Inside a Row with a Spacer, a
                      // SizedBox(height:) lets the button be measured at
                      // UNBOUNDED width ("BoxConstraints forces an infinite
                      // width"), so it silently fails to lay out / paint.
                      FilledButton.icon(
                        onPressed: onContinue,
                        icon: const Icon(Icons.arrow_forward, size: 18),
                        iconAlignment: IconAlignment.end,
                        label: const Text('Get started'),
                        style: FilledButton.styleFrom(
                          backgroundColor: palette.primary,
                          foregroundColor: palette.onPrimary,
                          // Visible-but-muted when the 18+ box isn't checked,
                          // so users can see the CTA waiting for them.
                          disabledBackgroundColor: palette.primaryLight,
                          disabledForegroundColor: palette.primary,
                          minimumSize:
                              const Size(0, DesignTokens.buttonHeightLg),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 22),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                DesignTokens.buttonRadius),
                          ),
                          textStyle: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Persistent 988 chip pinned to top-right (gate only).
            Positioned(
              top: 12,
              right: 16,
              child: Crisis988Pill(
                bg: dark
                    ? SemanticColors.errorBgDark
                    : SemanticColors.errorBgLight,
                border: dark
                    ? SemanticColors.errorBorderDark
                    : SemanticColors.errorBorderLight,
                fg: dark
                    ? SemanticColors.errorAccentDark
                    : SemanticColors.errorAccentLight,
                onTap: () => showCrisisSheet(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  final MhadPalette palette;
  const _SectionLabel(this.text, {required this.palette});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: 'JetBrains Mono',
        fontFamilyFallback: const [
          'Consolas',
          'Menlo',
          'Courier New',
          'monospace'
        ],
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
        color: palette.textMuted,
      ),
    );
  }
}

/// Editorial icon card — mirrors the Claude Design `WebDisclaimer` cards
/// (38px primaryTint icon square + title + body inside a bordered card).
class _DisclaimerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _DisclaimerCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: p.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 19, color: p.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    height: 1.5,
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

class _AckRow extends StatelessWidget {
  final MhadPalette palette;
  final bool checked;
  final VoidCallback onToggle;
  const _AckRow({
    required this.palette,
    required this.checked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Tinted acknowledgment row (artboard WebDisclaimer). The 18+ requirement
    // — which the artboard omits — is folded into the affirmation here.
    return Semantics(
      checked: checked,
      button: true,
      child: Material(
        color: palette.primaryTint,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: palette.primaryLight),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: checked ? palette.primary : Colors.transparent,
                    border: Border.all(color: palette.primary, width: 1.8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: checked
                      ? Icon(Icons.check, size: 14, color: palette.onPrimary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "I'm 18 or older, and I understand and want to continue.",
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: palette.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── 988 pill ───────────────────────────────────────────────────────────

// ─── Read-only accordion (Settings → Legal) ─────────────────────────────

class _ReadOnlyAccordion extends StatefulWidget {
  final MhadPalette palette;
  const _ReadOnlyAccordion({required this.palette});

  @override
  State<_ReadOnlyAccordion> createState() => _ReadOnlyAccordionState();
}

class _ReadOnlyAccordionState extends State<_ReadOnlyAccordion> {
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final sections = _buildSections(p);
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(title: const Text('Legal Disclaimer')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          children: [
            Text(
              'Full legal disclosure',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'The eight sections below were accepted at first launch. '
              'Tap to expand.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                color: p.textMuted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 14),
            for (int i = 0; i < sections.length; i++) ...[
              _AccordionSection(
                number: sections[i].number,
                title: sections[i].title,
                body: sections[i].body,
                expanded: _open == i,
                onTap: () =>
                    setState(() => _open = _open == i ? -1 : i),
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Full-legal modal sheet (opened from gate) ──────────────────────────

class _FullLegalSheet extends StatefulWidget {
  final ScrollController scrollController;
  const _FullLegalSheet({required this.scrollController});

  @override
  State<_FullLegalSheet> createState() => _FullLegalSheetState();
}

class _FullLegalSheetState extends State<_FullLegalSheet> {
  int _open = 0;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final sections = _buildSections(p);
    return Column(
      children: [
        // Drag handle
        Container(
          margin: const EdgeInsets.only(top: 10, bottom: 8),
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: p.border,
            borderRadius: BorderRadius.circular(100),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Full legal sections',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                tooltip: 'Close',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            controller: widget.scrollController,
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
            children: [
              for (int i = 0; i < sections.length; i++) ...[
                _AccordionSection(
                  number: sections[i].number,
                  title: sections[i].title,
                  body: sections[i].body,
                  expanded: _open == i,
                  onTap: () =>
                      setState(() => _open = _open == i ? -1 : i),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Section data (unchanged from prior implementation) ─────────────────

class _SectionData {
  final String number;
  final String title;
  final List<Widget> body;
  const _SectionData({
    required this.number,
    required this.title,
    required this.body,
  });
}

List<_SectionData> _buildSections(MhadPalette p) {
  return [
    _SectionData(
      number: '01',
      title: 'Not legal or medical advice',
      body: [
        _Para(spans: [
          const TextSpan(
              text:
                  'This app helps Pennsylvania residents document their treatment preferences under '),
          _bold('PA Act 194 of 2004'),
          const TextSpan(
              text:
                  '. The information is for informational purposes only and does '),
          _bold('not'),
          const TextSpan(text: ' constitute legal or medical advice.'),
        ], palette: p),
        _Para(spans: const [
          TextSpan(
              text:
                  'It is not a medical device. It does not diagnose, treat, cure, or prevent any condition. For treatment decisions, consult a qualified mental health professional. For legal questions, consult a licensed PA attorney.'),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '02',
      title: 'No professional relationship',
      body: [
        _Para(spans: [
          const TextSpan(text: 'Use of this app does '),
          _bold('not'),
          const TextSpan(
              text:
                  ' create an attorney–client relationship, a provider–patient relationship, or any other professional relationship between you and the developer.'),
        ], palette: p),
        _Para(spans: const [
          TextSpan(
              text:
                  'You are solely responsible for making sure your directive meets all legal requirements under PA law, including proper execution with witnesses.'),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '03',
      title: 'Use at your own risk',
      body: [
        _Para(spans: const [
          TextSpan(
              text:
                  'In plain terms: this app helps you put your own wishes into '
                  'a directive, and you use it at your own risk. Please review '
                  'the finished document for accuracy — mistakes can happen, '
                  'and details you entered may be out of date or incomplete. '
                  'If you are ever unsure whether something is legally right '
                  'for your situation, feel free to talk with an attorney. '
                  'The formal version:'),
        ], palette: p),
        _Para(spans: const [
          TextSpan(text: 'This app is provided '),
          TextSpan(
            text: '"as is"',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          TextSpan(
              text:
                  ', without warranties of any kind, and you use it at your own risk. To the fullest extent permitted by law, the developer is not liable for any damages arising from use of the app or any document created with it. You are responsible for reviewing your directive for accuracy and completeness; for legal questions specific to your situation, consult a licensed Pennsylvania attorney.'),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '04',
      title: 'Requirements for a valid directive',
      body: [
        _Para(spans: [
          const TextSpan(
              text:
                  'A PA Mental Health Advance Directive is legally valid '),
          _bold('only'),
          const TextSpan(text: ' when:'),
        ], palette: p),
        _Bullet(spans: const [
          TextSpan(
              text:
                  'You (the principal) have legal capacity at the time of signing'),
        ], palette: p),
        _Bullet(spans: [
          const TextSpan(text: 'It is signed in the presence of '),
          _bold('two adult witnesses'),
        ], palette: p),
        _Bullet(spans: const [
          TextSpan(
              text:
                  'Both witnesses meet eligibility requirements under Act 194'),
        ], palette: p),
        _Para(spans: [
          _bold('Witnesses cannot be: '),
          const TextSpan(
              text:
                  'your designated agent or alternate agent, your mental health care provider, or an employee of the facility where you receive treatment — unless they are related to you by blood, marriage, or adoption.'),
        ], palette: p),
        _Para(spans: [
          const TextSpan(
              text:
                  'This app captures touch-drawn signatures for convenience during preparation. The '),
          _bold('printed'),
          const TextSpan(
              text:
                  ' directive must be signed in original ink, in the presence of your two witnesses, to be legally valid.'),
        ], palette: p),
        _Para(spans: [
          const TextSpan(text: 'Once signed, providers and your agent '),
          _bold('must comply'),
          const TextSpan(
              text:
                  ' with your directive (20 Pa.C.S. § 5837). However, a provider may decline to follow specific instructions that are against accepted medical practice, or when the provider is not physically available.'),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '05',
      title: 'Two-year validity',
      body: [
        _Para(spans: [
          const TextSpan(text: 'Under PA Act 194, an MHAD is valid for '),
          _bold('two years'),
          const TextSpan(
              text:
                  ' from the date of execution unless revoked earlier — '),
          _bold('unless you are found incapable'),
          const TextSpan(
              text:
                  ' of making mental health decisions at the time it would expire, in which case it remains in effect until capacity returns. This app will remind you when your directive is approaching expiration.'),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '06',
      title: 'Revocation',
      body: [
        _Para(spans: const [
          TextSpan(
              text:
                  'You may revoke this directive at any time while you have legal capacity by:'),
        ], palette: p),
        _Bullet(spans: const [
          TextSpan(
              text: 'Notifying your healthcare provider or agent in writing'),
        ], palette: p),
        _Bullet(spans: const [
          TextSpan(text: 'Destroying the directive'),
        ], palette: p),
        _Bullet(spans: const [
          TextSpan(text: 'Executing a new directive'),
        ], palette: p),
        _Para(spans: const [
          TextSpan(text: 'Notify everyone who has copies of the revocation.'),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '07',
      title: 'Privacy & AI features',
      body: [
        _Para(spans: [
          const TextSpan(text: 'In '),
          _bold('Private Mode'),
          const TextSpan(
              text:
                  ', your directive is encrypted and stored on this device. In '),
          _bold('Public Mode'),
          const TextSpan(
              text:
                  ' (or on the web), data is held in memory only and is not saved permanently. This app is '),
          _bold('not'),
          const TextSpan(text: ' HIPAA-compliant.'),
        ], palette: p),
        _Para(spans: [
          const TextSpan(
              text:
                  "If you use the optional AI Assistant (Google Gemini), text you send is transmitted to Google's servers. On the free tier, Google may use this data to improve their products and human reviewers may read inputs. "),
          _bold('Do not include personally identifying information'),
          const TextSpan(
              text:
                  ' (full name, SSN, date of birth, address) in AI requests.'),
        ], palette: p),
        _Para(spans: const [
          TextSpan(
              text:
                  'AI suggestions are not legal or medical advice — review carefully before accepting.'),
        ], palette: p),
      ],
    ),
    _SectionData(
      number: '08',
      title: 'Resources & assistance',
      body: [
        _Resource(
            title: 'PA Protection & Advocacy',
            sub: 'Your rights under Act 194',
            mono:
                '${appData.phoneOf('paProtectionAdvocacy')} · TDD/TTY ${appData.contact('paProtectionAdvocacy').tdd ?? ''}',
            palette: p),
        const SizedBox(height: 10),
        _Resource(
            title: "PA Mental Health Consumers' Association",
            sub: null,
            mono: appData.phoneOf('pmhca'),
            palette: p),
        const SizedBox(height: 10),
        _Resource(
            title: 'Mental Health Association in Pennsylvania',
            sub: null,
            mono: appData.phoneOf('mhapa'),
            palette: p),
        const SizedBox(height: 10),
        _Resource(
            title: '988 Suicide & Crisis Lifeline',
            sub: '24/7, free, confidential',
            mono: 'Call or text 988',
            palette: p),
      ],
    ),
  ];
}

// ─── Building blocks (used by accordion sheet) ──────────────────────────

InlineSpan _bold(String text) => TextSpan(
      text: text,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );

class _Para extends StatelessWidget {
  final List<InlineSpan> spans;
  final MhadPalette palette;
  const _Para({required this.spans, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text.rich(
        TextSpan(
          children: spans
              .map((s) => _coloredBoldInBody(s, palette))
              .toList(growable: false),
        ),
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13.5,
          color: palette.textMuted,
          height: 1.55,
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final List<InlineSpan> spans;
  final MhadPalette palette;
  const _Bullet({required this.spans, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 7, right: 8),
            child: Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: palette.textMuted,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: spans
                    .map((s) => _coloredBoldInBody(s, palette))
                    .toList(growable: false),
              ),
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13.5,
                color: palette.textMuted,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

InlineSpan _coloredBoldInBody(InlineSpan span, MhadPalette palette) {
  if (span is! TextSpan) return span;
  final isBold = (span.style?.fontWeight == FontWeight.w600 ||
      span.style?.fontWeight == FontWeight.bold);
  if (!isBold) return span;
  return TextSpan(
    text: span.text,
    style: (span.style ?? const TextStyle()).copyWith(color: palette.text),
    children: span.children,
  );
}

class _Resource extends StatelessWidget {
  final String title;
  final String? sub;
  final String mono;
  final MhadPalette palette;
  const _Resource({
    required this.title,
    required this.sub,
    required this.mono,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: palette.text,
                ),
              ),
              if (sub != null)
                TextSpan(
                  text: ' — $sub',
                  style: TextStyle(color: palette.textMuted),
                ),
            ],
          ),
          style: const TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          mono,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontFamilyFallback: const [
              'Consolas',
              'Menlo',
              'Courier New',
              'monospace'
            ],
            fontSize: 12,
            color: palette.text,
          ),
        ),
      ],
    );
  }
}

class _AccordionSection extends StatelessWidget {
  final String number;
  final String title;
  final List<Widget> body;
  final bool expanded;
  final VoidCallback onTap;

  const _AccordionSection({
    required this.number,
    required this.title,
    required this.body,
    required this.expanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(
          color: expanded
              ? p.primary.withValues(alpha: 0.25)
              : p.border,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                height: 56,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          number,
                          style: TextStyle(
                            fontFamily: 'Instrument Serif',
                            fontFamilyFallback: const ['Georgia', 'serif'],
                            fontStyle: FontStyle.italic,
                            fontSize: 24,
                            fontWeight: FontWeight.w400,
                            height: 1,
                            letterSpacing: -0.5,
                            color: p.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.1,
                            color: p.text,
                          ),
                        ),
                      ),
                      AnimatedRotation(
                        duration: const Duration(milliseconds: 200),
                        turns: expanded ? 0.5 : 0,
                        child: Icon(Icons.keyboard_arrow_down,
                            size: 18, color: p.textMuted),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 0, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: body,
              ),
            ),
        ],
      ),
    );
  }
}
