import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/services/medline_plus_service.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/fda_label_dialog.dart';
import 'package:mhad/ui/widgets/medline_plus_dialog.dart';
import 'package:mhad/ui/wizard/widgets/medication_autocomplete_field.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_mixins.dart';

class MedicationsStep extends ConsumerStatefulWidget {
  final int directiveId;
  final FormType formType;
  const MedicationsStep(
      {required this.directiveId, required this.formType, super.key});

  @override
  ConsumerState<MedicationsStep> createState() => _MedicationsStepState();
}

class _MedicationsStepState extends ConsumerState<MedicationsStep>
    with WizardStepMixin, WizardStepLoadGuard {
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
    markLoaded();

    if (!mounted) return;
    setState(() {
      for (final m in meds) {
        final row = _MedRow(id: m.id)
          ..nameCtrl.text = m.medicationName
          ..reasonCtrl.text = m.reason
          ..dosageCtrl.text = m.dosage;
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
          content: Text(
              context.l10n.medsStepMaxPerCategory(_maxMedsPerCategory)),
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

  // Official FDA label text (side effects + interactions) for a medication.
  // Reference only, and AI-free — works without a Gemini key.
  void _showFdaInfo(String medName) {
    final name = medName.trim();
    if (name.isEmpty) return;
    showFdaLabelDialog(context, medName: name);
  }

  @override
  Future<bool> validateAndSave() async {
    if (!isLoaded) return true; // don't wipe meds before the load populates them
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
          // Dosage is captured only in the "currently taking" section; the
          // other sections never show the field, so it stays empty there.
          dosage: Value(row.dosageCtrl.text.trim()),
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
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          WizardHelpButton(
            // The meaning of each category (Never give / Limitations /
            // Preferred) is shown inline as each section's subtitle below, so
            // help only carries the detail that isn't already on screen.
            helpText: l10n.medsStepHelpText,
            stepId: 'medications',
          ),
          const SizedBox(height: 8),
          // FACTUAL_ANALYSIS C5 / F16 \u2014 PA Act 194 \u00a7 5823(b)(2) (the
          // statutory declaration form itself states this):
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
                          fontSize: 13,
                          height: 1.45,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: l10n.medsStepHeadsUpLead,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: l10n.medsStepHeadsUpBody,
                          ),
                          TextSpan(
                            text: l10n.medsStepHeadsUpBold,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                          TextSpan(
                            text: l10n.medsStepHeadsUpTail,
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
              title: Text(l10n.medsStepAgentDecides),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
          ],
          _MedTable(
            title: l10n.medsStepCurrentTitle,
            subtitle: l10n.medsStepCurrentSubtitle,
            rows: _current,
            accentColor: Theme.of(context).colorScheme.secondary,
            showDosage: true,
            onAdd: () => _addMedRow(_current),
            onMedlineInfo: _showMedInfo,
            onFdaInfo: _showFdaInfo,
            onRemove: (i) => setState(() {
              _current[i].dispose();
              _current.removeAt(i);
            }),
          ),
          const SizedBox(height: 16),
          _MedTable(
            title: l10n.medsStepNeverTitle,
            subtitle: l10n.medsStepNeverSubtitle,
            rows: _exceptions,
            accentColor: neverColor,
            onAdd: () => _addMedRow(_exceptions),
            onMedlineInfo: _showMedInfo,
            onFdaInfo: _showFdaInfo,
            onRemove: (i) => setState(() {
              _exceptions[i].dispose();
              _exceptions.removeAt(i);
            }),
          ),
          const SizedBox(height: 16),
          _MedTable(
            title: l10n.medsStepLimitTitle,
            subtitle: l10n.medsStepLimitSubtitle,
            rows: _limitations,
            accentColor: limitColor,
            onAdd: () => _addMedRow(_limitations),
            onMedlineInfo: _showMedInfo,
            onFdaInfo: _showFdaInfo,
            onRemove: (i) => setState(() {
              _limitations[i].dispose();
              _limitations.removeAt(i);
            }),
          ),
          const SizedBox(height: 16),
          _MedTable(
            title: l10n.medsStepPreferredTitle,
            subtitle: l10n.medsStepPreferredSubtitle,
            rows: _preferred,
            accentColor: preferColor,
            onAdd: () => _addMedRow(_preferred),
            onMedlineInfo: _showMedInfo,
            onFdaInfo: _showFdaInfo,
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
                  borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
                ),
                child: Icon(Icons.healing_outlined, color: p.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.medsStepSideEffectsTitle,
                      style: const TextStyle(
                        fontFamily: kSansFamily,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      context.l10n.medsStepSideEffectsBody,
                      style: TextStyle(
                        fontFamily: kSansFamily,
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
  // Only used (and shown) for the "currently taking" section.
  final TextEditingController dosageCtrl = TextEditingController();
  _MedRow({this.id});
  void dispose() {
    nameCtrl.dispose();
    reasonCtrl.dispose();
    dosageCtrl.dispose();
  }
}

class _MedTable extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<_MedRow> rows;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  // Plain-language education (MedlinePlus) and official FDA label text. Both are
  // AI-free lookups, so they work without a Gemini key.
  final void Function(String medName)? onMedlineInfo;
  final void Function(String medName)? onFdaInfo;
  final Color? accentColor;
  // Show a dosage field per row. Only the "currently taking" section sets this;
  // the preference sections (never/limitations/preferred) don't capture dosage.
  final bool showDosage;

  const _MedTable({
    required this.title,
    required this.subtitle,
    required this.rows,
    required this.onAdd,
    required this.onRemove,
    this.onMedlineInfo,
    this.onFdaInfo,
    this.accentColor,
    this.showDosage = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerLow,
      shape: accentColor != null
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.inputRadius),
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
                            // Strength suggestions only in the "currently
                            // taking" section (the only one that captures a
                            // strength); other sections search by name only.
                            showStrengths: showDosage,
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
                                        context.l10n.medsStepNtiNote(note),
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
                          if (showDosage) ...[
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: rows[i].dosageCtrl,
                              decoration: InputDecoration(
                                labelText: context.l10n.medsStepDosageLabel,
                                border: const OutlineInputBorder(),
                                isDense: true,
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: rows[i].reasonCtrl,
                            maxLength: appData.config.medicationNoteMaxChars,
                            decoration: InputDecoration(
                              labelText: context.l10n.medsStepReasonLabel,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onMedlineInfo != null || onFdaInfo != null)
                      ListenableBuilder(
                        listenable: rows[i].nameCtrl,
                        builder: (context, _) {
                          final name = rows[i].nameCtrl.text.trim();
                          if (name.isEmpty) return const SizedBox.shrink();
                          return PopupMenuButton<String>(
                            icon: Icon(Icons.info_outline, color: cs.primary),
                            tooltip: context.l10n.medsStepLearnAbout(name),
                            onSelected: (v) {
                              if (v == 'medline') onMedlineInfo?.call(name);
                              if (v == 'fda') onFdaInfo?.call(name);
                            },
                            itemBuilder: (_) => [
                              if (onMedlineInfo != null)
                                PopupMenuItem(
                                  value: 'medline',
                                  child: Text(context.l10n.medsStepMedlineInfo),
                                ),
                              if (onFdaInfo != null)
                                PopupMenuItem(
                                  value: 'fda',
                                  child: Text(context.l10n.medsStepFdaInfo),
                                ),
                            ],
                          );
                        },
                      ),
                    IconButton(
                      icon:
                          const Icon(Icons.remove_circle_outline),
                      color: cs.error,
                      tooltip: rows[i].nameCtrl.text.isEmpty
                          ? context.l10n.medsStepRemoveDefault
                          : context.l10n.medsStepRemoveNamed(
                              rows[i].nameCtrl.text),
                      onPressed: () => onRemove(i),
                    ),
                  ],
                ),
              );
            }),
            Semantics(
              button: true,
              label: context.l10n.medsStepAddToList(title),
              child: TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: Text(context.l10n.medsStepAddButton),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

