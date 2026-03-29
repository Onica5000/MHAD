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
  final List<String> _selectedPreferredMeds = [];
  final List<String> _selectedLimitationMeds = [];
  final List<String> _selectedAvoidMeds = [];
  bool _searchingMed = false;
  _MedCategory _medCategory = _MedCategory.preferred;

  // ── Step 3: Result ──────────────────────────────────────────────────
  SmartFillResult? _result;
  Map<String, bool>? _accepted;
  Map<String, String>? _editedValues;
  String? _error;

  // ── Consent context for review warnings & apply enforcement ────────
  // Keys that conflict with user's consent decisions.
  final Set<String> _consentConflicts = {};
  String _medicationConsent = 'yes';
  String _ectConsent = 'no';
  String _experimentalConsent = 'no';
  String _drugTrialConsent = 'no';

  // ── Existing field values for side-by-side comparison ──────────────
  Map<String, String> _existingFieldValues = {};

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
            !_selectedPreferredMeds.contains(m.medicationName)) {
          _selectedPreferredMeds.add(m.medicationName);
        } else if (m.entryType == 'limitation' &&
            !_selectedLimitationMeds.contains(m.medicationName)) {
          _selectedLimitationMeds.add(m.medicationName);
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
        currentMedications: [..._selectedPreferredMeds, ..._selectedLimitationMeds],
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

      // Capture consent values and existing data for review context
      // (reuse directive, prefs, instr from above)
      _medicationConsent = prefs?.medicationConsent ?? 'yes';
      _ectConsent = prefs?.ectConsent ?? 'no';
      _experimentalConsent = prefs?.experimentalConsent ?? 'no';
      _drugTrialConsent = prefs?.drugTrialConsent ?? 'no';

      // Build existing field values for side-by-side comparison
      _existingFieldValues = {};
      if (directive != null && directive.effectiveCondition.isNotEmpty) {
        _existingFieldValues['Effective Condition'] =
            directive.effectiveCondition;
      }
      if (instr != null) {
        if (instr.healthHistory.isNotEmpty) {
          _existingFieldValues['Health History'] = instr.healthHistory;
        }
        if (instr.crisisIntervention.isNotEmpty) {
          _existingFieldValues['Crisis Intervention'] =
              instr.crisisIntervention;
        }
        if (instr.activities.isNotEmpty) {
          _existingFieldValues['Helpful Activities'] = instr.activities;
        }
        if (instr.dietary.isNotEmpty) {
          _existingFieldValues['Dietary Considerations'] = instr.dietary;
        }
        if (instr.religious.isNotEmpty) {
          _existingFieldValues['Religious/Spiritual'] = instr.religious;
        }
        if (instr.childrenCustody.isNotEmpty) {
          _existingFieldValues['Children/Dependent Care'] =
              instr.childrenCustody;
        }
        if (instr.familyNotification.isNotEmpty) {
          _existingFieldValues['Family Notification'] =
              instr.familyNotification;
        }
        if (instr.recordsDisclosure.isNotEmpty) {
          _existingFieldValues['Records Disclosure'] =
              instr.recordsDisclosure;
        }
        if (instr.petCustody.isNotEmpty) {
          _existingFieldValues['Pet Care'] = instr.petCustody;
        }
      }

      // Detect consent conflicts
      _consentConflicts.clear();
      final medKeys = {
        'Additional Medications to Consider',
        'Additional Medications with Limitations',
      };
      if (_medicationConsent == 'no') {
        for (final k in medKeys) {
          if (result.toDisplayMap().containsKey(k)) _consentConflicts.add(k);
        }
      }
      if (_ectConsent == 'no' &&
          result.toDisplayMap().containsKey('ECT Guidance')) {
        _consentConflicts.add('ECT Guidance');
      }
      if (_experimentalConsent == 'no' &&
          result.toDisplayMap().containsKey('Experimental Studies Guidance')) {
        _consentConflicts.add('Experimental Studies Guidance');
      }
      if (_drugTrialConsent == 'no' &&
          result.toDisplayMap().containsKey('Drug Trials Guidance')) {
        _consentConflicts.add('Drug Trials Guidance');
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

      // Read consent preferences once for enforcement across the method
      final currentPrefs = await repo.getPreferences(id);

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
      final rel = editedVal('Religious/Spiritual');
      if (rel != null) instrUpdates['religious'] = rel;
      final cc = editedVal('Children/Dependent Care');
      if (cc != null) instrUpdates['childrenCustody'] = cc;
      final fn = editedVal('Family Notification');
      if (fn != null) instrUpdates['familyNotification'] = fn;
      final rd = editedVal('Records Disclosure');
      if (rd != null) instrUpdates['recordsDisclosure'] = rd;
      final pc = editedVal('Pet Care');
      if (pc != null) instrUpdates['petCustody'] = pc;
      // De-escalation, triggers, guidance stored as tagged entries in 'other' field.
      // Enforce consent: skip guidance for treatments user has refused.
      final deesc = editedVal('De-escalation Techniques');
      final trig = editedVal('Crisis Triggers');
      final ectG = (currentPrefs?.ectConsent ?? 'no') == 'no'
          ? null
          : editedVal('ECT Guidance');
      final expG = (currentPrefs?.experimentalConsent ?? 'no') == 'no'
          ? null
          : editedVal('Experimental Studies Guidance');
      final drugG = (currentPrefs?.drugTrialConsent ?? 'no') == 'no'
          ? null
          : editedVal('Drug Trials Guidance');
      final ag = editedVal('Agent Guidance');
      final otherParts = <String>[];
      if (deesc != null) otherParts.add('[DE-ESCALATION] $deesc');
      if (trig != null) otherParts.add('[TRIGGERS] $trig');
      if (ectG != null) otherParts.add('[ECT GUIDANCE] $ectG');
      if (expG != null) otherParts.add('[EXPERIMENTAL GUIDANCE] $expG');
      if (drugG != null) otherParts.add('[DRUG TRIAL GUIDANCE] $drugG');
      if (ag != null) otherParts.add(ag);
      if (otherParts.isNotEmpty) {
        instrUpdates['other'] = otherParts.join('\n');
      }

      // Facility notes → save to preferences if user hasn't already set them
      final prefFac = editedVal('Facility Notes (preferred)');
      final avoidFac = editedVal('Facility Notes (avoid)');
      if (prefFac != null || avoidFac != null) {
        final existingPrefs = await repo.getPreferences(id);
        final setPref = prefFac != null &&
            (existingPrefs?.preferredFacilityName.isEmpty ?? true);
        final setAvoid = avoidFac != null &&
            (existingPrefs?.avoidFacilityName.isEmpty ?? true);
        if (setPref || setAvoid) {
          await repo.upsertPreferences(DirectivePrefsCompanion(
            directiveId: Value(id),
            preferredFacilityName:
                setPref ? Value(prefFac) : const Value.absent(),
            avoidFacilityName:
                setAvoid ? Value(avoidFac) : const Value.absent(),
          ));
        }
      }

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
            religious: instrUpdates.containsKey('religious')
                ? Value(_merge(existing?.religious, instrUpdates['religious']!))
                : const Value.absent(),
            childrenCustody: instrUpdates.containsKey('childrenCustody')
                ? Value(_merge(existing?.childrenCustody,
                    instrUpdates['childrenCustody']!))
                : const Value.absent(),
            familyNotification:
                instrUpdates.containsKey('familyNotification')
                    ? Value(_merge(existing?.familyNotification,
                        instrUpdates['familyNotification']!))
                    : const Value.absent(),
            recordsDisclosure: instrUpdates.containsKey('recordsDisclosure')
                ? Value(_merge(existing?.recordsDisclosure,
                    instrUpdates['recordsDisclosure']!))
                : const Value.absent(),
            petCustody: instrUpdates.containsKey('petCustody')
                ? Value(_merge(
                    existing?.petCustody, instrUpdates['petCustody']!))
                : const Value.absent(),
            other: instrUpdates.containsKey('other')
                ? Value(_merge(existing?.other, instrUpdates['other']!))
                : const Value.absent(),
          ),
        );
      }

      // ── Medications ──────────────────────────────────────────────────
      // Enforce consent: skip medication suggestions if user refused
      final medConsent = currentPrefs?.medicationConsent ?? 'yes';
      if (medConsent == 'no') {
        // Silently skip — user was warned in review UI
        a.remove('Additional Medications to Consider');
        a.remove('Additional Medications with Limitations');
      }

      // Query existing meds ONCE and track order across all inserts to
      // avoid race conditions from multiple queries.
      final existingMeds = await repo.watchMedications(id).first;
      int order = existingMeds.length;
      final insertedNames = <String, Set<String>>{}; // entryType → names

      bool isDuplicate(String name, String entryType) {
        final lowerName = name.toLowerCase();
        if (existingMeds.any((m) =>
            m.medicationName.toLowerCase() == lowerName &&
            m.entryType == entryType)) {
          return true;
        }
        return insertedNames[entryType]?.contains(lowerName) ?? false;
      }

      void trackInserted(String name, String entryType) {
        (insertedNames[entryType] ??= {}).add(name.toLowerCase());
      }

      // AI-suggested medications to consider → preferred
      if (a['Additional Medications to Consider'] == true) {
        for (final m in r.additionalMedsToConsider) {
          if (!isDuplicate(m.name, MedicationEntryType.preferred.name)) {
            await repo.insertMedication(MedicationEntriesCompanion.insert(
              directiveId: id,
              entryType: MedicationEntryType.preferred.name,
              medicationName: Value(m.name),
              reason: Value(m.reason),
              sortOrder: Value(order++),
            ));
            trackInserted(m.name, MedicationEntryType.preferred.name);
          }
        }
      }

      // AI-suggested medications with limitations → limitations
      if (a['Additional Medications with Limitations'] == true) {
        for (final m in r.additionalMedsWithLimitations) {
          if (!isDuplicate(m.name, MedicationEntryType.limitation.name)) {
            await repo.insertMedication(MedicationEntriesCompanion.insert(
              directiveId: id,
              entryType: MedicationEntryType.limitation.name,
              medicationName: Value(m.name),
              reason: Value(m.reason),
              sortOrder: Value(order++),
            ));
            trackInserted(m.name, MedicationEntryType.limitation.name);
          }
        }
      }

      // AI-suggested medications to avoid → exceptions
      if (a['Additional Medications to Avoid'] == true) {
        for (final m in r.additionalMedsToAvoid) {
          if (!isDuplicate(m.name, MedicationEntryType.exception.name)) {
            await repo.insertMedication(MedicationEntriesCompanion.insert(
              directiveId: id,
              entryType: MedicationEntryType.exception.name,
              medicationName: Value(m.name),
              reason: Value(m.reason),
              sortOrder: Value(order++),
            ));
            trackInserted(m.name, MedicationEntryType.exception.name);
          }
        }
      }

      // User's explicit selections from step 2
      for (final name in _selectedPreferredMeds) {
        if (!isDuplicate(name, MedicationEntryType.preferred.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.preferred.name,
            medicationName: Value(name),
            sortOrder: Value(order++),
          ));
          trackInserted(name, MedicationEntryType.preferred.name);
        }
      }
      for (final name in _selectedLimitationMeds) {
        if (!isDuplicate(name, MedicationEntryType.limitation.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.limitation.name,
            medicationName: Value(name),
            sortOrder: Value(order++),
          ));
          trackInserted(name, MedicationEntryType.limitation.name);
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
          trackInserted(name, MedicationEntryType.exception.name);
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
          tooltip: 'Close',
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

  List<Widget> _buildGroupedConditionChips(ColorScheme cs) {
    final psychiatric = _selectedConditions
        .where((c) => c.code.startsWith('F'))
        .toList();
    final medical = _selectedConditions
        .where((c) => !c.code.startsWith('F'))
        .toList();
    return [
      if (psychiatric.isNotEmpty) ...[
        Text('Psychiatric',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: psychiatric
              .map((c) => Chip(
                    label:
                        Text(c.name, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () =>
                        setState(() => _selectedConditions.remove(c)),
                    backgroundColor: cs.primaryContainer,
                    labelStyle: TextStyle(color: cs.onPrimaryContainer),
                  ))
              .toList(),
        ),
        const SizedBox(height: 8),
      ],
      if (medical.isNotEmpty) ...[
        Text('Medical',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: medical
              .map((c) => Chip(
                    label:
                        Text(c.name, style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () =>
                        setState(() => _selectedConditions.remove(c)),
                    backgroundColor: cs.tertiaryContainer,
                    labelStyle: TextStyle(color: cs.onTertiaryContainer),
                  ))
              .toList(),
        ),
      ],
    ];
  }

  Widget _buildGroupedCondResults(ColorScheme cs) {
    final psych =
        _condResults.where((c) => c.code.startsWith('F')).toList();
    final med =
        _condResults.where((c) => !c.code.startsWith('F')).toList();

    Widget buildTile(IcdCondition c) {
      final selected = _selectedConditions.any((s) => s.code == c.code);
      return ListTile(
        dense: true,
        leading: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: c.code.startsWith('F')
                ? cs.primaryContainer
                : cs.tertiaryContainer,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            c.code,
            style: TextStyle(
              fontSize: 11,
              fontFamily: 'monospace',
              color: c.code.startsWith('F')
                  ? cs.onPrimaryContainer
                  : cs.onTertiaryContainer,
            ),
          ),
        ),
        title: Text(c.name, style: const TextStyle(fontSize: 14)),
        trailing: selected
            ? Icon(Icons.check_circle, color: cs.primary, size: 20)
            : Icon(Icons.add_circle_outline,
                color: cs.primary, size: 20),
        onTap: () {
          setState(() {
            if (selected) {
              _selectedConditions
                  .removeWhere((s) => s.code == c.code);
            } else if (_selectedConditions.length >=
                SmartFillInput.maxConditions) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Maximum ${SmartFillInput.maxConditions} conditions allowed'),
                ),
              );
            } else {
              _selectedConditions.add(c);
            }
          });
        },
      );
    }

    Widget sectionHeader(String label) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: cs.surfaceContainerHighest,
        child: Text(label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
            )),
      );
    }

    return ListView(
      children: [
        if (psych.isNotEmpty) ...[
          sectionHeader('Psychiatric'),
          ...psych.expand((c) => [
                buildTile(c),
                Divider(height: 1, color: cs.outlineVariant),
              ]),
        ],
        if (med.isNotEmpty) ...[
          sectionHeader('Medical'),
          ...med.expand((c) => [
                buildTile(c),
                Divider(height: 1, color: cs.outlineVariant),
              ]),
        ],
      ],
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
            ..._buildGroupedConditionChips(cs),
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
                : _buildGroupedCondResults(cs),
          ),
          const NlmAttribution(),
        ],
      ),
    );
  }

  // ── Step 2: Medications ─────────────────────────────────────────────

  Widget _buildMedicationsStep() {
    final cs = Theme.of(context).colorScheme;
    final targetList = switch (_medCategory) {
      _MedCategory.preferred => _selectedPreferredMeds,
      _MedCategory.limitations => _selectedLimitationMeds,
      _MedCategory.avoid => _selectedAvoidMeds,
    };
    final targetLabel = switch (_medCategory) {
      _MedCategory.preferred => 'preferred medications',
      _MedCategory.limitations => 'medications with limitations',
      _MedCategory.avoid => 'medications to NEVER give',
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExistingDataCard(),
          // Toggle between categories (matches wizard)
          SegmentedButton<_MedCategory>(
            segments: const [
              ButtonSegment(value: _MedCategory.preferred,
                  label: Text('Preferred', style: TextStyle(fontSize: 12))),
              ButtonSegment(value: _MedCategory.limitations,
                  label: Text('Limitations', style: TextStyle(fontSize: 12))),
              ButtonSegment(value: _MedCategory.avoid,
                  label: Text('Never', style: TextStyle(fontSize: 12))),
            ],
            selected: {_medCategory},
            onSelectionChanged: (v) =>
                setState(() => _medCategory = v.first),
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
          // Selected chips for all three categories
          if (_selectedPreferredMeds.isNotEmpty ||
              _selectedLimitationMeds.isNotEmpty ||
              _selectedAvoidMeds.isNotEmpty) ...[
            const SizedBox(height: 12),
            if (_selectedPreferredMeds.isNotEmpty) ...[
              Text('Preferred:', style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _selectedPreferredMeds
                    .map((m) => Chip(
                          label: Text(m, style: const TextStyle(fontSize: 11)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => _selectedPreferredMeds.remove(m)),
                          backgroundColor: cs.primaryContainer,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            if (_selectedLimitationMeds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Limitations:', style: TextStyle(fontSize: 11, color: cs.tertiary)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: _selectedLimitationMeds
                    .map((m) => Chip(
                          label: Text(m, style: const TextStyle(fontSize: 11)),
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => _selectedLimitationMeds.remove(m)),
                          backgroundColor: cs.tertiaryContainer,
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
            if (_selectedAvoidMeds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Never:', style: TextStyle(fontSize: 11, color: cs.error)),
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
                                  } else if (targetList.length >=
                                      SmartFillInput.maxMedsPerCategory) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Maximum ${SmartFillInput.maxMedsPerCategory} medications per category'),
                                      ),
                                    );
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
                                          } else if (targetList.length >=
                                              SmartFillInput
                                                  .maxMedsPerCategory) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Maximum ${SmartFillInput.maxMedsPerCategory} medications per category'),
                                              ),
                                            );
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
                                              ? (_medCategory == _MedCategory.avoid
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
          final hasConflict = _consentConflicts.contains(key);
          final existingValue = _existingFieldValues[key];

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            color: hasConflict
                ? cs.errorContainer.withValues(alpha: 0.3)
                : checked
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
                      onChanged: hasConflict
                          ? (v) {
                              if (v == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'This conflicts with your consent '
                                      'decision. Change your consent setting '
                                      'first if you want to accept this.',
                                    ),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                              }
                            }
                          : (v) =>
                              setState(() => _accepted![key] = v ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(key,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: hasConflict
                                                ? cs.error
                                                : checked
                                                    ? cs.onSurface
                                                    : cs.onSurfaceVariant,
                                          )),
                                ),
                                if (hasConflict)
                                  Tooltip(
                                    message: 'Conflicts with your consent decision',
                                    child: Icon(Icons.warning_amber_rounded,
                                        size: 18, color: cs.error),
                                  ),
                              ],
                            ),
                            if (hasConflict) ...[
                              const SizedBox(height: 4),
                              Text(
                                'You refused consent for this. This '
                                'suggestion will not be applied.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: cs.error,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            if (existingValue != null) ...[
                              const SizedBox(height: 4),
                              Text('Your current text:',
                                  style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurfaceVariant)),
                              Text(
                                existingValue.length > 120
                                    ? '${existingValue.substring(0, 120)}...'
                                    : existingValue,
                                style: TextStyle(
                                    fontSize: 11, color: cs.onSurfaceVariant),
                              ),
                              Text('AI will add to your text, not replace it.',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: cs.primary,
                                      fontStyle: FontStyle.italic)),
                              const SizedBox(height: 4),
                            ],
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
                onPressed: (_selectedPreferredMeds.isEmpty &&
                        _selectedLimitationMeds.isEmpty &&
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

enum _MedCategory { preferred, limitations, avoid }
