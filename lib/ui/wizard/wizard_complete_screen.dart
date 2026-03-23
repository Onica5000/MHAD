import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ui/router.dart';

/// Shown after the user finishes the wizard execution step.
/// Provides next-steps guidance.
class WizardCompleteScreen extends StatelessWidget {
  final int directiveId;
  const WizardCompleteScreen({required this.directiveId, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Directive Complete'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: 'Go to home',
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          Icon(Icons.check_circle_outline, size: 72, color: cs.primary),
          const SizedBox(height: 16),
          Text(
            'Your directive is saved!',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Here are the next steps to make it legally valid:',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),

          _NextStep(
            number: '1',
            title: 'Print your directive',
            description: 'Export the PDF and print it on paper.',
            icon: Icons.print,
          ),
          _NextStep(
            number: '2',
            title: 'Sign with ink',
            description:
                'Sign the printed directive with original ink signatures '
                'in the presence of two adult witnesses.',
            icon: Icons.edit,
          ),
          _NextStep(
            number: '3',
            title: 'Have witnesses sign',
            description:
                'Both witnesses must sign the printed document. '
                'They cannot be your agent, healthcare provider, or '
                'facility employee (unless related).',
            icon: Icons.people,
          ),
          _NextStep(
            number: '4',
            title: 'Distribute copies',
            description:
                'Give copies to your agent, doctor, hospital, family, '
                'and anyone who may need it in a crisis.',
            icon: Icons.share,
          ),

          const SizedBox(height: 16),
          Card(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.flight,
                    size: 20,
                    color: cs.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If you travel or live part-time in another state, '
                      'consider having your directive notarized for broader '
                      'acceptance.',
                      style: TextStyle(
                        fontSize: 13,
                        color: cs.onTertiaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.checklist, size: 20),
                      SizedBox(width: 8),
                      Text('Distribution Checklist',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'After printing and signing, give copies to:',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  const _ChecklistItem(
                      'Your designated agent (and alternate agent)'),
                  const _ChecklistItem('Your primary care physician'),
                  const _ChecklistItem('Your mental health provider(s)'),
                  const _ChecklistItem('Your local hospital'),
                  const _ChecklistItem('A trusted family member or friend'),
                  const _ChecklistItem('Your attorney (if you have one)'),
                  const SizedBox(height: 8),
                  const Text(
                    'Keep the original in a safe, accessible place. '
                    'Consider telling others where it is stored.',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('Export PDF'),
            onPressed: () =>
                context.push(AppRoutes.exportRoute(directiveId)),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.home),
            label: const Text('Go to Home'),
            onPressed: () => context.go(AppRoutes.home),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  final String text;
  const _ChecklistItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('\u2022 ', style: TextStyle(fontSize: 12)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }
}

class _NextStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _NextStep({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                color: cs.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.4,
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
