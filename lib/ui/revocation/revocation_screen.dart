import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/mono_pill.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

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
    // Use the picked recipients in the follow-up dialog so the choice is
    // not silently discarded. Previously `_notifyPicked` was captured but
    // never read, and the snackbar promised a revocation PDF the app did
    // not yet generate — honest copy now, with a per-recipient checklist
    // the user works from.
    final picked = _notifyPicked.toList();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Marked revoked on this device'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Per 20 Pa.C.S. § 5808, revocation is effective only when '
              'communicated to your attending physician or provider. '
              'Marking this directive revoked here does not communicate it — '
              'you still need to tell each recipient.',
            ),
            if (picked.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('You picked these recipients to notify:',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              for (final cat in picked) Text('• $cat'),
            ],
            const SizedBox(height: 12),
            const Text(
              'A revocation-letter PDF is not yet generated automatically. '
              'Until that is wired up, call or email each recipient yourself, '
              'and ask the receiving provider to record the revocation in '
              'your chart.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrRevoke (mobile-extra.jsx L1551-1656) opens with
      // CrisisBar + a thin in-body back row, then the editorial 'Are you
      // sure?' headline. No Material AppBar.
      body: Column(children: [
        const CrisisTopBar(compact: true),
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          // Editorial 'PERMANENT ACTION' pill replaces what was the
          // AppBar's title. The 38pt 'Are you sure?' headline below
          // matches the prototype L1568 wording exactly.
          MonoPill(
            label: 'Permanent action',
            foreground: cs.onErrorContainer,
            background: cs.errorContainer,
          ),
          const SizedBox(height: 12),
          // Headline bumped 30 -> 38pt to match prototype L1568.
          const EditorialHeading(text: 'Are you sure?', size: 38),
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
          // Plain-language "how it works" steps (artboard WebRevoke) — sits
          // above the verbatim statutory statement as an actionable summary.
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SectionLabel('How revocation works in PA'),
                  SizedBox(height: 10),
                  _RevokeStep(
                    n: 1,
                    text: 'Put it in writing — sign and date a short '
                        'statement that you are revoking this directive.',
                  ),
                  _RevokeStep(
                    n: 2,
                    text: 'Tell your agent, your providers, and anyone '
                        'holding a copy.',
                  ),
                  _RevokeStep(
                    n: 3,
                    text: 'Destroy old copies, or clearly mark them '
                        '“REVOKED”.',
                    last: true,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
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
            'No batch sends — pick each recipient. The app keeps your '
            'choices in front of you as a checklist; you contact each '
            'recipient yourself (call, email, or in person).',
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
      )),
      ]),
    );
  }
}

/// One numbered step in the "How revocation works in PA" card (artboard
/// WebRevoke) — a small primary numeral chip beside the step text.
class _RevokeStep extends StatelessWidget {
  final int n;
  final String text;
  final bool last;
  const _RevokeStep({required this.n, required this.text, this.last = false});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: p.primaryTint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$n',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontFamilyFallback: const [
                  'Consolas',
                  'Menlo',
                  'Courier New',
                  'monospace',
                ],
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: p.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13.5,
                  height: 1.5,
                  color: p.text,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
