import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/document_extraction_result.dart';
import 'package:mhad/ai/document_extractor.dart';
import 'package:mhad/ai/smart_fill_service.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/clinical_data_validator.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';
import 'package:mhad/ui/widgets/nlm_attribution.dart';
import 'package:mhad/ui/wizard/widgets/document_import_sheet.dart';

/// Launches the integrated document → validate → smart fill pipeline.
/// Returns true if data was applied.
Future<bool?> showDocumentPipelineFlow(
  BuildContext context, {
  required int directiveId,
  required String formType,
}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _PipelineScreen(
        directiveId: directiveId,
        formType: formType,
      ),
    ),
  );
}

class _PipelineScreen extends ConsumerStatefulWidget {
  final int directiveId;
  final String formType;
  const _PipelineScreen({required this.directiveId, required this.formType});

  @override
  ConsumerState<_PipelineScreen> createState() => _PipelineScreenState();
}

enum _PipelineStep { pick, extracting, validating, review, generating, results }

class _PipelineScreenState extends ConsumerState<_PipelineScreen> {
  _PipelineStep _step = _PipelineStep.pick;
  String _statusMessage = '';
  String? _error;

  // PII
  List<String> _piiStripped = [];

  // Validated extraction
  ValidatedExtractionResult? _validated;
  Map<String, bool> _reviewChecked = {};
  Map<String, String> _reviewEdited = {};

  // Smart Fill results
  SmartFillResult? _smartResult;
  Map<String, bool> _smartChecked = {};
  Map<String, String> _smartEdited = {};

  // ── Pipeline orchestration ──────────────────────────────────────────

  Future<void> _startPipeline(List<PickedDocument> docs) async {
    // AI consent
    if (!ref.read(aiConsentGivenProvider)) {
      final ok = await showAiConsentDialog(context);
      if (!ok || !mounted) return;
      ref.read(aiConsentGivenProvider.notifier).state = true;
    }

    final apiKey = ref.read(apiKeyProvider).valueOrNull;
    if (apiKey == null || apiKey.isEmpty) return;

    // Warn about PII in image/PDF documents (text files are stripped locally)
    final hasImageOrPdf = docs.any((d) =>
        d.mimeType.startsWith('image/') || d.mimeType == 'application/pdf');
    if (hasImageOrPdf && mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Document Upload Notice'),
          content: const Text(
            'Images and PDFs are sent to Google\'s servers for analysis. '
            'The app cannot strip personal information from images or PDFs '
            'before uploading.\n\n'
            'Only upload documents that do not contain sensitive personal '
            'information (names, SSNs, dates of birth). Medical data '
            '(medications, conditions) is safe to include.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Upload Anyway'),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    // ── Pre-flight: check rate limits and file sizes ────
    final tracker = ref.read(geminiRateTrackerProvider);

    // Each page = 1 API request. Check if we have enough RPM/RPD budget.
    final pagesNeeded = docs.length;
    if (tracker.remainingRpm < pagesNeeded) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Processing $pagesNeeded pages requires $pagesNeeded requests, '
              'but only ${tracker.remainingRpm} requests are available this '
              'minute. Please wait ${tracker.secondsUntilRpmSlot} seconds '
              'or select fewer pages.',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return;
    }
    if (tracker.remainingRpd < pagesNeeded) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Processing $pagesNeeded pages requires $pagesNeeded requests, '
              'but only ${tracker.remainingRpd} requests remain today '
              '(daily limit: ${GeminiRateTracker.maxRpd}).',
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
      return;
    }

