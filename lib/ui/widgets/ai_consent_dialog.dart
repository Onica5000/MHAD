import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/theme/app_theme.dart';
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
          title: Text(context.l10n.aiConsentDialogBeforeYouUpload),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.aiConsentDialogToAutofillYourDirectiveThe(provider.label),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
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
                Text(
                  context.l10n.aiConsentDialogNothingIsSavedToYour,
                ),
                const SizedBox(height: 10),
                Text(
                  context.l10n.aiConsentDialogUploadingIsOnlyAShortcut,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.aiConsentDialogSendToTheAi),
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
          title: Text(context.l10n.aiConsentDialogTranscribeWithAi),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.l10n.aiConsentDialogForMoreAccurateTranscriptionEspecially(provider.label),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.errorContainer,
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
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
                Text(
                  context.l10n.aiConsentDialogYouReviewTheTextBefore,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.aiConsentDialogUseAi),
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
      title: Text(context.l10n.aiConsentDialogAiDataNotice),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.aiConsentDialogImportantPleaseReadBeforeContinuing,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              context.l10n.aiConsentDialogThisAiAssistantIsNot,
            ),
            Text(
              context.l10n.aiConsentDialogTextYouEnterWillBe(provider.label, _providerDataCaveat(provider)),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.privacy_tip, size: 18, color: cs.onErrorContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.aiConsentDialogNeverEnterPersonalInformationFull,
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
              context.l10n.aiConsentDialogByTappingIAuthorizeYou(provider.label),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(context.l10n.aiConsentDialogNotNow),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(context.l10n.aiConsentDialogIAuthorize),
        ),
      ],
    ),
  ) ?? false;
}
