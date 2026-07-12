import 'package:flutter/material.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// The ONE article-detail screen for [EducationSection]s (2026-07-11 UX
/// audit C4). Previously the same content rendered through two different
/// screens depending on entry path — the editorial `_SectionDetailRoute`
/// (grid tiles, search) vs a plain Material `_SectionDetailScreen`
/// (Browse-by-topic rows). This merges them: editorial layout (source
/// line, serif headline, Try-it CTA) plus the P&A contact footer the
/// Material variant carried.
class ArticleDetailScreen extends StatelessWidget {
  final EducationSection section;
  const ArticleDetailScreen({required this.section, super.key});

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
          // P&A contact footer (carried over from the retired Material
          // detail screen).
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            'Questions? Contact PA Protection & Advocacy: '
            '${appData.phoneOf('paProtectionAdvocacy')}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
