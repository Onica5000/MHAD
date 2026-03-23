import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';

/// A small "AI Suggest" button that appears next to narrative text fields
/// in the wizard.  When tapped, it sends the current field value to Gemini
/// with a directive-specific prompt and shows the suggestion in a dialog.
/// The user can Accept (replacing the field text) or Dismiss.
///
/// Usage:
/// ```dart
/// AiSuggestButton(
///   controller: _ctrl,
///   fieldName: 'Effective Condition',
///   fieldGuidance: 'the condition under which the directive becomes effective',
/// )
/// ```
class AiSuggestButton extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String fieldName;
  final String fieldGuidance;

  const AiSuggestButton({
    required this.controller,
    required this.fieldName,
    required this.fieldGuidance,
    super.key,
  });

  @override
  ConsumerState<AiSuggestButton> createState() => _AiSuggestButtonState();
}

class _AiSuggestButtonState extends ConsumerState<AiSuggestButton> {
  bool _loading = false;

  Future<void> _suggest() async {
    final assistant = ref.read(aiAssistantProvider);
    if (assistant == null) {
      _showSetupDialog();
      return;
    }

    // Per-session AI consent gate
    if (!ref.read(aiConsentGivenProvider)) {
      final accepted = await showAiConsentDialog(context);
      if (!accepted || !mounted) return;
      ref.read(aiConsentGivenProvider.notifier).state = true;
    }

    final currentText = widget.controller.text.trim();
    if (currentText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Enter some text first, then tap AI Suggest.')),
      );
      return;
    }

    // Check rate limits
    final tracker = ref.read(geminiRateTrackerProvider);
    final blockReason = tracker.blockReason;
    if (blockReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(blockReason), duration: const Duration(seconds: 5)),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      // Strip PII before embedding in prompt
      final sanitizedText = PiiStripper.strip(currentText);

      final prompt = '''You are helping a user complete a Pennsylvania Mental Health Advance Directive under PA Act 194 of 2004.

The field being completed is: "${widget.fieldName}"
Field purpose: ${widget.fieldGuidance}

The user has entered:
"$sanitizedText"

Please provide a more concise, clear, and legally appropriate version of this text suitable for a formal advance directive document. Ensure the revised text complies with PA Act 194 of 2004 requirements. Preserve the user's intent and meaning. Use plain, direct language. Keep it brief. Return only the revised text — no explanation, no quotes.''';

      final suggestion = await assistant.sendMessage(prompt, history: []);
      tracker.recordRequest(
          estimatedTokens: GeminiRateTracker.estimateTokens(prompt.length));
      if (!mounted) return;

      await _showSuggestionDialog(suggestion.trim());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(FriendlyError.from(e))),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showSuggestionDialog(String suggestion) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.auto_awesome, size: 20),
          SizedBox(width: 8),
          Text('AI Suggestion'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggested revision for "${widget.fieldName}":',
              style: Theme.of(ctx)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(ctx).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                suggestion,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI suggestions are not legal advice. Review carefully before accepting.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Dismiss'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Accept'),
          ),
        ],
      ),
    );

    if (accepted == true && mounted) {
      widget.controller.text = suggestion;
    }
  }

  void _showSetupDialog() {
    context.push(AppRoutes.aiSetup);
  }

  @override
  Widget build(BuildContext context) {
    final hasAssistant = ref.watch(aiAssistantProvider) != null;
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      button: true,
      label: _loading
          ? 'AI Suggest, loading suggestion for ${widget.fieldName}'
          : hasAssistant
              ? 'AI Suggest for ${widget.fieldName}'
              : 'Set up AI Assistant to use suggestions',
      child: Tooltip(
        message: hasAssistant
            ? 'Get an AI suggestion for this field'
            : 'Set up AI Assistant to use this feature',
        child: _loading
            ? SizedBox(
                width: 48,
                height: 48,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Semantics(
                    label: 'Loading',
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            : IconButton(
                icon: Icon(
                  Icons.auto_awesome,
                  size: 20,
                  color: hasAssistant ? cs.primary : cs.onSurfaceVariant,
                ),
                onPressed: _suggest,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
              ),
      ),
    );
  }
}
