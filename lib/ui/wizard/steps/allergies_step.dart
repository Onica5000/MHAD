import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

/// Wizard step 8 — Allergies & reactions (Phase 3).
///
/// Per PROTOTYPE_DIFF_DECISIONS Decision 5 (user-overridden order), this step
/// comes AFTER Medications (step 7). When a user adds a Severe allergy, a
/// banner suggests they go back to step 7 and add it to the Avoid list — the
/// backward-nudge model that replaces the prototype's forward auto-link.
///
/// Visual structure mirrors the v2 prototype's `ScrAllergies`:
/// - kind selector (drug / food / material / other) — drives which clinical
///   source the future autocomplete will hit
/// - substance + free-text reactions + severity (Mild / Moderate / Severe)
/// - per-row chips list showing existing allergies
/// - Severe warn-banner that nudges back to step 7 (Medications · Avoid)
///
/// The NLM Clinical Tables autocomplete (`clinical_data_service.dart`) is
/// already wired for diagnoses and medications and can be reused here in a
/// follow-up polish pass.
class AllergiesStep extends ConsumerStatefulWidget {
  const AllergiesStep({
    required this.directiveId,
    this.embedded = false,
    super.key,
  });

  final int directiveId;
  final bool embedded;

  @override
  ConsumerState<AllergiesStep> createState() => _AllergiesStepState();
}

class _AllergiesStepState extends ConsumerState<AllergiesStep>
    with WizardStepMixin {
  final _substanceCtrl = TextEditingController();
  final _reactionsCtrl = TextEditingController();
  String _kind = 'drug';
  AllergySeverity _severity = AllergySeverity.moderate;

  List<DirectiveAllergy> _entries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _substanceCtrl.dispose();
    _reactionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final list = await ref
        .read(directiveRepositoryProvider)
        .getAllergies(widget.directiveId);
    if (mounted) setState(() => _entries = list);
  }

  Future<void> _addAllergy() async {
    final name = _substanceCtrl.text.trim();
    if (name.isEmpty) return;
    await ref.read(directiveRepositoryProvider).addAllergy(
          DirectiveAllergiesCompanion.insert(
            directiveId: widget.directiveId,
            kind: Value(_kind),
            substance: Value(name),
            severity: Value(_severity.name),
            reactions: Value(_reactionsCtrl.text.trim()),
            sortOrder: Value(_entries.length),
          ),
        );
    _substanceCtrl.clear();
    _reactionsCtrl.clear();
    setState(() {
      _severity = AllergySeverity.moderate;
    });
    await _loadData();
    if (_severity == AllergySeverity.severe) {
      _showSevereNudge(name);
    }
  }

  Future<void> _removeAllergy(int id) async {
    await ref.read(directiveRepositoryProvider).removeAllergy(id);
    await _loadData();
  }

  /// Backward nudge: a Severe allergy almost certainly belongs on the
  /// Medications-Avoid list (step 7). Surface a snackbar with a quick-link
  /// rather than auto-mutating step 7.
  void _showSevereNudge(String substance) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: cs.errorContainer,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 6),
        content: Text(
          'You marked $substance as Severe. Want to add it to "Never give" in '
          'step 7 (Medications)?',
          style: TextStyle(color: cs.onErrorContainer),
        ),
        action: SnackBarAction(
          label: 'Go to step 7',
          textColor: cs.onErrorContainer,
          onPressed: () {
            // Bubble up through the wizard's prior-step affordance; the
            // wizard screen handles the actual navigation via the Back button.
            Navigator.of(context).maybePop();
          },
        ),
      ),
    );
  }

  @override
  Future<bool> validateAndSave() async => true; // Saved on each add/remove

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: widget.embedded,
      physics: widget.embedded ? const NeverScrollableScrollPhysics() : null,
      padding: widget.embedded
          ? const EdgeInsets.symmetric(horizontal: 4)
          : const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const WizardHelpButton(
          helpText:
              'List drug allergies, sensitivities, and past adverse reactions. '
              'ER staff check this section first. Severity = Mild / Moderate / '
              'Severe. Mark a substance as Severe and we will nudge you back '
              'to step 7 to add it to "Never give".',
          stepId: 'allergies',
        ),
        const SizedBox(height: 8),
        // Kind selector — drives autocomplete source in a follow-up polish.
        Row(
          children: [
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'drug', label: Text('Drug')),
                  ButtonSegment(value: 'food', label: Text('Food')),
                  ButtonSegment(value: 'material', label: Text('Material')),
                  ButtonSegment(value: 'other', label: Text('Other')),
                ],
                selected: {_kind},
                onSelectionChanged: (s) => setState(() => _kind = s.first),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _substanceCtrl,
          decoration: const InputDecoration(
            labelText: 'Substance',
            hintText: 'e.g. Penicillin, Latex, Shellfish',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _reactionsCtrl,
          decoration: const InputDecoration(
            labelText: 'Reactions (comma-separated)',
            hintText: 'e.g. Hives, Swelling, Throat closing',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Text('How serious is it?',
            style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        SegmentedButton<AllergySeverity>(
          segments: const [
            ButtonSegment(
                value: AllergySeverity.mild, label: Text('Mild')),
            ButtonSegment(
                value: AllergySeverity.moderate, label: Text('Moderate')),
            ButtonSegment(
                value: AllergySeverity.severe, label: Text('Severe')),
          ],
          selected: {_severity},
          onSelectionChanged: (s) => setState(() => _severity = s.first),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _addAllergy,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add allergy'),
          ),
        ),
        if (_entries.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text(
            '${_entries.length} ${_entries.length == 1 ? 'allergy' : 'allergies'} on file',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          for (final a in _entries) _AllergyRow(
            entry: a,
            onRemove: () => _removeAllergy(a.id),
          ),
        ],
      ],
    );
  }
}

class _AllergyRow extends StatelessWidget {
  final DirectiveAllergy entry;
  final VoidCallback onRemove;
  const _AllergyRow({required this.entry, required this.onRemove});

  Color _severityColor(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    return switch (entry.severity) {
      'severe' =>
        dark ? SemanticColors.errorAccentDark : SemanticColors.errorAccentLight,
      'moderate' =>
        dark ? SemanticColors.warningTextDark : SemanticColors.warningTextLight,
      _ => cs.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final color = _severityColor(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                entry.severity.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.substance,
                      style: const TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )),
                  if (entry.reactions.isNotEmpty)
                    Text(entry.reactions,
                        style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              tooltip: 'Remove ${entry.substance}',
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}
