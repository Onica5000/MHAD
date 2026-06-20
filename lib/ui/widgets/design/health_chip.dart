import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Tone for a [HealthChip] — drives the colour family.
enum HealthChipTone { primary, warn, crisis }

/// Editorial chip used by the health wizard steps (diagnoses / allergies /
/// medications) to render an added item. Mirrors `health-steps.jsx::HealthChip`:
/// a monospace code badge, a bold label, an optional dose/sourceTag, an optional
/// sub line, and a trailing remove affordance.
class HealthChip extends StatelessWidget {
  /// The code badge text (e.g. an ICD-10 or RxTerms code). Hidden when empty.
  final String code;

  /// Primary label (condition / drug / allergen name).
  final String label;

  /// Optional secondary line under the label.
  final String? sub;

  /// Optional monospace dose shown next to the label (medications).
  final String? dose;

  /// Optional small source tag pill (e.g. "ICD-10", "RxTerms").
  final String? sourceTag;

  final HealthChipTone tone;

  /// Remove handler. When null, no remove affordance is shown.
  final VoidCallback? onRemove;

  /// Optional "learn about this" handler. When set, a small info affordance is
  /// shown before the remove button (used to open plain-language education).
  final VoidCallback? onInfo;

  const HealthChip({
    required this.code,
    required this.label,
    this.sub,
    this.dose,
    this.sourceTag,
    this.tone = HealthChipTone.primary,
    this.onRemove,
    this.onInfo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;

    late final Color bg;
    late final Color border;
    late final Color codeBg;
    late final Color codeFg;
    late final Color text;
    switch (tone) {
      case HealthChipTone.primary:
        bg = p.primaryTint;
        border = p.primaryLight;
        codeBg = p.primary;
        codeFg = p.onPrimary;
        text = p.text;
      case HealthChipTone.warn:
        bg = dark
            ? SemanticColors.warningBgDark
            : SemanticColors.warningBgLight;
        border = dark
            ? SemanticColors.warningBorderDark
            : SemanticColors.warningBorderLight;
        codeBg = dark
            ? SemanticColors.warningTextDark
            : SemanticColors.warningTextLight;
        codeFg = dark ? const Color(0xFF2A2102) : Colors.white;
        text = dark
            ? SemanticColors.warningTextDark
            : SemanticColors.warningTextLight;
      case HealthChipTone.crisis:
        bg = dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight;
        border = dark
            ? SemanticColors.errorBorderDark
            : SemanticColors.errorBorderLight;
        codeBg = dark
            ? SemanticColors.errorAccentDark
            : SemanticColors.errorAccentLight;
        codeFg = Colors.white;
        text =
            dark ? SemanticColors.errorTextDark : SemanticColors.errorTextLight;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (code.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(top: 1),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: codeBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                code,
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontFamilyFallback: const [
                    'Consolas',
                    'Menlo',
                    'Courier New',
                    'monospace'
                  ],
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: codeFg,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: text,
                      ),
                    ),
                    if (dose != null && dose!.isNotEmpty)
                      Text(
                        dose!,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontFamilyFallback: const [
                            'Consolas',
                            'Menlo',
                            'Courier New',
                            'monospace'
                          ],
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                          color: text.withValues(alpha: 0.75),
                        ),
                      ),
                    if (sourceTag != null && sourceTag!.isNotEmpty)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: p.card,
                          border: Border.all(color: border),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          sourceTag!,
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontFamilyFallback: const [
                              'Consolas',
                              'Menlo',
                              'Courier New',
                              'monospace'
                            ],
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                            color: codeBg,
                          ),
                        ),
                      ),
                  ],
                ),
                if (sub != null && sub!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    sub!,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      height: 1.35,
                      color: text.withValues(alpha: 0.78),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onInfo != null)
            Semantics(
              button: true,
              label: 'Learn about $label',
              child: InkWell(
                onTap: onInfo,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.info_outline, size: 16, color: text),
                ),
              ),
            ),
          if (onRemove != null)
            Semantics(
              button: true,
              label: 'Remove $label',
              child: InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(Icons.close, size: 14, color: text),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
