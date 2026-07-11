import 'package:flutter/material.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// The full eight-section legal disclosure, rendered two ways:
///   * [ReadOnlyAccordion] — a scrollable Scaffold used from Settings → Legal.
///   * [FullLegalSheet] — the same accordion inside the modal sheet opened
///     from the first-launch gate's "Read full disclaimer" link.
/// Both share the section data ([_buildSections]) and the [_AccordionSection]
/// expander, so the disclosure text lives in exactly one place.

// ─── Read-only accordion (Settings → Legal) ─────────────────────────────

class ReadOnlyAccordion extends StatefulWidget {
  final MhadPalette palette;
  const ReadOnlyAccordion({required this.palette, super.key});

  @override
  State<ReadOnlyAccordion> createState() => _ReadOnlyAccordionState();
}

class _ReadOnlyAccordionState extends State<ReadOnlyAccordion> {
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
                fontFamily: kSansFamily,
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
                fontFamily: kSansFamily,
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

class FullLegalSheet extends StatefulWidget {
  final ScrollController scrollController;
  const FullLegalSheet({required this.scrollController, super.key});

  @override
  State<FullLegalSheet> createState() => _FullLegalSheetState();
}

class _FullLegalSheetState extends State<FullLegalSheet> {
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
                    fontFamily: kSansFamily,
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
                  ' with your directive (20 Pa.C.S. §§ 5804, 5842). However, a provider may decline to follow specific instructions that are against accepted medical practice, or when the provider is not physically available.'),
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
          const TextSpan(
              text:
                  'This is a web app: your directive is held in memory in your '
                  'browser only and is '),
          _bold('not saved permanently'),
          const TextSpan(
              text:
                  ' — if you close the tab or it crashes, your work is kept on '
                  'this device for about 10 minutes for recovery, then wiped; '
                  'it is never sent to a server. Export or print to keep a '
                  'copy. This app is '),
          _bold('not'),
          const TextSpan(text: ' HIPAA-compliant.'),
        ], palette: p),
        _Para(spans: const [
          TextSpan(
              text:
                  "If you use the optional AI Assistant, text you send is transmitted to the AI provider you choose (Google Gemini by default; or Anthropic, OpenAI, or xAI). On Gemini's free tier, Google may use this data to improve their products and human reviewers may read inputs; other providers handle your data under their own API policies."),
        ], palette: p),
        _Para(spans: [
          const TextSpan(text: 'To protect you, the app '),
          _bold('automatically keeps identifying details out of what it sends '
              'to the AI assistant and its suggestions'),
          const TextSpan(
              text:
                  ' — your name, date of birth, address, and the names and '
                  'contact details of your agents and guardian are never '
                  'included. Only non-identifying context (such as conditions, '
                  'medications, and care preferences) is shared, and only if '
                  'you choose to use the assistant. (Uploading a document for '
                  'autofill is the one exception, described next.)'),
        ], palette: p),
        _Para(spans: [
          const TextSpan(
              text:
                  'Documents you upload for autofill are different: the whole '
                  'file is sent to your chosen AI provider as-is, and to fill '
                  'in your directive the AI reads the personal details in it (your '
                  'name, date of birth, address, and your agent\'s or '
                  'guardian\'s details). You review everything before it is '
                  'saved. '),
          _bold('Uploading is never required'),
          const TextSpan(
              text:
                  ' — black out anything you don\'t want sent, or simply type '
                  'any field by hand to keep it private. Also avoid typing '
                  'personal identifiers (full name, SSN, date of birth, '
                  'address) directly into chat messages.'),
        ], palette: p),
        _Para(spans: [
          const TextSpan(
              text:
                  'Separately, to help you fill in and understand your '
                  'directive, the app looks up medications, conditions, and '
                  '(optionally) your doctor in free, public U.S. government '
                  'databases — the NIH/NLM Clinical Tables, MedlinePlus, and '
                  'the FDA\'s openFDA. '),
          _bold('These lookups send only the medical term, code, or provider '
              'name being searched'),
          const TextSpan(
              text:
                  ' — never your identity, the people you name, or your saved '
                  'directive. They are reference information, not medical '
                  'advice.'),
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
          fontFamily: kSansFamily,
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
                fontFamily: kSansFamily,
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
            fontFamily: kSansFamily,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          mono,
          style: TextStyle(
            fontFamily: kMonoFamily,
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
                            fontFamily: kSansFamily,
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
