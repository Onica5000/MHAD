import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';

/// Tone for [ActionRow] — controls the icon tile's background + the
/// title color. Matches the prototype's `ActionRow` tone enum
/// (mobile-extra.jsx::ActionRow L298-321).
enum ActionRowTone { neutral, primary, danger }

/// Editorial action row used by past-detail and settings screens.
///
/// Visual: a card-radius surface with a 36pt rounded icon tile on the
/// left, title + optional subtitle in the middle, and a chevron-right
/// on the right.
///
/// Tone tints the icon tile (primaryTint / crisisBg / surface) + the icon
/// color and — for danger — the title text. Matches prototype
/// `ActionRow` (mobile-extra.jsx L298-321) which is the shared widget
/// behind ScrPastDetail's actions list and several ScrSettings rows.
class ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final ActionRowTone tone;
  final VoidCallback? onTap;

  const ActionRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.tone = ActionRowTone.neutral,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final dangerAccent =
        dark ? SemanticColors.errorAccentDark : SemanticColors.errorAccentLight;
    final dangerBg =
        dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight;

    final accent = switch (tone) {
      ActionRowTone.primary => p.primary,
      ActionRowTone.danger => dangerAccent,
      ActionRowTone.neutral => p.textMuted,
    };
    final iconBg = switch (tone) {
      ActionRowTone.primary => p.primaryTint,
      ActionRowTone.danger => dangerBg,
      ActionRowTone.neutral => p.surface,
    };
    final titleColor =
        tone == ActionRowTone.danger ? dangerAccent : p.text;

    return Material(
      color: p.card,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 18, color: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11.5,
                            color: p.textMuted,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  size: 18, color: p.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
