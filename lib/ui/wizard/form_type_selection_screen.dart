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

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.surface,
      appBar: AppBar(title: const Text('Choose Form Type')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              const _AiSetupPrompt(),
              const SizedBox(height: 16),
              Text(
                'Which type of directive would you like to create?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Not sure? The Combined form gives you the most options — '
                'you can designate an agent AND document your treatment preferences.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: p.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              _FormTypeCard(
                icon: Icons.people_alt_outlined,
                title: 'Combined',
                subtitle: 'Declaration + Power of Attorney',
                description:
                    'The most comprehensive option. Documents your treatment preferences '
                    'AND designates an agent (healthcare proxy) to make decisions on your behalf. '
                    'Recommended for most people.',
                recommended: true,
                onTap: _creating
                    ? null
                    : () => _createDirective(FormType.combined),
              ),
              const SizedBox(height: 12),
              _FormTypeCard(
                icon: Icons.description_outlined,
                title: 'Declaration Only',
                subtitle: 'Treatment preferences only',
                description:
                    'Documents your mental health treatment preferences without '
                    'designating an agent. Use this if you prefer not to name a '
                    'specific decision-maker.',
                recommended: false,
                onTap: _creating
                    ? null
                    : () => _createDirective(FormType.declaration),
              ),
              const SizedBox(height: 12),
              _FormTypeCard(
                icon: Icons.manage_accounts_outlined,
                title: 'Power of Attorney Only',
                subtitle: 'Agent designation only',
                description:
                    'Designates an agent to make mental health treatment decisions '
                    'without specifying detailed treatment preferences. The agent '
                    'uses their judgment within the bounds of PA law.',
                recommended: false,
                onTap: _creating
                    ? null
                    : () => _createDirective(FormType.poa),
              ),
              const SizedBox(height: 20),
              const SectionLabel('Need help?'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _creating
                      ? null
                      : () async {
                          final rec = await showFormTypeQuiz(context);
                          if (rec != null && mounted) {
                            _createDirective(rec);
                          }
                        },
                  icon: const Icon(Icons.quiz_outlined),
                  label: const Text('Which form is right for me?'),
                ),
              ),
              const SizedBox(height: 12),
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

class _FormTypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool recommended;
  final VoidCallback? onTap;

  const _FormTypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.recommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return DesignCard(
      variant: recommended ? DesignCardVariant.tinted : DesignCardVariant.plain,
      overrideBorder: recommended
          ? BorderSide(color: p.primary, width: 2)
          : null,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: p.primary, size: 22),
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
                            style: const TextStyle(
                              fontFamily: 'DM Sans',
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (recommended) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: p.primary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: const Text(
                              'Recommended',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: p.textMuted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 13,
              color: p.textMuted,
              height: 1.5,
            ),
          ),
        ],
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Set Up AI Assistant',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Get a free Gemini API key to unlock AI suggestions, '
                  'guided help, and document import. Takes ~30 seconds.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.9)),
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
