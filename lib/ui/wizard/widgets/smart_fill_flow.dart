import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/smart_fill_service.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/clinical_data_service.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';
import 'package:mhad/ui/widgets/nlm_attribution.dart';

/// Launches the Smart Fill flow as a full-screen dialog.
/// Returns true if data was applied, false/null if cancelled.
Future<bool?> showSmartFillFlow(
  BuildContext context, {
  required int directiveId,
  required String formType,
}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _SmartFillScreen(
        directiveId: directiveId,
        formType: formType,
      ),
    ),
  );
}

class _SmartFillScreen extends ConsumerStatefulWidget {
  final int directiveId;
  final String formType;

  const _SmartFillScreen({
    required this.directiveId,
    required this.formType,
  });

  @override
  ConsumerState<_SmartFillScreen> createState() => _SmartFillScreenState();
}

enum _Step { conditions, medications, generating, review }

class _SmartFillScreenState extends ConsumerState<_SmartFillScreen> {
  _Step _step = _Step.conditions;

  // ── Step 1: Conditions ──────────────────────────────────────────────
  final _condSearchCtrl = TextEditingController();
  List<IcdCondition> _condResults = [];
  final List<IcdCondition> _selectedConditions = [];
  bool _searchingCond = false;

  // ── Step 2: Medications ─────────────────────────────────────────────
  final _medSearchCtrl = TextEditingController();
  List<MedicationResult> _medResults = [];
  final List<String> _selectedCurrentMeds = [];
  final List<String> _selectedAvoidMeds = [];
  bool _searchingMed = false;
  bool _pickingAvoidMeds = false;

  // ── Step 3: Result ──────────────────────────────────────────────────
  SmartFillResult? _result;
  Map<String, bool>? _accepted;
  Map<String, String>? _editedValues;
  String? _error;

  // ── Existing wizard data summary (shown to user) ──────────────────
  final List<String> _existingDataSummary = [];
  bool _loadedExisting = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  /// Pre-populate conditions, medications, and build a summary of all
  /// existing wizard data so the user can see what the AI will work with.
  Future<void> _loadExistingData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final directive = await repo.getDirectiveById(widget.directiveId);
    final prefs = await repo.getPreferences(widget.directiveId);
    final instr = await repo.getAdditionalInstructions(widget.directiveId);
    final savedDiagnoses = await repo.getDiagnoses(widget.directiveId);
    final savedMeds = await repo.watchMedications(widget.directiveId).first;

