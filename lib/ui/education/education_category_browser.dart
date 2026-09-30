import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/ui/education/education_article_detail.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';

/// Top-level tab kinds shown above the editorial grid. Each owns its own
/// [filter] over [allEducationSections] so the hub and the screen-level
/// state agree on what "Articles" means (it's a five-category bucket,
/// not a single EducationCategory.intro mapping — that was the 2026-06-04
/// bug that buried 58 article sections behind a Search tap).
enum EducationTabKind {
  all,
  articles,
  glossary,
  faq,
  checklists;

  /// Categories included in this tab's bucket. Empty = no filter (the
  /// "All" tab returns every section).
  Set<EducationCategory> get _includes => switch (this) {
        EducationTabKind.all => const {},
        EducationTabKind.articles => const {
            EducationCategory.intro,
            EducationCategory.combined,
            EducationCategory.declaration,
            EducationCategory.poa,
            EducationCategory.supplementary,
          },
        EducationTabKind.glossary => const {EducationCategory.glossary},
        EducationTabKind.faq => const {EducationCategory.faq},
        EducationTabKind.checklists => const {EducationCategory.checklist},
      };

  /// Apply this tab's filter to [source] and return matching sections.
  List<EducationSection> filter(List<EducationSection> source) {
    final inc = _includes;
    if (inc.isEmpty) return List.of(source);
    return source.where((s) => inc.contains(s.category)).toList();
  }
}

/// 8-row index listing every [EducationCategory] with its section count
/// and a chevron. Tapping any row opens a page listing that category's
/// sections so the user can browse each topic bucket in isolation.
class BrowseByTopic extends StatelessWidget {
  const BrowseByTopic({super.key});

  static List<(EducationCategory, String, String)> _rows(BuildContext context) => [
    (EducationCategory.intro, context.l10n.eduBrowseIntroduction,
        context.l10n.eduBrowseWhatAnMhadIsAnd),
    (EducationCategory.combined, context.l10n.eduBrowseCombinedForm,
        context.l10n.eduBrowseBothAnAgentAndTreatment),
    (EducationCategory.declaration, context.l10n.declarationOnly,
        context.l10n.eduBrowseTreatmentPreferencesWithoutAnAgent),
    (EducationCategory.poa, context.l10n.eduBrowsePowerOfAttorney,
        context.l10n.eduBrowseAgentDesignationWithoutPreferences),
    (EducationCategory.faq, context.l10n.eduBrowseFrequentlyAsked,
        context.l10n.eduBrowseCommonQuestionsAboutMhads),
    (EducationCategory.glossary, context.l10n.eduBrowseGlossary,
        context.l10n.eduBrowseEveryLegalTermDefined),
    (EducationCategory.supplementary, context.l10n.eduBrowseBeyondTheBooklet,
        context.l10n.eduBrowseTopicsNotCoveredInThe),
    (EducationCategory.checklist, context.l10n.eduBrowseYourChecklist,
        context.l10n.eduBrowseStepByStepDistributionRevocation),
  ];

  /// Every row opens its own page listing that category's sections (the
  /// "Introduction" behavior), so each topic bucket browses in isolation.
  void _open(BuildContext context, EducationCategory cat) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => _CategoryListScreen(category: cat),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final rows = _rows(context);
    return Container(
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            _BrowseRow(
              category: rows[i].$1,
              title: rows[i].$2,
              sub: rows[i].$3,
              count: allEducationSections
                  .where((s) => s.category == rows[i].$1)
                  .length,
              onTap: () => _open(context, rows[i].$1),
            ),
            if (i < rows.length - 1)
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
      label: context.l10n.educationCategoryBrowserSections(title, count, sub),
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
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      sub,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 12,
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
                  borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
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
                    fontSize: 11,
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
          ? Center(
              child: Text(
                context.l10n.educationCategoryBrowserNoSectionsInThisCategory,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sections.length,
              itemBuilder: (context, i) =>
                  SectionTile(section: sections[i]),
            ),
    );
  }
}

/// Compact card for one [EducationSection] in a list — category badge,
/// title, and a two-line preview. Shared by the hub's filtered/search
/// views and the category-browser sub-flow. Tapping opens
/// [_SectionDetailScreen] as a fullscreen dialog.
class SectionTile extends StatelessWidget {
  final EducationSection section;
  const SectionTile({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${section.category.displayName}: ${section.title}',
      child: HoverLift(
        radius: 12,
        child: Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            fullscreenDialog: true,
            // One shared editorial detail screen for every entry path
            // (UX audit C4 — the Material variant was retired).
            builder: (_) => ArticleDetailScreen(section: section),
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
        borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        category.displayName,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
