import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Form Type')),
      body: Stack(
        children: [
          ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Which type of directive would you like to create?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Not sure? The Combined form gives you the most options — '
            'you can designate an agent AND document your treatment preferences.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 24),
          _FormTypeCard(
            formType: FormType.combined,
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
            formType: FormType.declaration,
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
            formType: FormType.poa,
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
          const SizedBox(height: 24),
          OutlinedButton.icon(
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
        ],
      ),
      if (_creating)
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black12,
            child: Center(
              child: Card(
                child: Padding(
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
        ),
      ],
      ),
    );
  }
}

class _FormTypeCard extends StatelessWidget {
  final FormType formType;
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final bool recommended;
  final VoidCallback? onTap;

  const _FormTypeCard({
    required this.formType,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.recommended,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: recommended ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: recommended ? cs.primary : cs.outlineVariant,
          width: recommended ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: cs.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: cs.onSurface)),
                            if (recommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('Recommended',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: cs.onPrimaryContainer,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ],
                        ),
                        Text(subtitle,
                            style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 10),
              Text(description,
                  style:
                      TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}
