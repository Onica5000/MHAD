import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/services/blank_form_service.dart';
import 'package:mhad/ui/home/directive_form_choice.dart';
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
                fontFamily: kSansFamily,
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

        // ── Print a blank form — pick any of the three official forms and
        //    open the print dialog directly; does NOT start a wizard draft.
        Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: _ToolCard(
              icon: Icons.print_outlined,
              title: 'Print a blank form',
              sub: 'Prefer paper? Open any of the three empty official forms '
                  'to print and fill in by hand — no account or wizard needed.',
              cta: 'Print blank form',
              onTap: () => showBlankFormPicker(context),
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
                // Deep-link to the plain-language overview ("the basics") rather
                // than the full Learn hub, so the button delivers the summary it
                // promises. Back returns here.
                onRead: () => context.push(
                  AppRoutes.education,
                  extra: (
                    ids: const ['intro_overview', 'intro_why_take_your_time'],
                    title: 'The basics',
                  ),
                ),
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
                      fontFamily: kSansFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.text),
                ),
                const SizedBox(height: 1),
                Text(
                  'No account, no cloud. If you close the tab or the app '
                  'crashes, your work is kept on this device for 10 minutes so '
                  'you can reopen and recover it — then it’s erased for good. '
                  'Open your PDF and save it to keep a copy.',
                  style: TextStyle(
                      fontFamily: kSansFamily,
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
            ),
          ),
        ],
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
                    fontFamily: kSansFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.text),
              ),
              const SizedBox(height: 3),
              Text(
                sub,
                style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 12,
                    height: 1.4,
                    color: p.textMuted),
              ),
              const SizedBox(height: 10),
              Text(
                '$cta →',
                style: TextStyle(
                    fontFamily: kSansFamily,
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
          'Save the PDF from your viewer — that’s the only copy.'),
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
                    fontFamily: kSansFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.text),
              ),
              const SizedBox(height: 1),
              Text(
                sub,
                style: TextStyle(
                    fontFamily: kSansFamily,
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
                  fontFamily: kSansFamily,
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
                child: const Text('Read the basics →'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
