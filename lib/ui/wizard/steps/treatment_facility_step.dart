import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class TreatmentFacilityStep extends ConsumerStatefulWidget {
  const TreatmentFacilityStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<TreatmentFacilityStep> createState() =>
      _TreatmentFacilityStepState();
}

class _TreatmentFacilityStepState
    extends ConsumerState<TreatmentFacilityStep> with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();
  final List<_FacilityRow> _preferred = [];
  final List<_FacilityRow> _avoid = [];
  // Selected room-preference chip ids — see [_RoomChip.all] for the canonical
  // list. Persisted as a comma-separated string in `roomPreferences`.
  final Set<String> _roomPrefs = {};
  // Free-form room-preference note that accompanies the chips. Persisted in
  // `roomPreferencesNote`.
  final TextEditingController _roomNoteCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    for (final row in [..._preferred, ..._avoid]) {
      row.dispose();
    }
    _roomNoteCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final pref = await ref
        .read(directiveRepositoryProvider)
        .getPreferences(widget.directiveId);
    if (pref != null && mounted) {
      setState(() {
        _preferred.addAll(_parseFacilities(pref.preferredFacilityName));
        _avoid.addAll(_parseFacilities(pref.avoidFacilityName));
        _roomPrefs
          ..clear()
          ..addAll(pref.roomPreferences
              .split(',')
              .where((s) => s.trim().isNotEmpty));
        _roomNoteCtrl.text = pref.roomPreferencesNote;
      });
    }
  }

  /// Parse newline-delimited "Name | Location" entries into rows.
  List<_FacilityRow> _parseFacilities(String raw) {
    if (raw.trim().isEmpty) return [];
    return raw.split('\n').where((l) => l.trim().isNotEmpty).map((line) {
      final parts = line.split(' | ');
      return _FacilityRow()
        ..nameCtrl.text = parts.first.trim()
        ..locationCtrl.text =
            (parts.length > 1 ? parts.sublist(1).join(' | ').trim() : '');
    }).toList();
  }

  /// Serialize rows into newline-delimited "Name | Location" string.
  String _serializeFacilities(List<_FacilityRow> rows) {
    return rows
        .where((r) => r.nameCtrl.text.trim().isNotEmpty)
        .map((r) {
      final name = r.nameCtrl.text.trim();
      final loc = r.locationCtrl.text.trim();
      return loc.isEmpty ? name : '$name | $loc';
    }).join('\n');
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate();

    final preferred = _serializeFacilities(_preferred);
    final avoid = _serializeFacilities(_avoid);

    final prefValue = preferred.isNotEmpty
        ? 'prefer'
        : avoid.isNotEmpty
            ? 'avoid'
            : 'noPreference';

    await ref.read(directiveRepositoryProvider).upsertPreferences(
          DirectivePrefsCompanion(
            directiveId: Value(widget.directiveId),
            treatmentFacilityPref: Value(prefValue),
            preferredFacilityName: Value(preferred),
            avoidFacilityName: Value(avoid),
            roomPreferences: Value(_roomPrefs.join(',')),
            roomPreferencesNote: Value(_roomNoteCtrl.text.trim()),
          ),
        );
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const helpText =
        'You may specify treatment facilities you prefer or want to avoid. '
        'These preferences guide your agent and treatment providers but '
        'may not always be possible to honor. Both sections are optional.';

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'treatmentFacility'),
          const SizedBox(height: 8),
          Card(
            color: cs.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18,
                      color: cs.onSecondaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Leave both sections empty if you have no preference. '
                      'Your directive will indicate "No Preference" for '
                      'treatment facilities.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSecondaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _FacilitySection(
            title: 'Preferred Facilities',
            subtitle: 'Facilities where you would prefer to be treated',
            rows: _preferred,
            onAdd: () => setState(() => _preferred.add(_FacilityRow())),
            onRemove: (i) => setState(() {
              _preferred[i].dispose();
              _preferred.removeAt(i);
            }),
          ),
          const SizedBox(height: 24),
          _FacilitySection(
            title: 'Facilities to Avoid',
            subtitle: 'Facilities where you do not want to be treated',
            rows: _avoid,
            onAdd: () => setState(() => _avoid.add(_FacilityRow())),
            onRemove: (i) => setState(() {
              _avoid[i].dispose();
              _avoid.removeAt(i);
            }),
          ),
          const SizedBox(height: 24),
          // Phase 2 — inclusive room-preference chip set per v2 prototype.
          // Stored as a comma-separated id list in `room_preferences`.
          _RoomPreferencesCard(
            selected: _roomPrefs,
            onToggle: (id) => setState(() {
              if (_roomPrefs.contains(id)) {
                _roomPrefs.remove(id);
              } else {
                _roomPrefs.add(id);
              }
            }),
          ),
          const SizedBox(height: 12),
          // Free-form room preferences, in addition to the chips above.
          TextField(
            controller: _roomNoteCtrl,
            minLines: 2,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Other room preferences',
              hintText:
                  'Anything else about your room or surroundings — e.g. '
                  'low lighting, near a window, away from loud areas…',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inclusive room-preference chip set, expanded from the prototype's
/// binary-gender chip to a more inclusive list (per PROTOTYPE_DIFF_DECISIONS
/// item #10 / submission item #10).
class _RoomChip {
  final String id;
  final String label;
  const _RoomChip(this.id, this.label);

  static const all = <_RoomChip>[
    _RoomChip('singleRoom', 'Single room'),
    _RoomChip('windowIfPossible', 'Window if possible'),
    _RoomChip('quietFloor', 'Quiet floor'),
    _RoomChip('sameGenderRoommate', 'Same-gender roommate'),
    _RoomChip('noRoommate', 'No roommate'),
    _RoomChip('transAffirmingStaff', 'Trans-affirming staff'),
    _RoomChip('lowStimulationUnit', 'Low-stimulation unit'),
  ];
}

class _RoomPreferencesCard extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;
  const _RoomPreferencesCard({
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Room preferences',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              'Optional — guides staff if a choice is available.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final chip in _RoomChip.all)
                  FilterChip(
                    label: Text(chip.label),
                    selected: selected.contains(chip.id),
                    onSelected: (_) => onToggle(chip.id),
                    showCheckmark: false,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FacilityRow {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  void dispose() {
    nameCtrl.dispose();
    locationCtrl.dispose();
  }
}

class _FacilitySection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_FacilityRow> rows;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const _FacilitySection({
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Text(subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            ...List.generate(rows.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: rows[i].nameCtrl,
                            decoration: InputDecoration(
                              labelText: 'Facility name',
                              hintText: 'e.g., Community Hospital',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              prefixIcon: Icon(Icons.local_hospital,
                                  size: 18, color: cs.primary),
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: rows[i].locationCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Location (optional)',
                              hintText: 'e.g., 123 Main St, Philadelphia, PA',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            textInputAction: TextInputAction.done,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      color: cs.error,
                      tooltip: 'Remove facility',
                      onPressed: () => onRemove(i),
                    ),
                  ],
                ),
              );
            }),
            Semantics(
              button: true,
              label: 'Add facility to $title',
              child: TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add facility'),
                style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
