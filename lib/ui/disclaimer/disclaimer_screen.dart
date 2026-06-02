import 'package:flutter/material.dart';
import 'package:mhad/services/disclaimer_service.dart';
import 'package:mhad/services/notification_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';

/// First-launch legal disclaimer + read-only Settings variant.
///
/// Layout — per `MHAD-handoff/mhad/project/Disclaimer Screen.html`:
///  - "Need 988" pill pinned to top-right
///  - Editorial italic header "A few _important_ things."
///  - Read-progress meter ("X / 8 READ") that fills as sections are opened
///  - Yellow "Short version" warning banner with the 25-word TL;DR
///  - 8 expandable accordion sections (one open at a time, #1 open by default)
///  - Pull-quote from the PA MHAD booklet
///  - Sticky accept bar: two checkboxes (age + acknowledgment) and a primary
///    Continue button that stays disabled until both are checked.
class DisclaimerScreen extends StatefulWidget {
  final DisclaimerNotifier? _notifier;
  final bool _readOnly;

  /// First-launch gate variant — user must tick both checkboxes before
  /// they can tap Continue.
  const DisclaimerScreen.gate({
    required DisclaimerNotifier notifier,
    super.key,
  })  : _notifier = notifier,
        _readOnly = false;

  /// Read-only variant — the same accordion content with an AppBar back
  /// button instead of the accept footer. Used from Settings → Legal.
  const DisclaimerScreen.readOnly({super.key})
      : _notifier = null,
        _readOnly = true;

  @override
  State<DisclaimerScreen> createState() => _DisclaimerScreenState();
}

class _DisclaimerScreenState extends State<DisclaimerScreen> {
  /// Index of the currently-expanded section (-1 = all collapsed).
  int _open = 0;

  /// Indices of every section the user has expanded at least once.
  final Set<int> _read = {0};

  bool _isAdult = false;
  bool _notLegal = false;

  void _toggle(int i) {
    setState(() {
      _open = _open == i ? -1 : i;
      _read.add(i);
    });
  }

