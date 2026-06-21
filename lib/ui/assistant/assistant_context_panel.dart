import 'package:flutter/material.dart';
import 'package:mhad/ai/ai_assistant.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// Desktop-only right-hand context panel shown beside the chat at >=1000px.
///
/// Purely presentational: surfaces the current [AssistantContext] (form type
/// + step) when the chat was opened from a wizard step, plus a short list of
/// example prompts that fire the existing send path via [onPromptTap]. When
/// there is no wizard context it falls back to a static "What I can help
/// with" card so the panel is never empty. No send/history state lives here.
class AssistantContextPanel extends StatelessWidget {
  final AssistantContext? context;
  final String? contextLabel;
  final ValueChanged<String> onPromptTap;

  const AssistantContextPanel({
    required this.context,
    required this.contextLabel,
    required this.onPromptTap,
    super.key,
  });

  static const _examplePrompts = [
    'What is a Mental Health Advance Directive?',
    'Who can be my agent?',
    'How long is the directive valid?',
    'Can I change my directive later?',
  ];

  @override
  Widget build(BuildContext buildContext) {
    final p = Theme.of(buildContext).mhadPalette;
    final hasContext = context != null;

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(left: BorderSide(color: p.border)),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          if (hasContext) ...[
            // "Context the AI sees" — structured key/value list mirroring the
            // Claude Design `WebAI` right panel.
            const SectionLabel('Context the AI sees'),
            const SizedBox(height: 8),
            _ContextKV(label: 'Form type', value: _ctxFormType(context!)),
            _ContextKV(
                label: 'Current step',
                value: context!.stepName ?? 'General question'),
            _ContextKV(
                label: 'Filled fields',
                value: '${context!.filledFields?.length ?? 0}'),
            const _ContextKV(label: 'PII', value: 'Stripped before send'),
            const SizedBox(height: 16),
            const SectionLabel('Suggested prompts'),
          ] else ...[
            const SectionLabel('What I can help with'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.card,
                border: Border.all(color: p.border),
                borderRadius:
                    BorderRadius.circular(DesignTokens.cardRadius),
              ),
              child: Text(
                'Ask about form types, agents, treatment preferences, or '
                'anything in the PA MHAD booklet. Try one of these:',
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 12.5,
                  height: 1.45,
                  color: p.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          for (final prompt in _examplePrompts) ...[
            _ContextPromptTile(text: prompt, onTap: () => onPromptTap(prompt)),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          const SectionLabel('Privacy'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.primaryTint,
              border: Border.all(color: p.primary.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: p.primary),
                    const SizedBox(width: 6),
                    Text(
                      'PII REDACTION ON',
                      style: TextStyle(
                        fontFamily: kMonoFamily,
                        fontFamilyFallback: const ['Consolas', 'monospace'],
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: p.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Names, addresses, phone numbers, and dates are replaced '
                  'with placeholders before sending to Gemini. Suggestions '
                  'come back with placeholders filled in locally.',
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 12,
                    height: 1.45,
                    color: p.text,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _ctxFormType(AssistantContext ctx) =>
      formTypeFromName(ctx.formType)?.shortName ?? '—';
}

/// One "Context the AI sees" key/value row (label left, value right).
class _ContextKV extends StatelessWidget {
  final String label;
  final String value;
  const _ContextKV({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 12,
                color: p.textMuted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContextPromptTile extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _ContextPromptTile({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      label: text,
      child: Material(
        color: p.card,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            constraints: const BoxConstraints(minHeight: 44),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    text,
                    style: TextStyle(
                      fontFamily: kSansFamily,
                      fontSize: 12.5,
                      height: 1.3,
                      color: p.text,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_ios, size: 11, color: p.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
