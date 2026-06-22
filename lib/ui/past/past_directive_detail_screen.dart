import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/action_row.dart';
import 'package:mhad/ui/widgets/design/dashed_divider.dart';
import 'package:mhad/ui/widgets/design/directive_status_style.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/mono_pill.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

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
      // Prototype ScrPastDetail (mobile-extra.jsx L186-193) uses CrisisBar
      // compact + an in-body 'Past directives' back link, not a Material
      // AppBar.
      body: Column(
        children: [
          WizardHeader(
            backLabel: 'Past directives',
            onBack: () => Navigator.of(context).maybePop(),
            actionLabel: '',
          ),
          Expanded(
            child: directiveAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Unable to load: $e')),
              data: (d) {
                if (d == null) {
                  return const Center(child: Text('Directive not found.'));
                }
                return _Body(directive: d, isPrivate: isPrivate);
              },
            ),
          ),
        ],
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
    final status = directiveStatusLabel(directive.status);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = directiveStatusColor(directive.status, dark: dark);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      children: [
        MonoPill(
          label: status,
          foreground: statusColor,
          background: statusColor.withValues(alpha: 0.15),
        ),
        const SizedBox(height: 10),
        // Editorial title — prototype uses "Directive · <YEAR>" with the
        // year in primary color. Year comes from executionDate if set,
        // otherwise createdAt as a fallback. When the user's stored name
        // is on file it goes into the subtitle line for context.
        _PastDetailTitle(directive: directive),
        const SizedBox(height: 4),
        Text(
          [
            FormType.values
                .firstWhere((e) => e.name == directive.formType,
                    orElse: () => FormType.combined)
                .displayName,
            if (directive.executionDate != null)
              'signed ${dateFmt.format(DateTime.fromMillisecondsSinceEpoch(directive.executionDate!))}',
            if (directive.expirationDate != null)
              status == 'Expired'
                  ? 'expired ${dateFmt.format(DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!))}'
                  : 'expires ${dateFmt.format(DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!))}',
          ].join(' · '),
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 13.5,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        // Editorial document-preview card — matches prototype ScrPastDetail
        // L204-231 with the FileText icon + filename + "N pages · ~X MB"
        // caption + ghost Preview button, then a 3-column dashed-divider
        // grid for Signed by / Witness 1 / Witness 2. Page count / size
        // are estimates since the PDF is generated on demand rather than
        // stored. Witnesses pull from the Witnesses table; if none are
        // recorded (e.g. directives signed under the new wet-ink-only
        // model where witness names aren't captured in-app) we render an
        // em-dash to match the prototype's "no data" treatment.
        _DocPreviewCard(directive: directive),
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
        // Editorial action rows — matches prototype ScrPastDetail L267-292.
        // Tone variants drive icon-tile color: primary for the recommended
        // "Copy to new directive" CTA, danger for "Delete from this
        // device", neutral for the rest.
        const ActionRow(
          tone: ActionRowTone.primary,
          icon: Icons.swap_vert,
          title: 'Copy to a new directive',
          subtitle:
              'Start with these answers — coming with the renewal flow',
          onTap: null,
        ),
        const SizedBox(height: 8),
        ActionRow(
          icon: Icons.open_in_new,
          title: 'Open the PDF',
          subtitle: 'Print or save for your records',
          onTap: () =>
              context.push(AppRoutes.exportRoute(directive.id)),
        ),
        const SizedBox(height: 8),
        ActionRow(
          tone: ActionRowTone.danger,
          icon: Icons.delete_outline,
          title: 'Delete from this device',
          subtitle: 'The directive remains $status regardless',
          onTap: () => _confirmDelete(context, ref),
        ),
      ],
    );
  }
}

/// Editorial "Directive · YEAR" title where the year is tinted primary.
/// Falls back to the directive's full name if no execution / created date
/// is available (e.g. an in-progress draft).
class _PastDetailTitle extends StatelessWidget {
  final Directive directive;
  const _PastDetailTitle({required this.directive});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final ts = directive.executionDate ?? directive.createdAt;
    final year = DateTime.fromMillisecondsSinceEpoch(ts).year.toString();
    return Text.rich(
      TextSpan(
        children: [
          const TextSpan(text: 'Directive · '),
          TextSpan(
            text: year,
            style: TextStyle(color: p.primary),
          ),
        ],
      ),
      style: const TextStyle(
        fontFamily: 'Instrument Serif',
        fontFamilyFallback: ['Georgia', 'serif'],
        fontStyle: FontStyle.italic,
        fontSize: 38,
        fontWeight: FontWeight.w400,
        height: 1.05,
        letterSpacing: -0.5,
      ),
    );
  }
}

/// Document-preview card with filename, page-count caption, ghost
/// "Preview" button, and a 3-column "Signed by / Witness 1 / Witness 2"
/// grid separated from the header by a dashed divider.
///
/// Witness data is pulled from the Witnesses table; if the directive was
/// signed under the new wet-ink-only model (no in-app witness capture),
/// those columns render an em-dash.
class _DocPreviewCard extends ConsumerWidget {
  final Directive directive;
  const _DocPreviewCard({required this.directive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = Theme.of(context).mhadPalette;
    final principal = directive.fullName.trim().isEmpty
        ? 'You'
        : directive.fullName.trim().split(RegExp(r'\s+')).first;
    final filename =
        'Directive_${DateTime.fromMillisecondsSinceEpoch(directive.executionDate ?? directive.createdAt).year}'
        '_${directive.fullName.trim().split(RegExp(r'\s+')).lastOrNull ?? 'MHAD'}.pdf';

    return FutureBuilder<List<WitnessesData>>(
      future: ref
          .read(directiveRepositoryProvider)
          .getWitnesses(directive.id),
      builder: (context, snapshot) {
        final witnesses = snapshot.data ?? const <WitnessesData>[];
        String witnessShort(int n) {
          final matches = witnesses.where((w) => w.witnessNumber == n);
          if (matches.isEmpty) return '—';
          final match = matches.first;
          if (match.fullName.trim().isEmpty) return '—';
          final parts = match.fullName.trim().split(RegExp(r'\s+'));
          if (parts.length == 1) return parts.first;
          return '${parts.first[0]}. ${parts.last}';
        }

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: p.card,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.description_outlined,
                      size: 20, color: p.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filename,
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: p.text,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Generated on demand · ~6 pages',
                          style: TextStyle(
                            fontFamily: kSansFamily,
                            fontSize: 11.5,
                            color: p.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context
                        .push(AppRoutes.exportRoute(directive.id)),
                    icon: const Icon(Icons.visibility_outlined, size: 14),
                    label: const Text('Preview'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Dashed-style divider — drawn as a custom painted line
              // since Flutter has no built-in dashed Divider widget.
              DashedDivider(color: p.border),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _SigCol(label: 'SIGNED BY', value: principal)),
                  Expanded(
                      child: _SigCol(
                          label: 'WITNESS 1', value: witnessShort(1))),
                  Expanded(
                      child: _SigCol(
                          label: 'WITNESS 2', value: witnessShort(2))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SigCol extends StatelessWidget {
  final String label;
  final String value;
  const _SigCol({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: kMonoFamily,
            fontFamilyFallback: const [
              'Consolas',
              'Menlo',
              'Courier New',
              'monospace',
            ],
            fontSize: 9.5,
            letterSpacing: 0.4,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: p.text,
          ),
        ),
      ],
    );
  }
}

