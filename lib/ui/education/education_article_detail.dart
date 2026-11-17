import 'package:flutter/material.dart';
import 'package:mhad/ui/ai/ai_step_helper.dart' show showAiSheet;
import 'package:mhad/ui/ai/ai_question_handoff.dart';
import 'package:mhad/ai/gemini_api_assistant.dart';
import 'package:mhad/ai/handoff/ai_handoff_data.dart';
import 'package:mhad/ui/widgets/design/back_link.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/rich_content_text.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_art.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/art_image.dart';

/// The ONE article-detail screen for [EducationSection]s (2026-07-11 UX
/// audit C4). Previously the same content rendered through two different
/// screens depending on entry path — the editorial `_SectionDetailRoute`
/// (grid tiles, search) vs a plain Material `_SectionDetailScreen`
/// (Browse-by-topic rows). This merges them: editorial layout (source
/// line, serif headline, Try-it CTA) plus the P&A contact footer the
/// Material variant carried.
class ArticleDetailScreen extends StatelessWidget {
  final EducationSection section;

  /// The article's AI help in a sheet: three questions about it, the
  /// question box and the copy-and-paste card; the AI is told which article
  /// the person is reading (ai_handoff.json "articleContext").
  void _askAboutArticle(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final articleLine = AiHandoffData.instance
        .text(lang, 'articleContext')
        .replaceAll('{title}', section.title);
    final t = Theme.of(context).textTheme;
    showAiSheet(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.learnAskAiTitle, style: t.titleMedium),
          const SizedBox(height: 4),
          Text(section.title, style: t.bodySmall),
          const SizedBox(height: 16),
          AiQuestionHandoff(
            suggestions: [
              context.l10n.articleAskAiQ1,
              context.l10n.articleAskAiQ2,
              context.l10n.articleAskAiQ3,
            ],
            ref: 'learn',
            panelTitle: context.l10n.askAiPanelTitle,
            panelSubtitle: context.l10n.askAiPanelSubtitle,
            instructions: () =>
                '${LlmAssistant.systemPromptFor(null)}\n$articleLine',
          ),
        ],
      ),
    );
  }
  const ArticleDetailScreen({required this.section, super.key});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final source = section.category == EducationCategory.supplementary
        ? context.l10n.educationSourceBeyondBooklet
        : context.l10n.educationSourceOfficialBooklet;
    return Scaffold(
      // A centered ~720px reading column (about 70 characters a line): the
      // article is pushed over Learn's FILL layout, so on a wide monitor the
      // text used to run the whole content width. The scrollbar stays at the
      // window edge because the padding, not a box, centers the column.
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BackLink(),
          Expanded(
            child: LayoutBuilder(
        builder: (context, box) {
          final side = box.maxWidth > _readingWidth + 40
              ? (box.maxWidth - _readingWidth) / 2
              : 20.0;
          return ListView(
        padding: EdgeInsets.fromLTRB(side, 20, side, 32),
        children: [
          // Category photo header (one definition: EducationCategoryArt).
          ArtImage(
            section.category.art,
            height: 180,
            expand: true,
            radius: DesignTokens.radiusLg,
          ),
          const SizedBox(height: 20),
          // Source line (artboard WebArticle).
          Text(
            source,
            style: TextStyle(
              fontSize: 12, letterSpacing: MhadType.trackingLabel,
              fontWeight: FontWeight.w700,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            section.title,
            style: EditorialHeading.styleFor(context, HeadingLevel.page),
          ),
          const SizedBox(height: 12),
          // Real bold + indented lists instead of raw `**` markers.
          RichContentText(
            section.content,
            style: const TextStyle(
              fontSize: 16, height: MhadType.leadingParagraph,
            ),
          ),
          const SizedBox(height: 24),
          // Ask AI about this article (copy-and-paste handoff) — on phones
          // too, where Learn had no AI entry before. API path hidden only;
          // with it shown, Learn's chat panel covers this.
          if (!appData.ai.apiModeVisible) ...[
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: OutlinedButton.icon(
                onPressed: () => _askAboutArticle(context),
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: Text(context.l10n.articleAskAiButton),
              ),
            ),
            const SizedBox(height: 24),
          ],
          // "TRY IT — Ready to write yours?" inline CTA (artboard WebArticle).
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.primaryTint,
              border: Border.all(color: p.primaryLight),
              borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.educationArticleDetailTryIt,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700, letterSpacing: MhadType.trackingLabel,
                    color: p.primary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.l10n.educationArticleDetailReadyToWriteYours,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  context.l10n.educationArticleDetailTheGuidedWizardTakesAbout,
                  style: TextStyle(
                    fontSize: 14, height: MhadType.leadingParagraph,
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
                  label: Text(context.l10n.educationArticleDetailStartMyDirective),
                  style: FilledButton.styleFrom(
                    iconAlignment: IconAlignment.end,
                  ),
                ),
              ],
            ),
          ),
          // P&A contact footer (carried over from the retired Material
          // detail screen).
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            context.l10n.educationArticleDetailQuestionsContactPaProtectionAdvocacy(appData.phoneOf('paProtectionAdvocacy')),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
        ],
          );
        },
      ),
          ),
        ],
      ),
    );
  }

  /// Reading measure for the article column (~70 characters at 16px).
  static const double _readingWidth = 720;
}
