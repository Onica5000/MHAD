import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mhad/ui/widgets/design/status_views.dart';
import 'package:mhad/ui/widgets/design/photo_action_card.dart';
import 'package:mhad/ui/widgets/design/page_hero.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/widgets/rich_content_text.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/ui/education/education_article_detail.dart';
import 'package:mhad/ui/education/education_category_browser.dart';
import 'package:mhad/ui/education/learn_ai_panel.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';

class EducationScreen extends StatefulWidget {
  /// If set, only show sections matching these IDs (deep-link from wizard Help,
  /// or the start page's "Read the basics").
  final List<String>? filterIds;

  /// AppBar title for the filtered view. Defaults to the localized "Help"
  /// (wizard Help), but a deep-link can label it for its context
  /// (e.g. 'The basics').
  final String? filterTitle;

  const EducationScreen({this.filterIds, this.filterTitle, super.key});

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
    final isFiltered = widget.filterIds != null && widget.filterIds!.isNotEmpty;

    // Filtered view (deep-link from wizard Help) keeps the Material
    // AppBar with a back arrow — it's a narrow utility view, not the
    // prototype's Learn hub. The unfiltered hub matches prototype
    // ScrLearn: no AppBar, CrisisTopBar at top, inline search pill
    // already lives inside the body widget.
    if (isFiltered) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.filterTitle ?? context.l10n.educationHelpTitle),
        ),
        body: _filteredSections.isEmpty
            ? _emptyArt(context.l10n.educationNoResultsFound)
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _filteredSections.length,
                itemBuilder: (context, i) =>
                    SectionTile(section: _filteredSections[i]),
              ),
      );
    }
    final hub = _filteredSections.isEmpty
        ? _emptyArt(context.l10n.educationNoResultsFound)
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
          // Keyed off the TOTAL window width (the desktop-shell signal), like
          // every other fill screen: the sidebar already takes 232px, so the
          // old content-width check only showed the rail from ~1232px.
          final wide =
              MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint;
          // ...and only with room to spare beside the reading column.
          final showPanel = wide &&
              c.maxWidth >=
                  LearnAiPanel.width + LearnAiPanel.minReadingWidth;
          if (!showPanel) return hub;
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
  static List<(EducationTabKind, String)> _tabs(BuildContext context) => [
    (EducationTabKind.all, context.l10n.educationTabAll),
    (EducationTabKind.articles, context.l10n.educationTabArticles),
    (EducationTabKind.glossary, context.l10n.educationTabGlossary),
    (EducationTabKind.faq, context.l10n.educationTabFaq),
    (EducationTabKind.checklists, context.l10n.educationTabChecklists),
  ];

  /// All sections in the active filter, as grid tiles (the former "featured"
  /// intro card is now just the first tile). No cap.
  List<EducationSection> _gridSections() => sections;

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final grid = _gridSections();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      children: [
        // Hero: the Learn photo (a reading nook) beside the headline on wide
        // screens, a banner above it on phones.
        PageHero(
          art: AppArt.learnHero,
          size: PageHeroSize.large,
          eyebrow: context.l10n.navLearn,
          lead: context.l10n.educationMostOfThisComesStraight,
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: context.l10n.educationUnderstand),
                TextSpan(
                  text: context.l10n.educationBefore,
                  style: TextStyle(color: p.primary),
                ),
                TextSpan(text: context.l10n.educationYouSign),
              ],
            ),
            style: const TextStyle(
              fontFamily: kSerifFamily,
              fontFamilyFallback: kSerifFallbacks,
              fontStyle: FontStyle.italic,
              fontSize: 42,
              height: 1,
              letterSpacing: -0.8,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // The articles are the official PA booklet text (English-only JSON);
        // say so up front instead of letting Spanish mode silently switch
        // language mid-screen.
        if (Localizations.localeOf(context).languageCode != 'en') ...[
          const SizedBox(height: 12),
          InfoBanner(
            icon: Icons.translate,
            variant: InfoBannerVariant.info,
            text: context.l10n.educationArticlesInEnglishNotice,
          ),
        ],
        const SizedBox(height: 16),
        // Inline search pill — opens the existing search delegate.
        Builder(
          builder: (ctx) => Material(
            color: p.card,
            borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
            child: InkWell(
              borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
              onTap: () async {
                final result = await showSearch<EducationSection?>(
                  context: ctx,
                  delegate: _EducationSearchDelegate(),
                );
                if (result != null && ctx.mounted) {
                  unawaited(
                    Navigator.of(ctx).push(
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailScreen(section: result),
                      ),
                    ),
                  );
                }
              },
              child: Container(
                // 48pt minimum tap-target per a11y guideline (constraints
                // floor it; padding adds breathing room beyond).
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: p.border),
                  borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search, size: 16, color: p.textMuted),
                    const SizedBox(width: 10),
                    // Expanded + ellipsis: the Spanish hint overflowed a
                    // phone-width pill by 95px.
                    Expanded(
                      child: Text(
                        context.l10n.educationSearchArticlesGlossaryFaqs,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 14,
                          color: p.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
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
              for (final t in _tabs(context))
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
            // Desktop shell active (total window width), then as many
            // ~360px columns as the actual content width holds.
            if (MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint) {
              columns = (constraints.maxWidth / 360).floor().clamp(2, 4);
            } else {
              columns = 2;
            }
            // Rows of EQUAL height (cards in a row match the tallest; a
            // short last row is padded so card widths stay even).
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < grid.length; i += columns) ...[
                  if (i > 0) const SizedBox(height: gap),
                  EqualHeightRow(
                    gap: gap,
                    children: [
                      for (var j = i; j < i + columns; j++)
                        if (j < grid.length)
                          _GridCard(section: grid[j])
                        else
                          const SizedBox.shrink(),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
        const SizedBox(height: 22),
        // Comprehensive topic index — moved BELOW the grid (UX audit C4):
        // the pills are the hub's primary organizer for quick filtering;
        // this 8-way per-category index is the deep browse, so it no longer
        // competes with the pills at the top of the page.
        SectionLabel(context.l10n.educationBrowseAllTopics),
        const SizedBox(height: 8),
        const BrowseByTopic(),
        const SizedBox(height: 18),
        // Full-width editorial pull-quote, centered. (The "Read the booklet"
        // CTA was removed — the topic index + tabs above already lead into the
        // booklet content.)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          decoration: BoxDecoration(
            color: p.primaryTint,
            border: Border.all(color: p.primary.withValues(alpha: 0.15)),
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                context.l10n.educationYourDirectiveIsYourVoice,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kSerifFamily,
                  fontFamilyFallback: kSerifFallbacks,
                  fontStyle: FontStyle.italic,
                  fontSize: 18,
                  height: 1.3,
                  color: p.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.educationPaOfficeOfMentalHealth,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
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
      borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(color: active ? p.primary : p.border),
            borderRadius: BorderRadius.circular(DesignTokens.chipRadius),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 14,
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
            builder: (_) => ArticleDetailScreen(section: section),
          ),
        ),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _iconFor(section.category),
                  size: 16,
                  color: p.primary,
                ),
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
                plainExcerpt(section.content),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 12,
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

class _EducationSearchDelegate extends SearchDelegate<EducationSection?> {
  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(
      icon: const Icon(Icons.clear),
      tooltip: context.l10n.diagnosesClearSearch,
      onPressed: () => query = '',
    ),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    tooltip: context.l10n.back,
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Text(context.l10n.educationTypeToSearchEducationalContent),
      );
    }
    final q = query.toLowerCase();
    final results = allEducationSections
        .where(
          (s) =>
              s.title.toLowerCase().contains(q) ||
              s.content.toLowerCase().contains(q),
        )
        .toList();

    if (results.isEmpty) {
      return _emptyArt(context.l10n.educationNoResultsFor(query),
      );
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

/// Centered empty / no-results state: the shared EmptyState with the
/// "nothing found" photo (one definition for every empty state).
Widget _emptyArt(String message) => Center(
      child: EmptyState(
        icon: Icons.search,
        art: AppArt.learnEmpty,
        title: message,
      ),
    );
