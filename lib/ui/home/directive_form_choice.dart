import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/wizard/widgets/form_type_quiz.dart';

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
            fontFamily: kSansFamily,
            fontSize: 12.5,
            height: 1.4,
            color: p.textMuted,
          ),
        ),
      ],
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
        // Brand CTA gradient (primary → primaryMid) for a richer feature hero
        // than the flat primary fill. Foreground stays onPrimary, fully legible.
        decoration: BoxDecoration(gradient: p.ctaGradient),
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
                        fontFamily: kSansFamily,
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
                      fontFamily: kSansFamily,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                      color: p.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Treatment preferences and a trusted decision-maker, in '
                    'one document. 11 short steps · about 20 minutes.',
                    style: TextStyle(
                      fontFamily: kSansFamily,
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
                        fontFamily: kSansFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sub,
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
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward, size: 14, color: p.primary),
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
                      fontFamily: kSansFamily,
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
                    fontFamily: kSansFamily,
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
