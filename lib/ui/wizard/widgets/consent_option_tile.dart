import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';

/// A selectable tile used on consent-style wizard steps (ECT, Experimental
/// Studies, Drug Trials). Renders as a DesignCard with an icon, title, and
/// optional description. When [selected], shows primary tint + border.
class ConsentOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final bool selected;
  final VoidCallback onTap;

  const ConsentOptionTile({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DesignCard(
        variant: selected ? DesignCardVariant.tinted : DesignCardVariant.plain,
        overrideBorder: selected
            ? BorderSide(color: p.primary, width: 2)
            : null,
        onTap: onTap,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? p.primary : p.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? Colors.white : p.primary,
              ),
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
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: p.text,
                      height: 1.35,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: p.textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              size: 20,
              color: selected ? p.primary : p.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
