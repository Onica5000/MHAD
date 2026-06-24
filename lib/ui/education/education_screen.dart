import 'package:flutter/material.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/ui/education/education_category_browser.dart';
import 'package:mhad/ui/education/learn_ai_panel.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/spot_illustration.dart';
import 'package:mhad/ui/widgets/design/brand_motif.dart';

class EducationScreen extends StatefulWidget {
  /// If set, only show sections matching these IDs (deep-link from wizard Help,
  /// or the start page's "Read the basics").
  final List<String>? filterIds;

  /// AppBar title for the filtered view. Defaults to 'Help' (wizard Help), but
  /// a deep-link can label it for its context (e.g. 'The basics').
  final String filterTitle;

  const EducationScreen({this.filterIds, this.filterTitle = 'Help', super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  // Selected tab (top-level enum, see [EducationTabKind]). Defaults to .all so
  // the user sees every available section on first arrival.
  EducationTabKind _activeTab = EducationTabKind.all;

  List<EducationSection> get _filteredSections {
    // When opened from a wizard Help button, show only the linked sections
    // and ignore the tab filter entirely.
    if (widget.filterIds != null && widget.filterIds!.isNotEmpty) {
      final ids = widget.filterIds!.toSet();
      return allEducationSections.where((s) => ids.contains(s.id)).toList();
    }
    return _activeTab.filter(allEducationSections);
  }

  @override
  Widget build(BuildContext context) {
    final isFiltered =
        widget.filterIds != null && widget.filterIds!.isNotEmpty;

    // Filtered view (deep-link from wizard Help) keeps the Material
    // AppBar with a back arrow — it's a narrow utility view, not the
    // prototype's Learn hub. The unfiltered hub matches prototype
    // ScrLearn: no AppBar, CrisisTopBar at top, inline search pill
    // already lives inside the body widget.
    if (isFiltered) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.filterTitle)),
        body: _filteredSections.isEmpty
            ? _emptyArt(SpotArt.search, 'No results found.')
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _filteredSections.length,
                itemBuilder: (context, i) =>
                    SectionTile(section: _filteredSections[i]),
              ),
      );
    }
    final hub = _filteredSections.isEmpty
        ? _emptyArt(SpotArt.search, 'No results found.')
        : _EditorialLearnHub(
            sections: _filteredSections,
            activeTab: _activeTab,
            onTabChange: (t) => setState(() => _activeTab = t),
          );

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, c) {
          // On wide (PC web) put the AI assistant in a right rail so users can
          // ask questions while reading. Narrow/mobile keeps the single column
          // (the floating crisis button / bottom nav own that space for now).
          final wide = c.maxWidth >= kWideLayoutBreakpoint;
          if (!wide) return hub;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: hub),
              const LearnAiPanel(),
            ],
          );
        },
      ),
    );
  }
}

/// Editorial Learn-hub body matching prototype `ScrLearn`
/// (mobile-extra.jsx::ScrLearn L882-1029).
///
/// Stacks: editorial header → inline search pill → "Browse all topics" index →
/// horizontal category-tab row → 2-column section grid with a primary-filled
/// featured card spanning both columns → centered italic pull-quote card.
///
/// Replaces the prior Dropdown category picker + flat ListView with the
/// prototype's grid + tabs layout. Existing search delegate stays
/// available via the AppBar search button.
class _EditorialLearnHub extends StatelessWidget {
  final List<EducationSection> sections;
  final EducationTabKind activeTab;
  final ValueChanged<EducationTabKind> onTabChange;

  const _EditorialLearnHub({
    required this.sections,
    required this.activeTab,
    required this.onTabChange,
  });

  // Five category pills shown above the grid. Articles is a multi-cat
  // bucket (intro + combined + declaration + poa + supplementary) — the
  // mapping lives on EducationTabKind itself so the screen-level filter and
  // the hub agree on what each tab means.
  static const _tabs = <(EducationTabKind, String)>[
    (EducationTabKind.all, 'All'),
    (EducationTabKind.articles, 'Articles'),
    (EducationTabKind.glossary, 'Glossary'),
    (EducationTabKind.faq, 'FAQ'),
    (EducationTabKind.checklists, 'Checklists'),
  ];

