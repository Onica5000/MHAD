import 'package:flutter/material.dart';
import 'package:mhad/ai/ai_provider.dart';

/// Provider-aware data caveat shown in the consent dialogs. Gemini's free tier
/// has a specific "used to improve their AI / human reviewers" risk; other
/// providers are governed by their own API data policy.
String _providerDataCaveat(AiProvider provider) => provider == AiProvider.gemini
    ? 'On the Gemini free tier, Google may retain your data and use it to '
        'improve their AI, human reviewers may see it, and what is sent cannot '
        'be recalled or deleted afterward.'
    : 'Your data is sent to ${provider.label} and handled under their API data '
        'policy; what is sent cannot be recalled or deleted by you or this app.';

/// Consent + data notice for the document-autofill flow specifically.
///
/// Unlike the chat and other AI features (which strip personal data before it
/// leaves the device — see [showAiConsentDialog]), autofill is the ONE AI path
/// that sends the whole document, INCLUDING personal details, to the AI so it
/// can read and fill in the directive. This notice states that accurately — do
/// NOT show the generic [showAiConsentDialog] here, whose "never send personal
/// information to the AI" wording contradicts how autofill works.
///
/// [provider] is the active AI provider so the notice names the right recipient.
/// Returns true if the user authorizes the upload. Recording the session
/// AI-consent flag is the caller's responsibility.
Future<bool> showAutofillConsentDialog(
  BuildContext context, {
  AiProvider provider = AiProvider.gemini,
}) async {
  final cs = Theme.of(context).colorScheme;
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Before you upload'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'To autofill your directive, the whole document — including '
                  'any personal details on it (names, dates of birth, '
                  'addresses, phone numbers) — is sent to ${provider.label} so '
                  'it can read it and fill in your fields.',
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.cloud_upload_outlined,
                          size: 18, color: cs.onErrorContainer),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _providerDataCaveat(provider),
                          style: TextStyle(
                            color: cs.onErrorContainer,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Nothing is saved to your directive automatically — you '
                  'review every field the AI fills in before it is applied.',
                ),
                const SizedBox(height: 10),
                const Text(
                  'Uploading is only a shortcut, never required:\n'
                  '• Black out anything you don\'t want sent (ID or card '
                  'numbers, other people\'s details) before uploading.\n'
                  '• Or skip the upload and type any field by hand — typed '
                  'fields stay on your device and are never sent to the AI.',
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
              child: const Text('Send to the AI'),
            ),
          ],
        ),
      ) ??
      false;
}

/// Consent + data notice for AI voice transcription. Like autofill, this is a
/// path where personal details (whatever the user speaks) are sent to the AI —
/// so it states that accurately rather than using the generic
/// [showAiConsentDialog], whose "never send personal information" wording would
/// contradict how AI dictation works. Audio is Gemini-only, but the notice still
/// names [provider] for accuracy. Returns true if the user authorizes it.
Future<bool> showAudioConsentDialog(
  BuildContext context, {
  AiProvider provider = AiProvider.gemini,
}) async {
  final cs = Theme.of(context).colorScheme;
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.mic_none),
          title: const Text('Transcribe with AI'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'For more accurate transcription (especially medication names '
                  'and conditions), your voice recording — including any '
                  'personal details you say — is sent to ${provider.label} to '
                  'turn into text.',
                ),
                const SizedBox(height: 10),
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
                          _providerDataCaveat(provider),
                          style: TextStyle(
                            color: cs.onErrorContainer,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You review the text before it goes into your form. Prefer not '
                  'to? Tap Cancel to use your device\'s built-in dictation '
                  'instead, or just type — neither sends audio to the AI.',
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
              child: const Text('Use AI'),
            ),
          ],
        ),
      ) ??
      false;
}

/// Shows the AI data-usage consent dialog. [provider] names the recipient so
/// the notice is accurate for whichever provider the user picked. Returns true
/// if the user accepts.
Future<bool> showAiConsentDialog(
  BuildContext context, {
  AiProvider provider = AiProvider.gemini,
}) async {
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
              '• This AI assistant is NOT a therapist, doctor, or lawyer. '
              'It provides general information about PA Mental Health Advance '
              'Directives only.\n',
            ),
            Text(
              '• Text you enter will be sent to ${provider.label} for AI '
              'processing. ${_providerDataCaveat(provider)}\n',
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
            Text(
              '\nBy tapping "I Authorize," you consent to sending your text to '
              '${provider.label} for AI processing under these terms.\n\n'
              'This notice appears once per session.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Not Now'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('I Authorize'),
        ),
      ],
    ),
  ) ?? false;
}
