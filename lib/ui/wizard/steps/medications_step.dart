import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
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
    for (final row in [..._exceptions, ..._limitations, ..._preferred]) {
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
          case MedicationEntryType.exception:
            _exceptions.add(row);
          case MedicationEntryType.limitation:
            _limitations.add(row);
          case MedicationEntryType.preferred:
            _preferred.add(row);
        }
      }
      if (prefs != null && _hasAgentSections) {
        _agentDecidesMeds = prefs.medicationConsent == 'agentDecides';
      }
    });
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

    collectRows(_exceptions, MedicationEntryType.exception);
    collectRows(_limitations, MedicationEntryType.limitation);
    collectRows(_preferred, MedicationEntryType.preferred);

    await repo.replaceMedications(widget.directiveId, entries);

    // Save medication consent option (idempotent upsert, no transaction needed)
    if (_hasAgentSections) {
      final existingPrefs = await repo.getPreferences(widget.directiveId);
      await repo.upsertPreferences(DirectivePrefsCompanion(
        id: existingPrefs != null ? Value(existingPrefs.id) : const Value.absent(),
        directiveId: Value(widget.directiveId),
        medicationConsent:
            Value(_agentDecidesMeds ? 'agentDecides' : 'yes'),
      ));
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WizardHelpButton(
            helpText:
                'List medications by name. '
                'Exceptions: medications you never want given. '
                'Limitations: medications that may be given but only with restrictions (e.g., low dose only). '
                'Preferred: medications that have worked well for you.\n\n'
                'Your treatment team will consider these preferences, but may not always be able to honor them.',
            stepId: 'medications',
          ),
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medication categories',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\u2022 Never give (Exceptions): Medications you refuse under any circumstances\n'
                    '\u2022 With limitations: Medications allowed but with restrictions (e.g., low dose only, only during acute crisis)\n'
                    '\u2022 Preferred: Medications that have worked well for you',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Theme.of(context)
                          .colorScheme
                          .onSecondaryContainer,
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
            title: 'Medications I NEVER want',
            subtitle: 'These medications should not be administered',
            rows: _exceptions,
            onAdd: () => setState(
                () => _exceptions.add(_MedRow())),
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
            onAdd: () => setState(
                () => _limitations.add(_MedRow())),
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
            onAdd: () =>
                setState(() => _preferred.add(_MedRow())),
            onRemove: (i) => setState(() {
              _preferred[i].dispose();
              _preferred.removeAt(i);
            }),
          ),
        ],
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

  const _MedTable({
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
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600)),
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
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: rows[i].reasonCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Reason / notes (optional)',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
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

