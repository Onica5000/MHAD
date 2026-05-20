import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/wizard/widgets/form_type_quiz.dart';

/// Form-type picker (3 options: Combined / Declaration / POA).
///
/// Visual design follows the prototype `ScrFormType` (mobile.jsx): sans-serif
/// H1, three radio-style option cards with title + sub + monospace tag pills,
/// a primaryLight "Help me choose" banner that launches the 4-question quiz,
/// then the AI-setup prompt and copy-from-existing helpers below.
///
/// All wiring (`_createDirective`, POA-only confirmation dialog, AI setup,
/// quiz launcher, copy-from-existing, loading overlay) is unchanged.
class FormTypeSelectionScreen extends ConsumerStatefulWidget {
  const FormTypeSelectionScreen({super.key});

  @override
  ConsumerState<FormTypeSelectionScreen> createState() =>
      _FormTypeSelectionScreenState();
}

class _FormTypeSelectionScreenState
    extends ConsumerState<FormTypeSelectionScreen> {
  bool _creating = false;

  Future<void> _createDirective(FormType formType) async {
    if (_creating) return;

    if (formType == FormType.poa && mounted) {
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
            'team the most guidance.'),
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
          .createDirective(formType);
      if (mounted) {
        context.go(AppRoutes.wizardRoute(id));
      }
    } catch (e) {
      debugPrint('Failed to create directive: $e');
      if (mounted) {
        setState(() => _creating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(
              'Could not create directive. Please try again.')),
        );
      }
    }
  }

  Future<void> _openQuiz() async {
    if (_creating) return;
    final rec = await showFormTypeQuiz(context);
    if (rec != null && mounted) _createDirective(rec);
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
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

              // Three form-type option cards — prototype "Opt" style: radio
              // dot on the left, title row with optional Recommended badge,
              // subtitle paragraph, and monospace tag pills.
              _OptCard(
                title: 'Combined',
                subtitle:
                    'Both name people I trust to speak for me, and document '
                    'my treatment preferences. Most flexibility.',
                tags: const ['9 steps', 'Agents + preferences', 'Most common'],
                recommended: true,
                onTap: _creating
                    ? null
                    : () => _createDirective(FormType.combined),
              ),
              const SizedBox(height: 10),
              _OptCard(
                title: 'Declaration only',
                subtitle:
                    'Just document my treatment preferences — no agent. '
                    'Decisions still go through doctors.',
                tags: const ['8 steps', 'No agents'],
                onTap: _creating
                    ? null
                    : () => _createDirective(FormType.declaration),
              ),
              const SizedBox(height: 10),
              _OptCard(
                title: 'Power of Attorney only',
                subtitle:
                    'Just name people to make decisions for me. They will '
                    'decide treatment in the moment.',
                tags: const ['9 steps', 'Agents only'],
                onTap: _creating
                    ? null
                    : () => _createDirective(FormType.poa),
              ),

              const SizedBox(height: 18),

              // "Help me choose" — prototype's primaryLight pill banner.
              _HelpMeChooseBanner(
                enabled: !_creating,
                onTap: _openQuiz,
              ),

              const SizedBox(height: 22),
              const _AiSetupPrompt(),
              const SizedBox(height: 14),
              _ImportFromExistingButton(
                creating: _creating,
                onCreated: (id) {
                  if (mounted) context.go(AppRoutes.wizardRoute(id));
                },
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
                        Text('Creating directive...',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Prototype `Opt` — a radio-style option card with a 22px dot, title row
/// (plus optional "Recommended" badge), subtitle paragraph, and monospace
/// tag pills.
class _OptCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> tags;
  final bool recommended;
  final VoidCallback? onTap;

  const _OptCard({
    required this.title,
    required this.subtitle,
    required this.tags,
    this.recommended = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      label: 'Select $title${recommended ? ' (recommended)' : ''}',
      child: Material(
        color: recommended ? p.primaryLight : p.card,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: recommended ? p.primary : p.border,
                width: 2,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Radio dot (filled if recommended/active).
                Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: recommended ? p.primary : Colors.transparent,
                    border: Border.all(
                      color: recommended ? p.primary : p.border,
                      width: 2,
                    ),
                  ),
                  child: recommended
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: p.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'RECOMMENDED',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.6,
                                  color: p.onPrimary,
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
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: tags
                            .map((t) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: p.scaffoldBackground,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    t.toUpperCase(),
                                    style: TextStyle(
                                      fontFamily: 'JetBrains Mono',
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
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            constraints: const BoxConstraints(minHeight: 48),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: p.primary.withValues(alpha: 0.20)),
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

class _AiSetupPrompt extends ConsumerWidget {
  const _AiSetupPrompt();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final hasKey = ref.watch(apiKeyProvider).whenOrNull(
              data: (k) => k != null && k.isNotEmpty,
            ) ??
        false;
    final isEphemeral = isEphemeralApiKeyMode(ref);

    if (hasKey) {
      return InfoBanner(
        icon: Icons.check_circle,
        text: isEphemeral
            ? 'AI Assistant Ready · API key set for this session'
            : 'AI Assistant Ready · API key saved',
        variant: InfoBannerVariant.success,
        onAction: () => context.push(AppRoutes.aiSetup),
        actionLabel: 'Manage',
      );
    }

    return DesignCard(
      variant: DesignCardVariant.primary,
      onTap: () => context.push(AppRoutes.aiSetup),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: p.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome,
                color: p.onPrimary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Up AI Assistant',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: p.onPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Get a free Gemini API key to unlock AI suggestions, '
                  'guided help, and document import. Takes ~30 seconds.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: p.onPrimaryLight.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: p.onPrimaryLight),
        ],
      ),
    );
  }
}

class _ImportFromExistingButton extends ConsumerWidget {
  final bool creating;
  final void Function(int newId) onCreated;

  const _ImportFromExistingButton({
    required this.creating,
    required this.onCreated,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final directivesAsync = ref.watch(allDirectivesProvider);
    return directivesAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (directives) {
        final eligible = directives.where((d) =>
            d.status == 'complete' || d.status == 'expired').toList();
        if (eligible.isEmpty) return const SizedBox.shrink();

        final label = eligible.first.fullName.isNotEmpty
            ? eligible.first.fullName
            : 'previous directive';
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: creating
                ? null
                : () => _importFrom(context, ref, eligible.first),
            icon: const Icon(Icons.content_copy_outlined),
            label: Text('Copy from "$label"'),
          ),
        );
      },
    );
  }

  Future<void> _importFrom(
      BuildContext context, WidgetRef ref, Directive source) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Copy Previous Directive?'),
        content: const Text(
          'This will create a new directive and copy your treatment '
          'preferences, medications, and additional instructions.\n\n'
          'Personal information (name, address, phone) will NOT be copied '
          'and must be re-entered.\n\n'
          'You can edit everything after copying.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Copy & Create'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final repo = ref.read(directiveRepositoryProvider);
      final snap = await repo.snapshotDirective(source.id);
      if (snap.isEmpty) return;
      final newId = await repo.restoreFromSnapshot(snap);
      onCreated(newId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Copy failed: $e')),
        );
      }
    }
  }
}
