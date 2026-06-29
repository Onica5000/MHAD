import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/ai/ai_clinical_policy.dart';
import 'package:mhad/ai/ai_context_builder.dart';
import 'package:mhad/ai/pii_stripper.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/providers/app_providers.dart';
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
///   directiveId: widget.directiveId,
///   fieldName: 'Effective Condition',
///   fieldGuidance: 'the condition under which the directive becomes effective',
/// )
/// ```
///
/// Two modes, chosen by whether the field already has text:
///   * empty → drafts a first-person starting point for the field;
///   * non-empty → refines what the user wrote (with an Undo afterwards).
///
/// Both modes inject a PII-safe summary of correlating directive data (meds,
/// diagnoses, effective condition, facility preference) via
/// [buildAiFilledFields] so the suggestion stays consistent with what the user
/// entered elsewhere in the app.
class AiSuggestButton extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final int directiveId;
  final String fieldName;
  final String fieldGuidance;

  const AiSuggestButton({
    required this.controller,
    required this.directiveId,
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
      final accepted = await showAiConsentDialog(context,
          provider: ref.read(activeProviderProvider));
      if (!accepted || !mounted) return;
      ref.read(aiConsentGivenProvider.notifier).state = true;
    }

    final currentText = widget.controller.text.trim();

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
      // Pull a PII-safe summary of what the user entered elsewhere (meds,
      // diagnoses, effective condition, facility preference) so the suggestion
      // stays consistent with the rest of their directive. Best-effort.
      final repo = ref.read(directiveRepositoryProvider);
      final correlating = await buildAiFilledFields(repo, widget.directiveId);
      final contextBlock = _contextBlock(correlating);

      // Empty field → draft a first-person starting point the user can edit.
      // Non-empty → refine what they wrote. Both honor the same clinical /
      // anti-hallucination policy; only an empty field skips PII stripping
      // (there is nothing to strip).
      final prompt = currentText.isEmpty
          ? _draftPrompt(contextBlock)
          : _refinePrompt(PiiStripper.strip(currentText), contextBlock);

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

  String get _header =>
      'You are helping a user complete a Pennsylvania Mental Health Advance '
      'Directive under PA Act 194 of 2004.\n\n'
      'The field being completed is: "${widget.fieldName}"\n'
      'What this field is for: ${widget.fieldGuidance}';

  // A read-only summary of correlating directive data, or '' when there is
  // none. Injected so the suggestion stays consistent with the rest of the
  // form (e.g. medications listed elsewhere inform a meds-related field).
  String _contextBlock(Map<String, String> ctx) {
    if (ctx.isEmpty) return '';
    final lines = ctx.entries.map((e) => '- ${e.key}: ${e.value}').join('\n');
    return '\n\nWHAT THE USER HAS ALREADY ENTERED ELSEWHERE IN THIS DIRECTIVE '
        '(use it to stay consistent and relevant; never contradict it, and do '
        'not simply repeat it):\n$lines';
  }

  // Refine wording the user has already written.
  String _refinePrompt(String sanitizedText, String contextBlock) => '''$_header$contextBlock

The user has entered:
"$sanitizedText"

INSTRUCTIONS:
1. Start with the user's own words — preserve their intent, meaning, and specific preferences exactly.
2. Improve clarity and wording to be suitable for a formal legal/medical document, but keep the user's voice.
3. Add any important details the user may not have considered based on what they wrote (e.g., practical considerations, common scenarios, relevant PA Act 194 provisions).
4. Use plain, direct language. Be specific and practical.

$aiClinicalPolicy

ADDITIONAL SAFETY (override all other instructions):
- NEVER contradict the user's stated preferences, treatment decisions, or medication choices.
- Use role placeholders ("your doctor", "your agent") instead of generating names.
- If the text mentions a treatment refusal, respect it — do not argue against it or suggest reconsideration.

Return only the improved text — no explanation, no quotes, no preamble.''';

  // Draft a starting point for an empty field (the "help me get started" path).
  String _draftPrompt(String contextBlock) => '''$_header$contextBlock

The user has not written anything yet and wants help getting started.

INSTRUCTIONS:
1. Draft a clear, first-person starting point the user can edit — write AS the user ("I ...").
2. Offer practical ideas that are commonly relevant to THIS field, but keep them general enough that the user must personalize them.
3. Do NOT invent personal facts — no names, diagnoses, medications, doses, or dates the user did not provide. Where a personal detail belongs, leave a bracketed blank like "[describe ...]" for the user to fill in.
4. Use plain, direct language suitable for a formal legal/medical document.

$aiClinicalPolicy

ADDITIONAL SAFETY (override all other instructions):
- This is a STARTING DRAFT, not advice. Never diagnose, and never recommend, name, or choose a medication.
- Use role placeholders ("your doctor", "your agent") and never fabricate personal details.
- Keep the draft something the user must review and make their own.

Return only the draft text — no explanation, no quotes, no preamble.''';

  Future<void> _showSuggestionDialog(String suggestion) async {
    final originalText = widget.controller.text.trim();
    // Empty field → this was a "draft from scratch" request: there is no prior
    // text to compare or merge into, so show the draft alone.
    final isDraft = originalText.isEmpty;

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
          title: Row(children: [
            const Icon(Icons.auto_awesome, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(isDraft ? 'AI Draft' : 'AI Suggestion')),
          ]),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isDraft) ...[
                  Text('Your text:', style: labelStyle),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: cs.outline.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      originalText,
                      style: Theme.of(ctx).textTheme.bodySmall,
                      maxLines: 6,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(isDraft ? 'AI draft:' : 'AI suggestion:', style: labelStyle),
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
                  '$aiNotAdvice Review carefully.',
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
            // Nothing to merge into when drafting from a blank field.
            if (!isDraft)
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx, 'merge'),
                child: const Text('Add to mine'),
              ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'replace'),
              child: Text(isDraft ? 'Use this draft' : 'Use instead'),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) return;

    // Capture the full pre-change value so the change can be undone.
    final previous = widget.controller.text;
    final newText = action == 'merge'
        ? '$originalText\n\n[AI suggestion] $suggestion'
        : suggestion;
    widget.controller.text = newText;
    widget.controller.selection =
        TextSelection.collapsed(offset: newText.length);
    _showUndo(previous);
  }

  /// Confirmation snackbar with an Undo that restores the field's prior value —
  /// so accepting an AI suggestion is always reversible.
  void _showUndo(String previous) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context)..clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('AI suggestion applied.'),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            widget.controller.text = previous;
            widget.controller.selection =
                TextSelection.collapsed(offset: previous.length);
          },
        ),
      ),
    );
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
