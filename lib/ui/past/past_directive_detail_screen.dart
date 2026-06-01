import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// Past directive detail (v2 prototype `m-past`).
///
/// Per v3: the "Who had a copy" share-log is PRIVATE MODE ONLY. In public
/// mode, the section shows a clear note that no history is kept. Each row
/// has a Redact control (since recipient PII is sensitive).
class PastDirectiveDetailScreen extends ConsumerWidget {
  final int directiveId;
  const PastDirectiveDetailScreen({required this.directiveId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final isPrivate =
        ref.watch(privacyModeNotifierProvider).isPrivate;
    final directiveAsync = ref.watch(directiveByIdProvider(directiveId));

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(title: const Text('Past directive')),
      body: directiveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Unable to load: $e')),
        data: (d) {
          if (d == null) {
            return const Center(child: Text('Directive not found.'));
          }
          return _Body(directive: d, isPrivate: isPrivate);
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Directive directive;
  final bool isPrivate;
  const _Body({required this.directive, required this.isPrivate});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dateFmt = DateFormat('MMM d, y');
    final status = directive.status == DirectiveStatus.revoked.name
        ? 'Revoked'
        : directive.status == DirectiveStatus.expired.name
            ? 'Expired'
            : directive.status == DirectiveStatus.complete.name
                ? 'Active'
                : 'Draft';
    final dark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = status == 'Revoked'
        ? (dark
            ? SemanticColors.errorAccentDark
            : SemanticColors.errorAccentLight)
        : status == 'Expired'
            ? (dark
                ? SemanticColors.warningTextDark
                : SemanticColors.warningTextLight)
            : (dark
                ? SemanticColors.successTextDark
                : SemanticColors.successTextLight);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text('● ${status.toUpperCase()}',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontFamilyFallback: const [
                  'Consolas',
                  'Menlo',
                  'Courier New',
                  'monospace'
                ],
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
                color: statusColor,
              )),
        ),
        const SizedBox(height: 10),
        EditorialHeading(
          text: directive.fullName.isEmpty
              ? 'Untitled directive'
              : directive.fullName,
          size: 28,
        ),
        const SizedBox(height: 4),
        Text(
          [
            FormType.values
                .firstWhere((e) => e.name == directive.formType,
                    orElse: () => FormType.combined)
                .displayName,
            if (directive.expirationDate != null)
              'expires ${dateFmt.format(DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!))}',
          ].join(' · '),
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13.5,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 20),
        const SectionLabel('Who had a copy'),
        const SizedBox(height: 6),
        if (!isPrivate)
          const InfoBanner(
            icon: Icons.privacy_tip_outlined,
            variant: InfoBannerVariant.info,
            text:
                'Public mode keeps no share history. This list is empty by '
                'design. Switch to private mode to record where copies went.',
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'No share log entries yet.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "We don't track delivery or receipt confirmation (that "
                    'would need a server). Add entries manually as you '
                    'distribute copies.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

        const SizedBox(height: 16),
        const SectionLabel('Actions'),
        const SizedBox(height: 6),
        ListTile(
          leading: const Icon(Icons.swap_vert),
          title: const Text('Copy to a new directive'),
          subtitle: const Text('Start with these answers'),
          onTap: () => Navigator.of(context).maybePop(),
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Download the PDF'),
          subtitle: const Text('Keep a record for yourself'),
          onTap: () => Navigator.of(context).maybePop(),
        ),
        ListTile(
          leading: const Icon(Icons.share_outlined),
          title: const Text('Re-send to someone'),
          subtitle: const Text('Use your system mail/SMS composer'),
          onTap: () => Navigator.of(context).maybePop(),
        ),
        ListTile(
          leading: Icon(Icons.delete_outline,
              color: Theme.of(context).colorScheme.error),
          title: Text('Delete from this device',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          subtitle: const Text('The directive remains revoked / expired regardless'),
          onTap: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}
