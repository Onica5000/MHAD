import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';

/// Revocation flow (v2 prototype `m-revoke`, v3 canonical PA statutory
/// wording).
///
/// Per 20 Pa.C.S. § 5808: revocation is effective when communicated to the
/// attending physician/provider, either by the principal or by a witness,
/// **and only while the principal has capacity**. The app records the
/// revocation locally (status → revoked); the user is responsible for
/// actually communicating it.
///
/// Per Decision 26 / v3 spec: two provider lists (specific + generic
/// categories); explicit per-row notification opt-in (no batch sends).
class RevocationScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const RevocationScreen({required this.directiveId, super.key});

  @override
  ConsumerState<RevocationScreen> createState() => _RevocationScreenState();
}

class _RevocationScreenState extends ConsumerState<RevocationScreen> {
  final _confirmCtrl = TextEditingController();
  final Set<String> _notifyPicked = {};
  bool _busy = false;

  static const _genericNotifyCategories = [
    'Primary care doctor',
    'Psychiatrist / therapist',
    'Nearest hospital ER',
    'Pharmacy',
    'Local rights advocate',
  ];

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _revoke() async {
    if (_confirmCtrl.text.trim().toUpperCase() != 'REVOKE') return;
    setState(() => _busy = true);
    final repo = ref.read(directiveRepositoryProvider);
    await repo.updateStatus(widget.directiveId, DirectiveStatus.revoked);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Directive marked revoked locally. Now print or email the '
            'revocation letter so providers know.'),
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      appBar: AppBar(title: const Text('Revoke this directive?')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text('● PERMANENT ACTION',
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
                  color: cs.onErrorContainer,
                )),
          ),
          const SizedBox(height: 12),
          const EditorialHeading(text: 'Revoke this directive?', size: 30),
          const SizedBox(height: 8),
          Text(
            'Your directive will no longer be legally binding once you '
            'communicate the revocation to your attending physician or '
            'provider (20 Pa.C.S. § 5808). This app marks the directive '
            'revoked locally and helps you generate a revocation letter.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              color: p.textMuted,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionLabel('Statutory revocation statement'),
                  const SizedBox(height: 6),
                  Text(
                    'This declaration may be revoked in whole or in part at '
                    'any time, either orally or in writing, as long as I '
                    'have not been found to be incapable of making mental '
                    'health decisions. My revocation will be effective upon '
                    'communication to my attending physician or other '
                    'mental health care provider, either by me or a witness '
                    'to my revocation, of the intent to revoke.',
                    style: TextStyle(
                      fontFamily: 'Instrument Serif',
                      fontFamilyFallback: const [
                        'Georgia',
                        'Times New Roman',
                        'serif',
                      ],
                      fontSize: 14,
                      height: 1.6,
                      color: p.text,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          const SectionLabel('Who to notify (opt-in per recipient)'),
          const SizedBox(height: 4),
          Text(
            'No batch sends — pick each recipient. The app generates a '
            'revocation PDF you can email from your phone\'s mail app.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          // Specific list: agents + preferred doctor (loaded via repository
          // would require additional plumbing; we surface the categories the
          // user manually picks).
          for (final cat in _genericNotifyCategories)
            CheckboxListTile(
              title: Text(cat),
              subtitle: Text(
                _notifyPicked.contains(cat)
                    ? 'Will be referenced in your revocation letter'
                    : 'Tap to include',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              value: _notifyPicked.contains(cat),
              onChanged: (v) => setState(() {
                if (v == true) {
                  _notifyPicked.add(cat);
                } else {
                  _notifyPicked.remove(cat);
                }
              }),
              contentPadding: EdgeInsets.zero,
            ),

          const SizedBox(height: 14),
          Card(
            color: cs.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Type REVOKE to confirm',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: cs.onErrorContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmCtrl,
                    decoration: InputDecoration(
                      hintText: 'REVOKE',
                      filled: true,
                      fillColor: cs.surface,
                      border: const OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _confirmCtrl.text.trim().toUpperCase() ==
                                'REVOKE' &&
                            !_busy
                        ? _revoke
                        : null,
                    icon: const Icon(Icons.delete_forever_outlined),
                    label: Text(_busy ? 'Revoking…' : 'Revoke now'),
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.error,
                      foregroundColor: cs.onError,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          const InfoBanner(
            icon: Icons.info_outline,
            variant: InfoBannerVariant.info,
            text:
                'If you have any further questions about how revocation '
                'applies to you, it is wise to consult an attorney for '
                'clarification.',
          ),
        ],
      ),
    );
  }
}
