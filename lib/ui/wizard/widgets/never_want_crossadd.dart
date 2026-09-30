import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/data/repository/directive_repository.dart';
import 'package:mhad/domain/model/directive.dart';

/// Opt-in cross-add: a drug allergy is also, very often, a medication the
/// person never wants given to them. Allergies and the "Medications I never
/// want" list are deliberately separate sections (neither auto-fills the
/// other), so this is offered only as an explicit prompt — never automatic —
/// for **drug** allergies. Used by both the AI-autofill apply path and the
/// manual allergies step so the behavior is consistent everywhere.
///
/// Returns the number of medications actually added to the "never want"
/// (exception) list. Shows nothing and returns 0 when there are no eligible
/// drug allergens (e.g. all already on the list).
Future<int> promptAddDrugAllergiesToNeverWant({
  required BuildContext context,
  required DirectiveRepository repo,
  required int directiveId,
  required List<String> drugSubstances,
}) async {
  // Distinct, non-empty substance names.
  final names = <String>[];
  final seen = <String>{};
  for (final raw in drugSubstances) {
    final s = raw.trim();
    if (s.isEmpty) continue;
    if (seen.add(s.toLowerCase())) names.add(s);
  }
  if (names.isEmpty) return 0;

  // Drop any already on the "never want" list so we never offer a duplicate.
  final existing = await repo.watchMedications(directiveId).first;
  final existingAvoid = existing
      .where((m) => m.entryType == MedicationEntryType.exception.name)
      .map((m) => m.medicationName.trim().toLowerCase())
      .toSet();
  final candidates =
      names.where((s) => !existingAvoid.contains(s.toLowerCase())).toList();
  if (candidates.isEmpty) return 0;

  if (!context.mounted) return 0;
  final chosen = await showDialog<List<String>>(
    context: context,
    builder: (ctx) => _NeverWantCrossAddDialog(candidates: candidates),
  );
  if (chosen == null || chosen.isEmpty) return 0;

  var order = existing.length;
  for (final s in chosen) {
    await repo.insertMedication(MedicationEntriesCompanion.insert(
      directiveId: directiveId,
      entryType: MedicationEntryType.exception.name,
      medicationName: Value(s),
      reason: const Value('Listed as a drug allergy'),
      sortOrder: Value(order++),
    ));
  }
  return chosen.length;
}

class _NeverWantCrossAddDialog extends StatefulWidget {
  final List<String> candidates;
  const _NeverWantCrossAddDialog({required this.candidates});

  @override
  State<_NeverWantCrossAddDialog> createState() =>
      _NeverWantCrossAddDialogState();
}

class _NeverWantCrossAddDialogState extends State<_NeverWantCrossAddDialog> {
  // Opt-in, default OFF — nothing is added unless the user confirms.
  late final Map<String, bool> _checked = {
    for (final s in widget.candidates) s: false,
  };

  bool get _single => widget.candidates.length == 1;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.medication_outlined),
      title: Text(context.l10n.neverWantCrossAddTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _single
                ? context.l10n.neverWantCrossAddBodySingle
                : context.l10n.neverWantCrossAddBodyMulti,
          ),
          const SizedBox(height: 8),
          if (_single)
            // A single item: the action button IS the opt-in, so no checkbox.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                widget.candidates.first,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          else
            ...widget.candidates.map(
              (s) => CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _checked[s],
                onChanged: (v) => setState(() => _checked[s] = v ?? false),
                title: Text(s),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, const <String>[]),
          child: Text(context.l10n.neverWantCrossAddNotNow),
        ),
        FilledButton(
          onPressed: () {
            final result = _single
                ? widget.candidates
                : widget.candidates.where((s) => _checked[s] == true).toList();
            Navigator.pop(context, result);
          },
          child: Text(_single
              ? context.l10n.neverWantCrossAddConfirmSingle
              : context.l10n.neverWantCrossAddConfirmMulti),
        ),
      ],
    );
  }
}
