import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// Article reader (v2 prototype `m-article`).
///
/// Full-screen reader with a 2 px reading-progress bar pinned at the top,
/// editorial italic title, attribution byline, body paragraphs, optional
/// pull-quote, and optional "TRY IT" CTA (per-article flag per v3).
class ArticleReaderScreen extends StatefulWidget {
  final Article article;
  final List<Article> upNext;

  const ArticleReaderScreen({
    required this.article,
    this.upNext = const [],
    super.key,
  });

  @override
  State<ArticleReaderScreen> createState() => _ArticleReaderScreenState();
}

class _ArticleReaderScreenState extends State<ArticleReaderScreen> {
  final _scroll = ScrollController();
  double _pct = 0.0;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    setState(() => _pct = (_scroll.offset / max).clamp(0.0, 1.0));
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final a = widget.article;

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'LEARN · ${a.minutes} MIN',
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontFamilyFallback: [
              'Consolas',
              'Menlo',
              'Courier New',
              'monospace',
            ],
            fontSize: 11,
            letterSpacing: 1,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: LinearProgressIndicator(
            value: _pct,
            minHeight: 2,
            backgroundColor: p.border,
            valueColor: AlwaysStoppedAnimation(p.primary),
          ),
        ),
        actions: const [
          // Bookmark + Share are placeholders for future article-level
          // affordances; tooltips are required by the button-label audit
          // even when disabled.
          IconButton(
            icon: Icon(Icons.bookmark_outline),
            tooltip: 'Bookmark (coming soon)',
            onPressed: null,
          ),
          IconButton(
            icon: Icon(Icons.share_outlined),
            tooltip: 'Share (coming soon)',
            onPressed: null,
          ),
        ],
      ),
      body: ListView(
        controller: _scroll,
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 80),
        children: [
          SectionLabel(a.sectionLabel ?? 'Most read · this week'),
          const SizedBox(height: 8),
          EditorialHeading(text: a.title, size: 34, height: 1.05),
          if (a.dek != null) ...[
            const SizedBox(height: 8),
            Text(
              a.dek!,
              style: TextStyle(
                fontFamily: 'Instrument Serif',
                fontFamilyFallback: const [
                  'Georgia',
                  'Times New Roman',
                  'serif',
                ],
                fontStyle: FontStyle.italic,
                fontSize: 18,
                color: p.textMuted,
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          if (a.attribution != null) _Byline(attribution: a.attribution!),
          const SizedBox(height: 6),
          const Divider(),
          const SizedBox(height: 14),
          for (final block in a.body) _renderBlock(context, block, p),
          if (a.tryIt != null) ...[
            const SizedBox(height: 18),
            _TryItCard(label: a.tryIt!.label, onPressed: a.tryIt!.onPressed),
          ],
          if (widget.upNext.isNotEmpty) ...[
            const SizedBox(height: 24),
            const SectionLabel('Up next'),
            const SizedBox(height: 6),
            for (final next in widget.upNext) _UpNextRow(article: next),
          ],
        ],
      ),
    );
  }

  Widget _renderBlock(BuildContext context, ArticleBlock block, MhadPalette p) {
    switch (block.kind) {
      case ArticleBlockKind.paragraph:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            block.text!,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 15,
              height: 1.65,
              color: p.text,
            ),
          ),
        );
      case ArticleBlockKind.subhead:
        return Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Text(
            block.text!,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: p.text,
              height: 1.3,
            ),
          ),
        );
      case ArticleBlockKind.pullQuote:
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 14),
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: p.primary, width: 3),
            ),
          ),
          child: Text(
            block.text!,
            style: TextStyle(
              fontFamily: 'Instrument Serif',
              fontFamilyFallback: const [
                'Georgia',
                'Times New Roman',
                'serif',
              ],
              fontStyle: FontStyle.italic,
              fontSize: 19,
              height: 1.45,
              color: p.primaryDark,
            ),
          ),
        );
      case ArticleBlockKind.bullets:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < block.items!.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '${i + 1}.',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: p.text,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          block.items![i],
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 15,
                            height: 1.6,
                            color: p.text,
                          ),
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
}

// ─── Article data model ────────────────────────────────────────────────────

enum ArticleBlockKind { paragraph, subhead, pullQuote, bullets }

class ArticleBlock {
  final ArticleBlockKind kind;
  final String? text;
  final List<String>? items;
  const ArticleBlock.paragraph(this.text)
      : kind = ArticleBlockKind.paragraph,
        items = null;
  const ArticleBlock.subhead(this.text)
      : kind = ArticleBlockKind.subhead,
        items = null;
  const ArticleBlock.pullQuote(this.text)
      : kind = ArticleBlockKind.pullQuote,
        items = null;
  const ArticleBlock.bullets(this.items)
      : kind = ArticleBlockKind.bullets,
        text = null;
}

class ArticleAttribution {
  final String name;
  final String avatarText;
  final String? sourceTag;
  const ArticleAttribution({
    required this.name,
    required this.avatarText,
    this.sourceTag,
  });
}

class ArticleTryIt {
  final String label;
  final VoidCallback onPressed;
  const ArticleTryIt({required this.label, required this.onPressed});
}

class Article {
  final String id;
  final String title;
  final String? dek;
  final int minutes;
  final String? sectionLabel;
  final ArticleAttribution? attribution;
  final List<ArticleBlock> body;
  final ArticleTryIt? tryIt;

  const Article({
    required this.id,
    required this.title,
    required this.minutes,
    required this.body,
    this.dek,
    this.sectionLabel,
    this.attribution,
    this.tryIt,
  });
}

// ─── Internal widgets ──────────────────────────────────────────────────────

class _Byline extends StatelessWidget {
  final ArticleAttribution attribution;
  const _Byline({required this.attribution});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: p.primaryLight,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            attribution.avatarText,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: p.onPrimaryLight,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Text(attribution.name,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  )),
              if (attribution.sourceTag != null) ...[
                const SizedBox(width: 8),
                Text(attribution.sourceTag!,
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
                    )),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TryItCard extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _TryItCard({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.primaryTint,
        border: Border.all(color: p.primaryLight),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, color: p.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Most people draft theirs in about 15 minutes. You can save '
              'and come back.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13.5,
                height: 1.45,
                color: p.text,
              ),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: Text(label),
            style: FilledButton.styleFrom(
              iconAlignment: IconAlignment.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _UpNextRow extends StatelessWidget {
  final Article article;
  const _UpNextRow({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.menu_book_outlined),
        title: Text(article.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${article.minutes} MIN',
            style: const TextStyle(
              fontFamily: 'JetBrains Mono',
              fontFamilyFallback: [
                'Consolas',
                'Menlo',
                'Courier New',
                'monospace',
              ],
              fontSize: 11,
              letterSpacing: 0.6,
            )),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ArticleReaderScreen(article: article),
          ),
        ),
      ),
    );
  }
}
