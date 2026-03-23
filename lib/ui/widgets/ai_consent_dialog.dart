import 'package:flutter/material.dart';

/// Shows AI data usage consent dialog. Returns true if user accepts.
Future<bool> showAiConsentDialog(BuildContext context) async {
  final cs = Theme.of(context).colorScheme;
  return await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('AI Data Notice'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Important: Please read before continuing.\n',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const Text(
              '\u2022 This AI assistant is NOT a therapist, doctor, or lawyer. '
              'It provides general information about PA Mental Health Advance '
              'Directives only.\n',
            ),
            const Text(
              '\u2022 Text you enter will be sent to Google\'s servers for AI processing. '
              'On the Gemini free tier, Google may use this data to improve their '
              'AI products, and human reviewers may read your inputs.\n',
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.privacy_tip, size: 18, color: cs.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'NEVER enter personal information (full name, date of '
                      'birth, Social Security number, address, phone number, '
                      'email) into the AI chat or AI-powered features.\n\n'
                      'The app automatically strips common personal data, but '
                      'this is not guaranteed. Personal information fields '
                      'must be filled in manually — they are stored on your '
                      'device only and never sent to the AI.',
                      style: TextStyle(
                        color: cs.onErrorContainer,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '\n\u2022 Data sent to Google cannot be recalled or deleted '
              'by you or this app.\n',
            ),
            const Text(
              'By tapping "I Authorize," you consent to sending your text to '
              'Google for AI processing under these terms.\n\n'
              'This notice appears once per session.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('I Authorize'),
        ),
      ],
    ),
  ) ?? false;
}
