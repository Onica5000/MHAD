import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/brand_motif.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';

/// Crisis plan / WRAP toolbox optional add-on (v2 prototype `m-crisisplan`).
///
/// Reachable from the wizard's "Anything else" step (Optional add-ons).
/// Five sections per WRAP:
/// 1. Early warning signs
/// 2. Triggers (red tone)
/// 3. Things that genuinely help
/// 4. Things to say to me
/// 5. Don't do these (red tone)
///
/// Stored as JSON in `directive_prefs.crisisPlanJson`.
class CrisisPlanScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const CrisisPlanScreen({required this.directiveId, super.key});

  @override
  ConsumerState<CrisisPlanScreen> createState() => _CrisisPlanScreenState();
}

class _CrisisPlanScreenState extends ConsumerState<CrisisPlanScreen> {
  final Map<String, List<String>> _data = {
    'earlyWarning': [],
    'triggers': [],
    'helps': [],
    'sayToMe': [],
    'dontDo': [],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final pref = await ref
        .read(directiveRepositoryProvider)
        .getPreferences(widget.directiveId);
    if (pref == null || !mounted) return;
    final raw = pref.crisisPlanJson;
    if (raw.isEmpty) return;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      setState(() {
        for (final k in _data.keys) {
          _data[k] = ((m[k] as List?) ?? []).map((e) => e.toString()).toList();
        }
      });
    } catch (_) {/* ignore malformed JSON */}
  }

  Future<void> _persist() async {
    final raw = jsonEncode(_data);
    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            crisisPlanJson: Value(raw),
          ),
        );
  }

  Future<void> _addItem(String section) async {
    // Extract the dialog into a real StatefulWidget so the
    // TextEditingController has a proper lifecycle and is disposed when
    // the dialog closes. The previous inline `builder:` created the
    // controller every rebuild and never disposed it.
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => const _AddNoteDialog(),
    );
    // Guard against the screen being popped mid-dialog before we touch
    // `setState` — without this check, a back-button between dialog
    // dismiss and the setState below crashes with "setState called after
    // dispose".
    if (!mounted) return;
    if (text == null || text.isEmpty) return;
    setState(() => _data[section] = [..._data[section]!, text]);
    await _persist();
  }

  Future<void> _removeItem(String section, int idx) async {
    setState(() {
      final list = List<String>.from(_data[section]!);
      list.removeAt(idx);
      _data[section] = list;
    });
    await _persist();
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype ScrCrisisPlan (gap-analysis.jsx L434-626) uses CrisisBar
      // + in-body back chevron, then a 38pt editorial heading. No Material
      // AppBar — the "How I know I'm not okay" headline owns the title.
      body: Column(children: [
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
        children: [
          BrandMotif(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionLabel('Optional add-on · WRAP'),
                const SizedBox(height: 6),
                // Headline bumped 30 -> 38pt to match prototype L446.
                const EditorialHeading(
                    text: "How I know I'm not okay", size: 38),
                const SizedBox(height: 6),
                Text(
                  'Adapted from WRAP. Help the people around you spot trouble '
                  'early — and know what actually helps you when they do.',
                  style: TextStyle(
                    fontFamily: kSansFamily,
                    fontSize: 14,
                    color: p.textMuted,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _Section(
            title: 'Early warning signs',
            sub: 'The first things I notice when my mood shifts.',
            icon: Icons.wb_sunny_outlined,
            items: _data['earlyWarning']!,
            onAdd: () => _addItem('earlyWarning'),
            onRemove: (i) => _removeItem('earlyWarning', i),
          ),
          _Section(
            title: 'Triggers to watch for',
            sub: 'External things that have set off episodes before.',
            icon: Icons.warning_amber_rounded,
            tone: _SecTone.crisis,
            items: _data['triggers']!,
            onAdd: () => _addItem('triggers'),
            onRemove: (i) => _removeItem('triggers', i),
          ),
          _Section(
            title: 'Things that genuinely help',
            sub: "Specific, concrete. Not 'self-care' — what actually works.",
            icon: Icons.favorite_outline,
            items: _data['helps']!,
            onAdd: () => _addItem('helps'),
            onRemove: (i) => _removeItem('helps', i),
          ),
          _Section(
            title: 'Things to say to me',
            sub: 'Words that ground me. Useful for staff, EMS, family.',
            icon: Icons.chat_bubble_outline,
            items: _data['sayToMe']!,
            onAdd: () => _addItem('sayToMe'),
            onRemove: (i) => _removeItem('sayToMe', i),
          ),
          _Section(
            title: "Don't do these",
            sub: 'Approaches that escalate me. Be specific.',
            icon: Icons.do_not_disturb_outlined,
            tone: _SecTone.crisis,
            items: _data['dontDo']!,
            onAdd: () => _addItem('dontDo'),
            onRemove: (i) => _removeItem('dontDo', i),
          ),
          const SizedBox(height: 14),
          const InfoBanner(
            icon: Icons.auto_awesome,
            variant: InfoBannerVariant.info,
            text:
                "Heads up: this section is yours alone — it isn't required by "
                'PA Act 194, but in practice it\'s the part agents and ER '
                'staff read first.',
          ),
        ],
      )),
      ]),
    );
  }
}

/// Owns a single `TextEditingController` with proper dispose lifecycle.
/// Returns the trimmed entered text via `Navigator.pop`, or `null` on cancel.
class _AddNoteDialog extends StatefulWidget {
  const _AddNoteDialog();

  @override
  State<_AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<_AddNoteDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add'),
      content: TextField(
        controller: _c,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'Type a short note'),
        onSubmitted: (_) => Navigator.pop(context, _c.text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _c.text.trim()),
          child: const Text('Add'),
        ),
      ],
    );
  }
}

enum _SecTone { primary, crisis }

class _Section extends StatelessWidget {
  final String title;
  final String sub;
  final IconData icon;
  final List<String> items;
  final _SecTone tone;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  const _Section({
    required this.title,
    required this.sub,
    required this.icon,
    required this.items,
    required this.onAdd,
    required this.onRemove,
    this.tone = _SecTone.primary,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final chipBg = tone == _SecTone.crisis
        ? (dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight)
        : p.primaryTint;
    final chipFg = tone == _SecTone.crisis
        ? (dark
            ? SemanticColors.errorAccentDark
            : SemanticColors.errorAccentLight)
        : p.onPrimaryLight;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: chipFg),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(title,
                        style: const TextStyle(
                          fontFamily: kSansFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(sub, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (var i = 0; i < items.length; i++)
                    InputChip(
                      label: Text(items[i]),
                      backgroundColor: chipBg,
                      labelStyle: TextStyle(color: chipFg),
                      onDeleted: () => onRemove(i),
                    ),
                  ActionChip(
                    label: const Text('+ Add'),
                    onPressed: onAdd,
                    side: BorderSide(color: cs.outline, style: BorderStyle.solid),
                    backgroundColor: Colors.transparent,
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
