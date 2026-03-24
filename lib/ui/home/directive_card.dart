import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/ui/home/section_completion_indicator.dart';
import 'package:mhad/ui/router.dart';

class DirectiveCard extends StatelessWidget {
  final Directive directive;
  final VoidCallback onDelete;
  final VoidCallback? onRevoke;
  final VoidCallback? onRenew;
  final VoidCallback? onExport;

  const DirectiveCard({
    required this.directive,
    required this.onDelete,
    this.onRevoke,
    this.onRenew,
    this.onExport,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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

    // Expiration countdown for complete directives
    String? expirationNote;
    if (status == DirectiveStatus.complete &&
        directive.expirationDate != null) {
      final expDate = DateTime.fromMillisecondsSinceEpoch(
          directive.expirationDate!);
      final hoursLeft = expDate.difference(DateTime.now()).inHours;
      final daysLeft = (hoursLeft / 24).ceil(); // round up so 23h = 1 day
      if (hoursLeft < 0) {
        expirationNote = 'Expired';
      } else if (daysLeft <= 1) {
        expirationNote = 'Expires today';
      } else if (daysLeft <= 60) {
        expirationNote = 'Expires in $daysLeft days';
      } else {
        final months = (daysLeft / 30).round();
        expirationNote = 'Expires in ~$months months';
      }
    }

    final displayName = directive.fullName.isNotEmpty
        ? directive.fullName
        : 'Unnamed directive';
    final statusLabel = switch (status) {
      DirectiveStatus.draft => 'Draft',
      DirectiveStatus.complete => 'Complete',
      DirectiveStatus.expired => 'Expired',
      DirectiveStatus.revoked => 'Revoked',
    };
    final formLabel = switch (formType) {
      FormType.combined => 'Combined',
      FormType.declaration => 'Declaration',
      FormType.poa => 'Power of Attorney',
    };

    return MergeSemantics(
      child: Semantics(
        label: '$displayName, $statusLabel $formLabel directive, '
            'last edited $dateStr',
        button: !isRevoked,
        child: Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: isRevoked
                ? null
                : () => context.push(AppRoutes.wizardRoute(directive.id)),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ExcludeSemantics(child: _StatusChip(status)),
                            const SizedBox(width: 8),
                            ExcludeSemantics(child: _FormTypeChip(formType)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Text(
                          'Last edited $dateStr',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        if (status == DirectiveStatus.draft)
                          SectionCompletionIndicator(directive: directive),
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
                                  color: expirationNote.contains('days')
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  expirationNote,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: expirationNote.contains('days')
                                            ? Theme.of(context)
                                                .colorScheme
                                                .error
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                        fontWeight:
                                            expirationNote.contains('days')
                                                ? FontWeight.w600
                                                : null,
                                      ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_Action>(
                    onSelected: (action) {
                      if (action == _Action.export) onExport?.call();
                      if (action == _Action.delete) onDelete();
                      if (action == _Action.revoke) onRevoke?.call();
                      if (action == _Action.renew) onRenew?.call();
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: _Action.export,
                        child: Row(children: [
                          Icon(Icons.picture_as_pdf),
                          SizedBox(width: 8),
                          Text('Export PDF'),
                        ]),
                      ),
                      if ((status == DirectiveStatus.complete ||
                              status == DirectiveStatus.expired) &&
                          onRenew != null)
                        const PopupMenuItem(
                          value: _Action.renew,
                          child: Row(children: [
                            Icon(Icons.autorenew),
                            SizedBox(width: 8),
                            Text('Renew'),
                          ]),
                        ),
                      if (status == DirectiveStatus.complete && onRevoke != null)
                        const PopupMenuItem(
                          value: _Action.revoke,
                          child: Row(children: [
                            Icon(Icons.cancel_outlined),
                            SizedBox(width: 8),
                            Text('Revoke'),
                          ]),
                        ),
                      PopupMenuItem(
                        value: _Action.delete,
                        child: Row(children: [
                          Icon(Icons.delete_outline,
                              color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
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
        ),
      ),
    );
  }
}

enum _Action { export, delete, revoke, renew }

class _StatusChip extends StatelessWidget {
  final DirectiveStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      DirectiveStatus.draft => ('Draft', cs.tertiary),
      DirectiveStatus.complete => ('Complete', cs.primary),
      DirectiveStatus.expired => ('Expired', cs.error),
      DirectiveStatus.revoked => ('Revoked', cs.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

class _FormTypeChip extends StatelessWidget {
  final FormType formType;
  const _FormTypeChip(this.formType);

  @override
  Widget build(BuildContext context) {
    final label = switch (formType) {
      FormType.combined => 'Combined',
      FormType.declaration => 'Declaration',
      FormType.poa => 'POA',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSecondaryContainer)),
    );
  }
}
