import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';

/// The privacy notice shown before the first copy-and-paste handoff of a
/// session (user decision 2026-11-17): the outside AI's own terms apply, MHAD's
/// promise covers MHAD only, using it is the person's choice — plus each AI's
/// private-chat mode and how the copy-and-paste works. Resolves true when the
/// person continues.
Future<bool> showHandoffPrivacyDialog(
  BuildContext context, {
  required String serviceLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dctx) {
      final p = Theme.of(dctx).mhadPalette;
      final t = Theme.of(dctx).textTheme;
      Widget section(IconData icon, String title, String body) => Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 20, color: p.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: t.titleSmall),
                      const SizedBox(height: 4),
                      Text(body, style: t.bodyMedium),
                    ],
                  ),
                ),
              ],
            ),
          );
      return AlertDialog(
        title: EditorialHeading(
          text: dctx.l10n.aiHandoffPrivacyTitle,
          level: HeadingLevel.sub,
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dctx.l10n.aiHandoffPrivacyBody(serviceLabel),
                    style: t.bodyLarge),
                section(
                  Icons.visibility_off_outlined,
                  dctx.l10n.aiHandoffPrivacyPrivateTitle,
                  dctx.l10n.aiHandoffPrivacyPrivateModes,
                ),
                section(
                  Icons.content_paste_go_outlined,
                  dctx.l10n.aiHandoffPrivacyHowTitle,
                  dctx.l10n.aiHandoffPrivacyHowSteps(serviceLabel),
                ),
                section(
                  Icons.timer_outlined,
                  '',
                  dctx.l10n.aiHandoffPrivacyKept,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dctx, false),
            child: Text(dctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dctx, true),
            child: Text(dctx.l10n.aiHandoffPrivacyContinue),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}
