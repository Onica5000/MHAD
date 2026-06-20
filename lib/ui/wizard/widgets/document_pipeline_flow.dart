import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/document_extraction_result.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/ai/document_extractor.dart';
import 'package:mhad/ai/smart_fill_service.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/services/clinical_data_validator.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';
import 'package:mhad/ui/widgets/nlm_attribution.dart';
import 'package:mhad/ui/wizard/widgets/document_import_sheet.dart';
import 'package:mhad/ui/wizard/widgets/pipeline_reconciliation.dart';
import 'package:mhad/utils/clipboard_paste.dart';
import 'package:mhad/utils/platform_utils.dart';

/// How [PipelineScreen] is presented:
///   * [modal] — pushed over the wizard as a fullscreen dialog; closing pops
///     back, applying pops with `true`.
///   * [standalone] — a routed page (`/upload/:id`) reached BEFORE the wizard;
///     applying or skipping navigates on into the wizard, and "set up AI"
///     pushes the setup route (never pops the page off the router stack).
enum PipelineMode { modal, standalone }

/// Launches the integrated document → validate → smart fill pipeline as a
/// modal over the wizard. Returns true if data was applied.
Future<bool?> showDocumentPipelineFlow(
  BuildContext context, {
  required int directiveId,
  required String formType,
}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => PipelineScreen(
        directiveId: directiveId,
        formType: formType,
      ),
    ),
  );
}

/// The snap-to-fill / upload-to-fill screen. Used BOTH as a wizard modal
/// ([PipelineMode.modal]) and as the standalone pre-wizard `/upload/:id` page
/// ([PipelineMode.standalone]).
class PipelineScreen extends ConsumerStatefulWidget {
  final int directiveId;
  final String formType;
  final PipelineMode mode;
  const PipelineScreen({
    required this.directiveId,
    required this.formType,
    this.mode = PipelineMode.modal,
    super.key,
  });

  @override
  ConsumerState<PipelineScreen> createState() => _PipelineScreenState();
}

enum _PipelineStep { pick, extracting, validating, review, generating, results }

class _PipelineScreenState extends ConsumerState<PipelineScreen> {
  bool get _standalone => widget.mode == PipelineMode.standalone;

  /// Standalone: leave the /upload page for the wizard. The directive already
  /// holds whatever fields were applied this session.
  void _toWizard() {
    if (!mounted) return;
    appRouter.go(AppRoutes.wizardRoute(widget.directiveId));
  }

  /// Skip / close / back. Standalone → into the wizard; modal → pop(false).
  void _exit() {
    if (!mounted) return;
    if (_standalone) {
      _toWizard();
    } else {
      Navigator.pop(context, false);
    }
  }

  /// Called once extracted fields are written to the directive. Both modes
  /// land the user in the wizard so they can verify the autofill: the modal
  /// pops back to the wizard it was opened over; the standalone /upload page
  /// navigates into the wizard (via the "Autofill Information" button).
  void _onApplied(int appliedCount) {
    if (!mounted) return;
    if (_standalone) {
      _toWizard();
    } else {
      Navigator.pop(context, true);
    }
  }

  /// Discard the current extraction without writing anything. Standalone →
  /// back to the pick step (session files kept); modal → pop(false).
  void _discardExtraction() {
    if (!mounted) return;
    if (!_standalone) {
      Navigator.pop(context, false);
      return;
    }
    setState(() {
      _resetExtraction();
      _step = _PipelineStep.pick;
    });
  }

  void _resetExtraction() {
    _validated = null;
    _reviewChecked = {};
    _reviewEdited = {};
    _smartResult = null;
    _smartChecked = {};
    _smartEdited = {};
    _piiStripped = [];
    _sourceDocs = const [];
    // Reset only the EXTRACTION state, not the source documents. The held
    // batch stays in `_pendingDocs` so the documents survive an AI read (and a
    // discard/back to the pick step) — they are kept in memory until the user
    // explicitly clears the tray ("Clear all") or the page is reset (the tab
    // is closed / the user navigates into the wizard, which disposes this
    // screen). This lets the user re-read the same documents without
    // re-selecting them.
    _error = null;
  }

  String _docName(PickedDocument d) {
    if (d.path == 'pasted-image') return 'Pasted image';
    final base = d.path.replaceAll('\\', '/').split('/').last;
    return base.isNotEmpty ? base : 'Document';
  }

  String _docKind(PickedDocument d) {
    if (d.mimeType == 'application/pdf') return 'PDF';
    if (d.mimeType.startsWith('image/')) return 'Photo';
    if (d.mimeType.startsWith('text/')) return 'Text';
    return 'File';
  }
  _PipelineStep _step = _PipelineStep.pick;
  String _statusMessage = '';
  String? _error;

  // True while a file is being dragged over the Snap-to-fill drop zone.
  bool _dragOver = false;

  // The documents being processed — retained so the review step can show a
  // source thumbnail of what the AI read.
  List<PickedDocument> _sourceDocs = const [];

  // Standalone only: files brought in across this session, accumulated so the
  // pick step can show the artboard "In this session · N FILES" row. A file is
  // recorded once its extracted fields are applied (see _returnToPickWithFile);
  // cleared when the tab closes (web in-memory). Modal mode pops after a single
  // apply, so this stays empty there.
  final List<_SessionFile> _sessionFiles = [];

  // Documents the user has selected/dropped/pasted/snapped but NOT yet sent to
  // the AI. They're held here (in-memory, this session only) and shown as a
  // pending tray on the pick step; the extractor/AI is only called when the
  // user explicitly taps "Read with AI" (see _readPendingDocs). This is the
  // select → store → hold → send pipeline — selecting a file no longer fires
  // the AI automatically.
  final List<PickedDocument> _pendingDocs = [];

  // Clipboard-paste listener disposer (web only).
  void Function()? _pasteDisposer;

  @override
  void initState() {
    super.initState();
    // ⌘V / Ctrl+V to paste an image into the Snap-to-fill zone (web). The
    // pasted image is HELD in the pending tray, not sent to the AI yet.
    _pasteDisposer = registerImagePaste((bytes, mime) {
      if (!mounted || _step != _PipelineStep.pick) return;
      _addPending([
        PickedDocument(
          path: 'pasted-image',
          mimeType: mime,
          bytes: Uint8List.fromList(bytes),
        ),
      ]);
    });
  }

  @override
  void dispose() {
    _pasteDisposer?.call();
    super.dispose();
  }

  // Route to AI setup, closing this snap-to-fill dialog first. Used when
  // extraction is attempted or requested without a Gemini key set.
  void _goAiSetup() {
    // Modal: close the dialog first, then plain setup (back returns to the
    // wizard). Standalone: pass this /upload route as the return target so
    // saving the key lands the user back here, not in the assistant chat.
    if (!_standalone) {
      Navigator.of(context).pop();
      appRouter.push(AppRoutes.aiSetup);
      return;
    }
    final ret = Uri.encodeComponent(AppRoutes.uploadRoute(widget.directiveId));
    appRouter.push('${AppRoutes.aiSetup}?return=$ret');
  }

