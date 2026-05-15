import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows the crisis resources bottom sheet (988, Crisis Text Line, SAMHSA,
/// PA Protection & Advocacy). Mirrors the prototype's `ScrCrisis`.
Future<void> showCrisisSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CrisisSheet(),
  );
}

class _CrisisSheet extends StatelessWidget {
  const _CrisisSheet();

  Future<void> _launch(BuildContext context, String uri,
      {String? copyValue}) async {
    if (platformIsMobile && !kIsWeb) {
      final url = Uri.parse(uri);
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } else if (copyValue != null) {
      await Clipboard.setData(ClipboardData(text: copyValue));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$copyValue copied to clipboard')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(DesignTokens.sheetRadius)),
        ),
        child: SafeArea(
          top: false,
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 24),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.border,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: SemanticColors.errorAccentLight,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '24/7 FREE, CONFIDENTIAL',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: SemanticColors.errorAccentLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const EditorialHeading(
                text: 'You are not alone.',
                size: 34,
              ),
              const SizedBox(height: 8),
              Text(
                'Real people are standing by — phone, text, or chat.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  color: p.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              _CrisisRow(
                name: '988 Suicide & Crisis Lifeline',
                detail: 'Call or text 988',
                icon: Icons.phone_outlined,
                accent: true,
                onTap: () => _launch(context, 'tel:$crisis988Phone',
                    copyValue: crisis988Phone),
              ),
              _CrisisRow(
                name: 'Crisis Text Line',
                detail: 'Text HOME to $crisisTextLine',
                icon: Icons.sms_outlined,
                onTap: () => _launch(
                    context, 'sms:$crisisTextLine?body=HOME',
                    copyValue: crisisTextLine),
              ),
              _CrisisRow(
                name: 'SAMHSA National Helpline',
                detail: '$samhsaHelpline · treatment referrals',
                icon: Icons.favorite_border,
                onTap: () => _launch(context, 'tel:$samhsaHelpline',
                    copyValue: samhsaHelpline),
              ),
              _CrisisRow(
                name: 'PA Protection & Advocacy',
                detail: '$paProtectionAdvocacyPhone · know your rights',
                icon: Icons.shield_outlined,
                onTap: () => _launch(context, 'tel:$paProtectionAdvocacyPhone',
                    copyValue: paProtectionAdvocacyPhone),
              ),
              _CrisisRow(
                name: 'Veterans Crisis Line',
                detail: 'Call 988, press 1',
                icon: Icons.military_tech_outlined,
                onTap: () => _launch(context, 'tel:$veteransCrisisPhone',
                    copyValue: veteransCrisisPhone),
              ),
              const SizedBox(height: 10),
              const SectionLabel('Why these numbers?'),
              const SizedBox(height: 4),
              Text(
                'Calling 988 connects you to a trained counselor in your '
                'area. It is free, confidential, and available 24 hours a '
                'day. Calling will not result in police being dispatched in '
                'most cases.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  color: p.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrisisRow extends StatelessWidget {
  final String name;
  final String detail;
  final IconData icon;
  final bool accent;
  final VoidCallback onTap;

  const _CrisisRow({
    required this.name,
    required this.detail,
    required this.icon,
    required this.onTap,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final bg = accent
        ? (dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight)
        : p.surface;
    final border = accent
        ? (dark
            ? SemanticColors.errorBorderDark
            : SemanticColors.errorBorderLight)
        : p.border;
    final iconBg = accent
        ? (dark
            ? SemanticColors.errorAccentDark
            : SemanticColors.errorAccentLight)
        : p.primaryLight;
    final iconFg = accent
        ? Colors.white
        : p.onPrimaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 20, color: iconFg),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: accent
                              ? (dark
                                  ? SemanticColors.errorTextDark
                                  : SemanticColors.errorTextLight)
                              : p.text,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        detail,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12,
                          color: accent
                              ? (dark
                                  ? SemanticColors.errorTextDark
                                  : SemanticColors.errorTextLight)
                                  .withValues(alpha: 0.85)
                              : p.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: accent
                      ? (dark
                          ? SemanticColors.errorAccentDark
                          : SemanticColors.errorAccentLight)
                      : p.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
