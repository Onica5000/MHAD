import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/home/section_completion_indicator.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/design_card.dart';
import 'package:mhad/ui/widgets/design/gradient_progress.dart';
import 'package:mhad/ui/widgets/design/status_pill.dart';

class DirectiveCard extends StatelessWidget {
  final Directive directive;
  final VoidCallback onDelete;
  final VoidCallback? onRevoke;
  final VoidCallback? onRenew;
  final VoidCallback? onExport;
  final String? agentName;

  const DirectiveCard({
    required this.directive,
    required this.onDelete,
    this.onRevoke,
    this.onRenew,
    this.onExport,
    this.agentName,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;

    final formType = FormType.values.firstWhere(
      (e) => e.name == directive.formType,
      orElse: () => FormType.combined,
    );
    final status = DirectiveStatus.values.firstWhere(
      (e) => e.name == directive.status,
      orElse: () => DirectiveStatus.draft,
    );
    final updated = DateTime.fromMillisecondsSinceEpoch(directive.updatedAt);
    final dateStr = DateFormat('MMM d, yyyy').format(updated);

    final isRevoked = status == DirectiveStatus.revoked;

    String? expirationNote;
    Color? expirationColor;
    if (status == DirectiveStatus.complete &&
        directive.expirationDate != null) {
      final expDate = DateTime.fromMillisecondsSinceEpoch(
          directive.expirationDate!);
      final hoursLeft = expDate.difference(DateTime.now()).inHours;
      final daysLeft = (hoursLeft / 24).ceil();
      if (hoursLeft < 0) {
        expirationNote = 'Expired';
        expirationColor = Theme.of(context).colorScheme.error;
      } else if (daysLeft <= 1) {
        expirationNote = 'Expires today';
        expirationColor = Theme.of(context).colorScheme.error;
      } else if (daysLeft <= 60) {
        expirationNote = 'Expires in $daysLeft days';
        expirationColor = Theme.of(context).colorScheme.error;
      } else {
        final months = (daysLeft / 30).round();
        expirationNote = 'Expires in ~$months months';
      }
    }

    final displayName = directive.fullName.isNotEmpty
        ? directive.fullName
        : 'Untitled Directive';
    final statusLabel = switch (status) {
      DirectiveStatus.draft => 'In Progress',
      DirectiveStatus.complete => 'Complete',
      DirectiveStatus.expired => 'Expired',
      DirectiveStatus.revoked => 'Revoked',
    };
    final formLabel = switch (formType) {
      FormType.combined => 'Combined',
      FormType.declaration => 'Declaration',
      FormType.poa => 'Power of Attorney',
    };
    final (statusFg, statusBg, statusIcon) = switch (status) {
      DirectiveStatus.complete => (
          dark
              ? SemanticColors.successTextDark
              : SemanticColors.successTextLight,
          dark ? SemanticColors.successBgDark : SemanticColors.successBgLight,
          Icons.check_circle,
        ),
      DirectiveStatus.draft => (
          dark
              ? SemanticColors.warningTextDark
              : SemanticColors.warningTextLight,
          dark ? SemanticColors.warningBgDark : SemanticColors.warningBgLight,
          Icons.edit_note,
        ),
      DirectiveStatus.expired => (
          p.textMuted,
          p.primaryTint,
          Icons.schedule,
        ),
      DirectiveStatus.revoked => (
          dark ? SemanticColors.errorTextDark : SemanticColors.errorTextLight,
          dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight,
          Icons.cancel,
        ),
    };

    double? completionPct;
    if (status == DirectiveStatus.draft) {
      // Rough progress from SectionCompletionIndicator behavior: let the
      // existing indicator render under the bar for granular details.
      completionPct = null;
    }

    return MergeSemantics(
      child: Semantics(
        label: '$displayName, $statusLabel $formLabel directive, '
            'last edited $dateStr',
        button: !isRevoked,
        child: DesignCard(
          margin: const EdgeInsets.only(bottom: 12),
          onTap: isRevoked
              ? null
              : () => context.push(AppRoutes.wizardRoute(directive.id)),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.description,
                    size: 24, color: p.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      formLabel,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        color: p.textMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        StatusPill(
                          label: statusLabel,
                          icon: statusIcon,
                          foreground: statusFg,
                          background: statusBg,
                        ),
                        if (status == DirectiveStatus.complete &&
                            directive.expirationDate != null)
                          Text(
                            'Expires ${DateFormat('MMM d, yyyy').format(DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!))}',
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 11,
                              color: p.textMuted,
                            ),
                          ),
                      ],
                    ),
                    if (status == DirectiveStatus.draft) ...[
                      const SizedBox(height: 10),
                      GradientProgress(
                        value: completionPct ?? 0.4,
                        height: 4,
                      ),
                      const SizedBox(height: 4),
                      SectionCompletionIndicator(directive: directive),
                    ],
                    if (agentName != null && agentName!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 13, color: p.textMuted),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Agent: $agentName',
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: p.textMuted,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Last edited $dateStr',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11,
                          color: p.textMuted,
                        ),
                      ),
                    ),
                    if (expirationNote != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(
                              expirationNote == 'Expired'
                                  ? Icons.error_outline
                                  : Icons.schedule,
                              size: 14,
                              color: expirationColor ?? p.textMuted,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              expirationNote,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12,
                                color: expirationColor ?? p.textMuted,
                                fontWeight: expirationColor != null
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<_Action>(
                tooltip: 'More actions',
                icon: Icon(Icons.more_vert,
                    size: 20, color: p.textMuted),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (action) {
                  if (action == _Action.export) onExport?.call();
                  if (action == _Action.delete) onDelete();
                  if (action == _Action.revoke) onRevoke?.call();
                  if (action == _Action.renew) onRenew?.call();
                  if (action == _Action.edit && !isRevoked) {
                    context.push(AppRoutes.wizardRoute(directive.id));
                  }
                },
                itemBuilder: (_) => [
                  if (!isRevoked)
                    const PopupMenuItem(
                      value: _Action.edit,
                      child: Row(children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Continue Editing'),
                      ]),
                    ),
                  const PopupMenuItem(
                    value: _Action.export,
                    child: Row(children: [
                      Icon(Icons.file_download_outlined, size: 18),
                      SizedBox(width: 10),
                      Text('Export / Print'),
                    ]),
                  ),
                  if ((status == DirectiveStatus.complete ||
                          status == DirectiveStatus.expired) &&
                      onRenew != null)
                    const PopupMenuItem(
                      value: _Action.renew,
                      child: Row(children: [
                        Icon(Icons.autorenew, size: 18),
                        SizedBox(width: 10),
                        Text('Renew'),
                      ]),
                    ),
                  if (status == DirectiveStatus.complete && onRevoke != null)
                    const PopupMenuItem(
                      value: _Action.revoke,
                      child: Row(children: [
                        Icon(Icons.cancel_outlined, size: 18),
                        SizedBox(width: 10),
                        Text('Revoke'),
                      ]),
                    ),
                  PopupMenuItem(
                    value: _Action.delete,
                    child: Row(children: [
                      Icon(Icons.delete_outline,
                          size: 18,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 10),
                      Text('Delete',
                          style: TextStyle(
                              color:
                                  Theme.of(context).colorScheme.error)),
                    ]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _Action { edit, export, delete, revoke, renew }
