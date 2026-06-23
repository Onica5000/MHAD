import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/utils/debouncer.dart';
import 'package:mhad/ui/widgets/design/health_chip.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/nlm_attribution.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';


/// The kind of allergen, and the clinical source its autocomplete hits.
///
/// Drug allergies search RxTerms; food / material / other search ICD-10-CM
/// (the only condition source `ClinicalDataService` exposes).
enum _AllergyKind { drug, food, material, other }

extension _AllergyKindX on _AllergyKind {
  String get id => name;
  String get label => switch (this) {
        _AllergyKind.drug => 'Drug',
        _AllergyKind.food => 'Food',
        _AllergyKind.material => 'Material',
        _AllergyKind.other => 'Other',
      };

  /// Data-source label rendered in mono under the kind label and used as the
  /// chip's `sourceTag`.
  String get source =>
      this == _AllergyKind.drug ? 'RxTerms' : 'ICD-10';
}

/// One autocomplete suggestion, normalised across RxTerms / ICD-10.
class _Suggestion {
  final String code;
  final String label;
  const _Suggestion({required this.code, required this.label});
}

/// Wizard step 8 — Allergies & reactions (Phase 3).
///
/// Per PROTOTYPE_DIFF_DECISIONS Decision 5 (user-overridden order), this step
/// comes AFTER Medications (step 7). When a user adds a Severe allergy, a
/// banner suggests they go back to step 7 and add it to the Avoid list — the
/// backward-nudge model that replaces the prototype's forward auto-link.
///
/// Visual structure mirrors the v2 prototype's `ScrAllergies`:
/// - a pill kind toggle (Drug / Food / Material / Other) that drives which
///   clinical source the autocomplete hits (each shows its source in mono)
/// - a search-field card with NLM clinical-tables autocomplete
/// - a severity selector (Mild / Moderate / Severe) + free-text reactions
/// - an "Added" list of [HealthChip] rows toned by severity
/// - a Severe warn-banner that nudges back to step 7 (Medications · Avoid)
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
  _AllergyKind _kind = _AllergyKind.drug;
  AllergySeverity _severity = AllergySeverity.moderate;

  // Autocomplete state (mirrors the diagnoses step's debounce model).
  final _debouncer = Debouncer();
  List<_Suggestion> _suggestions = [];
  bool _searching = false;
  String _query = '';

  List<DirectiveAllergy> _entries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _substanceCtrl.dispose();
    _reactionsCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final list = await repo.getAllergies(widget.directiveId);
    if (mounted) {
      setState(() => _entries = list);
    }
  }

  // ── Autocomplete ───────────────────────────────────────────────────────

  void _onSearchChanged(String query) {
    _query = query.trim();
    if (_query.length < 2) {
      _debouncer.cancel();
      setState(() => _suggestions = []);
      return;
    }
    _debouncer.run(_runSearch);
  }

  Future<void> _runSearch() async {
    final q = _query;
    if (q.length < 2) return;
    setState(() => _searching = true);
    try {
      final List<_Suggestion> results;
      if (_kind == _AllergyKind.drug) {
        // Drug allergens → RxTerms.
        final meds = await ClinicalDataService.searchMedications(q);
        results = meds
            .map((name) => _Suggestion(code: 'RX', label: name))
            .toList();
      } else {
        // Food / material / other → ICD-10 condition search (no dedicated
        // backend for these kinds; fall back to ICD-10 per the design note).
        final conds = await ClinicalDataService.searchConditions(q);
        results = conds
            .map((c) => _Suggestion(code: c.code, label: c.name))
            .toList();
      }
      if (mounted && q == _query) setState(() => _suggestions = results);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  /// Picking a match fills the substance field so the user can set severity /
  /// reactions before committing via [_addAllergy].
  void _pickSuggestion(_Suggestion s) {
    _substanceCtrl.text = s.label;
    _query = '';
    setState(() => _suggestions = []);
    FocusScope.of(context).unfocus();
  }

  // ── Persistence (unchanged data path) ────────────────────────────────────

  Future<void> _addAllergy() async {
    final name = _substanceCtrl.text.trim();
    if (name.isEmpty) return;
    await ref.read(directiveRepositoryProvider).addAllergy(
          DirectiveAllergiesCompanion.insert(
            directiveId: widget.directiveId,
            kind: Value(_kind.id),
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
      _suggestions = [];
    });
    await _loadData();
  }

  Future<void> _removeAllergy(int id) async {
    await ref.read(directiveRepositoryProvider).removeAllergy(id);
    await _loadData();
  }

  @override
  Future<bool> validateAndSave() async => true; // Saved on each add/remove

  // ── Tone mapping ─────────────────────────────────────────────────────────

  HealthChipTone _toneFor(String severity) => switch (severity) {
        'severe' => HealthChipTone.crisis,
        'moderate' => HealthChipTone.warn,
        _ => HealthChipTone.primary,
      };

  String _codeFor(String severity) => switch (severity) {
        'severe' => 'SEVERE',
        'moderate' => 'MOD',
        _ => 'MILD',
      };

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;

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
              'Severe. Allergies and the "Medications I never want" list are '
              'separate sections — add a medication you refuse there yourself.',
          stepId: 'allergies',
        ),
        const SizedBox(height: 8),

        // ── Add an allergy ────────────────────────────────────────────────
        const SectionLabel('Add an allergy'),

        // Kind toggle — switches the autocomplete data source.
        _KindToggle(
          selected: _kind,
          onChanged: (k) {
            setState(() {
              _kind = k;
              _suggestions = [];
            });
            if (_query.length >= 2) _onSearchChanged(_query);
          },
        ),
        const SizedBox(height: 10),

        // Search field + autocomplete.
        _SearchField(
          controller: _substanceCtrl,
          hint: _kind == _AllergyKind.drug
              ? 'Search a drug or class…'
              : 'Search ${_kind.label.toLowerCase()} allergens…',
          badge: _kind.source,
          searching: _searching,
          onChanged: _onSearchChanged,
          onClear: () {
            _substanceCtrl.clear();
            _query = '';
            setState(() => _suggestions = []);
          },
        ),
        if (_suggestions.isNotEmpty) ...[
          const SizedBox(height: 6),
          _AutoComplete(
            source: _kind == _AllergyKind.drug
                ? 'RxTerms · NLM clinical tables'
                : 'ICD-10-CM · NLM clinical tables',
            query: _query,
            items: _suggestions,
            onPick: _pickSuggestion,
          ),
        ],
        if (_suggestions.isEmpty && _query.length >= 2)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              _searching ? '' : 'No results found.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: kSansFamily,
                color: p.textMuted,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 2, 0),
          child: Text(
            'Drug allergies search RxTerms. Food, material & other allergies '
            'search ICD-10 (e.g. Z91.01 food allergy, T78.4 unspecified '
            'allergy).',
            style: TextStyle(
              fontFamily: kSansFamily,
              fontSize: 10.5,
              fontStyle: FontStyle.italic,
              height: 1.4,
              color: p.textMuted,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ── Severity & reaction ───────────────────────────────────────────
        const SectionLabel('Severity & reaction'),
        Container(
          decoration: BoxDecoration(
            color: p.card,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MonoLabel('How serious is it?'),
              const SizedBox(height: 8),
              _SeveritySelector(
                selected: _severity,
                onChanged: (s) => setState(() => _severity = s),
              ),
              const SizedBox(height: 12),
              _MonoLabel('What happens'),
              const SizedBox(height: 6),
              TextField(
                controller: _reactionsCtrl,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'e.g. Hives, Swelling, Throat closing',
                  hintStyle: TextStyle(color: p.textMuted, fontSize: 13),
                  border: const OutlineInputBorder(),
                ),
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
            ],
          ),
        ),

        // ── Added list ─────────────────────────────────────────────────────
        if (_entries.isNotEmpty) ...[
          SectionLabel(
            'Added · ${_entries.length} '
            '${_entries.length == 1 ? 'allergy' : 'allergies'}',
          ),
          for (final a in _entries) ...[
            HealthChip(
              code: _codeFor(a.severity),
              label: a.substance,
              sub: a.reactions.isNotEmpty ? a.reactions : null,
              sourceTag: a.kind == _AllergyKind.drug.id ? 'RxTerms' : 'ICD-10',
              tone: _toneFor(a.severity),
              onRemove: () => _removeAllergy(a.id),
            ),
            const SizedBox(height: 8),
          ],
        ],

        const SizedBox(height: 4),
        // Footer reassurance, matching the prototype's tone.
        Text(
          "You're not required to list anything. Anything you do list is shared "
          'only with the people your directive names.',
          style: TextStyle(
            fontFamily: kSansFamily,
            fontSize: 11,
            fontStyle: FontStyle.italic,
            height: 1.45,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        const NlmAttribution(),
      ],
    );
  }
}

