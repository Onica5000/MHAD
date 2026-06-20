import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_assistant.dart'
    show AssistantContext, ChatMessage, MessageRole;
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/assistant/assistant_send.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/design/bottom_nav.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
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
    final hub = _filteredSections.isEmpty
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
          );

    return Scaffold(
      bottomNavigationBar: const MhadBottomNav(),
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
              const _LearnAiPanel(),
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
            fontFamily: kSansFamily,
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
        _BrowseByTopic(onTabChange: onTabChange),
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
                        fontFamily: kSansFamily,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sub,
                      style: TextStyle(
                        fontFamily: kSansFamily,
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
                    fontFamily: kMonoFamily,
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
              const SizedBox(height: 8),
              Text(
                '${_estimatedMinutes(section.content)} MIN',
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

/// Right-side AI assistant rail on the wide Learn page, so users can ask
/// questions while reading. Shares the global conversation state with the
/// full AI Assistant screen.
class _LearnAiPanel extends ConsumerStatefulWidget {
  const _LearnAiPanel();

  @override
  ConsumerState<_LearnAiPanel> createState() => _LearnAiPanelState();
}

class _LearnAiPanelState extends ConsumerState<_LearnAiPanel> {
  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    final result = await sendAssistantMessage(
      ref,
      text: text,
      // No directive context on the Learn page — just a general "learning"
      // session. PII is stripped downstream regardless.
      assistantContext: const AssistantContext(stepName: 'Learning'),
      requestConsent: () => showAiConsentDialog(context),
      onSent: _scrollToBottom,
    );
    if (!mounted) return;
    if (result.needsKey) {
      _inputCtrl.text = text;
      context.push(AppRoutes.aiSetup);
      return;
    }
    if (result.consentDeclined || result.alreadySending) {
      _inputCtrl.text = text;
      return;
    }
    if (result.blockReason != null) {
      _inputCtrl.text = text;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.blockReason!),
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final messages = ref.watch(conversationProvider);
    final isSending = ref.watch(isSendingProvider);
    final hasKey = ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty ?? false;

    return Container(
      width: 340,
      decoration: BoxDecoration(
        color: p.card,
        border: Border(left: BorderSide(color: p.border)),
      ),
      child: SafeArea(
        left: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 4),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18, color: p.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Ask the AI',
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                ],
              ),
            ),
            // Mirror the wizard step rail's AI-panel header — the
            // "GEMINI · PII STRIPPED" badge — for a consistent AI panel
            // across the app. (The "not advice" line moves down by the input.)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 12),
              child: Text(
                '● GEMINI · PII STRIPPED',
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace',
                  ],
                  fontSize: 9.5,
                  letterSpacing: 0.5,
                  color: hasKey ? p.primary : p.textMuted,
                ),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          hasKey
                              ? 'Ask a question to get started — e.g. "What\'s '
                                  'the difference between a declaration and a '
                                  'power of attorney?"'
                              : 'Set up the free AI assistant to ask questions '
                                  'while you read.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 12.5,
                            height: 1.5,
                            color: p.textMuted,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollCtrl,
                      padding: const EdgeInsets.all(12),
                      itemCount: messages.length + (isSending ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == messages.length) {
                          return Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text('…',
                                style: TextStyle(color: p.textMuted)),
                          );
                        }
                        return _LearnChatBubble(message: messages[i]);
                      },
                    ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: hasKey
                  ? Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputCtrl,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: isSending ? null : _send,
                            decoration: const InputDecoration(
                              hintText: 'Ask a question…',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed:
                              isSending ? null : () => _send(_inputCtrl.text),
                          icon: const Icon(Icons.send, size: 18),
                        ),
                      ],
                    )
                  : SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => context.push(AppRoutes.aiSetup),
                        icon: const Icon(Icons.auto_awesome, size: 18),
                        label: const Text('Set up AI assistant'),
                      ),
                    ),
            ),
            // Disclaimer by the input, mirroring the wizard step rail.
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
              child: Text(
                'Not legal or medical advice.',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 10.5,
                  color: p.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact chat bubble for the Learn-page AI rail.
class _LearnChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _LearnChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final isUser = message.role == MessageRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color: isUser ? p.primary : p.surface,
          border: isUser ? null : Border.all(color: p.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 12.5,
            height: 1.4,
            color: isUser ? p.onPrimary : p.text,
          ),
        ),
      ),
    );
  }
}
