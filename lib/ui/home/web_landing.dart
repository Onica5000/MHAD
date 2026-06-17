import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/widgets/form_type_quiz.dart';

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
            fontSize: 56, // artboard WebDashboard hero size
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

        // ── Form choice (reusable — also shown on the returning dashboard so
        //    "Start a new directive" lands on the same picker) ──────────────
        const DirectiveFormChoice(),
        const SizedBox(height: 22),

        // ── Print the blank form (single tool — still being built out) ────
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: _ToolCard(
              icon: Icons.download_outlined,
              title: 'Print the blank form',
              sub: 'Prefer paper? Start a form and print it to fill by hand.',
              cta: 'Start a form',
              onTap: () => _start(context, ref, FormType.combined),
            ),
          ),
        ),
        const SizedBox(height: 22),

        // ── Privacy promise + booklet quote ──────────────────────────────
        // Both cards shrink-wrap (their Columns are mainAxisSize.min) so the
        // Row can measure their heights. Earlier they used the default
        // mainAxisSize.max, which under the Row's unbounded height blew up to
        // an infinite height ("BoxConstraints forces an infinite height") and
        // the whole section silently failed to paint — the bottom of the
        // dashboard went missing.
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

/// Reusable form-type picker — the bold "Combined" card + Declaration/POA
/// cards + the "Help me choose" quiz + a "you can switch later" line. Shown on
/// the empty dashboard ([WebDashboardLanding]) AND on the returning dashboard,
/// so picking a form type always happens on the dashboard (the form-type page
/// was retired and folded in here).
class DirectiveFormChoice extends ConsumerWidget {
  const DirectiveFormChoice({super.key});

  Future<void> _start(
      BuildContext context, WidgetRef ref, FormType type) async {
    final id =
        await ref.read(directiveRepositoryProvider).createDirective(type);
    if (context.mounted) context.go(AppRoutes.wizardRoute(id));
  }

  /// POA-only carries a statutory caveat (no personal treatment preferences) —
  /// show the warning the form-type page used to, then create + open.
  Future<void> _startPoa(BuildContext context, WidgetRef ref) async {
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.info_outline, size: 36),
        title: const Text('Power of Attorney Only'),
        content: const Text(
          'With a POA-only form, your agent will have authority to make '
          'mental health care decisions on your behalf, but the document '
          'will not include your personal treatment preferences.\n\n'
          'Consider using the Combined form instead to document both your '
          'preferences AND appoint an agent. This gives your care team the '
          'most guidance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Go Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Continue with POA'),
          ),
        ],
      ),
    );
    if (proceed == true && context.mounted) {
      await _start(context, ref, FormType.poa);
    }
  }

  /// "Help me choose" 4-question quiz — recommends a form type, then creates it.
  Future<void> _openQuiz(BuildContext context, WidgetRef ref) async {
    final rec = await showFormTypeQuiz(context);
    if (rec != null && context.mounted) await _start(context, ref, rec);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final combined = _CombinedCard(
      onStart: () => _start(context, ref, FormType.combined),
    );
    final declaration = _SingleFormCard(
      icon: Icons.description_outlined,
      title: 'Declaration only',
      sub: 'Treatment preferences without naming an agent.',
      onTap: () => _start(context, ref, FormType.declaration),
    );
    final poa = _SingleFormCard(
      icon: Icons.people_alt_outlined,
      title: 'Power of attorney only',
      sub: 'Name a decision-maker without listing preferences.',
      onTap: () => _startPoa(context, ref),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Wide: bold Combined card beside stacked Declaration/POA. Narrow
        // (mobile): all three stacked full-width.
        LayoutBuilder(
          builder: (context, c) {
            if (c.maxWidth < 520) {
              return Column(
                children: [
                  combined,
                  const SizedBox(height: 10),
                  declaration,
                  const SizedBox(height: 10),
                  poa,
                ],
              );
            }
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 14, child: combined),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 10,
                    child: Column(
                      children: [
                        Expanded(child: declaration),
                        const SizedBox(height: 10),
                        Expanded(child: poa),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        _HelpMeChooseBanner(onTap: () => _openQuiz(context, ref)),
        const SizedBox(height: 8),
        Text(
          'You can switch form types later if you change your mind — '
          'Combined is the broadest.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12.5,
            height: 1.4,
            color: p.textMuted,
          ),
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
                  'No account, no cloud. If you close the tab or the app '
                  'crashes, your work is kept on this device for 10 minutes so '
                  'you can reopen and recover it — then it’s erased for good. '
                  'Download your PDF to keep it.',
                  style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      height: 1.4,
                      color: p.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // "HOW THIS WORKS →" link (artboard WebDashboard anon banner) →
          // the privacy policy, which explains the anonymous / nothing-saved
          // model in full.
          InkWell(
            onTap: () => context.push(AppRoutes.privacyPolicy),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Text(
                'HOW THIS WORKS →',
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
  const _CombinedCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(color: p.primary),
        child: Stack(
          children: [
            // Oversized decorative serif star, low opacity (artboard position).
            Positioned(
              right: -16,
              top: -50,
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
                  FilledButton.icon(
                    onPressed: onStart,
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Start now'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: p.primaryDark,
                      iconAlignment: IconAlignment.end,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
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

// ── "Help me choose" quiz pill (merged from the retired form-type page) ─────
class _HelpMeChooseBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _HelpMeChooseBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      label: 'Take the 4-question quiz to choose a form',
      child: Material(
        color: p.primaryLight,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.primary.withValues(alpha: 0.20)),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 18, color: p.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Not sure which form fits? Take the 4-question quiz.',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: p.onPrimaryLight,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Help me choose →',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.primary,
                  ),
                ),
              ],
            ),
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
        mainAxisSize: MainAxisSize.min,
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
      mainAxisSize: MainAxisSize.min,
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
