import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';

/// Thin top bar prompting the user to call/text 988. Tap to open the
/// [CrisisSheet] bottom sheet with full resources.
class CrisisTopBar extends StatelessWidget {
  /// Compact = shorter padding, used when sharing space with the wizard header.
  final bool compact;
  const CrisisTopBar({this.compact = false, super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight;
    final border = dark
        ? SemanticColors.errorBorderDark
        : SemanticColors.errorBorderLight;
    final fg = dark
        ? SemanticColors.errorTextDark
        : SemanticColors.errorTextLight;
    final accent = dark
        ? SemanticColors.errorAccentDark
        : SemanticColors.errorAccentLight;

    return Semantics(
      button: true,
      label: 'Need help now? Tap to see crisis resources including 988',
      child: Material(
        color: bg,
        child: InkWell(
          onTap: () => showCrisisSheet(context),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: compact ? 8 : 10,
            ),
            child: Row(
              children: [
                Icon(Icons.phone_outlined, size: 14, color: accent),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: fg,
                      ),
                      children: [
                        const TextSpan(text: 'Need help now?  '),
                        TextSpan(
                          text: 'Call or text 988',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '24/7',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace'
                    ],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
