import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' show Value;
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/utils/debouncer.dart';
import 'package:mhad/ui/widgets/design/info_banner.dart';
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

  static List<(String, String)> _roommateOptions(AppLocalizations l10n) =>
      <(String, String)>[
        ('women', l10n.facilityRoommateWomen),
        ('men', l10n.facilityRoommateMen),
        ('sameAsIdentity', l10n.facilityRoommateSameAsIdentity),
        ('specify', l10n.facilityRoommateSpecify),
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
    final l10n = context.l10n;
    final helpText = l10n.facilityHelpText;

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(helpText: helpText, stepId: 'treatmentFacility'),
          const SizedBox(height: 8),
          InfoBanner(
            icon: Icons.info_outline,
            margin: EdgeInsets.zero,
            text: l10n.facilityNoPreferenceBanner,
          ),
          const SizedBox(height: 16),
          _FacilitySection(
            title: l10n.facilityPreferredTitle,
            subtitle: l10n.facilityPreferredSubtitle,
            rows: _preferred,
            onAdd: () => setState(() => _preferred.add(_FacilityRow())),
            onRemove: (i) => setState(() {
              _preferred[i].dispose();
              _preferred.removeAt(i);
            }),
          ),
          const SizedBox(height: 24),
          _FacilitySection(
            title: l10n.facilityAvoidTitle,
            subtitle: l10n.facilityAvoidSubtitle,
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
              options: _roommateOptions(l10n),
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
            decoration: InputDecoration(
              labelText: l10n.facilityOtherRoomPrefsLabel,
              hintText: l10n.facilityOtherRoomPrefsHint,
              alignLabelWithHint: true,
              border: const OutlineInputBorder(),
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

  static List<_RoomChip> all(AppLocalizations l10n) => <_RoomChip>[
        _RoomChip('singleRoom', l10n.facilityRoomSingle),
        _RoomChip('windowIfPossible', l10n.facilityRoomWindow),
        _RoomChip('quietFloor', l10n.facilityRoomQuietFloor),
        _RoomChip('sameGenderRoommate', l10n.facilityRoomSameGender),
        _RoomChip('noRoommate', l10n.facilityRoomNoRoommate),
        _RoomChip('transAffirmingStaff', l10n.facilityRoomTransAffirming),
        _RoomChip('lowStimulationUnit', l10n.facilityRoomLowStimulation),
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
              context.l10n.facilityRoomPrefsTitle,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              context.l10n.facilityRoomPrefsSubtitle,
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
                for (final chip in _RoomChip.all(context.l10n))
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
            context.l10n.facilityRoommateMatchPrompt,
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
              decoration: InputDecoration(
                labelText: context.l10n.facilityMatchMeWithLabel,
                hintText: context.l10n.facilityMatchMeWithHint,
                isDense: true,
                border: const OutlineInputBorder(),
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
                              labelText: context.l10n.facilityNameLabel,
                              hintText: context.l10n.facilityNameHint,
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
                            decoration: InputDecoration(
                              labelText: context.l10n.facilityLocationLabel,
                              hintText: context.l10n.facilityLocationHint,
                              border: const OutlineInputBorder(),
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
                      tooltip: context.l10n.facilityRemoveTooltip,
                      onPressed: () => widget.onRemove(i),
                    ),
                  ],
                ),
              );
            }),
            Semantics(
              button: true,
              label: context.l10n.facilityAddToSemantics(widget.title),
              child: TextButton.icon(
                onPressed: widget.onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: Text(context.l10n.facilityAddButton),
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
                context.l10n.facilityNpiAttribution,
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