/// Uppercased monospace micro-label used inside the severity card.
class _MonoLabel extends StatelessWidget {
  final String text;
  const _MonoLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        fontFamily: kMonoFamily,
        fontFamilyFallback: kMonoFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: p.textMuted,
      ),
    );
  }
}

/// Segmented pill toggle for the allergen kind. Active segment is a raised
/// `p.card` chip; each segment shows its data source in small mono.
class _KindToggle extends StatelessWidget {
  final _AllergyKind selected;
  final ValueChanged<_AllergyKind> onChanged;
  const _KindToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          for (final k in _AllergyKind.values)
            Expanded(
              child: _KindSegment(
                kind: k,
                active: k == selected,
                onTap: () => onChanged(k),
              ),
            ),
        ],
      ),
    );
  }
}

class _KindSegment extends StatelessWidget {
  final _AllergyKind kind;
  final bool active;
  final VoidCallback onTap;
  const _KindSegment({
    required this.kind,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Semantics(
      button: true,
      selected: active,
      label: '${kind.label} (${kind.source})',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? p.card : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: active
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 3,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                kind.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: active ? p.text : p.textMuted,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                kind.source,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: kMonoFallbacks,
                  fontSize: 8,
                  letterSpacing: 0.4,
                  color: active ? p.primary : p.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Editorial search field card mirroring the prototype's `SearchField`: a
/// rounded card with a leading search glyph, the text field, and an
/// RxTerms / ICD-10 source badge (or spinner while searching).
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String badge;
  final bool searching;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  const _SearchField({
    required this.controller,
    required this.hint,
    required this.badge,
    required this.searching,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 18, color: p.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: onChanged,
              style: TextStyle(
                fontFamily: kSansFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: p.text,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 11),
                hintText: hint,
                hintStyle: TextStyle(
                  color: p.textMuted,
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (searching)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else if (controller.text.isNotEmpty)
            Semantics(
              button: true,
              label: 'Clear search',
              child: InkWell(
                onTap: onClear,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, size: 16, color: p.textMuted),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: p.primaryTint,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome, size: 9, color: p.primary),
                  const SizedBox(width: 4),
                  Text(
                    badge,
                    style: TextStyle(
                      fontFamily: kMonoFamily,
                      fontFamilyFallback: kMonoFallbacks,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: p.primary,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Dropdown of autocomplete matches, mirroring the prototype's `AutoComplete`:
/// a sourced header plus tappable rows with a mono code badge and the match
/// label (the active query span emphasised).
class _AutoComplete extends StatelessWidget {
  final String source;
  final String query;
  final List<_Suggestion> items;
  final ValueChanged<_Suggestion> onPick;
  const _AutoComplete({
    required this.source,
    required this.query,
    required this.items,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Container(
      decoration: p.dropdownDecoration,
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sourced header.
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 6),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, size: 11, color: p.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    source.toUpperCase(),
                    style: TextStyle(
                      fontFamily: kMonoFamily,
                      fontFamilyFallback: kMonoFallbacks,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: p.primary,
                    ),
                  ),
                ),
                Text(
                  '${items.length} matches',
                  style: TextStyle(
                    fontFamily: kMonoFamily,
                    fontFamilyFallback: kMonoFallbacks,
                    fontSize: 9.5,
                    letterSpacing: 0.4,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: p.border),
          const SizedBox(height: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: items.length,
              itemBuilder: (context, i) => _AutoCompleteRow(
                item: items[i],
                query: query,
                first: i == 0,
                onTap: () => onPick(items[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AutoCompleteRow extends StatelessWidget {
  final _Suggestion item;
  final String query;
  final bool first;
  final VoidCallback onTap;
  const _AutoCompleteRow({
    required this.item,
    required this.query,
    required this.first,
    required this.onTap,
  });

  /// Splits [label] so the [query] substring is emphasised, like the prototype.
  List<TextSpan> _spans(BuildContext context, Color base, Color hit) {
    if (query.isEmpty) {
      return [TextSpan(text: item.label, style: TextStyle(color: base))];
    }
    final lower = item.label.toLowerCase();
    final q = query.toLowerCase();
    final spans = <TextSpan>[];
    var start = 0;
    while (true) {
      final idx = lower.indexOf(q, start);
      if (idx < 0) {
        spans.add(TextSpan(
            text: item.label.substring(start),
            style: TextStyle(color: base)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(
            text: item.label.substring(start, idx),
            style: TextStyle(color: base)));
      }
      spans.add(TextSpan(
        text: item.label.substring(idx, idx + q.length),
        style: TextStyle(color: hit, fontWeight: FontWeight.w800),
      ));
      start = idx + q.length;
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: first ? p.primaryTint : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 1),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: p.card,
                border: Border.all(color: p.primaryLight),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                item.code,
                style: TextStyle(
                  fontFamily: kMonoFamily,
                  fontFamilyFallback: kMonoFallbacks,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                  color: p.primary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      children: _spans(context, p.text, p.primary),
                    ),
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

/// Three-up severity selector. Each option is toned by its severity
/// (Severe→crisis, Moderate→warn, Mild→primary), filled when active.
class _SeveritySelector extends StatelessWidget {
  final AllergySeverity selected;
  final ValueChanged<AllergySeverity> onChanged;
  const _SeveritySelector({required this.selected, required this.onChanged});

  static const _options = <(AllergySeverity, String, String)>[
    (AllergySeverity.mild, 'Mild', 'rash, mild GI'),
    (AllergySeverity.moderate, 'Moderate', 'hives, swelling'),
    (AllergySeverity.severe, 'Severe', 'anaphylaxis · ER'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _options.length; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: _SeverityOption(
              severity: _options[i].$1,
              label: _options[i].$2,
              desc: _options[i].$3,
              active: _options[i].$1 == selected,
              onTap: () => onChanged(_options[i].$1),
            ),
          ),
        ],
      ],
    );
  }
}

class _SeverityOption extends StatelessWidget {
  final AllergySeverity severity;
  final String label;
  final String desc;
  final bool active;
  final VoidCallback onTap;
  const _SeverityOption({
    required this.severity,
    required this.label,
    required this.desc,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Tone family per severity.
    late final Color bg;
    late final Color fg;
    late final Color border;
    late final Color activeBg;
    late final Color activeFg;
    switch (severity) {
      case AllergySeverity.mild:
        bg = p.primaryTint;
        fg = p.text;
        border = p.primaryLight;
        activeBg = p.primary;
        activeFg = p.onPrimary;
      case AllergySeverity.moderate:
        bg = dark
            ? SemanticColors.warningBgDark
            : SemanticColors.warningBgLight;
        fg = dark
            ? SemanticColors.warningTextDark
            : SemanticColors.warningTextLight;
        border = dark
            ? SemanticColors.warningBorderDark
            : SemanticColors.warningBorderLight;
        activeBg = dark
            ? SemanticColors.warningTextDark
            : SemanticColors.warningTextLight;
        activeFg = dark ? const Color(0xFF2A2102) : Colors.white;
      case AllergySeverity.severe:
        bg = dark ? SemanticColors.errorBgDark : SemanticColors.errorBgLight;
        fg = dark
            ? SemanticColors.errorTextDark
            : SemanticColors.errorTextLight;
        border = dark
            ? SemanticColors.errorBorderDark
            : SemanticColors.errorBorderLight;
        activeBg = dark
            ? SemanticColors.errorAccentDark
            : SemanticColors.errorAccentLight;
        activeFg = Colors.white;
    }

    return Semantics(
      button: true,
      selected: active,
      label: '$label severity',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: active ? activeBg : bg,
            border: Border.all(
              color: active ? activeBg : border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                  color: active ? activeFg : fg,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: kSansFamily,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                  color: (active ? activeFg : fg).withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
