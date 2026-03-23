import 'package:flutter/material.dart';
import 'package:mhad/domain/model/directive.dart';

/// Interactive quiz that recommends a form type based on user's answers.
/// Returns the recommended FormType or null if cancelled.
Future<FormType?> showFormTypeQuiz(BuildContext context) {
  return showDialog<FormType>(
    context: context,
    builder: (ctx) => const _QuizDialog(),
  );
}

class _QuizDialog extends StatefulWidget {
  const _QuizDialog();

  @override
  State<_QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<_QuizDialog> {
  bool? _wantsAgent;
  bool? _wantsPreferences;

  FormType? get _recommendation {
    if (_wantsAgent == null || _wantsPreferences == null) return null;
    if (_wantsAgent! && _wantsPreferences!) return FormType.combined;
    if (_wantsAgent!) return FormType.poa;
    return FormType.declaration;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final rec = _recommendation;

    return AlertDialog(
      title: const Text('Which form is right for me?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Answer these questions to find the best form type:',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text('Do you want to designate someone (an agent) to make '
                'mental health decisions on your behalf during a crisis?',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Yes')),
                ButtonSegment(value: false, label: Text('No')),
              ],
              selected: _wantsAgent == null ? {} : {_wantsAgent!},
              onSelectionChanged: (v) =>
                  setState(() => _wantsAgent = v.first),
            ),
            const SizedBox(height: 16),
            Text(
                'Do you want to document specific treatment preferences '
                '(medications, facilities, ECT, etc.)?',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('Yes')),
                ButtonSegment(value: false, label: Text('No')),
              ],
              selected: _wantsPreferences == null ? {} : {_wantsPreferences!},
              onSelectionChanged: (v) =>
                  setState(() => _wantsPreferences = v.first),
            ),
            if (rec != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recommended:',
                        style: TextStyle(
                            fontSize: 12, color: cs.onPrimaryContainer)),
                    const SizedBox(height: 4),
                    Text(
                      rec.displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: cs.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _explanation(rec),
                      style: TextStyle(
                          fontSize: 12, color: cs.onPrimaryContainer),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (rec != null)
          FilledButton(
            onPressed: () => Navigator.pop(context, rec),
            child: Text('Use ${rec == FormType.combined ? 'Combined' : rec == FormType.poa ? 'POA' : 'Declaration'}'),
          ),
      ],
    );
  }

  String _explanation(FormType type) => switch (type) {
        FormType.combined =>
          'Includes both your treatment preferences AND an agent '
              'designation. This is the most comprehensive option.',
        FormType.poa =>
          'Designates an agent to make decisions for you, without '
              'specifying detailed treatment preferences.',
        FormType.declaration =>
          'Documents your treatment preferences without naming '
              'an agent. Your treatment team will follow your written wishes.',
      };
}
