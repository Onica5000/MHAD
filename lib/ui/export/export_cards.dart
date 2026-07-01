import 'package:flutter/material.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/utils/date_format.dart';

/// Presentational cards/banners extracted from `export_screen.dart` — pure
/// widgets with no dependency on the screen's mutable state, split out to trim
/// that file and make the pieces independently reusable/testable.

/// "Before sharing…" statutory reminder shown above the export options.
class ExportLegalDisclaimerCard extends StatelessWidget {
  const ExportLegalDisclaimerCard({super.key});

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Important: Before sharing, ensure this directive has been '
            'signed, dated, and witnessed by two adults as required by '
            'PA Act 194. Give copies to your agent, physician, and '
            'support people.',
        container: true,
        child: Card(
          color: Theme.of(context).colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Before sharing: ensure this directive has been signed, dated, '
              'and witnessed by two adults (18+) as required by PA Act 194. '
              'Give copies to your agent, physician, and support people.',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ),
      );
}

/// Principal summary (name + executed / expires dates).
class ExportPrincipalCard extends StatelessWidget {
  const ExportPrincipalCard({required this.directive, super.key});

  final Directive directive;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Principal',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const SizedBox(height: 4),
            Text(directive.fullName, style: const TextStyle(fontSize: 13)),
            if (directive.executionDate != null)
              Text(
                'Executed: ${formatShortDate(DateTime.fromMillisecondsSinceEpoch(directive.executionDate!))}',
                style: const TextStyle(fontSize: 12),
              ),
            if (directive.expirationDate != null)
              Text(
                'Expires: ${formatShortDate(DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!))}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
      ),
    );
  }
}

/// V4-M8 — persistent banner: the exported PDF is unencrypted by design.
class ExportUnencryptedBanner extends StatelessWidget {
  const ExportUnencryptedBanner({super.key});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lock_open_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'The exported PDF is not encrypted. Share only via '
                'channels you trust.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          ],
        ),
      );
}
