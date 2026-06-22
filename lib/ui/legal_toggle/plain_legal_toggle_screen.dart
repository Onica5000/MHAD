import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

/// Plain ⇄ Legal toggle for an existing directive (Phase 4, v2 prototype
/// `m-legaltoggle`). Per v3 spec: the Legal-language rendering shows a DRAFT
/// banner until attorney review is complete. Both modes are derived from the
/// SAME underlying data — only the prose changes.
///
/// PA Act 194 statutory wording from v3 corrections:
/// - Citation: 20 Pa.C.S. Ch. 58 (not "§ 5801 et seq.")
/// - Agent authority: § 5836 (not "§§ 5803-5805")
/// - Effective condition: psychiatrist + one of {another psychiatrist,
///   psychologist, family physician, attending physician, or mental health
///   treatment professional}
class PlainLegalToggleScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const PlainLegalToggleScreen({required this.directiveId, super.key});

  @override
  ConsumerState<PlainLegalToggleScreen> createState() =>
      _PlainLegalToggleScreenState();
}

class _PlainLegalToggleScreenState
    extends ConsumerState<PlainLegalToggleScreen> {
  bool _legalMode = false;
  Directive? _directive;
  List<Agent> _agents = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final repo = ref.read(directiveRepositoryProvider);
    final d = await repo.getDirectiveById(widget.directiveId);
    final a = await repo.getAgents(widget.directiveId);
    if (!mounted) return;
    setState(() {
      _directive = d;
      _agents = a;
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrLegalToggle (gap-analysis.jsx L903-1051) uses CrisisBar
      // + in-body back chevron, then the 40pt editorial heading. Share is
      // available as a tap on the header's right side (replaces the AppBar
      // action that previously lived there).
      body: Column(children: [
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: 'Share',
          onAction: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Sharing routes through the Export screen — use that to '
                  'open, print, or save the PDF.'),
            ));
          },
        ),
        Expanded(child: _directive == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              children: [
                const SectionLabel('Your directive · two registers'),
                const SizedBox(height: 6),
                // Headline bumped 32 -> 40pt to match prototype L915.
                const EditorialHeading(
                  text: 'Same meaning, two voices.',
                  size: 40,
                ),
                const SizedBox(height: 6),
                Text(
                  'What you wrote, and what a court or hospital will read.',
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 14,
                    color: p.textMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: false,
                      label: Text('Plain English'),
                      icon: Icon(Icons.favorite_outline),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text('Legal language'),
                      icon: Icon(Icons.description_outlined),
                    ),
                  ],
                  selected: {_legalMode},
                  onSelectionChanged: (s) =>
                      setState(() => _legalMode = s.first),
                ),
                const SizedBox(height: 14),
                if (_legalMode)
                  const InfoBanner(
                    icon: Icons.warning_amber_rounded,
                    variant: InfoBannerVariant.warning,
                    text:
                        'DRAFT — not yet attorney-reviewed. The signed printed '
                        'directive is the authoritative version. Legal mode '
                        'shows how PA Act 194 statutory voice renders this '
                        'data; verify against counsel before relying on it.',
                  ),
                if (_legalMode) const SizedBox(height: 10),
                Card(
                  color: cs.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: _legalMode ? _LegalBody(
                      directive: _directive!,
                      agents: _agents,
                    ) : _PlainBody(
                      directive: _directive!,
                      agents: _agents,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                InfoBanner(
                  icon: Icons.info_outline,
                  variant: InfoBannerVariant.info,
                  text:
                      'Both versions are derived from the same data. '
                      'Plain English is what you wrote; Legal voice renders '
                      'it under 20 Pa.C.S. Ch. 58.',
                ),
              ],
            )),
      ]),
    );
  }
}

class _PlainBody extends StatelessWidget {
  final Directive directive;
  final List<Agent> agents;
  const _PlainBody({required this.directive, required this.agents});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final primary = agents.primaryAgent;
    final alternate = agents.alternateAgent;
    final name = directive.fullName.isEmpty ? '(your name)' : directive.fullName;

    final paragraphs = <String>[
      "I'm $name, and this is my mental health advance directive.",
      'If two qualified professionals decide I can\'t make my own treatment '
          'decisions, here\'s what I want.',
      if (primary != null)
        '${primary.fullName.isEmpty ? "My primary agent" : primary.fullName} '
        '(${primary.relationship.isEmpty ? "primary agent" : primary.relationship}) '
        'should make decisions for me.'
        '${alternate != null ? " If they can't, "
            "${alternate.fullName.isEmpty ? "my alternate" : alternate.fullName}." : "."}',
      if (directive.effectiveCondition.isNotEmpty)
        'When it kicks in: ${directive.effectiveCondition}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final para in paragraphs) ...[
          Text(
            para,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 14.5,
              height: 1.55,
              color: p.text,
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _LegalBody extends StatelessWidget {
  final Directive directive;
  final List<Agent> agents;
  const _LegalBody({required this.directive, required this.agents});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final primary = agents.primaryAgent;
    final name = directive.fullName.isEmpty
        ? '(PRINCIPAL NAME)'
        : directive.fullName.toUpperCase();
    final agentLine = primary == null
        ? '(NO AGENT NAMED)'
        : '${primary.fullName.toUpperCase()}, '
            '${primary.relationship.isEmpty ? "" : "${primary.relationship}, "}'
            'residing at ${primary.address.isEmpty ? "(address)" : primary.address}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I, $name, being of sound mind and at least eighteen (18) years of '
          'age, do hereby execute this Mental Health Advance Directive '
          'pursuant to the Mental Health Advance Directive Act of 2004, '
          '20 Pa.C.S. Ch. 58.',
          style: _legalStyle(p),
        ),
        const SizedBox(height: 12),
        Text(
          'This Directive shall become effective upon a written determination '
          'by a psychiatrist and one of the following: another psychiatrist, '
          'a licensed psychologist, a family physician, an attending '
          'physician, or a mental health treatment professional (whenever '
          'possible, one of whom is a treating professional) that I am '
          'incapable of making mental health treatment decisions.',
          style: _legalStyle(p),
        ),
        const SizedBox(height: 12),
        if (primary != null) ...[
          Text(
            'I hereby appoint $agentLine as my mental health care agent, with '
            'the authority enumerated in 20 Pa.C.S. § 5836.',
            style: _legalStyle(p),
          ),
          const SizedBox(height: 12),
        ],
        Text(
          'This Directive shall terminate two (2) years from the date of '
          'execution unless, at the time of expiration, I am incapable of '
          'making mental health treatment decisions, in which case it shall '
          'remain in effect until capacity returns.',
          style: _legalStyle(p),
        ),
      ],
    );
  }

  TextStyle _legalStyle(MhadPalette p) => TextStyle(
        fontFamily: 'Instrument Serif',
        fontFamilyFallback: const [
          'Georgia',
          'Times New Roman',
          'serif',
        ],
        fontSize: 14.5,
        height: 1.7,
        letterSpacing: 0.2,
        color: p.text,
      );
}
