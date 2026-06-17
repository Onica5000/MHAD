import 'package:flutter/material.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/bottom_nav.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

class EducationScreen extends StatefulWidget {
  /// If set, only show sections matching these IDs (deep-link from wizard Help).
  final List<String>? filterIds;

  const EducationScreen({this.filterIds, super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  // Selected tab (top-level enum, see [_TabKind]). Defaults to .all so
  // the user sees every available section on first arrival.
  _TabKind _activeTab = _TabKind.all;

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
        appBar: AppBar(title: const Text('Help')),
        body: _filteredSections.isEmpty
            ? const Center(
                child: Text(
                  'No results found.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _filteredSections.length,
                itemBuilder: (context, i) =>
                    _SectionTile(section: _filteredSections[i]),
              ),
      );
    }
    return Scaffold(
      bottomNavigationBar: const MhadBottomNav(),
      body: Column(
        children: [
          const CrisisTopBar(compact: true),
          Expanded(
            child: _filteredSections.isEmpty
                ? const Center(
                    child: Text(
                      'No results found.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  )
                : _EditorialLearnHub(
                    sections: _filteredSections,
                    activeTab: _activeTab,
                    onTabChange: (t) => setState(() => _activeTab = t),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Editorial Learn-hub body matching prototype `ScrLearn`
/// (mobile-extra.jsx::ScrLearn L882-1029).
///
/// Stacks: editorial header → inline search pill → horizontal category-
/// tab row → 2-column section grid with a primary-filled featured card
/// spanning both columns → "Glossary · quick reference" mini-list →
/// "Frequently asked" teaser → italic pull-quote card.
///
/// Replaces the prior Dropdown category picker + flat ListView with the
/// prototype's grid + tabs layout. Existing search delegate stays
/// available via the AppBar search button.
class _EditorialLearnHub extends StatelessWidget {
  final List<EducationSection> sections;
  final _TabKind activeTab;
  final ValueChanged<_TabKind> onTabChange;

  const _EditorialLearnHub({
    required this.sections,
    required this.activeTab,
    required this.onTabChange,
  });

  // Five category pills shown above the grid. Articles is a multi-cat
  // bucket (intro + combined + declaration + poa + supplementary) — the
  // mapping lives on _TabKind itself so the screen-level filter and the
  // hub agree on what each tab means.
  static const _tabs = <(_TabKind, String)>[
    (_TabKind.all, 'All'),
    (_TabKind.articles, 'Articles'),
    (_TabKind.glossary, 'Glossary'),
    (_TabKind.faq, 'FAQ'),
    (_TabKind.checklists, 'Checklists'),
  ];

  /// Returns up to 3 glossary entries to surface inline below the grid.
  /// Falls back to fewer when fewer are available.
  List<(String, String)> _quickGlossary() {
    final all =
        sections.where((s) => s.category == EducationCategory.glossary);
    return all.take(3).map((g) {
      final firstPara = g.content.split('\n\n').first.trim();
      final firstSentence =
          firstPara.split(RegExp(r'(?<=[.!?])\s+')).first.trim();
      return (g.title, firstSentence);
    }).toList();
  }

  /// Picks the section to render as the prototype's featured card —
  /// the first section in the filtered list (which is typically the
  /// "intro_overview" intro).
  EducationSection? _featured() => sections.isEmpty ? null : sections.first;

  /// Every section after the featured one. No cap — earlier builds
  /// truncated to 8, which buried 50+ articles behind a Search tap.
  /// "All" therefore shows the entire library; each filtered tab shows
  /// its full bucket.
  List<EducationSection> _gridSections() {
    if (sections.length <= 1) return const [];
    return sections.skip(1).toList();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final featured = _featured();
    final grid = _gridSections();
    final glossary = _quickGlossary();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
      children: [
        const SectionLabel('Learn'),
        Text.rich(
          TextSpan(
            children: [
              const TextSpan(text: 'Understand '),
              TextSpan(text: 'before', style: TextStyle(color: p.primary)),
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
          'Everything below comes verbatim from the official PA MHAD booklet. '
          'No marketing, no opinions — just the rules and what they mean.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13.5,
            height: 1.5,
            color: p.textMuted,
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
                        fontFamily: 'DM Sans',
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
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < _tabs.length; i++) ...[
                _CategoryPill(
                  label: _tabs[i].$2,
                  active: activeTab == _tabs[i].$1,
                  onTap: () => onTabChange(_tabs[i].$1),
                ),
                if (i < _tabs.length - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (featured != null) ...[
          _FeaturedCard(section: featured),
          const SizedBox(height: 10),
        ],
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
        if (glossary.isNotEmpty) ...[
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(child: SectionLabel('Glossary · quick reference')),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => onTabChange(_TabKind.glossary),
                  child: Text(
                    'See all ›',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: p.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          for (final (term, def) in glossary) ...[
            _GlossaryRow(term: term, definition: def),
            const SizedBox(height: 6),
          ],
        ],
        const SizedBox(height: 14),
        // FAQ teaser
        _FaqTeaser(onTap: () => onTabChange(_TabKind.faq)),
        const SizedBox(height: 18),
        // Editorial pull-quote with a "Read the booklet" CTA (artboard
        // WebLearn). The CTA opens the booklet's intro article — the hub
        // content is the official booklet verbatim — or falls back to the
        // Articles bucket if there's no featured section.
        // Full-width editorial pull-quote: the quote text spans the whole card
        // so it always reads horizontally, with the "Read the booklet" CTA on
        // its own line below. (An earlier side-by-side Row squeezed the quote
        // next to the button at moderate widths, wrapping it one or two words
        // per line — it looked vertical.)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          decoration: BoxDecoration(
            color: p.primaryTint,
            border: Border.all(color: p.primary.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"Your directive is your voice — written in advance, '
                "kept safe, honored when you can't speak for yourself.\"",
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
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
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
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: () {
                    if (featured != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => _SectionDetailRoute(section: featured),
                      ));
                    } else {
                      onTabChange(_TabKind.articles);
                    }
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('Read the booklet'),
                  style: FilledButton.styleFrom(
                    iconAlignment: IconAlignment.end,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Comprehensive topic index — always visible so users have a
        // jump-list to any of the 8 EducationCategory buckets after the
        // editorial grid. Earlier builds only surfaced 9 sections out of
        // 136; this row guarantees the full library remains one tap away
        // (2026-06-04 fix per user direction "make sure ALL that
        // information is available").
        const SizedBox(height: 24),
        const SectionLabel('Browse all topics'),
        const SizedBox(height: 8),
        _BrowseByTopic(onTabChange: onTabChange),
      ],
    );
  }

}

/// 8-row index listing every [EducationCategory] with its section count
/// and a chevron. Tapping a row that maps onto a top-level tab switches
/// the hub to that tab; rows for sub-buckets inside Articles (Combined /
/// Declaration / POA / Supplementary) push a filtered list so the user
/// can browse that sub-bucket in isolation.
class _BrowseByTopic extends StatelessWidget {
  final ValueChanged<_TabKind> onTabChange;
  const _BrowseByTopic({required this.onTabChange});

  static const _rows = <(EducationCategory, String, String)>[
    (EducationCategory.intro, 'Introduction',
        'What an MHAD is and who should sign one'),
    (EducationCategory.combined, 'Combined Form',
        'Both an agent and treatment preferences'),
    (EducationCategory.declaration, 'Declaration Only',
        'Treatment preferences without an agent'),
    (EducationCategory.poa, 'Power of Attorney',
        'Agent designation without preferences'),
    (EducationCategory.faq, 'Frequently Asked',
        'Common questions about MHADs'),
    (EducationCategory.glossary, 'Glossary',
        'Every legal term, defined'),
    (EducationCategory.supplementary, 'Beyond the Booklet',
        'Topics not covered in the official PA booklet'),
    (EducationCategory.checklist, 'Your Checklist',
        'Step-by-step distribution + revocation guides'),
  ];

  /// Maps an [EducationCategory] onto the top-level [_TabKind] whose
  /// filter includes it. For sub-buckets of Articles we still need a way
  /// to surface JUST that sub-bucket — we push a `_CategoryListScreen`
  /// instead of switching tabs (the Articles tab itself is a 5-cat blend).
  void _open(BuildContext context, EducationCategory cat) {
    switch (cat) {
      case EducationCategory.intro:
      case EducationCategory.combined:
      case EducationCategory.declaration:
      case EducationCategory.poa:
      case EducationCategory.supplementary:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => _CategoryListScreen(category: cat),
        ));
      case EducationCategory.glossary:
        onTabChange(_TabKind.glossary);
      case EducationCategory.faq:
        onTabChange(_TabKind.faq);
      case EducationCategory.checklist:
        onTabChange(_TabKind.checklists);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < _rows.length; i++) ...[
            _BrowseRow(
              category: _rows[i].$1,
              title: _rows[i].$2,
              sub: _rows[i].$3,
              count: allEducationSections
                  .where((s) => s.category == _rows[i].$1)
                  .length,
              onTap: () => _open(context, _rows[i].$1),
            ),
            if (i < _rows.length - 1)
              Divider(height: 1, color: p.border),
          ],
        ],
      ),
    );
  }
}

class _BrowseRow extends StatelessWidget {
  final EducationCategory category;
  final String title;
  final String sub;
  final int count;
  final VoidCallback onTap;

  const _BrowseRow({
    required this.category,
    required this.title,
    required this.sub,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      label: '$title, $count sections. $sub',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sub,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11.5,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Section count chip on the right — prototype mono caption
              // style so it reads as a count, not a button.
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace',
                    ],
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                    color: p.primary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, size: 18, color: p.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// Standalone list of every [EducationSection] in a single
/// [EducationCategory] sub-bucket. Used when the user taps a row inside
/// the Articles bucket (intro / combined / declaration / poa /
/// supplementary) — those don't have their own top-level tab so we
/// route through a dedicated screen instead of switching the hub.
class _CategoryListScreen extends StatelessWidget {
  final EducationCategory category;
  const _CategoryListScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    final sections = allEducationSections
        .where((s) => s.category == category)
        .toList();
    return Scaffold(
      appBar: AppBar(title: Text(category.displayName)),
      body: sections.isEmpty
          ? const Center(
              child: Text(
                'No sections in this category yet.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sections.length,
              itemBuilder: (context, i) =>
                  _SectionTile(section: sections[i]),
            ),
    );
  }
}

/// Top-level tab kinds shown above the editorial grid. Each owns its own
/// [filter] over [allEducationSections] so the hub and the screen-level
/// state agree on what "Articles" means (it's a five-category bucket,
/// not a single EducationCategory.intro mapping — that was the 2026-06-04
/// bug that buried 58 article sections behind a Search tap).
enum _TabKind {
  all,
  articles,
  glossary,
  faq,
  checklists;

  /// Categories included in this tab's bucket. Empty = no filter (the
  /// "All" tab returns every section).
  Set<EducationCategory> get _includes => switch (this) {
        _TabKind.all => const {},
        _TabKind.articles => const {
            EducationCategory.intro,
            EducationCategory.combined,
            EducationCategory.declaration,
            EducationCategory.poa,
            EducationCategory.supplementary,
          },
        _TabKind.glossary => const {EducationCategory.glossary},
        _TabKind.faq => const {EducationCategory.faq},
        _TabKind.checklists => const {EducationCategory.checklist},
      };

  /// Apply this tab's filter to [source] and return matching sections.
  List<EducationSection> filter(List<EducationSection> source) {
    final inc = _includes;
    if (inc.isEmpty) return List.of(source);
    return source.where((s) => inc.contains(s.category)).toList();
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
              fontFamily: 'DM Sans',
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

class _FeaturedCard extends StatelessWidget {
  final EducationSection section;
  const _FeaturedCard({required this.section});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: p.primary,
      borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => _SectionDetailRoute(section: section),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -22,
              child: ExcludeSemantics(
                child: Text(
                  '?',
                  style: TextStyle(
                    fontFamily: 'Instrument Serif',
                    fontFamilyFallback: const ['Georgia', 'serif'],
                    fontStyle: FontStyle.italic,
                    fontSize: 130,
                    height: 1,
                    fontWeight: FontWeight.w400,
                    color: p.onPrimary.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: p.onPrimary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.menu_book,
                        size: 18, color: p.onPrimary),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    section.title,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      height: 1.2,
                      color: p.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _previewOf(section.content),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      height: 1.4,
                      color: p.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_estimatedMinutes(section.content)} MIN · MOST READ',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 10,
                      letterSpacing: 0.6,
                      color: p.onPrimary.withValues(alpha: 0.7),
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
                  fontFamily: 'DM Sans',
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
                  fontFamily: 'DM Sans',
                  fontSize: 11.5,
                  height: 1.4,
                  color: p.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_estimatedMinutes(section.content)} MIN',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
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
      ),
    );
  }
}

class _GlossaryRow extends StatelessWidget {
  final String term;
  final String definition;
  const _GlossaryRow({required this.term, required this.definition});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              term,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontFamilyFallback: const [
                  'Consolas',
                  'Menlo',
                  'Courier New',
                  'monospace',
                ],
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
                color: p.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              definition,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                height: 1.4,
                color: p.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqTeaser extends StatelessWidget {
  final VoidCallback onTap;
  const _FaqTeaser({required this.onTap});

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
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.help_outline,
                    size: 15, color: p.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently asked',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    Text(
                      'Can I change it later? Does it expire? Tap to read.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11.5,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: p.textMuted),
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
          // Source + read-time line (artboard WebArticle).
          Text(
            '$source · ${_estimatedMinutes(section.content)} MIN READ',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
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
              fontFamily: 'DM Sans',
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
                    fontFamily: 'JetBrains Mono',
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
                    fontFamily: 'DM Sans',
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
                    fontFamily: 'DM Sans',
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

/// Estimate reading time in minutes based on a 200 wpm cadence —
/// matches the prototype's "N MIN" mono caption convention.
int _estimatedMinutes(String content) {
  final words =
      content.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  final mins = (words / 200).ceil();
  return mins < 1 ? 1 : mins;
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

class _SectionTile extends StatelessWidget {
  final EducationSection section;
  const _SectionTile({required this.section});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${section.category.displayName}: ${section.title}',
      child: Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => _SectionDetailScreen(section: section),
          ),
        ),
        // ≥48px tap target for the whole card per a11y guideline; the
        // visible content (badge + title + preview) sizes naturally inside.
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _CategoryBadge(category: section.category),
                  const Spacer(),
                  ExcludeSemantics(
                    child: Icon(Icons.chevron_right, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                section.title,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                section.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final EducationCategory category;
  const _CategoryBadge({required this.category});

  Color _color(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    switch (category) {
      case EducationCategory.intro:
        return cs.primary;
      case EducationCategory.faq:
        return cs.secondary;
      case EducationCategory.combined:
        return cs.tertiary;
      case EducationCategory.declaration:
        return cs.primary;
      case EducationCategory.poa:
        return cs.secondary;
      case EducationCategory.glossary:
        return cs.onSurfaceVariant;
      case EducationCategory.supplementary:
        return cs.tertiary;
      case EducationCategory.checklist:
        return cs.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _color(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        category.displayName,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SectionDetailScreen extends StatelessWidget {
  final EducationSection section;
  const _SectionDetailScreen({required this.section});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(section.category.displayName)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CategoryBadge(category: section.category),
            const SizedBox(height: 12),
            Text(
              section.title,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              section.content,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(height: 1.6),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Questions? Contact PA Protection & Advocacy: ${appData.phoneOf('paProtectionAdvocacy')}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
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
      return Center(
        child: Text('No results for "$query"'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: results.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () => close(context, results[i]),
        child: _SectionTile(section: results[i]),
      ),
    );
  }
}