  Future<void> _promptAiSetup() async {
    final goSetup = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.auto_awesome, size: 36),
        title: const Text('Set up AI to read documents'),
        content: const Text(
          'Snap-to-fill uses AI to read your uploaded document (photo, PDF, or '
          'text) and pull out details to fill your form — medications, '
          'conditions, care preferences, and your contact details. It needs a '
          'free Gemini key — about 30 seconds to set up. You review every field '
          'before anything lands in your form.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Set up AI'),
          ),
        ],
      ),
    );
    if (goSetup == true && mounted) _goAiSetup();
  }

  // Allowed dropped/pasted file extensions → mime type.
  static const _allowedMime = <String, String>{
    'pdf': 'application/pdf',
    'txt': 'text/plain',
    'csv': 'text/csv',
    'png': 'image/png',
    'webp': 'image/webp',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'heic': 'image/heic',
  };

  String? _mimeForName(String name) {
    final dot = name.lastIndexOf('.');
    if (dot < 0) return null;
    return _allowedMime[name.substring(dot + 1).toLowerCase()];
  }

  Future<void> _handleDroppedFiles(List<XFile> files) async {
    setState(() {
      _dragOver = false;
      _error = null;
    });
    if (files.isEmpty) return;
    final docs = <PickedDocument>[];
    for (final f in files) {
      final mime = _mimeForName(f.name);
      if (mime == null) continue; // skip unsupported types
      final bytes = await f.readAsBytes();
      docs.add(PickedDocument(
        // Use the original file NAME for display. On web, dropped XFiles carry
        // a blob: URL in `path`, which would show as gibberish in the tray;
        // `name` is the real filename and the bytes are already loaded, so the
        // path isn't needed for reading.
        path: f.name.isNotEmpty ? f.name : 'Dropped file',
        mimeType: mime,
        bytes: bytes,
      ));
    }
    if (!mounted) return;
    if (docs.isEmpty) {
      setState(() => _error =
          'That file type isn\'t supported. Use a JPG, PNG, HEIC, PDF, or '
          'text file.');
      return;
    }
    _addPending(docs);
  }

  // PII
  List<String> _piiStripped = [];

  // Validated extraction
  ValidatedExtractionResult? _validated;
  Map<String, bool> _reviewChecked = {};
  Map<String, String> _reviewEdited = {};

  /// Reconciliation items (priority + conflict) for the review step, built from
  /// the extracted values vs the directive's current values.
  List<ReconItem> _reconItems = [];

  // Smart Fill results
  SmartFillResult? _smartResult;
  Map<String, bool> _smartChecked = {};
  Map<String, String> _smartEdited = {};

  // ── Pipeline orchestration ──────────────────────────────────────────

  Future<void> _startPipeline(List<PickedDocument> docs) async {
    _sourceDocs = docs;

    // Extraction needs a Gemini key. On web (public mode) the user often has
    // none — prompt to set it up rather than silently doing nothing, so the
    // snap-to-fill page never feels like a dead end.
    final apiKey = ref.read(apiKeyProvider).valueOrNull;
    if (apiKey == null || apiKey.isEmpty) {
      await _promptAiSetup();
      return;
    }

    // AI consent
    if (!ref.read(aiConsentGivenProvider)) {
      final ok = await showAiConsentDialog(context);
      if (!ok || !mounted) return;
      ref.read(aiConsentGivenProvider.notifier).state = true;
    }

    // Heads-up before any upload: the whole document — including personal
    // details — is sent to Google's AI so it can READ and autofill your
    // directive (your name, address, your agent's details, etc.). This applies
    // to every file type now: images, PDFs, and text are all sent as-is so the
    // AI can fill those fields. Nothing is saved until you review and apply.
    if (mounted) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.privacy_tip_outlined),
          title: const Text('Heads up'),
          content: const Text(
            'To autofill your directive, the whole document — including any '
            'personal details (names, dates of birth, addresses, phone '
            'numbers) — is sent to Google\'s AI so it can read it. You\'ll '
            'review everything before anything is saved.\n\n'
            'Uploading is only a shortcut, never required:\n'
            '• Black out anything you don\'t want sent (ID or card numbers, '
            'other people\'s details) before uploading.\n'
            '• Every field can be typed in by hand instead, to keep it '
            'private.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Upload anyway'),
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

    // Check for oversized files (Gemini limit for inline data; from config)
    final maxFileSizeBytes = appData.config.maxUploadBytes;
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

      // Build review data + reconcile against the directive's current values
      _validated = validated;
      _buildReviewData(validated);
      await _buildReconciliation();
      if (!mounted) return;

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
    // Health history is verbatim prose (one reviewable note), not split into
    // ICD-matched fragments — preserves everything the document said.
    if (v.healthHistory != null) {
      _reviewChecked['hh_note'] = true;
      _reviewEdited['hh_note'] = v.healthHistory!;
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
    if (v.petCustody != null) {
      _reviewChecked['pet_custody'] = true;
      _reviewEdited['pet_custody'] = v.petCustody!;
    }
    if (v.childrenCustody != null) {
      _reviewChecked['children_custody'] = true;
      _reviewEdited['children_custody'] = v.childrenCustody!;
    }
    if (v.familyNotification != null) {
      _reviewChecked['family_notification'] = true;
      _reviewEdited['family_notification'] = v.familyNotification!;
    }
    if (v.recordsDisclosure != null) {
      _reviewChecked['records_disclosure'] = true;
      _reviewEdited['records_disclosure'] = v.recordsDisclosure!;
    }
    if (v.other != null) {
      _reviewChecked['other'] = true;
      _reviewEdited['other'] = v.other!;
    }

    // ── Diagnoses — one review key per diagnosis
    for (final d in v.diagnoses) {
      final key = 'diag_${d.name}';
      _reviewChecked[key] = true;
      _reviewEdited[key] = d.display;
    }

    // ── Allergies — one review key per allergy
    for (final a in v.allergies) {
      final key = 'allergy_${a.substance}';
      _reviewChecked[key] = true;
      _reviewEdited[key] = a.display;
    }

    // ── Currently-taking medications (reference list)
    for (final m in v.currentMeds) {
      final key = 'med_current_${m.originalName}';
      _reviewChecked[key] = true;
      final badge = m.isValidated ? ' [RxNorm verified]' : ' [unverified]';
      _reviewEdited[key] = '${m.displayName}$badge';
    }

    // ── Medication limitations
    for (final m in v.limitedMeds) {
      final key = 'med_limit_${m.originalName}';
      _reviewChecked[key] = true;
      final badge = m.isValidated ? ' [RxNorm verified]' : ' [unverified]';
      final reason = m.reason.isNotEmpty ? ' — ${m.reason}' : '';
      _reviewEdited[key] = '${m.displayName}$reason$badge';
    }

    // ── Agent authority limitations
    if (v.agentAuthorityLimitations != null) {
      _reviewChecked['agent_authority_limitations'] = true;
      _reviewEdited['agent_authority_limitations'] = v.agentAuthorityLimitations!;
    }

    // ── Personal info (PII) — autofill the declarant + the people they
    // designate. Address is split into components matching the app's form.
    final pi = v.personalInfo;
    void put(String key, String? value) {
      if (value != null && value.trim().isNotEmpty) {
        _reviewChecked[key] = true;
        _reviewEdited[key] = value.trim();
      }
    }

    put('person_name', pi.fullName);
    put('person_dob', pi.dateOfBirth);
    put('person_address1', pi.addressLine1);
    put('person_address2', pi.addressLine2);
    put('person_city', pi.city);
    put('person_county', pi.county);
    put('person_state', pi.state);
    put('person_zip', pi.zip);
    put('person_phone', pi.phone);
    put('person_doctor_name', pi.primaryDoctorName);
    put('person_doctor_phone', pi.primaryDoctorPhone);
    put('person_eval_doctor_name', pi.preferredEvaluatingDoctorName);
    put('person_eval_doctor_contact', pi.preferredEvaluatingDoctorContact);
    final ag = pi.agent;
    if (ag != null) {
      put('agent_name', ag.name);
      put('agent_relationship', ag.relationship);
      put('agent_address1', ag.addressLine1);
      put('agent_address2', ag.addressLine2);
      put('agent_city', ag.city);
      put('agent_state', ag.state);
      put('agent_zip', ag.zip);
      put('agent_phone', ag.phone);
    }
    final alt = pi.alternateAgent;
    if (alt != null) {
      put('alt_agent_name', alt.name);
      put('alt_agent_relationship', alt.relationship);
      put('alt_agent_address1', alt.addressLine1);
      put('alt_agent_address2', alt.addressLine2);
      put('alt_agent_city', alt.city);
      put('alt_agent_state', alt.state);
      put('alt_agent_zip', alt.zip);
      put('alt_agent_phone', alt.phone);
    }
    final gd = pi.guardian;
    if (gd != null) {
      put('guardian_name', gd.name);
      put('guardian_relationship', gd.relationship);
      put('guardian_address1', gd.addressLine1);
      put('guardian_address2', gd.addressLine2);
      put('guardian_city', gd.city);
      put('guardian_state', gd.state);
      put('guardian_zip', gd.zip);
      put('guardian_phone', gd.phone);
    }
  }

  /// After extraction, classify each field by priority and detect conflicts
  /// against the directive's CURRENT scalar values. Low-priority items stay
  /// pre-selected (autofilled silently); conflicting scalars start UNSELECTED
  /// so the user makes a deliberate keep/replace choice, with the more-complete
  /// value pre-filled as the suggested default.
  Future<void> _buildReconciliation() async {
    final repo = ref.read(directiveRepositoryProvider);
    final id = widget.directiveId;
    final prefs = await repo.getPreferences(id);
    final instr = await repo.getAdditionalInstructions(id);
    // Personal-info current values, so an autofilled name/address/phone that
    // would REPLACE something the user already typed starts unchecked (a
    // deliberate keep/replace choice) instead of silently overwriting.
    final directive = await repo.getDirectiveById(id);
    final agents = await repo.getAgents(id);
    final primaryAgents =
        agents.where((a) => a.agentType == 'primary').toList();
    final primaryAgent = primaryAgents.isEmpty ? null : primaryAgents.first;
    final altAgents =
        agents.where((a) => a.agentType == 'alternate').toList();
    final altAgent = altAgents.isEmpty ? null : altAgents.first;
    final guardian = await repo.getGuardianNomination(id);
    final existing = <String, String>{
      'facility_prefer': prefs?.preferredFacilityName ?? '',
      'facility_avoid': prefs?.avoidFacilityName ?? '',
      'dietary': instr?.dietary ?? '',
      'religious': instr?.religious ?? '',
      'activities': instr?.activities ?? '',
      'crisis': instr?.crisisIntervention ?? '',
      'agent_authority_limitations': prefs?.agentAuthorityLimitations ?? '',
      'pet_custody': instr?.petCustody ?? '',
      'children_custody': instr?.childrenCustody ?? '',
      'family_notification': instr?.familyNotification ?? '',
      'records_disclosure': instr?.recordsDisclosure ?? '',
      'other': instr?.other ?? '',
      'hh_note': instr?.healthHistory ?? '',
      // Declarant — split address fields
      'person_name': directive?.fullName ?? '',
      'person_dob': directive?.dateOfBirth ?? '',
      'person_address1': directive?.address ?? '',
      'person_address2': directive?.address2 ?? '',
      'person_city': directive?.city ?? '',
      'person_county': directive?.county ?? '',
      'person_state': directive?.state ?? '',
      'person_zip': directive?.zip ?? '',
      'person_phone': directive?.phone ?? '',
      'person_doctor_name': directive?.primaryDoctorName ?? '',
      'person_doctor_phone': directive?.primaryDoctorPhone ?? '',
      'person_eval_doctor_name': directive?.preferredDoctorName ?? '',
      'person_eval_doctor_contact': directive?.preferredDoctorContact ?? '',
      // Primary agent — split address
      'agent_name': primaryAgent?.fullName ?? '',
      'agent_relationship': primaryAgent?.relationship ?? '',
      'agent_address1': primaryAgent?.address ?? '',
      'agent_address2': primaryAgent?.address2 ?? '',
      'agent_city': primaryAgent?.city ?? '',
      'agent_state': primaryAgent?.state ?? '',
      'agent_zip': primaryAgent?.zip ?? '',
      'agent_phone': primaryAgent?.homePhone ?? '',
      // Alternate agent — split address
      'alt_agent_name': altAgent?.fullName ?? '',
      'alt_agent_relationship': altAgent?.relationship ?? '',
      'alt_agent_address1': altAgent?.address ?? '',
      'alt_agent_address2': altAgent?.address2 ?? '',
      'alt_agent_city': altAgent?.city ?? '',
      'alt_agent_state': altAgent?.state ?? '',
      'alt_agent_zip': altAgent?.zip ?? '',
      'alt_agent_phone': altAgent?.homePhone ?? '',
      // Guardian — split address
      'guardian_name': guardian?.nomineeFullName ?? '',
      'guardian_relationship': guardian?.nomineeRelationship ?? '',
      'guardian_address1': guardian?.nomineeAddress ?? '',
      'guardian_address2': guardian?.nomineeAddress2 ?? '',
      'guardian_city': guardian?.nomineeCity ?? '',
      'guardian_state': guardian?.nomineeState ?? '',
      'guardian_zip': guardian?.nomineeZip ?? '',
      'guardian_phone': guardian?.nomineePhone ?? '',
    };
    _reconItems = buildReconItems(
      extracted: Map<String, String>.of(_reviewEdited),
      existing: existing,
    );
    for (final it in _reconItems) {
      _reviewChecked[it.key] = it.selected;
      // Pre-fill the conflict default (the more-complete value); editable.
      if (it.isConflict) _reviewEdited[it.key] = it.suggestedValue;
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
      final response = await service.generate(SmartFillInput(
        conditions: _validated!.icdConditions,
        currentMedications: _validated!.validatedPreferredMedNames,
        medicationsToAvoid: _validated!.validatedAvoidMedNames,
        formType: widget.formType,
      ));

      final result = response.result;
      ref.read(geminiRateTrackerProvider).recordRequest(
          estimatedTokens: response.totalTokens);

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
    // Count only what's actually written so the "N fields added" message is
    // honest (skips duplicates and already-set fields).
    var applied = 0;

    // Dedup: compare full name (including dosage/form) AND entry type.
    // "Sertraline 50 MG" and "Sertraline 100 MG" are different entries.
    // Same drug in "preferred" and "avoid" are both allowed (different intent).
    bool medExists(String name, String entryType) {
      return existingMeds.any((m) =>
          m.medicationName.toLowerCase() == name.toLowerCase() &&
          m.entryType == entryType);
    }

    // Promote the nullable field to a local so the med/condition branches
    // below are null-safe. `_applyAll` can be invoked from the always-enabled
    // "Autofill Information" button before any successful extraction (or after
    // a reset clears `_validated` at the top of the flow); the validated-data
    // branches must simply no-op in that case rather than throw
    // "Null check operator used on a null value". Smart Fill (which reads
    // `_smartResult`, not `_validated`) still runs below.
    final validated = _validated;

    for (final entry in _reviewChecked.entries) {
      if (!entry.value) continue;
      final key = entry.key;

      if (validated != null && key.startsWith('med_prefer_')) {
        final med = validated.preferredMeds
            .firstWhere((m) => 'med_prefer_${m.originalName}' == key);
        if (!medExists(med.displayName, MedicationEntryType.preferred.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.preferred.name,
            medicationName: Value(med.displayName),
            reason: Value(med.reason),
            sortOrder: Value(medOrder++),
          ));
          applied++;
        }
      } else if (validated != null && key.startsWith('med_avoid_')) {
        final med = validated.avoidMeds
            .firstWhere((m) => 'med_avoid_${m.originalName}' == key);
        if (!medExists(med.displayName, MedicationEntryType.exception.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.exception.name,
            medicationName: Value(med.displayName),
            reason: Value(med.reason),
            sortOrder: Value(medOrder++),
          ));
          applied++;
        }
      } else if (key == 'facility_prefer') {
        await repo.upsertPreferences(DirectivePrefsCompanion(
          directiveId: Value(id),
          treatmentFacilityPref: Value(TreatmentFacilityPreference.prefer.name),
          preferredFacilityName: Value(_reviewEdited[key] ?? ''),
        ));
        applied++;
      } else if (key == 'facility_avoid') {
        await repo.upsertPreferences(DirectivePrefsCompanion(
          directiveId: Value(id),
          treatmentFacilityPref: Value(TreatmentFacilityPreference.avoid.name),
          avoidFacilityName: Value(_reviewEdited[key] ?? ''),
        ));
        applied++;
      }
    }

    // Write conditions to effective condition field
    final condNames = validated == null
        ? <String>[]
        : validated.conditions
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
        applied++;
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

    // Health history — verbatim prose the user reviewed (single note).
    addInstr('hh_note', 'healthHistory');

    addInstr('dietary', 'dietary');
    addInstr('religious', 'religious');
    addInstr('activities', 'activities');
    addInstr('crisis', 'crisisIntervention');
    addInstr('pet_custody', 'petCustody');
    addInstr('children_custody', 'childrenCustody');
    addInstr('family_notification', 'familyNotification');
    addInstr('records_disclosure', 'recordsDisclosure');
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
          applied++;
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
      // Smart-fill no longer suggests medications — the AI must never
      // recommend or name drugs the user didn't enter (see smart_fill_service).
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
          petCustody: instrMap.containsKey('petCustody')
              ? Value(merge(existing?.petCustody, instrMap['petCustody']))
              : const Value.absent(),
          childrenCustody: instrMap.containsKey('childrenCustody')
              ? Value(merge(existing?.childrenCustody, instrMap['childrenCustody']))
              : const Value.absent(),
          familyNotification: instrMap.containsKey('familyNotification')
              ? Value(merge(
                  existing?.familyNotification, instrMap['familyNotification']))
              : const Value.absent(),
          recordsDisclosure: instrMap.containsKey('recordsDisclosure')
              ? Value(merge(
                  existing?.recordsDisclosure, instrMap['recordsDisclosure']))
              : const Value.absent(),
          other: instrMap.containsKey('other')
              ? Value(merge(existing?.other, instrMap['other']))
              : const Value.absent(),
        ),
      );
    }

    // ── Apply diagnoses → DiagnosisEntries table ─────────────────────
    if (validated != null) {
      final existingDiagnoses = await repo.getDiagnoses(id);
      final existingDiagNames =
          existingDiagnoses.map((d) => d.name.toLowerCase()).toSet();
      int diagOrder = existingDiagnoses.length;
      for (final d in validated.diagnoses) {
        final key = 'diag_${d.name}';
        if (_reviewChecked[key] != true) continue;
        if (existingDiagNames.contains(d.name.toLowerCase())) continue;
        await repo.insertDiagnosis(DiagnosisEntriesCompanion.insert(
          directiveId: id,
          name: Value(d.name),
          icdCode: Value(d.icdCode ?? ''),
          sortOrder: Value(diagOrder++),
        ));
        applied++;
      }
    }

    // ── Apply allergies → DirectiveAllergies table ────────────────────
    if (validated != null) {
      final existingAllergies = await repo.getAllergies(id);
      final existingSubstances =
          existingAllergies.map((a) => a.substance.toLowerCase()).toSet();
      int allergyOrder = existingAllergies.length;
      for (final a in validated.allergies) {
        final key = 'allergy_${a.substance}';
        if (_reviewChecked[key] != true) continue;
        if (existingSubstances.contains(a.substance.toLowerCase())) continue;
        // Clamp kind and severity to the values the app understands.
        const validKinds = {'drug', 'food', 'material', 'other'};
        const validSeverities = {'mild', 'moderate', 'severe'};
        final kind = validKinds.contains(a.kind) ? a.kind : 'other';
        final severity =
            validSeverities.contains(a.severity) ? a.severity : 'moderate';
        await repo.addAllergy(DirectiveAllergiesCompanion.insert(
          directiveId: id,
          kind: Value(kind),
          substance: Value(a.substance),
          severity: Value(severity),
          reactions: Value(a.reactions ?? ''),
          sortOrder: Value(allergyOrder++),
        ));
        applied++;
      }
    }

    // ── Apply currently-taking medications (reference list) ──────────
    if (validated != null) {
      for (final med in validated.currentMeds) {
        final key = 'med_current_${med.originalName}';
        if (_reviewChecked[key] != true) continue;
        if (!medExists(med.displayName, MedicationEntryType.current.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.current.name,
            medicationName: Value(med.displayName),
            reason: Value(med.reason),
            sortOrder: Value(medOrder++),
          ));
          applied++;
        }
      }
    }

    // ── Apply medication limitations ──────────────────────────────────
    if (validated != null) {
      for (final med in validated.limitedMeds) {
        final key = 'med_limit_${med.originalName}';
        if (_reviewChecked[key] != true) continue;
        if (!medExists(med.displayName, MedicationEntryType.limitation.name)) {
          await repo.insertMedication(MedicationEntriesCompanion.insert(
            directiveId: id,
            entryType: MedicationEntryType.limitation.name,
            medicationName: Value(med.displayName),
            reason: Value(med.reason),
            sortOrder: Value(medOrder++),
          ));
          applied++;
        }
      }
    }

    // ── Apply personal info (PII) ────────────────────────────────────────
    // Autofill the declarant + the people they designate. Only checked,
    // non-empty values are written; an un-extracted field keeps its current
    // value (we never blank something the user already had).
    String? pv(String key) {
      if (_reviewChecked[key] != true) return null;
      final t = _reviewEdited[key]?.trim();
      return (t != null && t.isNotEmpty) ? t : null;
    }

    final pName = pv('person_name');
    final pDob = pv('person_dob');
    final pAddr1 = pv('person_address1');
    final pAddr2 = pv('person_address2');
    final pCity = pv('person_city');
    final pCounty = pv('person_county');
    final pState = pv('person_state');
    final pZip = pv('person_zip');
    final pPhone = pv('person_phone');
    if (pName != null ||
        pDob != null ||
        pAddr1 != null ||
        pCity != null ||
        pPhone != null) {
      final d = await repo.getDirectiveById(id);
      await repo.updatePersonalInfo(
        id,
        fullName: pName ?? d?.fullName ?? '',
        dateOfBirth: pDob ?? d?.dateOfBirth ?? '',
        address: pAddr1 ?? d?.address ?? '',
        address2: pAddr2 ?? d?.address2 ?? '',
        city: pCity ?? d?.city ?? '',
        county: pCounty ?? d?.county ?? '',
        state: pState ?? d?.state ?? '',
        zip: pZip ?? d?.zip ?? '',
        phone: pPhone ?? d?.phone ?? '',
      );
      applied += [pName, pDob, pAddr1, pCity, pPhone]
          .whereType<String>()
          .length;
    }

    final docName = pv('person_doctor_name');
    final docPhone = pv('person_doctor_phone');
    if (docName != null || docPhone != null) {
      final d = await repo.getDirectiveById(id);
      await repo.updatePrimaryDoctor(
        id,
        name: docName ?? d?.primaryDoctorName ?? '',
        specialty: d?.primaryDoctorSpecialty ?? '',
        phone: docPhone ?? d?.primaryDoctorPhone ?? '',
      );
      applied += [docName, docPhone].whereType<String>().length;
    }

    final evalDocName = pv('person_eval_doctor_name');
    final evalDocContact = pv('person_eval_doctor_contact');
    if (evalDocName != null || evalDocContact != null) {
      final d = await repo.getDirectiveById(id);
      await repo.updatePreferredDoctor(
        id,
        name: evalDocName ?? d?.preferredDoctorName ?? '',
        contact: evalDocContact ?? d?.preferredDoctorContact ?? '',
      );
      applied += [evalDocName, evalDocContact].whereType<String>().length;
    }

    Future<void> applyAgent(String type, String prefix) async {
      final name = pv('${prefix}_name');
      final rel = pv('${prefix}_relationship');
      final addr1 = pv('${prefix}_address1');
      final addr2 = pv('${prefix}_address2');
      final city = pv('${prefix}_city');
      final state = pv('${prefix}_state');
      final zip = pv('${prefix}_zip');
      final phone = pv('${prefix}_phone');
      if (name == null &&
          rel == null &&
          addr1 == null &&
          city == null &&
          phone == null) {
        return;
      }
      final existing =
          (await repo.getAgents(id)).where((a) => a.agentType == type).toList();
      final cur = existing.isEmpty ? null : existing.first;
      await repo.upsertAgent(AgentsCompanion(
        id: cur != null ? Value(cur.id) : const Value.absent(),
        directiveId: Value(id),
        agentType: Value(type),
        fullName: Value(name ?? cur?.fullName ?? ''),
        relationship: Value(rel ?? cur?.relationship ?? ''),
        address: Value(addr1 ?? cur?.address ?? ''),
        address2: Value(addr2 ?? cur?.address2 ?? ''),
        city: Value(city ?? cur?.city ?? ''),
        state: Value(state ?? cur?.state ?? ''),
        zip: Value(zip ?? cur?.zip ?? ''),
        homePhone: Value(phone ?? cur?.homePhone ?? ''),
      ));
      applied += [name, rel, addr1, city, phone].whereType<String>().length;
    }

    await applyAgent('primary', 'agent');
    await applyAgent('alternate', 'alt_agent');

    final gName = pv('guardian_name');
    final gRel = pv('guardian_relationship');
    final gAddr1 = pv('guardian_address1');
    final gAddr2 = pv('guardian_address2');
    final gCity = pv('guardian_city');
    final gState = pv('guardian_state');
    final gZip = pv('guardian_zip');
    final gPhone = pv('guardian_phone');
    if (gName != null ||
        gRel != null ||
        gAddr1 != null ||
        gCity != null ||
        gPhone != null) {
      final cur = await repo.getGuardianNomination(id);
      await repo.upsertGuardianNomination(GuardianNominationsCompanion(
        id: cur != null ? Value(cur.id) : const Value.absent(),
        directiveId: Value(id),
        nomineeFullName: Value(gName ?? cur?.nomineeFullName ?? ''),
        nomineeRelationship: Value(gRel ?? cur?.nomineeRelationship ?? ''),
        nomineeAddress: Value(gAddr1 ?? cur?.nomineeAddress ?? ''),
        nomineeAddress2: Value(gAddr2 ?? cur?.nomineeAddress2 ?? ''),
        nomineeCity: Value(gCity ?? cur?.nomineeCity ?? ''),
        nomineeState: Value(gState ?? cur?.nomineeState ?? ''),
        nomineeZip: Value(gZip ?? cur?.nomineeZip ?? ''),
        nomineePhone: Value(gPhone ?? cur?.nomineePhone ?? ''),
      ));
      applied += [gName, gRel, gAddr1, gCity, gPhone].whereType<String>().length;
    }

    // ── Apply agent authority limitations ─────────────────────────────
    final agentLimits = pv('agent_authority_limitations');
    if (agentLimits != null) {
      final existingPrefs = await repo.getPreferences(id);
      final cur = existingPrefs?.agentAuthorityLimitations ?? '';
      final merged = cur.isEmpty ? agentLimits : '$cur\n$agentLimits';
      await repo.upsertPreferences(DirectivePrefsCompanion(
        directiveId: Value(id),
        agentAuthorityLimitations: Value(merged),
      ));
      applied++;
    }

    // Each additional-instruction field actually written counts once (review
    // pass-throughs + smart-fill both land in instrMap).
    applied += instrMap.length;
    _onApplied(applied);
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
    if (key.startsWith('med_current_')) return 'Currently Taking';
    if (key.startsWith('med_limit_')) return 'Restricted-Use Medication';
    if (key.startsWith('cond_')) return 'Condition';
    if (key.startsWith('diag_')) return 'Diagnosis';
    if (key.startsWith('allergy_')) return 'Allergy';
    if (key.startsWith('hh_')) return 'Health History';
    if (key == 'facility_prefer') return 'Preferred Facility';
    if (key == 'facility_avoid') return 'Facility to Avoid';
    if (key == 'dietary') return 'Dietary';
    if (key == 'religious') return 'Religious/Cultural';
    if (key == 'activities') return 'Activities';
    if (key == 'crisis') return 'Crisis Intervention';
    if (key == 'agent_authority_limitations') return 'Agent authority limits';
    if (key == 'pet_custody') return 'Pet care';
    if (key == 'children_custody') return 'Children / dependents';
    if (key == 'family_notification') return 'Who to notify';
    if (key == 'records_disclosure') return 'Records disclosure';
    if (key == 'other') return 'Other';
    // Personal info (PII) — declarant
    if (key == 'person_name') return 'Your full name';
    if (key == 'person_dob') return 'Date of birth';
    if (key == 'person_address1') return 'Street address';
    if (key == 'person_address2') return 'Apt / suite / unit';
    if (key == 'person_city') return 'City';
    if (key == 'person_county') return 'County';
    if (key == 'person_state') return 'State';
    if (key == 'person_zip') return 'ZIP code';
    if (key == 'person_phone') return 'Your phone';
    if (key == 'person_doctor_name') return 'Primary doctor';
    if (key == 'person_doctor_phone') return "Doctor's phone";
    if (key == 'person_eval_doctor_name') return 'Preferred evaluating doctor';
    if (key == 'person_eval_doctor_contact') return 'Evaluating doctor contact';
    // Primary agent
    if (key == 'agent_name') return 'Agent name';
    if (key == 'agent_relationship') return 'Agent relationship';
    if (key == 'agent_address1') return 'Agent street address';
    if (key == 'agent_address2') return 'Agent apt / suite';
    if (key == 'agent_city') return 'Agent city';
    if (key == 'agent_state') return 'Agent state';
    if (key == 'agent_zip') return 'Agent ZIP';
    if (key == 'agent_phone') return 'Agent phone';
    // Alternate agent
    if (key == 'alt_agent_name') return 'Alternate agent name';
    if (key == 'alt_agent_relationship') return 'Alternate agent relationship';
    if (key == 'alt_agent_address1') return 'Alt agent street address';
    if (key == 'alt_agent_address2') return 'Alt agent apt / suite';
    if (key == 'alt_agent_city') return 'Alt agent city';
    if (key == 'alt_agent_state') return 'Alt agent state';
    if (key == 'alt_agent_zip') return 'Alt agent ZIP';
    if (key == 'alt_agent_phone') return 'Alternate agent phone';
    // Guardian
    if (key == 'guardian_name') return 'Guardian nominee';
    if (key == 'guardian_relationship') return 'Guardian relationship';
    if (key == 'guardian_address1') return 'Guardian street address';
    if (key == 'guardian_address2') return 'Guardian apt / suite';
    if (key == 'guardian_city') return 'Guardian city';
    if (key == 'guardian_state') return 'Guardian state';
    if (key == 'guardian_zip') return 'Guardian ZIP';
    if (key == 'guardian_phone') return 'Guardian phone';
    return key;
  }

  String _sectionLabel(String key) {
    if (key.startsWith('med_prefer_')) return 'Preferred Meds';
    if (key.startsWith('med_avoid_')) return 'Meds to Avoid';
    if (key.startsWith('med_current_')) return 'Currently Taking';
    if (key.startsWith('med_limit_')) return 'Restricted-Use Meds';
    if (key.startsWith('cond_')) return 'Conditions';
    if (key.startsWith('diag_')) return 'Diagnoses';
    if (key.startsWith('allergy_')) return 'Allergies';
    if (key.startsWith('hh_')) return 'Health History';
    if (key.startsWith('person_')) return 'Your details';
    if (key.startsWith('agent_') && !key.startsWith('agent_authority')) {
      return 'Your agent';
    }
    if (key == 'agent_authority_limitations') return 'Agent Authority';
    if (key.startsWith('alt_agent_')) return 'Alternate agent';
    if (key.startsWith('guardian_')) return 'Guardian';
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
      // Modal (over the wizard): standard Material AppBar. Standalone (the
      // routed /upload page): no AppBar — the artboard top bar lives in-body
      // (progress row on pick; back row elsewhere), matching WebSnapFill.
      appBar: _standalone
          ? null
          : AppBar(
              title: Text(_title),
              leading: IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Close',
                onPressed: isProcessing ? null : _exit,
              ),
            ),
      body: SafeArea(
        child: Column(
          children: [
            if (_standalone)
              _standaloneTopBar(isProcessing)
            else ...[
              LinearProgressIndicator(
                value: (_step.index + 1) / _PipelineStep.values.length,
                backgroundColor: cs.surfaceContainerHighest,
              ),
              Semantics(
                liveRegion: true,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    _title,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ),
              ),
            ],
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottom(),
    ),
    );
  }

  // Artboard top bar for the standalone /upload page (WebSnapFill jsx L41-51).
  // Pick: "‹ Wizard" + a thin progress bar + "Step 1 of 11". Review/results: a
  // back chevron to the previous step. Processing: a plain title (no back).
  Widget _standaloneTopBar(bool isProcessing) {
    final p = Theme.of(context).mhadPalette;

    Widget backLink(String label, VoidCallback? onTap) => InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chevron_left, size: 18, color: p.textMuted),
                const SizedBox(width: 2),
                Text(label,
                    style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 13,
                        color: p.textMuted)),
              ],
            ),
          ),
        );

    if (_step == _PipelineStep.pick) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
        child: Row(
          children: [
            backLink('Wizard', _toWizard),
            const Spacer(),
          ],
        ),
      );
    }

    // Processing / review / results: a back affordance (disabled mid-process).
    final (label, onBack) = switch (_step) {
      _PipelineStep.results => (
          'Review',
          isProcessing ? null : () => setState(() => _step = _PipelineStep.review)
        ),
      _ => ('Snap to fill', isProcessing ? null : _discardExtraction),
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 0),
      child: Row(
        children: [
          backLink(label, onBack),
          const Spacer(),
        ],
      ),
    );
  }

  String get _title => switch (_step) {
        _PipelineStep.pick => 'Snap to fill',
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

  // ── Snap-to-fill (artboard WebSnapFill): the full-page drop / browse /
  //    webcam surface that feeds the extraction pipeline. ──────────────────

  Future<void> _browseFiles() async {
    setState(() => _error = null);
    List<PickedDocument>? docs;
    try {
      docs = await pickDocumentFiles();
    } catch (e) {
      // The picker threw (seen on web with some browsers) — surface it instead
      // of leaving the Browse button feeling dead.
      if (mounted) {
        setState(() => _error =
            'Couldn\'t open the file picker ($e). Try dragging the file onto '
            'the box above instead.');
      }
      return;
    }
    if (!mounted || docs == null) return; // null = cancelled, stay quiet
    if (docs.isEmpty) {
      // Files were chosen but none could be read — never fail silently.
      setState(() => _error =
          'We couldn\'t read that file. Please use a PDF, JPG, PNG, WEBP, '
          'HEIC, or plain-text file under 10 MB.');
      return;
    }
    _addPending(docs);
  }

  Future<void> _useWebcam() async {
    setState(() => _error = null);
    final docs = await pickDocumentCameraPhoto();
    if (docs.isNotEmpty && mounted) _addPending(docs);
  }

  // ── Pending tray (held documents, not yet sent to the AI) ────────────

  /// Append newly picked/dropped/pasted/snapped documents to the held tray,
  /// de-duplicating by name + byte length so re-picking the same file doesn't
  /// create a duplicate. Nothing is sent to the AI here — the user reads the
  /// batch explicitly via [_readPendingDocs].
  void _addPending(List<PickedDocument> docs) {
    if (docs.isEmpty) return;
    setState(() {
      _error = null;
      for (final d in docs) {
        final dup = _pendingDocs.any((e) =>
            _docName(e) == _docName(d) &&
            (e.bytes?.length ?? -1) == (d.bytes?.length ?? -2));
        if (!dup) _pendingDocs.add(d);
      }
    });
  }

  void _removePending(PickedDocument doc) {
    setState(() => _pendingDocs.remove(doc));
  }

  void _clearPending() {
    setState(() => _pendingDocs.clear());
  }

  /// The explicit "send to AI" action. Snapshots the held tray (so removing a
  /// pending file mid-extraction can't mutate what's being read) and runs the
  /// extraction → validate → review pipeline over it.
  void _readPendingDocs() {
    if (_pendingDocs.isEmpty) return;
    _startPipeline(List<PickedDocument>.of(_pendingDocs));
  }

  Widget _buildPickStep() {
    final p = Theme.of(context).mhadPalette;
    final hasKey = ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty == true;
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 720;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionLabel('Snap to fill · optional'),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'Have a photo handy? '),
                  TextSpan(
                    text: "We'll read it.",
                    style: TextStyle(color: p.primary),
                  ),
                ]),
                style: TextStyle(
                  fontFamily: 'Instrument Serif',
                  fontFamilyFallback: const ['Georgia', 'serif'],
                  fontStyle: FontStyle.italic,
                  fontSize: 32,
                  height: 1.05,
                  letterSpacing: -0.5,
                  color: p.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Drop a photo or PDF — ID, medication list, prescription label, '
                'an old directive — and the AI will extract what it can. You '
                'review every field before it lands in the form. Or skip and '
                'type it all yourself.',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 14,
                  height: 1.5,
                  color: p.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.privacy_tip_outlined, size: 15, color: p.textMuted),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Your privacy: black out anything sensitive before '
                      'uploading. You never have to upload personal details at '
                      'all — any field can be typed in by hand to keep it '
                      'confidential.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 12.5,
                        height: 1.45,
                        color: p.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (!hasKey) ...[
                _noKeyBanner(p),
                const SizedBox(height: 16),
              ],
              if (_error != null) ...[
                _errorCard(p),
                const SizedBox(height: 16),
              ],
              // Document-gathering affordances. Autofill REQUIRES the AI to
              // read documents, so every gather action here is DISABLED (and
              // dimmed) until a Gemini key is set up — the "Set up AI" banner
              // above is then the only thing to act on. The Skip/Continue
              // footer stays enabled so the user can always leave and type by
              // hand.
              Opacity(
                opacity: hasKey ? 1.0 : 0.45,
                child: IgnorePointer(
                  ignoring: !hasKey,
                  child: wide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _dropZone(p)),
                            const SizedBox(width: 16),
                            Expanded(flex: 2, child: _targetsPanel(p)),
                          ],
                        )
                      // Narrow + camera (phone): the artboard mobile chooser
                      // ("Take a photo" / "Pick a file" cards + a vertical
                      // targets list, WebSnapFillMobile jsx L505-586). Narrow
                      // desktop (no camera) keeps the drag-and-drop zone.
                      : deviceHasCamera
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _mobileChooser(p),
                                const SizedBox(height: 18),
                                _mobileTargets(p),
                                const SizedBox(height: 14),
                                _privacyLockLine(p),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _dropZone(p),
                                const SizedBox(height: 16),
                                _targetsPanel(p),
                              ],
                            ),
                ),
              ),
              // Held documents the user picked but hasn't sent yet. The AI is
              // only called when they tap "Read … with AI" inside this tray.
              if (_pendingDocs.isNotEmpty) ...[
                const SizedBox(height: 22),
                _pendingDocsTray(p, hasKey),
              ],
              // "In this session" — files whose fields were applied this
              // session (standalone accumulation). WebSnapFill jsx L174-251.
              if (_sessionFiles.isNotEmpty) ...[
                const SizedBox(height: 22),
                _sessionFilesRow(p),
              ],
              // Skip / Continue footer (standalone only; the modal uses its
              // AppBar close). WebSnapFill jsx L253-258.
              if (_standalone) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    TextButton(
                      onPressed: _toWizard,
                      child: const Text("Skip — I'll type it all"),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _toWizard,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('Continue to step 2'),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Human-readable byte size for the pending-file rows ("1.4 MB", "812 KB").
  String _humanSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes >= 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    if (bytes >= 1024) return '${(bytes / 1024).round()} KB';
    return '$bytes B';
  }

  IconData _docIcon(PickedDocument d) {
    if (d.mimeType == 'application/pdf') return Icons.picture_as_pdf_outlined;
    if (d.mimeType.startsWith('image/')) return Icons.image_outlined;
    return Icons.description_outlined;
  }

  // The held-documents tray: files the user selected/dropped/pasted/snapped
  // but has NOT sent to the AI yet. Each row can be removed; the primary
  // button is the only thing that actually calls the extractor (_readPendingDocs).
  Widget _pendingDocsTray(MhadPalette p, bool hasKey) {
    final n = _pendingDocs.length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SectionLabel('Ready to read'),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$n FILE${n == 1 ? '' : 'S'} · HELD, NOT SENT YET',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace',
                    ],
                    fontSize: 10,
                    letterSpacing: 0.4,
                    color: p.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: _clearPending,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Clear all'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final d in _pendingDocs) _pendingDocRow(p, d),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 13, color: p.textMuted),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  hasKey
                      ? 'Held on this device. Nothing is sent until you tap '
                          'Read — then it goes to the AI to read and is discarded.'
                      : 'Held on this device. Reading needs AI set up first '
                          '(free, ~30 seconds) — nothing is sent until then.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    height: 1.4,
                    color: p.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _readPendingDocs,
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: Text(
                n == 1 ? 'Read this document with AI' : 'Read $n documents with AI',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pendingDocRow(MhadPalette p, PickedDocument d) {
    final size = _humanSize(d.bytes?.length);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 40,
            decoration: BoxDecoration(
              color: p.surface,
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(_docIcon(d), size: 16, color: p.textMuted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _docName(d),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
                if (size.isNotEmpty)
                  Text(
                    '${_docKind(d)} · $size',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: p.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            tooltip: 'Remove',
            visualDensity: VisualDensity.compact,
            color: p.textMuted,
            onPressed: () => _removePending(d),
          ),
        ],
      ),
    );
  }

  // The "In this session · N FILES · CLEARED ON TAB CLOSE" grid: one card per
  // applied file + a dashed "Add another" tile. Uses a Wrap so cards reflow at
  // any width (the artboard's fixed 3-column grid).
  Widget _sessionFilesRow(MhadPalette p) {
    final n = _sessionFiles.length;
    return LayoutBuilder(builder: (context, c) {
      // Aim for 3 columns on wide, fewer when narrow.
      final cols = c.maxWidth >= 720 ? 3 : (c.maxWidth >= 460 ? 2 : 1);
      final cardW = (c.maxWidth - (cols - 1) * 10) / cols;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SectionLabel('In this session'),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$n FILE${n == 1 ? '' : 'S'} · CLEARED ON TAB CLOSE',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace',
                    ],
                    fontSize: 10,
                    letterSpacing: 0.4,
                    color: p.textMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final f in _sessionFiles)
                SizedBox(width: cardW, child: _sessionFileCard(p, f)),
              SizedBox(width: cardW, child: _addAnotherTile(p)),
            ],
          ),
        ],
      );
    });
  }

  Widget _sessionFileCard(MhadPalette p, _SessionFile f) {
    final okText = Theme.of(context).brightness == Brightness.dark
        ? SemanticColors.successTextDark
        : SemanticColors.successTextLight;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 48,
            decoration: BoxDecoration(
              color: p.surface,
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Icon(
              f.kind == 'PDF'
                  ? Icons.picture_as_pdf_outlined
                  : f.kind == 'Photo'
                      ? Icons.image_outlined
                      : Icons.description_outlined,
              size: 18,
              color: p.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: p.primaryTint,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    f.kind.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const [
                        'Consolas',
                        'Menlo',
                        'Courier New',
                        'monospace',
                      ],
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: p.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  f.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '● ${f.fieldsAdded} field${f.fieldsAdded == 1 ? '' : 's'} added',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: okText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _addAnotherTile(MhadPalette p) {
    return InkWell(
      onTap: _browseFiles,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(minHeight: 72),
        decoration: BoxDecoration(
          color: p.surface,
          border: Border.all(color: p.border, width: 1.5, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, size: 16, color: p.textMuted),
            const SizedBox(width: 8),
            Text(
              'Add another',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: p.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Shown on the snap-to-fill page when no Gemini key is set (the common web
  // case). The page stays visible so the user sees how it works; this explains
  // that actually reading a document needs AI set up, with a one-tap CTA.
  Widget _noKeyBanner(MhadPalette p) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.primaryTint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: p.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome_outlined, size: 18, color: p.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "AI isn't set up yet",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'You can see how snap-to-fill works below, but reading a real photo '
            'or PDF needs a free Gemini key (about 30 seconds). You review '
            'every field before it lands in your form.',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.5,
              height: 1.45,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _goAiSetup,
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: const Text('Set up AI'),
          ),
        ],
      ),
    );
  }

  Widget _errorCard(MhadPalette p) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_error!, style: TextStyle(color: cs.onErrorContainer)),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _browseFiles,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _dropZone(MhadPalette p) {
    return DropTarget(
      onDragEntered: (_) => setState(() => _dragOver = true),
      onDragExited: (_) => setState(() => _dragOver = false),
      onDragDone: (detail) => _handleDroppedFiles(detail.files),
      child: InkWell(
        onTap: _browseFiles,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: BoxDecoration(
            color: _dragOver ? p.primaryLight : p.primaryTint,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: p.primary,
              width: _dragOver ? 3 : 2,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 30, 24, 22),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: p.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.upload_file, size: 28, color: p.onPrimary),
            ),
            const SizedBox(height: 14),
            Text(
              // Phones can't drag-and-drop files; desktop / PC web can.
              deviceHasCamera
                  ? 'Add a photo of your document'
                  : 'Drop a photo, PDF, or screenshot',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              // Clipboard paste is a desktop-web affordance only; the shortcut
              // label matches the OS (⌘V on Apple, Ctrl+V on Windows/Linux).
              kIsWeb && !deviceHasCamera
                  ? 'JPG · PNG · HEIC · PDF · up to 10 MB — or paste with '
                      '$pasteShortcutLabel'
                  : 'JPG · PNG · HEIC · PDF · up to 10 MB',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12.5,
                color: p.textMuted,
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _browseFiles,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Browse files'),
                ),
                if (deviceHasCamera)
                  OutlinedButton.icon(
                    onPressed: _useWebcam,
                    icon: const Icon(Icons.photo_camera_outlined, size: 16),
                    label: const Text('Take a photo'),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: p.card,
                border: Border.all(color: p.primaryLight),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 14, color: p.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'To autofill, your file — including any personal details '
                      "in it — is sent to Google's AI to read. The app saves "
                      'nothing (it\'s gone when this tab closes), but Google\'s '
                      'free tier may retain it. You review everything before it '
                      'is added to your directive.',
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 11.5,
                        height: 1.4,
                        color: p.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
  }

  Widget _targetsPanel(MhadPalette p) {
    const targets = <(IconData, String, String)>[
      (Icons.badge_outlined, 'Photo of ID', 'Name · DOB · address'),
      (Icons.medication_outlined, 'Rx bottle / label', 'Drug · dose · schedule'),
      (Icons.coronavirus_outlined, 'Conditions list', 'Diagnoses · allergies'),
      (Icons.description_outlined, 'Anything else', 'Notes, old directive…'),
    ];
    Widget tile((IconData, String, String) t) => Expanded(
          child: InkWell(
            onTap: _browseFiles,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.card,
                border: Border.all(color: p.border),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: p.primaryTint,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(t.$1, size: 16, color: p.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.$2,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.$3,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      height: 1.3,
                      color: p.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(
            deviceHasCamera ? 'What you can add' : 'What you can drop here'),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [tile(targets[0]), const SizedBox(width: 8), tile(targets[1])],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [tile(targets[2]), const SizedBox(width: 8), tile(targets[3])],
          ),
        ),
        // Cross-device nudge — desktop / PC web only (no camera here). On a
        // phone this is redundant: the "Take a photo" button is right above.
        if (!deviceHasCamera) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: p.card,
              border: Border.all(color: p.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.smartphone_outlined, size: 18, color: p.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'On a phone instead?',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Open this page on your phone to snap a page directly '
                        'with its camera.',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11.5,
                          height: 1.35,
                          color: p.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // Mobile capture chooser (WebSnapFillMobile jsx L505-548): two big cards —
  // "Take a photo" (primary, opens the camera) and "Pick a file" (from the
  // gallery / files). The real native picker appears on tap.
  Widget _mobileChooser(MhadPalette p) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _chooserCard(
              onTap: _useWebcam,
              filled: true,
              bg: p.primary,
              fg: p.onPrimary,
              icon: Icons.photo_camera_outlined,
              iconBg: p.onPrimary.withValues(alpha: 0.20),
              title: 'Take a photo',
              subtitle: 'Opens your camera. Snap your ID, Rx label, anything.',
              subtitleColor: p.onPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _chooserCard(
              onTap: _browseFiles,
              filled: false,
              bg: p.card,
              fg: p.text,
              icon: Icons.image_outlined,
              iconBg: p.primaryTint,
              iconFg: p.primary,
              title: 'Pick a file',
              subtitle: 'From your photos or files. JPG, PNG, HEIC, PDF.',
              subtitleColor: p.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chooserCard({
    required VoidCallback onTap,
    required bool filled,
    required Color bg,
    required Color fg,
    required IconData icon,
    required Color iconBg,
    Color? iconFg,
    required String title,
    required String subtitle,
    required Color subtitleColor,
  }) {
    final p = Theme.of(context).mhadPalette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: filled ? null : Border.all(color: p.border, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: iconFg ?? fg),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                height: 1.35,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Vertical "What helps most" targets list (WebSnapFillMobile jsx L550-586):
  // each row is an icon tile + label (+ FASTEST tag on ID) + what it fills +
  // a trailing chevron. Tapping any row opens the file picker.
  Widget _mobileTargets(MhadPalette p) {
    const targets = <(IconData, String, String, bool)>[
      (Icons.badge_outlined, 'Photo of ID', 'Name · DOB · address', true),
      (Icons.medication_outlined, 'Rx bottle / label', 'Drug · dose · schedule',
          false),
      (Icons.coronavirus_outlined, 'Conditions list', 'Diagnoses · allergies',
          false),
      (Icons.description_outlined, 'Anything else', 'Old directive, notes…',
          false),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('What helps most'),
        const SizedBox(height: 8),
        for (final t in targets) ...[
          InkWell(
            onTap: _browseFiles,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: p.card,
                border: Border.all(color: p.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: p.primaryTint,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(t.$1, size: 14, color: p.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                t.$2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'DM Sans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: p.text,
                                ),
                              ),
                            ),
                            if (t.$4) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: p.primaryLight,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  'FASTEST',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontFamilyFallback: const [
                                      'Consolas',
                                      'Menlo',
                                      'Courier New',
                                      'monospace',
                                    ],
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                    color: p.onPrimaryLight,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 1),
                        Text(
                          t.$3,
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 11.5,
                            color: p.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward, size: 12, color: p.textMuted),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }

  // Standalone privacy reassurance line shared by the mobile chooser
  // (WebSnapFillMobile jsx L621-631).
  Widget _privacyLockLine(MhadPalette p) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 14, color: p.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Your file (including any personal details) is sent to Google's "
              'AI to read it. The app saves nothing; Google may retain it on '
              'the free tier. You review before anything is added.',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11,
                height: 1.4,
                color: p.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Processing ──────────────────────────────────────────────────────

  Widget _buildProcessingStep() {
    final p = Theme.of(context).mhadPalette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_statusMessage),
          // Keep the document list visible while the AI reads — initiating
          // autofill shouldn't make the files the user added disappear.
          if (_sourceDocs.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              constraints: const BoxConstraints(maxWidth: 380),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.surface,
                border: Border.all(color: p.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reading ${_sourceDocs.length} '
                    'document${_sourceDocs.length == 1 ? '' : 's'}:',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: p.textMuted,
                    ),
                  ),
                  for (final d in _sourceDocs)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(
                            d.mimeType == 'application/pdf'
                                ? Icons.picture_as_pdf_outlined
                                : d.mimeType.startsWith('image/')
                                    ? Icons.image_outlined
                                    : Icons.description_outlined,
                            size: 15,
                            color: p.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _docName(d),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'DM Sans',
                                fontSize: 12.5,
                                color: p.text,
                              ),
                            ),
                          ),
                        ],
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

  /// Source thumbnail for the review step — shows what the AI read (first
  /// document), with a frame. Images render inline; PDFs/text show an icon.
  Widget _sourceThumb(MhadPalette p) {
    final doc = _sourceDocs.first;
    final isImage = doc.mimeType.startsWith('image/') && doc.bytes != null;
    final name = doc.path.split(RegExp(r'[\\/]')).last;
    final n = _sourceDocs.length;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: p.card,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: isImage
                ? Image.memory(
                    doc.bytes!,
                    width: 72,
                    height: 92,
                    fit: BoxFit.cover,
                    gaplessPlayback: true,
                  )
                : Container(
                    width: 72,
                    height: 92,
                    color: p.primaryTint,
                    child: Icon(
                      doc.mimeType == 'application/pdf'
                          ? Icons.picture_as_pdf_outlined
                          : Icons.description_outlined,
                      color: p.primary,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  n == 1
                      ? "Read by Google's AI to autofill."
                      : "$n files read by Google's AI to autofill.",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    height: 1.4,
                    color: p.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // One "how this page works" instruction line: a small icon + wrapped text.
  Widget _howToLine(MhadPalette p, IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: p.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12.5,
                  height: 1.45,
                  color: p.textMuted,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildReviewStep() {
    final p = Theme.of(context).mhadPalette;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final keys = _reviewEdited.keys.toList();
    final checkedCount =
        _reviewChecked.values.where((v) => v).length;

    final okText = dark
        ? SemanticColors.successTextDark
        : SemanticColors.successTextLight;

    // Editorial header (full width) — mono AI pill, italic serif headline,
    // muted body. Below it the artboard forks into a 1fr / 1.4fr two-pane on
    // wide (photo left, fields right); narrow stacks them.
    final header = <Widget>[
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: p.primaryTint,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, size: 11, color: p.primary),
                const SizedBox(width: 5),
                Text(
                  'AI READ THIS PHOTO',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontFamilyFallback: const [
                      'Consolas',
                      'Menlo',
                      'Courier New',
                      'monospace',
                    ],
                    fontSize: 10.5,
                    letterSpacing: 0.6,
                    fontWeight: FontWeight.w700,
                    color: p.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        "Here's what we read.",
        style: TextStyle(
          fontFamily: 'Instrument Serif',
          fontFamilyFallback: const ['Georgia', 'serif'],
          fontStyle: FontStyle.italic,
          fontSize: 32,
          fontWeight: FontWeight.w400,
          height: 1.05,
          letterSpacing: -0.4,
          color: p.text,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        'These are the details the AI pulled from your document. Here\'s how '
        'to use this page:',
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: p.text,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 6),
      _howToLine(p, Icons.check_box_outlined,
          'A checked box means it will be added to your form. Uncheck '
          'anything you don\'t want.'),
      _howToLine(p, Icons.edit_outlined,
          'Tap any field to edit its wording before it\'s added.'),
      _howToLine(p, Icons.rule,
          'Items under "Needs your decision" would replace something you '
          'already entered — review those.'),
      _howToLine(p, Icons.arrow_forward,
          'When you\'re ready, tap "Autofill Information" at the bottom to '
          'fill these into your form and continue — you\'ll land in the form '
          'to review everything.'),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final twoPane = c.maxWidth >= 720 && _sourceDocs.isNotEmpty;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
          children: [
            ...header,
            const SizedBox(height: 18),
            if (twoPane)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 10, child: _sourceThumb(p)),
                  const SizedBox(width: 18),
                  Expanded(
                    flex: 14,
                    child: _reviewFieldsPane(p, keys, checkedCount, okText),
                  ),
                ],
              )
            else ...[
              if (_sourceDocs.isNotEmpty) ...[
                _sourceThumb(p),
                const SizedBox(height: 16),
              ],
              _reviewFieldsPane(p, keys, checkedCount, okText),
            ],
          ],
        );
      },
    );
  }

  // The extracted-fields column of the review screen (right pane on wide):
  // PII notice → "Add to your directive" label → field rows → privacy lock
  // line → ready-count → NLM attribution.
  Widget _reviewFieldsPane(
    MhadPalette p,
    List<String> keys,
    int checkedCount,
    Color okText,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_piiStripped.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: p.primaryTint,
              border: Border.all(color: p.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.shield_outlined, size: 14, color: p.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'PII was detected and removed before analysis: '
                    '${_piiStripped.toSet().join(", ")}',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11.5,
                      height: 1.4,
                      color: p.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        Text(
          'Add to your directive',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontFamilyFallback: const [
              'Consolas',
              'Menlo',
              'Courier New',
              'monospace',
            ],
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: p.textMuted,
          ),
        ),
        const SizedBox(height: 8),
        _buildReconGroups(p, keys),
        const SizedBox(height: 14),
        // Privacy reassurance lock-line — matches prototype L2082-2087.
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.lock_outline, size: 14, color: p.textMuted),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Your photo was sent to the AI to read, then '
                  'discarded. Nothing is stored after you confirm or '
                  'discard.',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 11.5,
                    color: p.textMuted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$checkedCount of ${keys.length} fields ready to add',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontFamilyFallback: const [
              'Consolas',
              'Menlo',
              'Courier New',
              'monospace',
            ],
            fontSize: 10.5,
            letterSpacing: 0.6,
            color: checkedCount > 0 ? okText : p.textMuted,
          ),
        ),
        const SizedBox(height: 12),
        const NlmAttribution(),
      ],
    );
  }

  /// The extracted fields, grouped into "needs your decision" (high-priority or
  /// conflicting — start unchecked when they'd replace an existing value) and
  /// "autofilled for you" (low-priority, pre-checked). Falls back to a flat
  /// list if reconciliation wasn't built.
  Widget _buildReconGroups(MhadPalette p, List<String> keys) {
    Widget groupCard(List<ReconItem> group) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: p.card,
            border: Border.all(color: p.border),
            borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          ),
          child: Column(
            children: [
              for (var i = 0; i < group.length; i++) ...[
                _reconRow(group[i], p),
                if (i < group.length - 1)
                  Divider(height: 1, color: p.border),
              ],
            ],
          ),
        );

    if (_reconItems.isEmpty) {
      // Safety fallback: original flat list.
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: p.card,
          border: Border.all(color: p.border),
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
        ),
        child: Column(
          children: [
            for (var i = 0; i < keys.length; i++) ...[
              _SnapReviewRow(
                ok: _reviewChecked[keys[i]] ?? false,
                fieldLabel: _displayLabel(keys[i]),
                value: _reviewEdited[keys[i]] ?? '',
                target: _sectionLabel(keys[i]),
                onToggle: () => setState(() => _reviewChecked[keys[i]] =
                    !(_reviewChecked[keys[i]] ?? false)),
                onEdit: () => _editField(keys[i]),
              ),
              if (i < keys.length - 1) Divider(height: 1, color: p.border),
            ],
          ],
        ),
      );
    }

    final groups = ReconGroups.from(_reconItems);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (groups.needsDecision.isNotEmpty) ...[
          _groupLabel('Needs your decision', p),
          const SizedBox(height: 6),
          groupCard(groups.needsDecision),
          const SizedBox(height: 14),
        ],
        if (groups.autoApplied.isNotEmpty) ...[
          _groupLabel('Autofilled for you — review optional', p),
          const SizedBox(height: 6),
          groupCard(groups.autoApplied),
        ],
      ],
    );
  }

  Widget _reconRow(ReconItem it, MhadPalette p) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // A conflict replaces something you already entered — show what.
        if (it.isConflict)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Replaces what you have: "${it.existing}"',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: p.textMuted,
              ),
            ),
          ),
        _SnapReviewRow(
          ok: _reviewChecked[it.key] ?? false,
          fieldLabel: _displayLabel(it.key),
          value: _reviewEdited[it.key] ?? '',
          target: _sectionLabel(it.key),
          onToggle: () => setState(() =>
              _reviewChecked[it.key] = !(_reviewChecked[it.key] ?? false)),
          onEdit: () => _editField(it.key),
        ),
      ],
    );
  }

  Widget _groupLabel(String text, MhadPalette p) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontFamilyFallback: const [
            'Consolas',
            'Menlo',
            'Courier New',
            'monospace',
          ],
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: p.textMuted,
        ),
      );

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

    // Artboard WebSnapReview footer: "Discard all" (left) · "Generate more"
    // (Smart Fill, when conditions/meds were validated) · primary button.
    // Results step keeps Back · Apply All.
    final canSmartFill = _validated?.hasValidatedConditions == true ||
        _validated?.hasValidatedMeds == true;
    // The primary review button is "Autofill Information" in BOTH modes — it
    // applies the checked fields and continues into the wizard (standalone
    // navigates there; the modal pops back to the wizard it was opened over),
    // so the user can verify the autofill. The "N of M fields ready to add"
    // line in the fields pane already communicates the count.
    const addLabel = 'Autofill Information';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        // The primary action is a FULL-WIDTH button on its own line so it can
        // never be clipped off the right edge by a too-narrow footer (the old
        // single-Row layout with a Spacer overflowed and hid this button when
        // "Generate more" was also present or the window was narrow).
        child: _step == _PipelineStep.results
            ? Row(
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        setState(() => _step = _PipelineStep.review),
                    child: const Text('Back'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _applyAll,
                    icon: const Icon(Icons.check),
                    label: const Text('Apply All'),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Secondary actions row.
                  Row(
                    children: [
                      OutlinedButton(
                        onPressed: _discardExtraction,
                        child: const Text('Discard all'),
                      ),
                      const Spacer(),
                      if (canSmartFill)
                        TextButton.icon(
                          onPressed: _runSmartFill,
                          icon: const Icon(Icons.auto_awesome, size: 16),
                          label: const Text('Generate more'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Primary: always enabled, full width — applies the checked
                  // fields and continues into the wizard to verify.
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _applyAll,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            child: Text(addLabel,
                                overflow: TextOverflow.ellipsis),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Editorial extraction-review row matching prototype `ScrSnapReview`
/// L2030-2067. Replaces the prior Material Card + Checkbox row.
///
/// Layout: 22pt rounded checkbox (filled primary when ok, surface with
/// border + X when unchecked) → flex column with monospace UPPERCASE
/// field name + right-aligned "→ Step N · Section" target chip → value
/// in 14pt bold (line-through when unchecked) → 11.5pt muted subtitle
/// → trailing edit pencil icon.
class _SnapReviewRow extends StatelessWidget {
  final bool ok;
  final String fieldLabel;
  final String value;
  final String target;
  final VoidCallback onToggle;
  final VoidCallback onEdit;

  const _SnapReviewRow({
    required this.ok,
    required this.fieldLabel,
    required this.value,
    required this.target,
    required this.onToggle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 22,
              height: 22,
              margin: const EdgeInsets.only(top: 1),
              decoration: BoxDecoration(
                color: ok ? p.primary : p.surface,
                border: ok
                    ? null
                    : Border.all(color: p.border, width: 1.5),
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: ok
                  ? Icon(Icons.check, size: 13, color: p.onPrimary)
                  : Icon(Icons.close, size: 11, color: p.textMuted),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        fieldLabel.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontFamilyFallback: const [
                            'Consolas',
                            'Menlo',
                            'Courier New',
                            'monospace',
                          ],
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: p.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ok ? '→ $target' : 'Not added',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontFamilyFallback: const [
                          'Consolas',
                          'Menlo',
                          'Courier New',
                          'monospace',
                        ],
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: ok ? p.primary : p.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: ok ? p.text : p.textMuted,
                    decoration:
                        ok ? null : TextDecoration.lineThrough,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.edit_outlined,
                  size: 14, color: p.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// One file brought into the standalone snap-to-fill page this session,
/// recorded after its extracted fields are applied. Powers the artboard
/// "In this session · N FILES" row (WebSnapFill jsx L174-251).
class _SessionFile {
  final String name;
  final String kind; // 'Photo' · 'PDF' · 'Text' · 'File'
  final int fieldsAdded;
  const _SessionFile({
    required this.name,
    required this.kind,
    required this.fieldsAdded,
  });
}
