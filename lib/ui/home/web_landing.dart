import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// Editorial web landing — a faithful Flutter port of the Claude Design
/// `WebDashboard` (web.jsx). Rendered as the Home screen's WIDE (desktop/web)
/// empty-state, for first-time / no-directive users. Returning users (with
/// drafts or past directives) keep the draft/past dashboard.
///
/// Pieces, top to bottom, mirror the artboard:
///   - anonymous-mode tinted banner (web/public sessions)
///   - editorial serif hero "Make a mental health advance directive."
///   - 2-column form choice: bold primary "Combined" card (★ watermark,
///     Recommended badge) + stacked Declaration-only / POA-only cards
///   - 3-column tools row
///   - "Our privacy promise" grid + "From the booklet" pull-quote
class WebDashboardLanding extends ConsumerWidget {
  final bool isPublic;
  const WebDashboardLanding({required this.isPublic, super.key});

  Future<void> _start(
      BuildContext context, WidgetRef ref, FormType type) async {
    final id =
        await ref.read(directiveRepositoryProvider).createDirective(type);
    if (context.mounted) context.go(AppRoutes.wizardRoute(id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final aiReady =
        ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty ?? false;

    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 32, 40, 60),
      children: [
        if (isPublic) ...[
          _AnonBanner(),
          const SizedBox(height: 22),
        ],

        // ── Editorial hero ───────────────────────────────────────────────
        const SectionLabel('Pennsylvania · Act 194 of 2004'),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Make a mental health '),
            TextSpan(
                text: 'advance directive.',
                style: TextStyle(color: p.primary)),
          ]),
          style: const TextStyle(
            fontFamily: 'Instrument Serif',
            fontFamilyFallback: ['Georgia', 'serif'],
            fontStyle: FontStyle.italic,
            fontSize: 52,
            height: 1,
            letterSpacing: -1,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 14),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Text(
            'A legal document that tells doctors, family, and a person you '
            'trust how to care for you if you can’t speak for yourself. '
            'Free, anonymous, and takes about 20 minutes.',
            style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                height: 1.5,
                color: p.textMuted),
          ),
        ),
        const SizedBox(height: 24),

        // ── 2-column form choice ─────────────────────────────────────────
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 14,
                child: _CombinedCard(
                  onStart: () => _start(context, ref, FormType.combined),
                  onSee: () => context.go(AppRoutes.formTypeSelection),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 10,
                child: Column(
                  children: [
                    Expanded(
                      child: _SingleFormCard(
                        icon: Icons.description_outlined,
                        title: 'Declaration only',
                        sub: 'Treatment preferences without naming an agent.',
                        onTap: () =>
                            _start(context, ref, FormType.declaration),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: _SingleFormCard(
                        icon: Icons.people_alt_outlined,
                        title: 'Power of attorney only',
                        sub: 'Name a decision-maker without listing '
                            'preferences.',
                        // POA carries a statutory warning that lives on the
                        // form-type screen — route there so it isn't skipped.
                        onTap: () => context.go(AppRoutes.formTypeSelection),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ── 3-column tools row ───────────────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ToolCard(
                icon: Icons.auto_awesome,
                title: 'AI assistant',
                sub: 'Plain-language explanations, suggested wording for any '
                    'field.',
                cta: 'Open assistant',
                onTap: () => context.go(
                    aiReady ? AppRoutes.assistant : AppRoutes.aiSetup),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ToolCard(
                icon: Icons.menu_book_outlined,
                title: 'Learn first',
                sub: 'A 4-minute primer on what an MHAD is and how it works.',
                cta: 'Read the basics',
                onTap: () => context.go(AppRoutes.education),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _ToolCard(
                icon: Icons.download_outlined,
                title: 'Print the blank form',
                sub: 'Prefer paper? Start a form and print it to fill by hand.',
                cta: 'Start a form',
                onTap: () => context.go(AppRoutes.formTypeSelection),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // ── Privacy promise + booklet quote ──────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 14, child: _PrivacyPromiseCard()),
            const SizedBox(width: 18),
            Expanded(
              flex: 10,
              child: _BookletQuoteCard(
                onRead: () => context.go(AppRoutes.education),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Anonymous-mode banner (calm, tinted) ──────────────────────────────────
class _AnonBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: p.primaryTint,
        border: Border.all(color: p.primaryLight),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: p.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock_outline, size: 16, color: p.onPrimary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You’re working anonymously. Nothing is saved.',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.text),
                ),
                const SizedBox(height: 1),
                Text(
                  'No account, no cloud, no cookies. Close the tab and '
                  'everything is gone — download your PDF before you leave.',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      height: 1.4,
                      color: p.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Bold primary "Combined directive" card with ★ watermark ───────────────
class _CombinedCard extends StatelessWidget {
  final VoidCallback onStart;
  final VoidCallback onSee;
  const _CombinedCard({required this.onStart, required this.onSee});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(color: p.primary),
        child: Stack(
          children: [
            // Oversized decorative serif star, low opacity.
            Positioned(
              right: -10,
              top: -70,
              child: Text(
                '★',
                style: TextStyle(
                  fontFamily: 'Instrument Serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 240,
                  height: 1,
                  color: p.onPrimary.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: p.onPrimary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'RECOMMENDED',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: p.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Combined directive',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: p.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Treatment preferences and a trusted decision-maker, in '
                    'one document. 9 short steps · about 20 minutes.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13.5,
                      height: 1.5,
                      color: p.onPrimary.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: onStart,
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        label: const Text('Start now'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: p.primaryDark,
                          iconAlignment: IconAlignment.end,
                          minimumSize: const Size(0, 44),
                          padding:
                              const EdgeInsets.symmetric(horizontal: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: onSee,
                        style: TextButton.styleFrom(
                          foregroundColor: p.onPrimary,
                          minimumSize: const Size(0, 44),
                        ),
                        child: const Text('See the form'),
                      ),
                    ],
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

// ── Declaration / POA single-form card ────────────────────────────────────
class _SingleFormCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  const _SingleFormCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: p.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        height: 1.4,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 14, color: p.primary),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tool card (3-column row) ───────────────────────────────────────────────
class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String sub;
  final String cta;
  final VoidCallback onTap;
  const _ToolCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: p.primaryTint,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: p.primary),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.text),
              ),
              const SizedBox(height: 3),
              Text(
                sub,
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    height: 1.4,
                    color: p.textMuted),
              ),
              const SizedBox(height: 10),
              Text(
                '$cta →',
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── "Our privacy promise" 2×2 grid ─────────────────────────────────────────
class _PrivacyPromiseCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    const rows = <(IconData, String, String)>[
      (Icons.lock_outline, 'No account required',
          'No email, no password, no sign-up.'),
      (Icons.shield_outlined, 'Nothing leaves your browser',
          'Your answers live in this tab. We never see them.'),
      (Icons.block, 'No cookies, no tracking',
          'No analytics, no third-party scripts.'),
      (Icons.download_outlined, 'You keep the file',
          'Download the PDF — that’s the only copy.'),
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionLabel('Our privacy promise'),
          const SizedBox(height: 12),
          // Fixed 2×2 grid via two plain Rows.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PromiseItem(row: rows[0])),
              const SizedBox(width: 10),
              Expanded(child: _PromiseItem(row: rows[1])),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _PromiseItem(row: rows[2])),
              const SizedBox(width: 10),
              Expanded(child: _PromiseItem(row: rows[3])),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Single privacy-promise item (icon + title + sub) ──────────────────────
class _PromiseItem extends StatelessWidget {
  final (IconData, String, String) row;
  const _PromiseItem({required this.row});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final (icon, title, sub) = row;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: p.primaryTint,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 14, color: p.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.text),
              ),
              const SizedBox(height: 1),
              Text(
                sub,
                style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    height: 1.4,
                    color: p.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── "From the booklet" serif pull-quote ────────────────────────────────────
class _BookletQuoteCard extends StatelessWidget {
  final VoidCallback onRead;
  const _BookletQuoteCard({required this.onRead});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('From the booklet'),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
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
                '“An MHAD is your voice when you can’t speak for '
                'yourself.”',
                style: TextStyle(
                  fontFamily: 'Instrument Serif',
                  fontFamilyFallback: const ['Georgia', 'serif'],
                  fontStyle: FontStyle.italic,
                  fontSize: 22,
                  height: 1.2,
                  color: p.primaryDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '— PA MHAD booklet · Office of Mental Health',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 11.5,
                  letterSpacing: 0.3,
                  color: p.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: onRead,
                style: TextButton.styleFrom(
                  foregroundColor: p.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 36),
                  alignment: Alignment.centerLeft,
                ),
                child: const Text('Read 4-min summary →'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
