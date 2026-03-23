import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/educational_content.dart';
import 'package:mhad/ui/router.dart';

/// Shared help button used by all wizard steps.
///
/// Shows the step's help text in a draggable bottom sheet, plus a
/// "Learn More" link that deep-links to the Education screen filtered
/// to the relevant sections via [wizardStepEducationMap].
class WizardHelpButton extends StatelessWidget {
  final String helpText;

  /// Key into [wizardStepEducationMap], e.g. 'effectiveCondition'.
  final String? stepId;

  const WizardHelpButton({
    required this.helpText,
    this.stepId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Semantics(
        button: true,
        label: 'Help for this step. Opens help sheet.',
        child: TextButton.icon(
          onPressed: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => _HelpSheet(helpText: helpText, stepId: stepId),
          ),
          icon: const Icon(Icons.help_outline, size: 16),
          label: const Text('Help'),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.primary,
            textStyle: const TextStyle(fontSize: 13),
          ),
        ),
      ),
    );
  }
}

class _HelpSheet extends StatelessWidget {
  final String helpText;
  final String? stepId;

  const _HelpSheet({required this.helpText, this.stepId});

  @override
  Widget build(BuildContext context) {
    final filterIds = stepId != null ? wizardStepEducationMap[stepId] : null;
    final hasEducation = filterIds != null && filterIds.isNotEmpty;

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      expand: false,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Icon(Icons.help, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text('Help',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      )),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 8),
          Text(helpText, style: Theme.of(context).textTheme.bodyMedium),
          if (hasEducation) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context); // close bottom sheet
                context.push(AppRoutes.education, extra: filterIds);
              },
              icon: const Icon(Icons.menu_book, size: 18),
              label: const Text('Learn More'),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Questions? Contact PA Protection & Advocacy: 1-800-692-7443',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ),
    );
  }
}
