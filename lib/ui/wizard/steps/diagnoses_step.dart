import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/ui/widgets/nlm_attribution.dart';
import 'package:mhad/ui/wizard/widgets/wizard_help_button.dart';
import 'package:mhad/ui/wizard/wizard_step_mixin.dart';

class DiagnosesStep extends ConsumerStatefulWidget {
  const DiagnosesStep({required this.directiveId, super.key});

  final int directiveId;

  @override
  ConsumerState<DiagnosesStep> createState() => _DiagnosesStepState();
}

class _DiagnosesStepState extends ConsumerState<DiagnosesStep>
    with WizardStepMixin {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<IcdCondition> _searchResults = [];
  bool _searching = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Future<bool> validateAndSave() async => true; // Data saved on each add/remove

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search(query.trim());
    });
  }

  Future<void> _search(String query) async {
    setState(() => _searching = true);
    try {
      final results = await ClinicalDataService.searchConditions(query);
      if (mounted) setState(() => _searchResults = results);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  Future<void> _addDiagnosis(IcdCondition condition,
      List<DiagnosisEntry> current) async {
    // Skip if already added
    if (current.any((d) => d.icdCode == condition.code)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${condition.name} is already added')),
      );
      return;
    }

    await ref.read(directiveRepositoryProvider).insertDiagnosis(
          DiagnosisEntriesCompanion.insert(
            directiveId: widget.directiveId,
            icdCode: Value(condition.code),
            name: Value(condition.name),
            sortOrder: Value(current.length),
          ),
        );
    _searchCtrl.clear();
    setState(() => _searchResults = []);
  }

  Future<void> _removeDiagnosis(int id) async {
    await ref.read(directiveRepositoryProvider).deleteDiagnosis(id);
  }

  Widget _buildDiagnosisTile(DiagnosisEntry d, ColorScheme cs) {
    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      child: ListTile(
        dense: true,
        leading: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            d.icdCode,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: cs.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(d.name, style: const TextStyle(fontSize: 14)),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline, color: cs.error, size: 20),
          tooltip: 'Remove',
          onPressed: () => _removeDiagnosis(d.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final diagnosesStream =
        ref.watch(directiveRepositoryProvider).watchDiagnoses(widget.directiveId);

    const helpText =
        'Search for your psychiatric and medical diagnoses using ICD-10 codes. '
        'These are the official medical classification codes used by healthcare '
        'providers. Adding your diagnoses helps your care team and agent '
        'understand your conditions.\n\n'
        'Psychiatric diagnoses (F-codes) and medical diagnoses are shown '
        'in separate sections.\n\n'
        'This lookup is free and uses the NIH Clinical Tables Service — '
        'no AI tokens are used.';

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              WizardHelpButton(helpText: helpText, stepId: 'diagnoses'),
              const SizedBox(height: 8),
              Text(
                'Diagnoses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Search and add your psychiatric and medical diagnoses. '
                'These will be included in your directive.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),

              // Search field
              TextField(
                controller: _searchCtrl,
                autofillHints: const [],
                autocorrect: false,
                enableSuggestions: false,
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  labelText: 'Search ICD-10 diagnoses',
                  hintText: 'e.g., bipolar, anxiety, PTSD, depression',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : _searchCtrl.text.isNotEmpty
                          ? Semantics(
                              button: true,
                              label: 'Clear search',
                              child: IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                tooltip: 'Clear search',
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchResults = []);
                                },
                              ),
                            )
                          : null,
                ),
              ),
              const SizedBox(height: 8),

              // Search results
              if (_searchResults.isNotEmpty)
                StreamBuilder<List<DiagnosisEntry>>(
                  stream: diagnosesStream,
                  builder: (context, snap) {
                    final current = snap.data ?? [];
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: _searchResults.length,
                          separatorBuilder: (context2, index) =>
                              Divider(height: 1, color: cs.outlineVariant),
                          itemBuilder: (ctx, i) {
                            final c = _searchResults[i];
                            final alreadyAdded =
                                current.any((d) => d.icdCode == c.code);
                            return ListTile(
                              dense: true,
                              leading: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  c.code,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                    color: cs.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              title: Text(c.name,
                                  style: const TextStyle(fontSize: 14)),
                              trailing: alreadyAdded
                                  ? Icon(Icons.check_circle,
                                      color: cs.primary, size: 20)
                                  : Icon(Icons.add_circle_outline,
                                      color: cs.primary, size: 20),
                              onTap: alreadyAdded
                                  ? null
                                  : () => _addDiagnosis(c, current),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),

              if (_searchResults.isEmpty && _searchCtrl.text.length >= 2)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    _searching ? '' : 'No results found.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),

              const SizedBox(height: 16),

              // Selected diagnoses
              StreamBuilder<List<DiagnosisEntry>>(
                stream: diagnosesStream,
                builder: (context, snap) {
                  final diagnoses = snap.data ?? [];
                  if (diagnoses.isEmpty) {
                    return Card(
                      color: cs.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.medical_information_outlined,
                                size: 36, color: cs.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text(
                              'No diagnoses added yet',
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use the search above to find and add your diagnoses.',
                              style: TextStyle(
                                  fontSize: 12, color: cs.onSurfaceVariant),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  final psychiatric = diagnoses
                      .where((d) => d.icdCode.startsWith('F'))
                      .toList();
                  final medical = diagnoses
                      .where((d) => !d.icdCode.startsWith('F'))
                      .toList();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (psychiatric.isNotEmpty) ...[
                        Text(
                          'Psychiatric Diagnoses (${psychiatric.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...psychiatric.map((d) => _buildDiagnosisTile(d, cs)),
                        const SizedBox(height: 16),
                      ],
                      if (medical.isNotEmpty) ...[
                        Text(
                          'Medical Diagnoses (${medical.length})',
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        ...medical.map((d) => _buildDiagnosisTile(d, cs)),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              const NlmAttribution(),
            ],
          ),
        ),
      ],
    );
  }
}
