import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

/// Self-binding ("Ulysses") clause (v2 prototype `m-ulysses`, v3 corrected
/// framing).
///
/// IMPORTANT (per v3): in Pennsylvania, self-binding is **structural, not
/// opt-in** — once two qualified professionals find the principal incapable,
/// the directive can only be revoked when capacity returns (20 Pa.C.S.
/// § 5808). The toggle on this screen simply records the principal's
/// **acknowledgment** that they understand this structural effect, so the
/// rendered PDF can include a one-line acknowledgment that the principal
/// reviewed the boundary.
class UlyssesClauseScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const UlyssesClauseScreen({required this.directiveId, super.key});

  @override
  ConsumerState<UlyssesClauseScreen> createState() =>
      _UlyssesClauseScreenState();
}

class _UlyssesClauseScreenState extends ConsumerState<UlyssesClauseScreen> {
  bool _acknowledged = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final pref = await ref
        .read(directiveRepositoryProvider)
        .getPreferences(widget.directiveId);
    if (!mounted) return;
    setState(() {
      _acknowledged = pref?.selfBindingEnabled ?? false;
      _loading = false;
    });
  }

  Future<void> _setAcknowledged(bool v) async {
    if (v) {
      final confirmed = await _confirmEnable();
      if (!confirmed) return;
    }
    setState(() => _acknowledged = v);
    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            selfBindingEnabled: Value(v),
          ),
        );
  }

  Future<bool> _confirmEnable() async {
    final cs = Theme.of(context).colorScheme;
    final v = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Before you acknowledge'),
        content: const Text(
          'This is a significant decision. Once you are found incapable, the '
          'directive cannot be revoked by you until capacity returns. We '
          'strongly recommend talking it through with a peer specialist or '
          'your clinician before saving.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Not now')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(backgroundColor: cs.primary),
              child: const Text('I understand')),
        ],
      ),
    );
    return v == true;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrUlysses (gap-analysis.jsx L727-901) uses CrisisBar + an
      // in-body back chevron. The editorial "If future-me refuses…" header
      // owns the visual title rather than a Material AppBar string.
      body: Column(children: [
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
              children: [
                const SectionLabel('Optional add-on'),
                const SizedBox(height: 6),
                const EditorialHeading(text: 'If future-me refuses…', size: 30),
                const SizedBox(height: 6),
                Text(
                  'Sometimes during a crisis, people refuse treatment that '
                  "they'd want when well. PA law honors what you wrote today, "
                  'even if you protest in the moment.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    color: p.textMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: _acknowledged ? cs.primary : cs.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SELF-BINDING ("Ulysses")',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontFamilyFallback: const [
                              'Consolas',
                              'Menlo',
                              'Courier New',
                              'monospace',
                            ],
                            fontSize: 11,
                            letterSpacing: 1,
                            fontWeight: FontWeight.w700,
                            color: _acknowledged
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tie myself to the mast.',
                          style: TextStyle(
                            fontFamily: 'Instrument Serif',
                            fontFamilyFallback: const [
                              'Georgia',
                              'Times New Roman',
                              'serif',
                            ],
                            fontStyle: FontStyle.italic,
                            fontSize: 24,
                            color: _acknowledged ? cs.onPrimary : cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Per PA Act 194 (20 Pa.C.S. § 5808), this directive '
                          "may be revoked only while I have capacity. Once I'm "
                          "found incapable, what I wrote here stands — even "
                          'over my in-the-moment protest — until capacity '
                          'returns.',
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13.5,
                            height: 1.45,
                            color: _acknowledged
                                ? cs.onPrimary
                                : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          value: _acknowledged,
                          onChanged: _setAcknowledged,
                          activeThumbColor: cs.onPrimary,
                          title: Text(
                            'I acknowledge this',
                            style: TextStyle(
                              color: _acknowledged
                                  ? cs.onPrimary
                                  : cs.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            'Recorded in your directive PDF.',
                            style: TextStyle(
                              color: _acknowledged
                                  ? cs.onPrimary.withValues(alpha: 0.8)
                                  : cs.onSurfaceVariant,
                            ),
                          ),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _BoundariesCard(),
                const SizedBox(height: 14),
                const InfoBanner(
                  icon: Icons.warning_amber_rounded,
                  variant: InfoBannerVariant.warning,
                  text:
                      'Strongly recommended: talk with a peer specialist or '
                      'clinician before saving. See "Get help" in Settings.',
                ),
              ],
            )),
      ]),
    );
  }
}

class _BoundariesCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const boundaries = [
      'Only applies once I have been formally found to lack capacity',
      'Only for treatments I explicitly named (medications, ECT, facility)',
      'Does not authorize physical restraint',
      'A court-appointed guardian (not the agent) may revoke, suspend, or terminate',
      'My directive still terminates at 2 years — unless I am incapable when '
          'it would expire, in which case it remains in effect (§ 5808)',
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel('Boundaries on this clause'),
            const SizedBox(height: 8),
            for (final b in boundaries)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(b,
                          style: const TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 13.5,
                            height: 1.4,
                          )),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