  /// All sections in the active filter, as grid tiles (the former "featured"
  /// intro card is now just the first tile). No cap.
  List<EducationSection> _gridSections() => sections;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final grid = _gridSections();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      children: [
        // Brand-motif hero header — decorative backdrop behind the Learn
        // headline + intro (content unchanged).
        BrandMotif(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Learn'),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Understand '),
                    TextSpan(
                        text: 'before', style: TextStyle(color: p.primary)),
                    const TextSpan(text: ' you sign.'),
                  ],
                ),
                style: const TextStyle(
                  fontFamily: 'Instrument Serif',
                  fontFamilyFallback: ['Georgia', 'serif'],
                  fontStyle: FontStyle.italic,
                  fontSize: 42,
                  height: 1,
                  letterSpacing: -0.8,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Most of this comes straight from the official PA MHAD booklet, '
                'plus a few plain-language explainers. No marketing, no '
                'opinions — just the rules and what they mean.',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 13.5,
                  height: 1.5,
                  color: p.textMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Inline search pill — opens the existing search delegate.
        Builder(
          builder: (ctx) => Material(
            color: p.card,
            borderRadius: BorderRadius.circular(100),
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () async {
                final result = await showSearch<EducationSection?>(
                  context: ctx,
                  delegate: _EducationSearchDelegate(),
                );
                if (result != null && ctx.mounted) {
                  Navigator.of(ctx).push(MaterialPageRoute(
                    builder: (_) =>
                        _SectionDetailRoute(section: result),
                  ));
                }
              },
              child: Container(
                // 48pt minimum tap-target per a11y guideline (constraints
                // floor it; padding adds breathing room beyond).
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: p.border),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 16, color: p.textMuted),
                    const SizedBox(width: 10),
                    Text(
                      'Search articles, glossary, FAQs…',
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 13.5,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Comprehensive topic index — moved up here (right under the search
        // box) so the full library of EducationCategory buckets is immediately
        // browsable, before the editorial tabs/grid.
        const SectionLabel('Browse all topics'),
        const SizedBox(height: 8),
        const BrowseByTopic(),
        const SizedBox(height: 18),
        // Category filter pills, centered in a blue box (replaces the old
        // featured "What is the PA MHAD" card — that section is now a normal
        // grid tile below).
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: p.primaryTint,
            border: Border.all(color: p.primary.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in _tabs)
                _CategoryPill(
                  label: t.$2,
                  active: activeTab == t.$1,
                  onTap: () => onTabChange(t.$1),
                ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        // 2-column grid for the remaining sections — built as a Wrap
        // of FixedExtentColumns instead of GridView so the children
        // size naturally to their content (the prototype's cards are
        // variable height).
        LayoutBuilder(
          builder: (ctx, constraints) {
            const gap = 10.0;
            // Desktop wide layout (>=1000px): render the hub tile list as a
            // multi-column masonry grid instead of a stretched 2-column run.
            // Cap each tile at ~360px so wide windows read as a desktop grid;
            // narrow widths keep the existing 2-column arrangement untouched.
            final int columns;
            if (constraints.maxWidth >= 1000) {
              columns =
                  (constraints.maxWidth / 360).floor().clamp(2, 4);
            } else {
              columns = 2;
            }
            final cardW =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final s in grid)
                  SizedBox(width: cardW, child: _GridCard(section: s)),
              ],
            );
          },
        ),
        const SizedBox(height: 18),
        // Full-width editorial pull-quote, centered. (The "Read the booklet"
        // CTA was removed — the topic index + tabs above already lead into the
        // booklet content.)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: p.primaryTint,
            border: Border.all(color: p.primary.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '"Your directive is your voice — written in advance, '
                "kept safe, honored when you can't speak for yourself.\"",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Instrument Serif',
                  fontFamilyFallback: const ['Georgia', 'serif'],
                  fontStyle: FontStyle.italic,
                  fontSize: 19,
                  height: 1.3,
                  color: p.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '— PA OFFICE OF MENTAL HEALTH & SUBSTANCE ABUSE '
                'SERVICES · BOOKLET P.3',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace',
                  ],
                  fontSize: 10,
                  letterSpacing: 0.6,
                  color: p.textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class _CategoryPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: active ? p.primary : p.card,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(
              color: active ? p.primary : p.border,
            ),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: active ? p.onPrimary : p.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final EducationSection section;
  const _GridCard({required this.section});

  static IconData _iconFor(EducationCategory cat) {
    switch (cat) {
      case EducationCategory.glossary:
        return Icons.description_outlined;
      case EducationCategory.faq:
        return Icons.help_outline;
      case EducationCategory.checklist:
        return Icons.check_box_outlined;
      case EducationCategory.combined:
      case EducationCategory.declaration:
      case EducationCategory.poa:
        return Icons.assignment_outlined;
      case EducationCategory.supplementary:
        return Icons.psychology_outlined;
      case EducationCategory.intro:
        return Icons.menu_book;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _SectionDetailRoute(section: section),
          ),
        ),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: p.border),
            borderRadius:
                BorderRadius.circular(DesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(_iconFor(section.category),
                    size: 16, color: p.primary),
              ),
              const SizedBox(height: 10),
              Text(
                section.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                  height: 1.2,
                  color: p.text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _previewOf(section.content),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 11.5,
                  height: 1.4,
                  color: p.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionDetailRoute extends StatelessWidget {
  final EducationSection section;
  const _SectionDetailRoute({required this.section});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final source = section.category == EducationCategory.supplementary
        ? 'BEYOND THE BOOKLET'
        : 'FROM THE OFFICIAL BOOKLET';
    return Scaffold(
      appBar: AppBar(title: Text(section.title)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Source line (artboard WebArticle).
          Text(
            source,
            style: TextStyle(
              fontFamily: kMonoFamily,
              fontFamilyFallback: const [
                'Consolas',
                'Menlo',
                'Courier New',
                'monospace',
              ],
              fontSize: 10.5,
              letterSpacing: 0.6,
              fontWeight: FontWeight.w700,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            section.title,
            style: const TextStyle(
              fontFamily: 'Instrument Serif',
              fontFamilyFallback: ['Georgia', 'serif'],
              fontStyle: FontStyle.italic,
              fontSize: 30,
              fontWeight: FontWeight.w400,
              height: 1.05,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            section.content,
            style: const TextStyle(
              fontFamily: kSansFamily,
              fontSize: 14.5,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          // "TRY IT — Ready to write yours?" inline CTA (artboard WebArticle).
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.primaryTint,
              border: Border.all(color: p.primaryLight),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRY IT',
                  style: TextStyle(
                    fontFamily: kMonoFamily,
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace',
                    ],
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: p.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ready to write yours?',
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'The guided wizard takes about 20 minutes and works '
                  'anonymously.',
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 13,
                    height: 1.5,
                    color: p.textMuted,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  // Close this article, then start the new-directive flow.
                  // (The detail route is pushed imperatively, so pop first —
                  // same pattern as the snap-to-fill → AI-setup hop.)
                  onPressed: () {
                    Navigator.of(context).pop();
                    appRouter.go(AppRoutes.home);
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Start my directive'),
                  style: FilledButton.styleFrom(
                    iconAlignment: IconAlignment.end,
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

/// Short preview taken from the first sentence of the first paragraph,
/// trimmed to keep grid cards visually consistent.
String _previewOf(String content) {
  final firstPara = content.split('\n\n').first.trim();
  final firstSentence =
      firstPara.split(RegExp(r'(?<=[.!?])\s+')).first.trim();
  if (firstSentence.length > 110) {
    return '${firstSentence.substring(0, 110)}…';
  }
  return firstSentence;
}

class _EducationSearchDelegate extends SearchDelegate<EducationSection?> {
  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: 'Clear search',
          onPressed: () => query = '',
        ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: 'Back',
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Type to search educational content...'),
      );
    }
    final q = query.toLowerCase();
    final results = allEducationSections
        .where((s) =>
            s.title.toLowerCase().contains(q) ||
            s.content.toLowerCase().contains(q))
        .toList();

    if (results.isEmpty) {
      return _emptyArt(SpotArt.search, 'No results for "$query"');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () => close(context, results[i]),
        child: SectionTile(section: results[i]),
      ),
    );
  }
}

/// Centered empty/no-results state with a themeable spot illustration above the
/// message. Visual only — replaces the previous bare centered text.
Widget _emptyArt(SpotArt art, String message) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpotIllustration(art: art, size: 88),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
