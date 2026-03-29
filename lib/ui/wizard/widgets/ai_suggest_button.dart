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

INSTRUCTIONS:
1. Start with the user's own words — preserve their intent, meaning, and specific preferences exactly.
2. Improve clarity and wording to be suitable for a formal legal/medical document, but keep the user's voice.
3. Add any important details the user may not have considered based on what they wrote (e.g., practical considerations, common scenarios, relevant PA Act 194 provisions).
4. SAFETY: Never suggest anything that could endanger the user's physical or mental health. Never contradict the user's stated preferences or treatment decisions.
5. Use plain, direct language. Be specific and practical.

Return only the improved text — no explanation, no quotes, no preamble.''';

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
    final originalText = widget.controller.text.trim();

    // 'replace' = replace with AI text, 'merge' = append AI text, null = dismiss
    final action = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final cs = Theme.of(ctx).colorScheme;
        final labelStyle = Theme.of(ctx)
            .textTheme
            .labelMedium
            ?.copyWith(fontWeight: FontWeight.w600);
        return AlertDialog(
          title: const Row(children: [
            Icon(Icons.auto_awesome, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text('AI Suggestion')),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your text:', style: labelStyle),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    originalText,
                    style: Theme.of(ctx).textTheme.bodySmall,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 12),
                Text('AI suggestion:', style: labelStyle),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: cs.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
                  ),
                  child: SelectableText(
                    suggestion,
                    style: Theme.of(ctx).textTheme.bodySmall,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'AI suggestions are not legal advice. Review carefully.',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Dismiss'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx, 'merge'),
              child: const Text('Add to mine'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'replace'),
              child: const Text('Use instead'),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'replace') {
      widget.controller.text = suggestion;
    } else if (action == 'merge') {
      widget.controller.text = '$originalText\n\n[AI suggestion] $suggestion';
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
                tooltip: 'AI suggestion',
                onPressed: _suggest,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                ),
              ),
      ),
    );
  }
}
