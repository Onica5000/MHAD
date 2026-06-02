import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
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

class _Body extends ConsumerWidget {
  final Directive directive;
  final bool isPrivate;
  const _Body({required this.directive, required this.isPrivate});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete from this device?'),
        content: const Text(
          'This removes the saved directive from this device. The legal '
          'effect of any previously-signed paper copy is unchanged. This '
          'cannot be undone.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await ref
        .read(directiveRepositoryProvider)
        .deleteDirective(directive.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Directive deleted from this device.')),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          subtitle: const Text(
              'Start a fresh directive with these answers pre-filled — '
              'coming with renewal flow'),
          // Wire to renewal/duplication once the renewal flow is built;
          // for now the visible CTA tells the user it's pending so it isn't
          // a silent no-op.
          enabled: false,
          onTap: null,
        ),
        ListTile(
          leading: const Icon(Icons.download_outlined),
          title: const Text('Download the PDF'),
          subtitle: const Text('Open the Export screen'),
          onTap: () =>
              context.push(AppRoutes.exportRoute(directive.id)),
        ),
        ListTile(
          leading: const Icon(Icons.share_outlined),
          title: const Text('Re-send to someone'),
          subtitle: const Text('Open the share sheet'),
          onTap: () =>
              context.push(AppRoutes.shareSheetRoute(directive.id)),
        ),
        ListTile(
          leading: Icon(Icons.delete_outline,
              color: Theme.of(context).colorScheme.error),
          title: Text('Delete from this device',
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          subtitle: const Text(
              'Permanently removes the saved row from this device. Legal '
              'effect of any signed paper copy is unchanged.'),
          onTap: () => _confirmDelete(context, ref),
        ),
      ],
    );
  }
}