    if (!mounted) return;
    setState(() {
      // Pre-populate conditions from saved diagnoses
      for (final d in savedDiagnoses) {
        if (!_selectedConditions.any((c) => c.code == d.icdCode)) {
          _selectedConditions
              .add(IcdCondition(code: d.icdCode, name: d.name));
        }
      }
      // Pre-populate medications
      for (final m in savedMeds) {
        if (m.entryType == 'preferred' &&
            !_selectedCurrentMeds.contains(m.medicationName)) {
          _selectedCurrentMeds.add(m.medicationName);
        } else if (m.entryType == 'exception' &&
            !_selectedAvoidMeds.contains(m.medicationName)) {
          _selectedAvoidMeds.add(m.medicationName);
        }
      }

      // Build summary of ALL existing wizard data for display
      _existingDataSummary.clear();
      if (directive != null) {
        if (directive.effectiveCondition.isNotEmpty) {
          _existingDataSummary.add(
              'Effective condition: ${directive.effectiveCondition}');
        }
      }
      if (prefs != null) {
        if (prefs.preferredFacilityName.isNotEmpty) {
          _existingDataSummary.add(
              'Preferred facility: ${prefs.preferredFacilityName}');
        }
        if (prefs.avoidFacilityName.isNotEmpty) {
          _existingDataSummary.add(
              'Avoid facility: ${prefs.avoidFacilityName}');
        }
        if (prefs.medicationConsent != 'yes') {
          _existingDataSummary.add(
              'Medication consent: ${prefs.medicationConsent}');
        }
        if (prefs.ectConsent != 'no') {
          _existingDataSummary.add('ECT consent: ${prefs.ectConsent}');
        }
        if (prefs.experimentalConsent != 'no') {
          _existingDataSummary.add(
              'Experimental consent: ${prefs.experimentalConsent}');
        }
        if (prefs.drugTrialConsent != 'no') {
          _existingDataSummary.add(
              'Drug trial consent: ${prefs.drugTrialConsent}');
        }
        if (prefs.agentAuthorityLimitations.isNotEmpty) {
          _existingDataSummary.add(
              'Agent limitations: ${prefs.agentAuthorityLimitations}');
        }
      }
      if (instr != null) {
        if (instr.healthHistory.isNotEmpty) {
          _existingDataSummary.add(
              'Health history: ${instr.healthHistory}');
        }
        if (instr.crisisIntervention.isNotEmpty) {
          _existingDataSummary.add(
              'Crisis plan: ${instr.crisisIntervention}');
        }
        if (instr.activities.isNotEmpty) {
          _existingDataSummary.add('Activities: ${instr.activities}');
        }
        if (instr.dietary.isNotEmpty) {
          _existingDataSummary.add('Dietary: ${instr.dietary}');
        }
        if (instr.religious.isNotEmpty) {
          _existingDataSummary.add(
              'Religious/spiritual: ${instr.religious}');
        }
        if (instr.childrenCustody.isNotEmpty) {
          _existingDataSummary.add(
              'Children/custody: ${instr.childrenCustody}');
        }
        if (instr.familyNotification.isNotEmpty) {
          _existingDataSummary.add(
              'Family notification: ${instr.familyNotification}');
        }
        if (instr.recordsDisclosure.isNotEmpty) {
          _existingDataSummary.add(
              'Records disclosure: ${instr.recordsDisclosure}');
        }
        if (instr.petCustody.isNotEmpty) {
          _existingDataSummary.add('Pet custody: ${instr.petCustody}');
        }
        if (instr.other.isNotEmpty) {
          _existingDataSummary.add('Other: ${instr.other}');
        }
      }
      // Limitation meds (separate from preferred/avoid)
      final limitationMeds = savedMeds
          .where((m) => m.entryType == 'limitation')
          .map((m) => m.medicationName)
          .toList();
      if (limitationMeds.isNotEmpty) {
        _existingDataSummary.add(
            'Medication limitations: ${limitationMeds.join(", ")}');
      }

      _loadedExisting = true;
    });
  }

  @override
  void dispose() {
    _condSearchCtrl.dispose();
    _medSearchCtrl.dispose();
    super.dispose();
  }

  // ── Search helpers ──────────────────────────────────────────────────

  Future<void> _searchConditions(String query) async {
    if (query.trim().length < 2) {
      setState(() => _condResults = []);
      return;
    }
    setState(() => _searchingCond = true);
    try {
      final results = await ClinicalDataService.searchConditions(query);
      if (mounted) setState(() => _condResults = results);
    } finally {
      if (mounted) setState(() => _searchingCond = false);
    }
  }

  Future<void> _searchMedications(String query) async {
    if (query.trim().length < 2) {
      setState(() => _medResults = []);
      return;
    }
    setState(() => _searchingMed = true);
    try {
      final results =
          await ClinicalDataService.searchMedicationsWithStrengths(query);
      if (mounted) setState(() => _medResults = results);
    } finally {
      if (mounted) setState(() => _searchingMed = false);
    }
  }

  // ── Generate ────────────────────────────────────────────────────────

  Future<void> _generate() async {
    // AI consent
    if (!ref.read(aiConsentGivenProvider)) {
      final ok = await showAiConsentDialog(context);
      if (!ok || !mounted) return;
      ref.read(aiConsentGivenProvider.notifier).state = true;
    }

    final apiKey = ref.read(apiKeyProvider).valueOrNull;
    if (apiKey == null || apiKey.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI is not set up. Go to AI Assistant Setup to add your API key.'),
          ),
        );
      }
      return;
    }

    // Check rate limits
    final tracker = ref.read(geminiRateTrackerProvider);
    final blockReason = tracker.blockReason;
    if (blockReason != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(blockReason), duration: const Duration(seconds: 5)),
      );
      return;
    }

    setState(() {
      _step = _Step.generating;
      _error = null;
    });

    try {
      // Read existing wizard data so AI can supplement, not duplicate
      final repo = ref.read(directiveRepositoryProvider);
      final directive = await repo.getDirectiveById(widget.directiveId);
      final prefs = await repo.getPreferences(widget.directiveId);
      final instr = await repo.getAdditionalInstructions(widget.directiveId);
      final meds = await repo.watchMedications(widget.directiveId).first;
      final savedDiagnoses = await repo.getDiagnoses(widget.directiveId);

      // Merge wizard's saved diagnoses with Smart Fill's selected conditions
      final allConditions = <IcdCondition>[..._selectedConditions];
      for (final d in savedDiagnoses) {
        if (!allConditions.any((c) => c.code == d.icdCode)) {
          allConditions.add(IcdCondition(code: d.icdCode, name: d.name));
        }
      }

      final existingPreferred = meds
          .where((m) => m.entryType == 'preferred')
          .map((m) => m.medicationName)
          .toList();
      final existingLimitation = meds
          .where((m) => m.entryType == 'limitation')
          .map((m) => m.medicationName)
          .toList();
      final existingAvoid = meds
          .where((m) => m.entryType == 'exception')
          .map((m) => m.medicationName)
          .toList();

      final service = SmartFillService(apiKey: apiKey);
      final response = await service.generate(SmartFillInput(
        conditions: allConditions,
        currentMedications: _selectedCurrentMeds,
        medicationsToAvoid: _selectedAvoidMeds,
        formType: widget.formType,
        // Directive
        existingEffectiveCondition: directive?.effectiveCondition ?? '',
        // Preferences
        existingFacilityPref: prefs?.treatmentFacilityPref ?? 'noPreference',
        existingPreferredFacility: prefs?.preferredFacilityName ?? '',
        existingAvoidFacility: prefs?.avoidFacilityName ?? '',
        existingMedicationConsent: prefs?.medicationConsent ?? 'yes',
        existingEctConsent: prefs?.ectConsent ?? 'no',
        existingExperimentalConsent: prefs?.experimentalConsent ?? 'no',
        existingDrugTrialConsent: prefs?.drugTrialConsent ?? 'no',
        existingAgentCanConsentHospitalization:
            prefs?.agentCanConsentHospitalization ?? true,
        existingAgentCanConsentMedication:
            prefs?.agentCanConsentMedication ?? true,
        existingAgentAuthorityLimitations:
            prefs?.agentAuthorityLimitations ?? '',
        // Additional instructions
        existingHealthHistory: instr?.healthHistory ?? '',
        existingCrisisIntervention: instr?.crisisIntervention ?? '',
        existingActivities: instr?.activities ?? '',
        existingDietary: instr?.dietary ?? '',
        existingReligious: instr?.religious ?? '',
        existingChildrenCustody: instr?.childrenCustody ?? '',
        existingFamilyNotification: instr?.familyNotification ?? '',
        existingRecordsDisclosure: instr?.recordsDisclosure ?? '',
        existingPetCustody: instr?.petCustody ?? '',
        existingOther: instr?.other ?? '',
        // Medications
        existingPreferredMeds: existingPreferred,
        existingLimitationMeds: existingLimitation,
        existingAvoidMeds: existingAvoid,
      ));

      final result = response.result;

      // Record actual token usage from API response
      tracker.recordRequest(estimatedTokens: response.totalTokens);

      if (!mounted) return;

      if (result.isEmpty) {
        setState(() {
          _error =
              'The AI could not generate suggestions from the selected data. '
              'Try adding more conditions or medications.';
          _step = _Step.medications;
        });
        return;
      }

      final display = result.toDisplayMap();
      setState(() {
        _result = result;
        _accepted = {for (final key in display.keys) key: false};
        _editedValues = Map<String, String>.from(display);
        _step = _Step.review;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = FriendlyError.from(e);
          _step = _Step.medications;
        });
      }
    }
  }

  // ── Apply ───────────────────────────────────────────────────────────

  Future<void> _apply() async {
    if (_result == null || _accepted == null || _editedValues == null) return;

    try {
      final repo = ref.read(directiveRepositoryProvider);
      final id = widget.directiveId;
      final r = _result!;
      final a = _accepted!;
      final v = _editedValues!;

      String? editedVal(String key) {
        if (a[key] != true) return null;
        final text = v[key]?.trim();
        return (text != null && text.isNotEmpty) ? text : null;
      }

      // Effective condition
      final ec = editedVal('Effective Condition');
      if (ec != null) {
        final d = await repo.getDirectiveById(id);
        if (d != null && d.effectiveCondition.isEmpty) {
          await repo.updateEffectiveCondition(id, ec);
        }
      }

      // Health history + other additional instructions
      final instrUpdates = <String, String>{};
      final hh = editedVal('Health History');
      if (hh != null) instrUpdates['healthHistory'] = hh;
      final ci = editedVal('Crisis Intervention');
      if (ci != null) instrUpdates['crisisIntervention'] = ci;
      final act = editedVal('Helpful Activities');
      if (act != null) instrUpdates['activities'] = act;
      final diet = editedVal('Dietary Considerations');
      if (diet != null) instrUpdates['dietary'] = diet;
      final ag = editedVal('Agent Guidance');
      if (ag != null) instrUpdates['other'] = ag;

      if (instrUpdates.isNotEmpty) {
        final existing = await repo.getAdditionalInstructions(id);
        await repo.upsertAdditionalInstructions(
          AdditionalInstructionsTableCompanion(
            directiveId: Value(id),
            healthHistory: instrUpdates.containsKey('healthHistory')
                ? Value(_merge(
                    existing?.healthHistory, instrUpdates['healthHistory']!))
                : const Value.absent(),
            crisisIntervention: instrUpdates.containsKey('crisisIntervention')
                ? Value(_merge(existing?.crisisIntervention,
                    instrUpdates['crisisIntervention']!))
                : const Value.absent(),
            activities: instrUpdates.containsKey('activities')
                ? Value(
                    _merge(existing?.activities, instrUpdates['activities']!))
                : const Value.absent(),
            dietary: instrUpdates.containsKey('dietary')
                ? Value(_merge(existing?.dietary, instrUpdates['dietary']!))
                : const Value.absent(),
            other: instrUpdates.containsKey('other')
                ? Value(_merge(existing?.other, instrUpdates['other']!))
                : const Value.absent(),
          ),
        );
      }

      // Medications to consider → preferred
      if (a['Additional Medications to Consider'] == true) {
        final existing = await repo.watchMedications(id).first;
        int order = existing.length;
        for (final m in r.additionalMedsToConsider) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.preferred.name,
            medicationName: Value(m.name),
            reason: Value(m.reason),
            sortOrder: Value(order++),
          ));
        }
      }

      // Medications to avoid → exceptions
      if (a['Additional Medications to Avoid'] == true) {
        final existing = await repo.watchMedications(id).first;
        int order = existing.length;
        for (final m in r.additionalMedsToAvoid) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.exception.name,
            medicationName: Value(m.name),
            reason: Value(m.reason),
            sortOrder: Value(order++),
          ));
        }
      }

      // Also save the user's explicit current meds + avoid meds from step 2
      final existingMeds = await repo.watchMedications(id).first;
      int order = existingMeds.length;
      bool isDuplicate(String name, String entryType) {
        return existingMeds.any((m) =>
            m.medicationName.toLowerCase() == name.toLowerCase() &&
            m.entryType == entryType);
      }

      for (final name in _selectedCurrentMeds) {
        if (!isDuplicate(name, MedicationEntryType.preferred.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.preferred.name,
            medicationName: Value(name),
            reason: Value('Currently prescribed'),
            sortOrder: Value(order++),
          ));
        }
      }
      for (final name in _selectedAvoidMeds) {
        if (!isDuplicate(name, MedicationEntryType.exception.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.exception.name,
            medicationName: Value(name),
            sortOrder: Value(order++),
          ));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying suggestions: $e')),
        );
      }
    }

    if (mounted) Navigator.pop(context, true);
  }

  String _merge(String? existing, String newText) {
    if (existing == null || existing.trim().isEmpty) return newText;
    return '$existing\n\n[AI suggestion] $newText';
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final isProcessing = _step == _Step.generating;

    return PopScope(
      canPop: !isProcessing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isProcessing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait while AI is generating...')),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: isProcessing
              ? null
              : () => Navigator.pop(context, false),
        ),
      ),
      body: Column(
        children: [
          // Step indicator
          LinearProgressIndicator(
            value: (_step.index + 1) / _Step.values.length,
            backgroundColor: cs.surfaceContainerHighest,
          ),
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Step ${_step.index + 1} of ${_Step.values.length}: $_stepSubtitle',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          Expanded(child: _buildStepBody()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    ),
    );
  }

  String get _stepTitle => switch (_step) {
        _Step.conditions => 'Your Conditions',
        _Step.medications => 'Your Medications',
        _Step.generating => 'Generating',
        _Step.review => 'Review Suggestions',
      };

  String get _stepSubtitle => switch (_step) {
        _Step.conditions => 'Search and select your diagnoses',
        _Step.medications => 'Search and select your medications',
        _Step.generating => 'AI is creating suggestions...',
        _Step.review => 'Accept or reject each suggestion',
      };

  Widget _buildStepBody() {
    return switch (_step) {
      _Step.conditions => _buildConditionsStep(),
      _Step.medications => _buildMedicationsStep(),
      _Step.generating => _buildGeneratingStep(),
      _Step.review => _buildReviewStep(),
    };
  }

  // ── Step 1: Conditions ──────────────────────────────────────────────

  Widget _buildExistingDataCard() {
    if (!_loadedExisting || _existingDataSummary.isEmpty) {
      return const SizedBox.shrink();
    }
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Icon(Icons.info_outline, size: 18, color: cs.primary),
        title: Text(
          'Your existing form data (${_existingDataSummary.length} fields)',
          style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
        ),
        children: _existingDataSummary.map((line) {
          final parts = line.split(': ');
          final label = parts.first;
          final value = parts.length > 1 ? parts.sublist(1).join(': ') : '';
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant)),
                ),
                Expanded(
                  child: Text(
                    value.length > 80 ? '${value.substring(0, 80)}...' : value,
                    style: TextStyle(fontSize: 11, color: cs.onSurface),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConditionsStep() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExistingDataCard(),
          TextField(
            controller: _condSearchCtrl,
            decoration: InputDecoration(
              labelText: 'Search diagnoses',
              hintText: 'e.g., bipolar, anxiety, depression',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchingCond
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
            onChanged: _searchConditions,
          ),
          if (_selectedConditions.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _selectedConditions
                  .map((c) => Chip(
                        label: Text(c.name, style: const TextStyle(fontSize: 12)),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => setState(
                            () => _selectedConditions.remove(c)),
                        backgroundColor: cs.primaryContainer,
                        labelStyle:
                            TextStyle(color: cs.onPrimaryContainer),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 8),
          Expanded(
            child: _condResults.isEmpty
                ? Center(
                    child: Text(
                      _condSearchCtrl.text.isEmpty
                          ? 'Type to search ICD-10 diagnoses.\nThese are looked up for free — no AI tokens used.'
                          : 'No results found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : ListView.separated(
                    itemCount: _condResults.length,
                    separatorBuilder: (context2, index) =>
                        Divider(height: 1, color: cs.outlineVariant),
                    itemBuilder: (ctx, i) {
                      final c = _condResults[i];
                      final selected = _selectedConditions
                          .any((s) => s.code == c.code);
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
                        trailing: selected
                            ? Icon(Icons.check_circle,
                                color: cs.primary, size: 20)
                            : Icon(Icons.add_circle_outline,
                                color: cs.primary, size: 20),
                        onTap: () {
                          setState(() {
                            if (selected) {
                              _selectedConditions
                                  .removeWhere((s) => s.code == c.code);
                            } else {
                              _selectedConditions.add(c);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
          const NlmAttribution(),
        ],
      ),
    );
  }

  // ── Step 2: Medications ─────────────────────────────────────────────

  Widget _buildMedicationsStep() {
    final cs = Theme.of(context).colorScheme;
    final targetList =
        _pickingAvoidMeds ? _selectedAvoidMeds : _selectedCurrentMeds;
    final targetLabel =
        _pickingAvoidMeds ? 'medications to AVOID' : 'current medications';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExistingDataCard(),
          // Toggle between current / avoid
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: false, label: Text('Current Meds')),
              ButtonSegment(value: true, label: Text('Meds to Avoid')),
            ],
            selected: {_pickingAvoidMeds},
            onSelectionChanged: (v) =>
                setState(() => _pickingAvoidMeds = v.first),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _medSearchCtrl,
            decoration: InputDecoration(
              labelText: 'Search $targetLabel',
              hintText: 'e.g., lithium, sertraline',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchingMed
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : null,
            ),
            onChanged: _searchMedications,
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(_error!,
                        style: TextStyle(color: cs.onErrorContainer, fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () {
                      setState(() => _error = null);
                      _generate();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
          // Selected chips for both lists
          if (_selectedCurrentMeds.isNotEmpty ||
              _selectedAvoidMeds.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (_selectedCurrentMeds.isNotEmpty) ...[
              Text('Current:', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _selectedCurrentMeds
                    .map((m) => Chip(
                          label: Text(m, style: const TextStyle(fontSize: 11)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => _selectedCurrentMeds.remove(m)),
                          backgroundColor: cs.primaryContainer,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            if (_selectedAvoidMeds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Avoid:', style: TextStyle(fontSize: 11, color: cs.error)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _selectedAvoidMeds
                    .map((m) => Chip(
                          label: Text(m, style: const TextStyle(fontSize: 11)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => _selectedAvoidMeds.remove(m)),
                          backgroundColor: cs.errorContainer,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ],
          const SizedBox(height: 8),
          Expanded(
            child: _medResults.isEmpty
                ? Center(
                    child: Text(
                      _medSearchCtrl.text.isEmpty
                          ? 'Type to search RxNorm medications.\nFree lookup — no AI tokens used.'
                          : 'No results found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: _medResults.length,
                    itemBuilder: (ctx, i) {
                      final med = _medResults[i];
                      final baseName = med.name.split(' (').first;

                      // Build list of selectable items: the base name + each strength
                      final items = <String>[med.name];
                      for (final s in med.strengths) {
                        items.add('$baseName $s');
                      }

                      final nameSelected = targetList.contains(med.name);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Main medication name
                          Semantics(
                            button: true,
                            label: 'Select ${med.name}',
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  if (nameSelected) {
                                    targetList.remove(med.name);
                                  } else {
                                    targetList.add(med.name);
                                  }
                                });
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(12, 10, 12, 4),
                                child: Row(
                                  children: [
                                    Icon(Icons.medication,
                                        size: 16, color: cs.primary),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(med.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                  fontWeight:
                                                      FontWeight.w600)),
                                    ),
                                    if (nameSelected)
                                      Icon(Icons.check_circle,
                                          size: 18, color: cs.primary),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Strength chips
                          if (med.strengths.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(36, 0, 12, 8),
                              child: Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: med.strengths.map((s) {
                                  final display = '$baseName $s';
                                  final inTarget = targetList.contains(display);
                                  return Semantics(
                                    button: true,
                                    label: 'Select $display',
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: () {
                                        setState(() {
                                          if (inTarget) {
                                            targetList.remove(display);
                                          } else {
                                            targetList.add(display);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: inTarget
                                              ? (_pickingAvoidMeds
                                                  ? cs.errorContainer
                                                  : cs.primaryContainer)
                                              : cs.surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          s,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                  color: inTarget
                                                      ? cs.onPrimaryContainer
                                                      : cs.onSurfaceVariant),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          if (i < _medResults.length - 1)
                            Divider(height: 1, color: cs.outlineVariant),
                        ],
                      );
                    },
                  ),
          ),
          const NlmAttribution(),
        ],
      ),
    );
  }

  // ── Step 3: Generating ──────────────────────────────────────────────

  Widget _buildGeneratingStep() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          const Text('Generating personalized suggestions...'),
          const SizedBox(height: 8),
          Text(
            'Using your selections + a single compact AI call',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  // ── Step 4: Review ──────────────────────────────────────────────────

  Widget _buildReviewStep() {
    if (_result == null || _accepted == null || _editedValues == null) {
      return const Center(child: Text('No suggestions generated.'));
    }

    final cs = Theme.of(context).colorScheme;
    final keys = _editedValues!.keys.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: cs.onTertiaryContainer),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Review each suggestion carefully. Tap to edit, '
                  'then check the box to approve it. Only checked '
                  'items will be applied. This is not medical or legal advice.',
                  style: TextStyle(
                      fontSize: 12,
                      color: cs.onTertiaryContainer,
                      fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...keys.map((key) {
          final checked = _accepted![key] ?? false;
          final value = _editedValues![key] ?? '';

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: checked
                ? cs.surfaceContainerLow
                : cs.surfaceContainerHighest.withValues(alpha: 0.5),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _editField(key, value),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: checked,
                      onChanged: (v) =>
                          setState(() => _accepted![key] = v ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(key,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: checked
                                          ? cs.onSurface
                                          : cs.onSurfaceVariant,
                                    )),
                            const SizedBox(height: 4),
                            Text(
                              value,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: checked
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(Icons.edit, size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Future<void> _editField(String key, String currentValue) async {
    final controller = TextEditingController(text: currentValue);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(key),
        content: TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();

    if (result != null && mounted) {
      setState(() {
        _editedValues![key] = result;
        // Auto-check if user edited it
        if (result.trim().isNotEmpty) {
          _accepted![key] = true;
        }
      });
    }
  }

  // ── Bottom bar ──────────────────────────────────────────────────────

  Widget? _buildBottomBar() {
    if (_step == _Step.generating) return null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (_step != _Step.conditions)
              OutlinedButton(
                onPressed: _step == _Step.generating
                    ? null
                    : () {
                        setState(() {
                          if (_step == _Step.medications) {
                            _step = _Step.conditions;
                          } else if (_step == _Step.review) {
                            _step = _Step.medications;
                          }
                        });
                      },
                child: const Text('Back'),
              ),
            const Spacer(),
            if (_step == _Step.conditions)
              FilledButton.icon(
                onPressed: _selectedConditions.isEmpty
                    ? null
                    : () => setState(() => _step = _Step.medications),
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                    'Next (${_selectedConditions.length} selected)'),
              ),
            if (_step == _Step.medications)
              FilledButton.icon(
                onPressed: (_selectedCurrentMeds.isEmpty &&
                        _selectedAvoidMeds.isEmpty &&
                        _selectedConditions.isEmpty)
                    ? null
                    : _generate,
                icon: const Icon(Icons.auto_awesome),
                label: const Text('Generate'),
              ),
            if (_step == _Step.review)
              FilledButton.icon(
                onPressed: _accepted?.values.any((v) => v) == true
                    ? _apply
                    : null,
                icon: const Icon(Icons.check),
                label: Text(
                    'Apply ${_accepted?.values.where((v) => v).length ?? 0} items'),
              ),
          ],
        ),
      ),
    );
  }
}


