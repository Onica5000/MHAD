import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/utils/debouncer.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

class TreatmentFacilityStep extends ConsumerStatefulWidget {
  const TreatmentFacilityStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<TreatmentFacilityStep> createState() =>
      _TreatmentFacilityStepState();
}

class _TreatmentFacilityStepState
    extends ConsumerState<TreatmentFacilityStep>
    with WizardStepMixin, WizardStepLoadGuard {
  final _formKey = GlobalKey<FormState>();
  final List<_FacilityRow> _preferred = [];
  final List<_FacilityRow> _avoid = [];
  // Selected room-preference chip ids — see [_RoomChip.all] for the canonical
  // list. Persisted as a comma-separated string in `roomPreferences`.
  final Set<String> _roomPrefs = {};
  // Free-form room-preference note that accompanies the chips. Persisted in
  // `roomPreferencesNote`.
  final TextEditingController _roomNoteCtrl = TextEditingController();
  // Same-gender-roommate match preference (artboard WebWizCare sub-selector).
  // One of 'women' | 'men' | 'sameAsIdentity' | 'specify' | '' (none). The
  // free text for 'specify' lives in [_roommateSpecifyCtrl]. Persisted in
  // `roommateGenderMatch` as the option id, or 'specify:<text>'.
  String _roommateOption = '';
  final TextEditingController _roommateSpecifyCtrl = TextEditingController();

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
    _roommateSpecifyCtrl.dispose();
    super.dispose();
  }

  static const _roommateOptions = <(String, String)>[
    ('women', 'Women'),
    ('men', 'Men'),
    ('sameAsIdentity', 'Same as my gender identity'),
    ('specify', 'Let me specify'),
  ];

  void _parseRoommateMatch(String raw) {
    final v = raw.trim();
    if (v.isEmpty) {
      _roommateOption = '';
      return;
    }
    if (v.startsWith('specify:')) {
      _roommateOption = 'specify';
      _roommateSpecifyCtrl.text = v.substring('specify:'.length).trim();
      return;
    }
    if (v == 'women' || v == 'men' || v == 'sameAsIdentity') {
      _roommateOption = v;
      return;
    }
    // Legacy / free-text value — treat as a "specify" entry.
    _roommateOption = 'specify';
    _roommateSpecifyCtrl.text = v;
  }

  String _buildRoommateMatch() {
    // Only meaningful when the same-gender chip is selected.
    if (!_roomPrefs.contains('sameGenderRoommate') || _roommateOption.isEmpty) {
      return '';
    }
    if (_roommateOption == 'specify') {
      final t = _roommateSpecifyCtrl.text.trim();
      return t.isEmpty ? '' : 'specify:$t';
    }
    return _roommateOption;
  }

  Future<void> _loadData() async {
    final pref = await ref
        .read(directiveRepositoryProvider)
        .getPreferences(widget.directiveId);
    markLoaded();
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
        _parseRoommateMatch(pref.roommateGenderMatch);
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
    if (!isLoaded) return true; // don't overwrite facilities before load
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
            roommateGenderMatch: Value(_buildRoommateMatch()),
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
          // Same-gender-roommate match sub-selector (artboard WebWizCare) —
          // only shown when the "Same-gender roommate" chip is selected.
          if (_roomPrefs.contains('sameGenderRoommate')) ...[
            const SizedBox(height: 10),
            _RoommateMatchSelector(
              options: _roommateOptions,
              selected: _roommateOption,
              specifyCtrl: _roommateSpecifyCtrl,
              onSelect: (id) => setState(() => _roommateOption = id),
            ),
          ],
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

/// Sub-selector shown under the room chips when "Same-gender roommate" is on
/// (artboard WebWizCare): "For 'same-gender', match me with…" + four choices,
/// with a free-text field when "Let me specify" is picked.
class _RoommateMatchSelector extends StatelessWidget {
  final List<(String, String)> options;
  final String selected;
  final TextEditingController specifyCtrl;
  final ValueChanged<String> onSelect;
  const _RoommateMatchSelector({
    required this.options,
    required this.selected,
    required this.specifyCtrl,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.only(left: 12),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: cs.primary.withValues(alpha: 0.35), width: 2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'For "same-gender roommate", match me with:',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final (id, label) in options)
                ChoiceChip(
                  label: Text(label),
                  selected: selected == id,
                  onSelected: (_) => onSelect(selected == id ? '' : id),
                  showCheckmark: false,
                ),
            ],
          ),
          if (selected == 'specify') ...[
            const SizedBox(height: 10),
            TextField(
              controller: specifyCtrl,
              decoration: const InputDecoration(
                labelText: 'Match me with',
                hintText: 'Describe your roommate-matching preference',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
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

class _FacilitySection extends StatefulWidget {
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
  State<_FacilitySection> createState() => _FacilitySectionState();
}

class _FacilitySectionState extends State<_FacilitySection> {
  // NPI organization (facility) autocomplete. One debouncer for the section;
  // [_activeRow] tracks which row's dropdown is currently open.
  final _debouncer = Debouncer(delay: const Duration(milliseconds: 400));
  int? _activeRow;
  List<FacilityResult> _results = const [];
  bool _searching = false;

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  void _onNameChanged(int i, String query) {
    final q = query.trim();
    if (q.length < 3) {
      _debouncer.cancel();
      setState(() {
        _activeRow = i;
        _results = const [];
      });
      return;
    }
    setState(() => _activeRow = i);
    _debouncer.run(() => _search(q));
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final r = await ClinicalDataService.searchFacilities(query);
      if (mounted) setState(() => _results = r);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _pick(int i, FacilityResult f) {
    setState(() {
      widget.rows[i].nameCtrl.text = f.name;
      if (f.address.isNotEmpty) widget.rows[i].locationCtrl.text = f.address;
      _results = const [];
      _activeRow = null;
    });
  }

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
            Text(widget.title,
                style: Theme.of(context)
                    .textTheme
                    .titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600)),
            Text(widget.subtitle,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 12),
            ...List.generate(widget.rows.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: widget.rows[i].nameCtrl,
                            onChanged: (q) => _onNameChanged(i, q),
                            decoration: InputDecoration(
                              labelText: 'Facility name',
                              hintText: 'Type to search facilities',
                              border: const OutlineInputBorder(),
                              isDense: true,
                              prefixIcon: Icon(Icons.local_hospital,
                                  size: 18, color: cs.primary),
                              suffixIcon: (_searching && _activeRow == i)
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    )
                                  : null,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                          // NPI facility matches — tap to autofill name + address.
                          if (_activeRow == i && _results.isNotEmpty)
                            _facilityDropdown(i, cs),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: widget.rows[i].locationCtrl,
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
                      onPressed: () => widget.onRemove(i),
                    ),
                  ],
                ),
              );
            }),
            Semantics(
              button: true,
              label: 'Add facility to ${widget.title}',
              child: TextButton.icon(
                onPressed: widget.onAdd,
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

  Widget _facilityDropdown(int i, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(6),
          children: [
            for (final f in _results)
              InkWell(
                onTap: () => _pick(i, f),
                borderRadius: BorderRadius.circular(7),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(f.name,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600)),
                      if (f.address.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            f.address,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 11.5, color: cs.onSurfaceVariant),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 2),
              child: Text(
                'Facility names from the NPI registry (NIH Clinical Tables). '
                'Verify details before relying on them.',
                style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
