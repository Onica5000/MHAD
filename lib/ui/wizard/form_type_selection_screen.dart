import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/ui/wizard/widgets/form_type_quiz.dart';

/// Form-type picker (Combined / Declaration / POA) — prototype-exact
/// rebuild of mobile.jsx::ScrFormType (L365-447).
///
/// Behavior matches the prototype:
///   * Cards are radio-style — tap to SELECT, no immediate side effect.
///   * Combined is pre-selected (the prototype's `active` Opt).
///   * A primary "Continue" CTA at the bottom commits the selection.
///   * "Help me choose" pill banner opens the 4-question quiz; the
///     quiz still creates a directive directly when the user finishes,
///     mirroring the prior wiring.
///
/// AI-setup and copy-from-existing affordances that previously lived
/// here were removed 2026-06-03 per user direction "drop both — strict
/// prototype." AI setup is reachable from Home → Tools / Settings;
/// copy-from-existing migrates to the past-directive detail screen.
class FormTypeSelectionScreen extends ConsumerStatefulWidget {
  const FormTypeSelectionScreen({super.key});

  @override
  ConsumerState<FormTypeSelectionScreen> createState() =>
      _FormTypeSelectionScreenState();
}

class _FormTypeSelectionScreenState
    extends ConsumerState<FormTypeSelectionScreen> {
  FormType _selected = FormType.combined;
  bool _creating = false;

  Future<void> _continue() async {
    if (_creating) return;

    if (_selected == FormType.poa && mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.info_outline, size: 36),
          title: const Text('Power of Attorney Only'),
          content: const Text(
            'With a POA-only form, your agent will have authority to make '
            'mental health care decisions on your behalf, but the document '
            'will not include your personal treatment preferences.\n\n'
            'Consider using the Combined form instead to document both '
            'your preferences AND appoint an agent. This gives your care '
            'team the most guidance.',
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
      if (proceed != true || !mounted) return;
    }

    setState(() => _creating = true);
    try {
      final id = await ref
          .read(directiveRepositoryProvider)
          .createDirective(_selected);
      if (mounted) {
        context.go(AppRoutes.wizardRoute(id));
      }
    } catch (e) {
      debugPrint('Failed to create directive: $e');
      if (mounted) {
        setState(() => _creating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not create directive. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _openQuiz() async {
    if (_creating) return;
    final rec = await showFormTypeQuiz(context);
    if (rec != null && mounted) {
      setState(() {
        _selected = rec;
        _creating = true;
      });
      try {
        final id =
            await ref.read(directiveRepositoryProvider).createDirective(rec);
        if (mounted) context.go(AppRoutes.wizardRoute(id));
      } catch (e) {
        debugPrint('Failed to create directive from quiz: $e');
        if (mounted) setState(() => _creating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrFormType has CrisisBar + an in-body Back chevron — no
      // Material AppBar. Matches the sibling mode-selection screen's chrome so
      // the new-directive flow reads as one piece. The 'New directive · 1 of 2'
      // SectionLabel + 'Which form fits you?' heading own the visual title.
      body: SafeArea(
        child: Column(children: [
          const CrisisTopBar(compact: true),
          WizardHeader(
            backLabel: 'Back',
            onBack: () => Navigator.of(context).maybePop(),
            actionLabel: '',
          ),
          Expanded(
            child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 32),
            children: [
              const SectionLabel('New directive · 1 of 2'),
              const SizedBox(height: 6),
              Text(
                'Which form fits you?',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.4,
                  color: p.text,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You can switch later if you change your mind. Combined is '
                'the broadest.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  color: p.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),

              _OptCard(
                title: 'Combined',
                subtitle:
                    'Both name people I trust to speak for me, and document '
                    'my treatment preferences. Most flexibility.',
                blurb:
                    'A Combined directive is two documents in one — a '
                    'Declaration (your written treatment wishes) plus a '
                    'Power of Attorney (the people you name to decide for you).',
                tags: const [
                  '11 steps',
                  'Agents + preferences',
                  'Most common'
                ],
                recommended: true,
                active: _selected == FormType.combined,
                onTap: _creating
                    ? null
                    : () => setState(() => _selected = FormType.combined),
              ),
              const SizedBox(height: 10),
              _OptCard(
                title: 'Declaration only',
                subtitle:
                    'Just document my treatment preferences — no agent. '
                    'Decisions still go through doctors.',
                blurb:
                    'A Declaration is a written statement of the mental-health '
                    'treatment you do and don’t want.',
                tags: const ['9 steps', 'No agents'],
                active: _selected == FormType.declaration,
                onTap: _creating
                    ? null
                    : () => setState(() => _selected = FormType.declaration),
              ),
              const SizedBox(height: 10),
              _OptCard(
                title: 'Power of Attorney only',
                subtitle:
                    'Just name people to make decisions for me. They will '
                    'decide treatment in the moment.',
                blurb:
                    'A mental-health Power of Attorney names a person (your '
                    '“agent”) to make treatment decisions when you can’t.',
                tags: const ['6 steps', 'Agents only'],
                active: _selected == FormType.poa,
                onTap: _creating
                    ? null
                    : () => setState(() => _selected = FormType.poa),
              ),

              const SizedBox(height: 18),

              _HelpMeChooseBanner(
                enabled: !_creating,
                onTap: _openQuiz,
              ),

              const SizedBox(height: 22),
              SizedBox(
                height: DesignTokens.buttonHeightLg,
                child: FilledButton.icon(
                  onPressed: _creating ? null : _continue,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Continue'),
                  style: FilledButton.styleFrom(
                    backgroundColor: p.primary,
                    foregroundColor: p.onPrimary,
                    iconAlignment: IconAlignment.end,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(DesignTokens.buttonRadius),
                    ),
                    textStyle: const TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_creating)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black26,
                child: Center(
                  child: DesignCard(
                    margin: const EdgeInsets.symmetric(horizontal: 48),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Creating directive...',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
          ),
        ]),
      ),
    );
  }
}

/// Prototype `Opt` — a radio-style option with a 22px dot, title row
/// (optionally with a "Recommended" badge), subtitle paragraph, and
/// monospace tag pills. Selecting flips the card to primaryTint bg +
/// primary border and fills the radio dot. Mirrors mobile.jsx
/// L368-396 widget-for-widget.
class _OptCard extends StatelessWidget {
  final String title;
  final String subtitle;

  /// Plain-language definition of the form-type term itself (e.g. what a
  /// "Declaration" is), shown as a small info line under the subtitle so a
  /// first-time user doesn't have to know the jargon before choosing.
  final String? blurb;
  final List<String> tags;
  final bool recommended;
  final bool active;
  final VoidCallback? onTap;

  const _OptCard({
    required this.title,
    required this.subtitle,
    this.blurb,
    required this.tags,
    this.recommended = false,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      selected: active,
      label: 'Select $title${recommended ? ' (recommended)' : ''}',
      child: Material(
        color: active ? p.primaryTint : p.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: active ? p.primary : p.border,
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio dot — filled inner circle when active.
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active ? p.primary : Colors.transparent,
                    border: Border.all(
                      color: active ? p.primary : p.border,
                      width: 2,
                    ),
                  ),
                  child: active
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: p.onPrimary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.2,
                                color: p.text,
                              ),
                            ),
                          ),
                          if (recommended) ...[
                            const SizedBox(width: 8),
                            // Primary-tinted Badge atom (ds.jsx L169-186):
                            // DM Sans 11/700, letter-spacing 0.4, uppercase,
                            // padding 4×9, radius 6, primaryLight bg.
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: p.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'RECOMMENDED',
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: p.onPrimaryLight,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          color: p.textMuted,
                          height: 1.45,
                        ),
                      ),
                      if (blurb != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                size: 13, color: p.textMuted),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                blurb!,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: p.textMuted,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: tags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: p.surface,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    t.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'JetBrains Mono',
                                      fontFamilyFallback: const [
                                        'Consolas',
                                        'Menlo',
                                        'Courier New',
                                        'monospace',
                                      ],
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.4,
                                      color: p.textMuted,
                                    ),
                                  ),
                                ))
                            .toList(growable: false),
                      ),
                    ],
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

/// Prototype "Help me choose" pill — opens the 4-question quiz.
/// Matches mobile.jsx L432-441: primaryLight bg, primary border at 30%,
/// Sparkles icon, body span + bold "Help me choose →" CTA span.
class _HelpMeChooseBanner extends StatelessWidget {
  final bool enabled;
  final VoidCallback onTap;

  const _HelpMeChooseBanner({required this.enabled, required this.onTap});

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
          onTap: enabled ? onTap : null,
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
                    'Not sure? Take the 4-question quiz.',
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