    // Check for oversized files (>10MB per file — Gemini limit for inline data)
    const maxFileSizeBytes = 10 * 1024 * 1024; // 10 MB
    for (final doc in docs) {
      if (doc.bytes != null && doc.bytes!.length > maxFileSizeBytes) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'File "${doc.path.split('/').last}" is too large '
                '(${(doc.bytes!.length / 1024 / 1024).toStringAsFixed(1)} MB). '
                'Maximum file size is 10 MB per document.',
              ),
              duration: const Duration(seconds: 5),
            ),
          );
        }
        return;
      }
    }

    // ── Step 1: Extract each page one at a time, merge results ────
    setState(() {
      _step = _PipelineStep.extracting;
      _statusMessage = 'Extracting page 1 of ${docs.length}...';
    });

    try {
      final extractor = DocumentExtractor(apiKey: apiKey);
      DocumentExtractionResult? merged;
      final allPii = <String>[];

      for (var i = 0; i < docs.length; i++) {
        if (!mounted) return;
        setState(() {
          _statusMessage = docs.length > 1
              ? 'Extracting page ${i + 1} of ${docs.length}...'
              : 'Extracting medical data from document...';
        });

        // Read bytes from PickedDocument (pre-loaded on web, may need file read on native)
        final docBytes = docs[i].bytes;
        if (docBytes == null) continue;

        final extraction = await extractor.extractFromBytes(
          docBytes,
          mimeType: docs[i].mimeType,
        );

        // Record this extraction in the rate tracker
        // Images: ~258 tokens per 768x768 tile; 1024px image ≈ 2 tiles ≈ 516 tokens
        // PDFs: ~500 tokens per page estimate
        // Text: chars / 4
        final estimatedTokens = docs[i].mimeType.startsWith('image/')
            ? 800 // prompt + ~2 image tiles
            : docs[i].mimeType == 'application/pdf'
                ? 1500 // prompt + PDF page
                : GeminiRateTracker.estimateTokens(docBytes.length) + 500;
        tracker.recordRequest(estimatedTokens: estimatedTokens);

        allPii.addAll(extraction.strippedPiiCategories);

        if (merged == null) {
          merged = extraction.result;
        } else {
          merged = merged.merge(extraction.result);
        }
      }

      if (!mounted) return;
      _piiStripped = allPii;

      if (merged == null || merged.isEmpty) {
        setState(() {
          _error = 'No medical information found in '
              '${docs.length == 1 ? 'this document' : 'these ${docs.length} pages'}.';
          _step = _PipelineStep.pick;
        });
        return;
      }

      // ── Step 2: Validate against NIH APIs ───────────────────────
      setState(() {
        _step = _PipelineStep.validating;
        _statusMessage = 'Validating medications and conditions...';
      });

      final validated = await ClinicalDataValidator.validate(merged);
      if (!mounted) return;

      // Build review data
      _validated = validated;
      _buildReviewData(validated);

      setState(() => _step = _PipelineStep.review);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = FriendlyError.from(e);
          _step = _PipelineStep.pick;
        });
      }
    }
  }

  void _buildReviewData(ValidatedExtractionResult v) {
    _reviewChecked = {};
    _reviewEdited = {};

    for (final m in v.preferredMeds) {
      final key = 'med_prefer_${m.originalName}';
      _reviewChecked[key] = true;
      final badge = m.isValidated ? ' [RxNorm verified]' : ' [unverified]';
      final reason = m.reason.isNotEmpty ? ' — ${m.reason}' : '';
      _reviewEdited[key] = '${m.displayName}$reason$badge';
    }
    for (final m in v.avoidMeds) {
      final key = 'med_avoid_${m.originalName}';
      _reviewChecked[key] = true;
      final badge = m.isValidated ? ' [RxNorm verified]' : ' [unverified]';
      final reason = m.reason.isNotEmpty ? ' — ${m.reason}' : '';
      _reviewEdited[key] = '${m.displayName}$reason$badge';
    }
    for (final c in v.conditions) {
      final key = 'cond_${c.originalText}';
      _reviewChecked[key] = true;
      final badge =
          c.isValidated ? ' [${c.code}]' : ' [no ICD match]';
      _reviewEdited[key] = '${c.displayName}$badge';
    }
    for (final c in v.healthHistoryConditions) {
      final key = 'hh_${c.originalText}';
      _reviewChecked[key] = true;
      final badge =
          c.isValidated ? ' [${c.code}]' : ' [no ICD match]';
      _reviewEdited[key] = '${c.displayName}$badge';
    }
    // Pass-through text fields
    if (v.preferredFacility != null) {
      _reviewChecked['facility_prefer'] = true;
      _reviewEdited['facility_prefer'] = v.preferredFacility!;
    }
    if (v.avoidFacility != null) {
      _reviewChecked['facility_avoid'] = true;
      _reviewEdited['facility_avoid'] = v.avoidFacility!;
    }
    if (v.dietary != null) {
      _reviewChecked['dietary'] = true;
      _reviewEdited['dietary'] = v.dietary!;
    }
    if (v.religious != null) {
      _reviewChecked['religious'] = true;
      _reviewEdited['religious'] = v.religious!;
    }
    if (v.activities != null) {
      _reviewChecked['activities'] = true;
      _reviewEdited['activities'] = v.activities!;
    }
    if (v.crisisIntervention != null) {
      _reviewChecked['crisis'] = true;
      _reviewEdited['crisis'] = v.crisisIntervention!;
    }
    if (v.other != null) {
      _reviewChecked['other'] = true;
      _reviewEdited['other'] = v.other!;
    }
  }

  // ── Smart Fill generation ───────────────────────────────────────────

  Future<void> _runSmartFill() async {
    final apiKey = ref.read(apiKeyProvider).valueOrNull;
    if (apiKey == null || _validated == null) return;

    setState(() {
      _step = _PipelineStep.generating;
      _statusMessage = 'AI is generating personalized suggestions...';
    });

    try {
      final service = SmartFillService(apiKey: apiKey);
      final result = await service.generate(SmartFillInput(
        conditions: _validated!.icdConditions,
        currentMedications: _validated!.validatedPreferredMedNames,
        medicationsToAvoid: _validated!.validatedAvoidMedNames,
        formType: widget.formType,
      ));

      if (!mounted) return;

      if (result.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI could not generate additional suggestions.')),
        );
        // Fall through to apply just the extracted data
        await _applyAll();
        return;
      }

      final display = result.toDisplayMap();
      _smartResult = result;
      _smartChecked = {for (final k in display.keys) k: true};
      _smartEdited = Map<String, String>.from(display);

      setState(() => _step = _PipelineStep.results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Smart Fill failed: $e')),
        );
        // Still apply extracted data
        await _applyAll();
      }
    }
  }

  // ── Apply everything ────────────────────────────────────────────────

  Future<void> _applyAll() async {
    final repo = ref.read(directiveRepositoryProvider);
    final id = widget.directiveId;

    // ── Apply extracted + validated data ─────────────────────────────
    final existingMeds = await repo.watchMedications(id).first;
    int medOrder = existingMeds.length;

    // Dedup: compare full name (including dosage/form) AND entry type.
    // "Sertraline 50 MG" and "Sertraline 100 MG" are different entries.
    // Same drug in "preferred" and "avoid" are both allowed (different intent).
    bool medExists(String name, String entryType) {
      return existingMeds.any((m) =>
          m.medicationName.toLowerCase() == name.toLowerCase() &&
          m.entryType == entryType);
    }

    for (final entry in _reviewChecked.entries) {
      if (!entry.value) continue;
      final key = entry.key;

      if (key.startsWith('med_prefer_')) {
        final med = _validated!.preferredMeds
            .firstWhere((m) => 'med_prefer_${m.originalName}' == key);
        if (!medExists(med.displayName, MedicationEntryType.preferred.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.preferred.name,
            medicationName: Value(med.displayName),
            reason: Value(med.reason),
            sortOrder: Value(medOrder++),
          ));
        }
      } else if (key.startsWith('med_avoid_')) {
        final med = _validated!.avoidMeds
            .firstWhere((m) => 'med_avoid_${m.originalName}' == key);
        if (!medExists(med.displayName, MedicationEntryType.exception.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.exception.name,
            medicationName: Value(med.displayName),
            reason: Value(med.reason),
            sortOrder: Value(medOrder++),
          ));
        }
      } else if (key == 'facility_prefer') {
        await repo.upsertPreferences(DirectivePrefsCompanion(
          directiveId: Value(id),
          treatmentFacilityPref: Value(TreatmentFacilityPreference.prefer.name),
          preferredFacilityName: Value(_reviewEdited[key] ?? ''),
        ));
      } else if (key == 'facility_avoid') {
        await repo.upsertPreferences(DirectivePrefsCompanion(
          directiveId: Value(id),
          treatmentFacilityPref: Value(TreatmentFacilityPreference.avoid.name),
          avoidFacilityName: Value(_reviewEdited[key] ?? ''),
        ));
      }
    }

    // Write conditions to effective condition field
    final condNames = _validated!.conditions
        .where((c) => _reviewChecked['cond_${c.originalText}'] == true)
        .map((c) => c.displayName)
        .toList();
    if (condNames.isNotEmpty) {
      final directive = await repo.getDirectiveById(id);
      if (directive != null && directive.effectiveCondition.isEmpty) {
        await repo.updateEffectiveCondition(
          id,
          'This directive becomes effective when I am unable to make mental '
          'health treatment decisions as determined by qualified professionals. '
          'Relevant conditions: ${condNames.join(", ")}.',
        );
      }
    }

    // Additional instruction text fields
    final instrMap = <String, String>{};
    void addInstr(String reviewKey, String instrField) {
      if (_reviewChecked[reviewKey] == true &&
          _reviewEdited[reviewKey] != null) {
        instrMap[instrField] = _reviewEdited[reviewKey]!;
      }
    }

    // Health history from validated conditions
    final hhNames = _validated!.healthHistoryConditions
        .where((c) => _reviewChecked['hh_${c.originalText}'] == true)
        .map((c) => c.displayName)
        .toList();
    if (hhNames.isNotEmpty) {
      instrMap['healthHistory'] = hhNames.join('; ');
    }

    addInstr('dietary', 'dietary');
    addInstr('religious', 'religious');
    addInstr('activities', 'activities');
    addInstr('crisis', 'crisisIntervention');
    addInstr('other', 'other');

    // ── Apply Smart Fill results ─────────────────────────────────────
    if (_smartResult != null && _smartEdited.isNotEmpty) {
      String? smartVal(String key) {
        if (_smartChecked[key] != true) return null;
        final t = _smartEdited[key]?.trim();
        return (t != null && t.isNotEmpty) ? t : null;
      }

      // Smart Fill effective condition (only if not already set by extraction)
      final ec = smartVal('Effective Condition');
      if (ec != null && condNames.isEmpty) {
        final d = await repo.getDirectiveById(id);
        if (d != null && d.effectiveCondition.isEmpty) {
          await repo.updateEffectiveCondition(id, ec);
        }
      }

      final hh = smartVal('Health History');
      if (hh != null) {
        instrMap['healthHistory'] = instrMap.containsKey('healthHistory')
            ? '${instrMap['healthHistory']}\n$hh'
            : hh;
      }
      final ci = smartVal('Crisis Intervention');
      if (ci != null) {
        instrMap['crisisIntervention'] =
            instrMap.containsKey('crisisIntervention')
                ? '${instrMap['crisisIntervention']}\n$ci'
                : ci;
      }
      final act = smartVal('Helpful Activities');
      if (act != null) {
        instrMap['activities'] = instrMap.containsKey('activities')
            ? '${instrMap['activities']}\n$act'
            : act;
      }
      final diet = smartVal('Dietary Considerations');
      if (diet != null) {
        instrMap['dietary'] = instrMap.containsKey('dietary')
            ? '${instrMap['dietary']}\n$diet'
            : diet;
      }
      final ag = smartVal('Agent Guidance');
      if (ag != null) {
        instrMap['other'] = instrMap.containsKey('other')
            ? '${instrMap['other']}\n$ag'
            : ag;
      }

      // AI-suggested additional meds
      if (_smartChecked['Additional Medications to Consider'] == true) {
        for (final m in _smartResult!.additionalMedsToConsider) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.preferred.name,
            medicationName: Value(m.name),
            reason: Value(m.reason),
            sortOrder: Value(medOrder++),
          ));
        }
      }
      if (_smartChecked['Additional Medications to Avoid'] == true) {
        for (final m in _smartResult!.additionalMedsToAvoid) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.exception.name,
            medicationName: Value(m.name),
            reason: Value(m.reason),
            sortOrder: Value(medOrder++),
          ));
        }
      }
    }

    // Write all accumulated instruction fields
    if (instrMap.isNotEmpty) {
      final existing = await repo.getAdditionalInstructions(id);
      String merge(String? old, String? add) {
        if (add == null) return old ?? '';
        if (old == null || old.trim().isEmpty) return add;
        return '$old\n$add';
      }

      await repo.upsertAdditionalInstructions(
        AdditionalInstructionsTableCompanion(
          directiveId: Value(id),
          healthHistory: instrMap.containsKey('healthHistory')
              ? Value(merge(existing?.healthHistory, instrMap['healthHistory']))
              : const Value.absent(),
          dietary: instrMap.containsKey('dietary')
              ? Value(merge(existing?.dietary, instrMap['dietary']))
              : const Value.absent(),
          religious: instrMap.containsKey('religious')
              ? Value(merge(existing?.religious, instrMap['religious']))
              : const Value.absent(),
          activities: instrMap.containsKey('activities')
              ? Value(merge(existing?.activities, instrMap['activities']))
              : const Value.absent(),
          crisisIntervention: instrMap.containsKey('crisisIntervention')
              ? Value(merge(
                  existing?.crisisIntervention, instrMap['crisisIntervention']))
              : const Value.absent(),
          other: instrMap.containsKey('other')
              ? Value(merge(existing?.other, instrMap['other']))
              : const Value.absent(),
        ),
      );
    }

    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _editField(String key) async {
    final controller = TextEditingController(text: _reviewEdited[key]);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_displayLabel(key)),
        content: TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
        _reviewEdited[key] = result;
        if (result.trim().isNotEmpty) _reviewChecked[key] = true;
      });
    }
  }

  Future<void> _editSmartField(String key) async {
    final controller = TextEditingController(text: _smartEdited[key]);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(key),
        content: TextField(
          controller: controller,
          maxLines: null,
          minLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
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
        _smartEdited[key] = result;
        if (result.trim().isNotEmpty) _smartChecked[key] = true;
      });
    }
  }

  String _displayLabel(String key) {
    if (key.startsWith('med_prefer_')) return 'Preferred Medication';
    if (key.startsWith('med_avoid_')) return 'Medication to Avoid';
    if (key.startsWith('cond_')) return 'Condition';
    if (key.startsWith('hh_')) return 'Health History';
    if (key == 'facility_prefer') return 'Preferred Facility';
    if (key == 'facility_avoid') return 'Facility to Avoid';
    if (key == 'dietary') return 'Dietary';
    if (key == 'religious') return 'Religious/Cultural';
    if (key == 'activities') return 'Activities';
    if (key == 'crisis') return 'Crisis Intervention';
    if (key == 'other') return 'Other';
    return key;
  }

  String _sectionLabel(String key) {
    if (key.startsWith('med_prefer_')) return 'Preferred Meds';
    if (key.startsWith('med_avoid_')) return 'Meds to Avoid';
    if (key.startsWith('cond_')) return 'Conditions';
    if (key.startsWith('hh_')) return 'Health History';
    return 'Other';
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isProcessing = _step == _PipelineStep.extracting ||
        _step == _PipelineStep.validating ||
        _step == _PipelineStep.generating;

    return PopScope(
      canPop: !isProcessing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && isProcessing) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please wait while processing...')),
          );
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: Text(_title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: isProcessing
              ? null
              : () => Navigator.pop(context, false),
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_step.index + 1) / _PipelineStep.values.length,
            backgroundColor: cs.surfaceContainerHighest,
          ),
          Semantics(
            liveRegion: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                _title,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
      bottomNavigationBar: _buildBottom(),
    ),
    );
  }

  String get _title => switch (_step) {
        _PipelineStep.pick => 'Import Document',
        _PipelineStep.extracting || _PipelineStep.validating => 'Processing',
        _PipelineStep.review => 'Review Extracted Data',
        _PipelineStep.generating => 'Generating Suggestions',
        _PipelineStep.results => 'AI Suggestions',
      };

  Widget _buildBody() {
    return switch (_step) {
      _PipelineStep.pick => _buildPickStep(),
      _PipelineStep.extracting || _PipelineStep.validating =>
        _buildProcessingStep(),
      _PipelineStep.review => _buildReviewStep(),
      _PipelineStep.generating => _buildProcessingStep(),
      _PipelineStep.results => _buildResultsStep(),
    };
  }

  // ── Pick ─────────────────────────────────────────────────────────────

  Widget _buildPickStep() {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.document_scanner, size: 64, color: cs.primary),
          const SizedBox(height: 16),
          Text('Import a medical document',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'The app will extract medications and conditions, validate them '
            'against clinical databases, then use AI to fill remaining fields.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(_error!,
                      style: TextStyle(color: cs.onErrorContainer)),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () async {
                      setState(() => _error = null);
                      final docs = await showDocumentPickerSheet(context);
                      if (docs != null && docs.isNotEmpty && mounted) _startPipeline(docs);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () async {
              final doc = await showDocumentPickerSheet(context);
              if (doc != null && mounted) _startPipeline(doc);
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Choose Document'),
          ),
        ],
      ),
    );
  }

  // ── Processing ──────────────────────────────────────────────────────

  Widget _buildProcessingStep() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_statusMessage),
          if (_piiStripped.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PII removed: ${_piiStripped.toSet().join(", ")}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Review extracted data ───────────────────────────────────────────

  Widget _buildReviewStep() {
    final cs = Theme.of(context).colorScheme;
    final keys = _reviewEdited.keys.toList();

    // Group by section
    String? lastSection;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_piiStripped.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.shield, size: 16, color: cs.onPrimaryContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PII was detected and removed before analysis: '
                    '${_piiStripped.toSet().join(", ")}',
                    style: TextStyle(
                        fontSize: 12, color: cs.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Tap any item to edit. Medications and conditions have been '
            'validated against NIH clinical databases. Uncheck items you '
            'do not want.',
            style: TextStyle(
                fontSize: 12,
                color: cs.onTertiaryContainer,
                fontStyle: FontStyle.italic),
          ),
        ),
        ...keys.map((key) {
          final section = _sectionLabel(key);
          final showHeader = section != lastSection;
          lastSection = section;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader)
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(section,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w600,
                          )),
                ),
              Card(
                margin: const EdgeInsets.only(bottom: 6),
                color: (_reviewChecked[key] ?? false)
                    ? cs.surfaceContainerLow
                    : cs.surfaceContainerHighest.withValues(alpha: 0.5),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _editField(key),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _reviewChecked[key] ?? false,
                          onChanged: (v) => setState(
                              () => _reviewChecked[key] = v ?? false),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_displayLabel(key),
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: cs.onSurfaceVariant)),
                                const SizedBox(height: 2),
                                Text(
                                  _reviewEdited[key] ?? '',
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Icon(Icons.edit, size: 14, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        const NlmAttribution(),
      ],
    );
  }

  // ── Smart Fill results ──────────────────────────────────────────────

  Widget _buildResultsStep() {
    final cs = Theme.of(context).colorScheme;
    final keys = _smartEdited.keys.toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cs.tertiaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'The AI generated these additional suggestions based on your '
            'validated conditions and medications. Tap to edit, uncheck '
            'to skip. This is not medical or legal advice.',
            style: TextStyle(
                fontSize: 12,
                color: cs.onTertiaryContainer,
                fontStyle: FontStyle.italic),
          ),
        ),
        ...keys.map((key) {
          final checked = _smartChecked[key] ?? false;
          return Card(
            margin: const EdgeInsets.only(bottom: 6),
            color: checked
                ? cs.surfaceContainerLow
                : cs.surfaceContainerHighest.withValues(alpha: 0.5),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _editSmartField(key),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: checked,
                      onChanged: (v) =>
                          setState(() => _smartChecked[key] = v ?? false),
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
                                          : cs.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Text(
                              _smartEdited[key] ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: checked
                                        ? cs.onSurface
                                        : cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Icon(Icons.edit, size: 14, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── Bottom bar ──────────────────────────────────────────────────────

  Widget? _buildBottom() {
    if (_step == _PipelineStep.pick ||
        _step == _PipelineStep.extracting ||
        _step == _PipelineStep.validating ||
        _step == _PipelineStep.generating) {
      return null;
    }

    final checkedCount = _step == _PipelineStep.review
        ? _reviewChecked.values.where((v) => v).length
        : _smartChecked.values.where((v) => v).length;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            if (_step == _PipelineStep.results)
              OutlinedButton(
                onPressed: () => setState(() => _step = _PipelineStep.review),
                child: const Text('Back'),
              ),
            const Spacer(),
            if (_step == _PipelineStep.review) ...[
              // Option to skip Smart Fill and just apply extracted data
              OutlinedButton(
                onPressed: checkedCount > 0 ? _applyAll : null,
                child: const Text('Apply Only'),
              ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed:
                    (_validated?.hasValidatedConditions == true ||
                            _validated?.hasValidatedMeds == true)
                        ? _runSmartFill
                        : null,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Generate More'),
              ),
            ],
            if (_step == _PipelineStep.results)
              FilledButton.icon(
                onPressed: _applyAll,
                icon: const Icon(Icons.check),
                label: const Text('Apply All'),
              ),
          ],
        ),
      ),
    );
  }
}