  Future<void> _accept() async {
    if (widget._notifier == null) return;
    await widget._notifier!.accept();
    await NotificationService.instance.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final readOnly = widget._readOnly;
    final sections = _buildSections(p);
    final readCount = _read.length;
    final total = sections.length;
    final pct = total == 0 ? 0.0 : readCount / total;
    final canContinue = _isAdult && _notLegal;

    return PopScope(
      canPop: readOnly,
      child: Scaffold(
        backgroundColor: p.scaffoldBackground,
        appBar: readOnly ? AppBar(title: const Text('Legal Disclaimer')) : null,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Editorial header + read-progress meter
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BEFORE WE BEGIN',
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
                            color: p.textMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'A few '),
                              TextSpan(
                                text: 'important',
                                style: TextStyle(color: p.primary),
                              ),
                              const TextSpan(text: ' things.'),
                            ],
                          ),
                          style: TextStyle(
                            fontFamily: 'Instrument Serif',
                            fontFamilyFallback: const [
                              'Georgia',
                              'Times New Roman',
                              'serif'
                            ],
                            fontStyle: FontStyle.italic,
                            fontSize: 44,
                            fontWeight: FontWeight.w400,
                            height: 0.98,
                            letterSpacing: -1,
                            color: p.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 340),
                          child: Text.rich(
                            TextSpan(
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 14,
                                color: p.textMuted,
                                height: 1.5,
                              ),
                              children: [
                                const TextSpan(
                                    text:
                                        "Read carefully — these confirm what this app does and doesn't do under "),
                                TextSpan(
                                  text: 'PA Act 194',
                                  style: TextStyle(
                                    color: p.text,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Read-progress micro-meter
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: SizedBox(
                                  height: 3,
                                  child: LinearProgressIndicator(
                                    value: pct,
                                    backgroundColor: p.border,
                                    valueColor: AlwaysStoppedAnimation(
                                        p.primary),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '$readCount / $total READ',
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
                                letterSpacing: 0.6,
                                color: readCount == total
                                    ? p.primary
                                    : p.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Sections list (scrollable). Bottom 24px fades to the
                  // scaffold — matches the prototype's maskImage gradient
                  // (linear-gradient(to bottom, black calc(100% - 24px),
                  // transparent)).
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final fadeStop = constraints.maxHeight <= 0
                            ? 1.0
                            : (1 - 24 / constraints.maxHeight)
                                .clamp(0.0, 1.0);
                        return ShaderMask(
                          shaderCallback: (rect) => LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0, fadeStop, 1],
                            colors: const [
                              Colors.black,
                              Colors.black,
                              Colors.transparent,
                            ],
                          ).createShader(rect),
                          blendMode: BlendMode.dstIn,
                          child: ListView(
                            padding:
                                const EdgeInsets.fromLTRB(22, 0, 22, 24),
                            children: [
                        _ShortVersionBanner(),
                        const SizedBox(height: 14),
                        for (int i = 0; i < sections.length; i++) ...[
                          _AccordionSection(
                            number: sections[i].number,
                            title: sections[i].title,
                            body: sections[i].body,
                            expanded: _open == i,
                            onTap: () => _toggle(i),
                          ),
                          const SizedBox(height: 8),
                        ],
                        const SizedBox(height: 6),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Text(
                                  '"Your directive is your voice — written in '
                                  "advance, kept safe, honored when you can't "
                                  'speak for yourself."',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Instrument Serif',
                                    fontFamilyFallback: const [
                                      'Georgia',
                                      'Times New Roman',
                                      'serif'
                                    ],
                                    fontStyle: FontStyle.italic,
                                    fontSize: 16,
                                    color: p.textMuted,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '— PA MHAD BOOKLET',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontFamilyFallback: const [
                                      'Consolas',
                                      'Menlo',
                                      'Courier New',
                                      'monospace'
                                    ],
                                    fontSize: 10,
                                    letterSpacing: 0.6,
                                    color: p.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Sticky accept bar — gate only
                  if (!readOnly)
                    _AcceptFooter(
                      isAdult: _isAdult,
                      notLegal: _notLegal,
                      onAdultToggle: () =>
                          setState(() => _isAdult = !_isAdult),
                      onNotLegalToggle: () =>
                          setState(() => _notLegal = !_notLegal),
                      canContinue: canContinue,
                      onContinue: canContinue ? _accept : null,
                    ),
                ],
              ),

              // Persistent 988 chip pinned to top-right (gate only — Settings
              // has its own AppBar and the route is already private).
              if (!readOnly)
                Positioned(
                  top: 12,
                  right: 16,
                  child: _Need988Pill(
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
      ),
    );
  }
}

// ─── Data ────────────────────────────────────────────────────────────────

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
      title: 'No warranty',
      body: [
        _Para(spans: const [
          TextSpan(text: 'This app is provided '),
          TextSpan(
            text: '"as is"',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          TextSpan(
              text:
                  ' without warranty of any kind. The developer assumes no liability for damages arising from use of the app or any document created with it, and is not responsible for ensuring the legal validity of any directive.'),
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
              text: 'Both witnesses meet eligibility requirements under Act 194'),
        ], palette: p),
        _Para(spans: [
          _bold('Witnesses cannot be: '),
          const TextSpan(
              text:
                  "your designated agent, your agent's spouse, your mental health care provider, or an employee of your treatment facility (unless related to you)."),
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
          TextSpan(text: 'Notifying your healthcare provider or agent in writing'),
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
            mono: '1-800-692-7443 · TDD/TTY 1-877-375-7139',
            palette: p),
        const SizedBox(height: 10),
        _Resource(
            title: "PA Mental Health Consumers' Association",
            sub: null,
            mono: '1-800-887-6422',
            palette: p),
        const SizedBox(height: 10),
        _Resource(
            title: 'Mental Health Association in Pennsylvania',
            sub: null,
            mono: '1-866-578-3659',
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

// ─── Building blocks ─────────────────────────────────────────────────────

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

/// Bold spans inside body text get the full-text color (rather than the
/// muted body color) — matches the prototype's `.disc-body strong` rule.
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

// ─── Accordion section ──────────────────────────────────────────────────

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
                // Fixed accordion-header height â‰¥ 48 for the a11y guideline.
                // The visible content (number + title + chevron) is centered
                // within it, matching the prototype's tight header look.
                height: 56,
                child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 30,
                      child: Text(
                        number,
                        style: TextStyle(
                          fontFamily: 'Instrument Serif',
                          fontFamilyFallback: const [
                            'Georgia',
                            'Times New Roman',
                            'serif'
                          ],
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
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
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

// ─── Short-version banner ───────────────────────────────────────────────

class _ShortVersionBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? SemanticColors.warningBgDark : SemanticColors.warningBgLight;
    final border = dark
        ? SemanticColors.warningBorderDark
        : SemanticColors.warningBorderLight;
    final fg = dark
        ? SemanticColors.warningTextDark
        : SemanticColors.warningTextLight;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning_amber_rounded, size: 16, color: fg),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Short version',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: fg,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.5,
                      color: fg,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'This app helps you '),
                      const TextSpan(
                        text: 'document',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                      const TextSpan(text: ' your preferences. It is '),
                      TextSpan(
                        text: 'not',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(
                          text:
                              ' legal or medical advice. To be valid, your directive must be signed in front of '),
                      TextSpan(
                        text: 'two adult witnesses',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const TextSpan(text: '. Tap each section below to expand.'),
                    ],
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

// ─── 988 pill ───────────────────────────────────────────────────────────

class _Need988Pill extends StatelessWidget {
  final Color bg;
  final Color border;
  final Color fg;
  final VoidCallback onTap;
  const _Need988Pill({
    required this.bg,
    required this.border,
    required this.fg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Need 988 — open crisis resources',
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(100),
          // 48px tap target around the ~29px visible pill (a11y guideline).
          child: SizedBox(
            height: 48,
            child: Center(
              widthFactor: 1,
              child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_outlined, size: 11, color: fg),
                const SizedBox(width: 5),
                Text(
                  'Need 988',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Accept footer (gate only) ──────────────────────────────────────────

class _AcceptFooter extends StatelessWidget {
  final bool isAdult;
  final bool notLegal;
  final VoidCallback onAdultToggle;
  final VoidCallback onNotLegalToggle;
  final bool canContinue;
  final VoidCallback? onContinue;

  const _AcceptFooter({
    required this.isAdult,
    required this.notLegal,
    required this.onAdultToggle,
    required this.onNotLegalToggle,
    required this.canContinue,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        border: Border(top: BorderSide(color: p.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CheckRow(
            checked: isAdult,
            onToggle: onAdultToggle,
            labelSpans: [
              const TextSpan(text: "I'm "),
              _bold('18 or older'),
              const TextSpan(text: ', or an emancipated minor.'),
            ],
          ),
          const SizedBox(height: 8),
          _CheckRow(
            checked: notLegal,
            onToggle: onNotLegalToggle,
            labelSpans: [
              const TextSpan(text: 'I understand this app is '),
              _bold('not legal or medical advice'),
              const TextSpan(text: '.'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: DesignTokens.buttonHeightLg,
            child: FilledButton.icon(
              onPressed: onContinue,
              icon: Icon(
                Icons.arrow_forward,
                size: 18,
                color: canContinue ? p.onPrimary : p.textMuted,
              ),
              label: Text(
                'I understand · Continue',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: canContinue ? p.onPrimary : p.textMuted,
                ),
              ),
              style: FilledButton.styleFrom(
                iconAlignment: IconAlignment.end,
                backgroundColor: canContinue ? p.primary : p.border,
                disabledBackgroundColor: p.border,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(DesignTokens.buttonRadius),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You can re-read this anytime from Settings → Legal.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10.5,
              color: p.textMuted,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  final bool checked;
  final VoidCallback onToggle;
  final List<InlineSpan> labelSpans;
  const _CheckRow({
    required this.checked,
    required this.onToggle,
    required this.labelSpans,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      checked: checked,
      child: InkWell(
        onTap: onToggle,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          // Vertical 14 (â‰ˆ 22 + 28 = 50) keeps the row â‰¥ 48 for a11y while
          // staying close to the prototype's tight checkbox row.
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                margin: const EdgeInsets.only(top: 1),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: checked ? p.primary : Colors.transparent,
                  border: checked
                      ? null
                      : Border.all(color: p.border, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                alignment: Alignment.center,
                child: checked
                    ? Icon(Icons.check, size: 14, color: p.onPrimary)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    children: labelSpans
                        .map((s) => _coloredBoldInBody(s, p))
                        .toList(growable: false),
                  ),
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13.5,
                    color: p.text,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
