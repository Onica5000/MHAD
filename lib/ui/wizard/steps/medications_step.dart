import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/services/medline_plus_service.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/medline_plus_dialog.dart';
import 'package:mhad/ui/wizard/widgets/medication_autocomplete_field.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class MedicationsStep extends ConsumerStatefulWidget {
  final int directiveId;
  final FormType formType;
  const MedicationsStep(
      {required this.directiveId, required this.formType, super.key});

  @override
  ConsumerState<MedicationsStep> createState() => _MedicationsStepState();
}

class _MedicationsStepState extends ConsumerState<MedicationsStep>
    with WizardStepMixin {
  final _formKey = GlobalKey<FormState>();

  // Each entry: {name controller, reason controller, existing id or null}
  final List<_MedRow> _current = [];
  final List<_MedRow> _exceptions = [];
  final List<_MedRow> _limitations = [];
  final List<_MedRow> _preferred = [];

  // Only shown for Combined/POA
  bool _agentDecidesMeds = false;

  bool _hasAgentSections = false;

  @override
  void initState() {
    super.initState();
    _hasAgentSections = widget.formType.hasAgentSections;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    for (final row in [
      ..._current,
      ..._exceptions,
      ..._limitations,
      ..._preferred
    ]) {
      row.dispose();
    }
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final meds = await repo.watchMedications(widget.directiveId).first;
    final prefs = await repo.getPreferences(widget.directiveId);

    if (!mounted) return;
    setState(() {
      for (final m in meds) {
        final row = _MedRow(id: m.id)
          ..nameCtrl.text = m.medicationName
          ..reasonCtrl.text = m.reason;
        switch (MedicationEntryType.values
            .firstWhere((e) => e.name == m.entryType,
                orElse: () => MedicationEntryType.exception)) {
          case MedicationEntryType.current:
            _current.add(row);
          case MedicationEntryType.exception:
            _exceptions.add(row);
          case MedicationEntryType.limitation:
            _limitations.add(row);
          case MedicationEntryType.preferred:
            _preferred.add(row);
        }
      }
      if (prefs != null && _hasAgentSections) {
        _agentDecidesMeds = prefs.medicationConsent == consentAgentDecides;
      }
    });
  }

  static const _maxMedsPerCategory = 50;

  void _addMedRow(List<_MedRow> rows) {
    if (rows.length >= _maxMedsPerCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Maximum $_maxMedsPerCategory medications per category'),
        ),
      );
      return;
    }
    setState(() => rows.add(_MedRow()));
  }

  // Plain-language MedlinePlus education for a medication (resolves the name →
  // RxCUI → MedlinePlus topic). Educational only.
  void _showMedInfo(String medName) {
    final name = medName.trim();
    if (name.isEmpty) return;
    showMedlinePlusDialog(
      context,
      title: name,
      future: MedlinePlusService.forMedication(name),
    );
  }

  @override
  Future<bool> validateAndSave() async {
    _formKey.currentState?.validate();
    final repo = ref.read(directiveRepositoryProvider);

    int order = 0;
    final entries = <MedicationEntriesCompanion>[];

    void collectRows(List<_MedRow> rows, MedicationEntryType type) {
      for (final row in rows) {
        if (row.nameCtrl.text.trim().isEmpty) continue;
        entries.add(MedicationEntriesCompanion.insert(
          directiveId: widget.directiveId,
          entryType: type.name,
          medicationName: Value(row.nameCtrl.text.trim()),
          reason: Value(row.reasonCtrl.text.trim()),
          sortOrder: Value(order++),
        ));
      }
    }

    collectRows(_current, MedicationEntryType.current);
    collectRows(_exceptions, MedicationEntryType.exception);
    collectRows(_limitations, MedicationEntryType.limitation);
    collectRows(_preferred, MedicationEntryType.preferred);

    await repo.replaceMedications(widget.directiveId, entries);

    // Save medication consent option (idempotent upsert, no transaction needed)
    if (_hasAgentSections) {
      await repo.upsertPreferences(DirectivePrefsCompanion(
        directiveId: Value(widget.directiveId),
        medicationConsent:
            Value(_agentDecidesMeds ? consentAgentDecides : consentYes),
      ));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Semantic accent colors for the medication sections (light/dark aware):
    // red = never give, yellow = limitations, green = preferred.
    final dark = Theme.of(context).brightness == Brightness.dark;
    final neverColor =
        dark ? SemanticColors.errorAccentDark : SemanticColors.errorAccentLight;
    // A clearly golden-yellow — the SemanticColors warning text (0xFFB45309) is
    // a burnt orange that reads as red next to the "never give" red box.
    final limitColor =
        dark ? const Color(0xFFFBBF24) : const Color(0xFFCA8A04);
    final preferColor =
        dark ? SemanticColors.successTextDark : SemanticColors.successTextLight;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(
            // The meaning of each category (Never give / Limitations /
            // Preferred) is shown inline as each section's subtitle below, so
            // help only carries the detail that isn't already on screen.
            helpText:
                'List medications by name. Your preferences apply to generic, '
                'brand name, and trade name equivalents unless you specify '
                'otherwise in the notes — to request brand-name only, note it '
                'in the reason field.\n\n'
                'Narrow Therapeutic Index (NTI) drugs — ones with only a small '
                'safety margin between a helpful dose and a harmful one, like '
                'lithium, carbamazepine, and valproic acid — cannot have '
                'generics substituted under PA law (35 P.S. §960.3). These are '
                'marked with an "NTI" badge when you search.',
            stepId: 'medications',
          ),
          const SizedBox(height: 8),
          // FACTUAL_ANALYSIS C5 / F16 \u2014 PA Act 194 \u00a7 5823(B)(2) / \u00a7 5808:
          // dose instructions are not binding on the physician. Surface this
          // honestly so users understand the limits of dose-level preferences.
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.45,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(
                            text: 'Heads up \u2014 ',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(
                            text:
                                'your refusal of a medication and any limits you set on its use are binding under PA Act 194, but ',
                          ),
                          TextSpan(
                            text: 'specific dosage instructions are not binding',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          const TextSpan(
                            text:
                                ' on the physician \u2014 they choose the dose. (20 Pa.C.S. \u00a7 5808.)',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (_hasAgentSections) ...[
            CheckboxListTile(
              value: _agentDecidesMeds,
              onChanged: (v) =>
                  setState(() => _agentDecidesMeds = v ?? false),
              title: const Text(
                  'I have designated an agent to make decisions about my medications'),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
          ],
          _MedTable(
            title: 'Medications I am currently taking',
            subtitle: 'For your care team’s reference — not a preference',
            rows: _current,
            accentColor: Theme.of(context).colorScheme.secondary,
            onAdd: () => _addMedRow(_current),
            onInfo: _showMedInfo,
            onRemove: (i) => setState(() {
              _current[i].dispose();
              _current.removeAt(i);
            }),
          ),
          const SizedBox(height: 16),
          _MedTable(
            title: 'Medications I NEVER want',
            subtitle: 'These medications should not be administered',
            rows: _exceptions,
            accentColor: neverColor,
            onAdd: () => _addMedRow(_exceptions),
            onInfo: _showMedInfo,
            onRemove: (i) => setState(() {
              _exceptions[i].dispose();
              _exceptions.removeAt(i);
            }),
          ),
          const SizedBox(height: 16),
          _MedTable(
            title: 'Medications with limitations',
            subtitle: 'May be given but with restrictions',
            rows: _limitations,
            accentColor: limitColor,
            onAdd: () => _addMedRow(_limitations),
            onInfo: _showMedInfo,
            onRemove: (i) => setState(() {
              _limitations[i].dispose();
              _limitations.removeAt(i);
            }),
          ),
          const SizedBox(height: 16),
          _MedTable(
            title: 'Preferred medications',
            subtitle: 'Medications that have worked well for you',
            rows: _preferred,
            accentColor: preferColor,
            onAdd: () => _addMedRow(_preferred),
            onInfo: _showMedInfo,
            onRemove: (i) => setState(() {
              _preferred[i].dispose();
              _preferred.removeAt(i);
            }),
          ),
          const SizedBox(height: 16),
          // Side-effects checklist — about the medications you take now, so it
          // lives here (moved from "Anything else" 2026-06-19). The destination
          // screen owns the full explanation.
          _sideEffectsCard(),
        ],
      ),
    );
  }

  /// Tappable card linking to the side-effects checklist. Mirrors the add-on
  /// card style used elsewhere in the wizard for visual consistency.
  Widget _sideEffectsCard() {
    final p = Theme.of(context).mhadPalette;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () =>
            context.push(AppRoutes.sideEffectsRoute(widget.directiveId)),
        borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: p.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.healing_outlined, color: p.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Side effects you may be experiencing',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'For the medications you take now, check common side '
                      'effects — especially any that affect your daily '
                      'activities — so your care team knows. Needs AI set up. '
                      'Not medical advice.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12,
                        height: 1.4,
                        color: p.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: p.textMuted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _MedRow {
  final int? id;
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController reasonCtrl = TextEditingController();
  _MedRow({this.id});
  void dispose() {
    nameCtrl.dispose();
    reasonCtrl.dispose();
  }
}

class _MedTable extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_MedRow> rows;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(String medName)? onInfo;
  final Color? accentColor;

  const _MedTable({
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.onAdd,
    required this.onRemove,
    this.onInfo,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerLow,
      shape: accentColor != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: accentColor!, width: 2),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700, color: accentColor)),
            Text(subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            ...List.generate(rows.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          MedicationAutocompleteField(
                            controller: rows[i].nameCtrl,
                          ),
                          // NTI monitoring note — shows only when the entered
                          // medication is a narrow-therapeutic-index drug.
                          // Rebuilds as the name changes; informational only.
                          ListenableBuilder(
                            listenable: rows[i].nameCtrl,
                            builder: (context, _) {
                              final note = NtiDrugReference.ntiNote(
                                  rows[i].nameCtrl.text);
                              if (note == null) return const SizedBox.shrink();
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.info_outline,
                                        size: 14, color: cs.tertiary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Narrow therapeutic index drug — $note. '
                                        'Pennsylvania law bars generic '
                                        'substitution for these; note any '
                                        'monitoring needs below. (Informational, '
                                        'not medical advice.)',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: cs.onSurfaceVariant),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: rows[i].reasonCtrl,
                            maxLength: appData.config.medicationNoteMaxChars,
                            decoration: const InputDecoration(
                              labelText: 'Reason / notes (optional)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onInfo != null)
                      ListenableBuilder(
                        listenable: rows[i].nameCtrl,
                        builder: (context, _) {
                          final name = rows[i].nameCtrl.text.trim();
                          if (name.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: const Icon(Icons.info_outline),
                            color: cs.primary,
                            tooltip: 'Learn about $name',
                            onPressed: () => onInfo!(name),
                          );
                        },
                      ),
                    IconButton(
                      icon:
                          const Icon(Icons.remove_circle_outline),
                      color: cs.error,
                      tooltip: 'Remove ${rows[i].nameCtrl.text.isEmpty ? 'medication' : rows[i].nameCtrl.text}',
                      onPressed: () => onRemove(i),
                    ),
                  ],
                ),
              );
            }),
            Semantics(
              button: true,
              label: 'Add medication to $title list',
              child: TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add medication'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

