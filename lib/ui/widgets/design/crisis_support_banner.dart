import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_sheet.dart';
import 'package:mhad/utils/launch_utils.dart';

/// 988 banner shown at the top of every AI chat surface once a message has
/// matched [looksLikeCrisis] in this session. App-driven, not AI-driven: it
/// appears even if the AI refuses, fails, or isn't set up.
class CrisisSupportBanner extends ConsumerWidget {
  const CrisisSupportBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(crisisSupportShownProvider)) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    final number = appData.phoneOf('crisis988');
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 10, 12, 4),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
        decoration: BoxDecoration(
          color: cs.errorContainer,
          borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.crisisBannerTitle,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onErrorContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.crisisBannerBody,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 13,
                height: 1.4,
                color: cs.onErrorContainer,
              ),
            ),
            Wrap(
              spacing: 4,
              children: [
                TextButton.icon(
                  onPressed: () =>
                      launchOrCopy(context, 'tel:$number', copyValue: number),
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: Text(context.l10n.crisisBannerCall),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onErrorContainer,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      launchOrCopy(context, 'sms:$number', copyValue: number),
                  icon: const Icon(Icons.sms_outlined, size: 18),
                  label: Text(context.l10n.crisisBannerText),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onErrorContainer,
                  ),
                ),
                TextButton(
                  onPressed: () => showCrisisSheet(context),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.onErrorContainer,
                  ),
                  child: Text(context.l10n.crisisBannerMore),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
