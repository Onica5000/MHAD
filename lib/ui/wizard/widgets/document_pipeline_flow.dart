import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mhad/ai/document_extraction_result.dart';
import 'package:mhad/constants.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/ai/document_extractor.dart';
import 'package:mhad/ai/smart_fill_service.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/providers/assistant_providers.dart';
import 'package:mhad/providers/kept_documents_provider.dart';
import 'package:mhad/services/clinical_data_validator.dart';
import 'package:mhad/services/gemini_rate_tracker.dart';
import 'package:mhad/services/geo_service.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/ai_consent_dialog.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/friendly_error.dart';
import 'package:mhad/ui/widgets/nlm_attribution.dart';
import 'package:mhad/ui/wizard/widgets/document_import_sheet.dart';
import 'package:mhad/ui/wizard/widgets/never_want_crossadd.dart';
import 'package:mhad/ui/wizard/widgets/pipeline_reconciliation.dart';
import 'package:mhad/utils/clipboard_paste.dart';
import 'package:mhad/utils/platform_utils.dart';

part 'pipeline_apply_service.dart';
part 'pipeline_pick_ui.dart';
part 'pipeline_review_widget.dart';

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
    // batch lives in the session-scoped [keptDocumentsProvider], so the
    // documents survive an AI read, a discard/back to the pick step, AND
    // navigating into the wizard and back — they stay in memory until the user
    // explicitly clears the tray ("Clear all") or the web session ends (tab
    // closed / refresh). This lets the user re-read the same documents without
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
    if (d.mimeType.startsWith('audio/')) return 'Audio';
    return 'File';
  }
  _PipelineStep _step = _PipelineStep.pick;
  String _statusMessage = '';
  String? _error;

  // Monotonic id of the current extract/validate run. Cancel bumps it, so
  // any in-flight run notices its id is stale after the next await and
  // stops without applying anything (UX audit B8 — a long AI read used to
  // be unabortable).
  int _processingRunId = 0;

  /// Aborts the in-flight extract/validate run and returns to the pick
  /// step. The stale run's awaits still complete but their results are
  /// discarded (checked via [_processingRunId]).
  void _cancelProcessing() {
    _processingRunId++;
    setState(() {
      _step = _PipelineStep.pick;
      _statusMessage = '';
      _error = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Processing cancelled — nothing was applied.')),
    );
  }

  // The form the user is filling. In modal mode it's fixed (the wizard's type);
  // in standalone the user picks it BEFORE extraction so the AI only reads/
  // returns the fields that form uses. Defaults to the constructor value.
  late String _activeFormType = widget.formType;

  // Per-field "Consolidate" (AI merge) in-flight flags — keyed by review key.
  // Held here (not in the review extension, which can't own state).
  final Map<String, bool> _consolidating = {};

  // True while a file is being dragged over the Snap-to-fill drop zone.
  bool _dragOver = false;

  // The documents being processed — retained so the review step can show a
  // source thumbnail of what the AI read.
  List<PickedDocument> _sourceDocs = const [];

  // Documents the user has selected/dropped/pasted/snapped. They live in the
  // session-scoped [keptDocumentsProvider] (not this widget's State) so the
  // held files SURVIVE navigating into the wizard and back — the pick step
  // shows an always-visible list of every kept document. The extractor/AI is
  // only called when the user explicitly taps "Read with AI" (see
  // _readPendingDocs): selecting a file never fires the AI automatically.
  List<PickedDocument> get _pendingDocs => ref.read(keptDocumentsProvider);

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
          'conditions, care preferences, and your contact details. It needs an '
          "AI key — Gemini's free tier takes about 30 seconds to set up. You "
          'review every field before anything lands in your form.',
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
    // Audio (spoken description) — Gemini transcribes + extracts.
    'mp3': 'audio/mp3',
    'm4a': 'audio/mp4',
    'wav': 'audio/wav',
    'aac': 'audio/aac',
    'ogg': 'audio/ogg',
    'oga': 'audio/ogg',
    'flac': 'audio/flac',
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

    // Extraction needs an AI key. On web (public mode) the user often has
    // none — prompt to set it up rather than silently doing nothing, so the
    // snap-to-fill page never feels like a dead end.
    final aiCfg = ref.read(aiConfigProvider);
    if (aiCfg == null) {
      await _promptAiSetup();
      return;
    }

    // Standalone: pick which form to fill BEFORE anything is sent to the AI, so
    // it only reads / returns the fields that form uses (POA = agent-only,
    // Declaration = preferences-only). Modal mode already has a fixed form.
    if (_standalone) {
      final chosen = await showDialog<FormType>(
        context: context,
        builder: (_) => const _FormTypeChooser(),
      );
      if (chosen == null || !mounted) return; // cancelled → stay on pick
      _activeFormType = chosen.name;
      await ref
          .read(directiveRepositoryProvider)
          .updateFormType(widget.directiveId, chosen);
    }

    // Single, accurate consent + data notice for the autofill upload. This is
    // the ONE AI path that sends the document's personal details to Google
    // (every other path strips PII), so it has its own notice rather than the
    // generic showAiConsentDialog, whose "never send personal info" wording
    // would contradict how autofill works. Shown before each read; on accept we
    // also record the session AI-consent flag so chat/suggest don't re-prompt.
    if (!mounted) return;
    final authorized =
        await showAutofillConsentDialog(context, provider: aiCfg.provider);
    if (!authorized || !mounted) return;
    ref.read(aiConsentGivenProvider.notifier).state = true;

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
    final runId = ++_processingRunId;
    // Stale after Cancel (or a newer run) — results must be discarded.
    bool cancelled() => !mounted || runId != _processingRunId;
    setState(() {
      _step = _PipelineStep.extracting;
      _statusMessage = 'Extracting page 1 of ${docs.length}...';
    });

    DocumentExtractor? extractor;
    try {
      extractor = DocumentExtractor(
        apiKey: aiCfg.key,
        provider: aiCfg.provider,
        model: aiCfg.model,
      );
      DocumentExtractionResult? merged;
      final allPii = <String>[];
      // Relevance gate: an unrelated upload (lease, bill, contract, …) comes
      // back documentRelevant=false with nothing extracted. Track whether any
      // uploaded file was actually a health/care document.
      var anyRelevant = false;
      String? irrelevantKind;

      for (var i = 0; i < docs.length; i++) {
        if (cancelled()) return;
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
          formType: _activeFormType,
        );
        if (cancelled()) return;

        // Record this extraction in the rate tracker
        // Images: ~258 tokens per 768x768 tile; 1024px image ≈ 2 tiles ≈ 516 tokens
        // PDFs: ~500 tokens per page estimate
        // Audio: ~32 tokens/sec; byte length is a poor proxy (high-bitrate files
        //   are huge but Gemini downsamples to 16kHz mono), so use a flat
        //   estimate for a few minutes of speech.
        // Text: chars / 4
        final estimatedTokens = docs[i].mimeType.startsWith('image/')
            ? 800 // prompt + ~2 image tiles
            : docs[i].mimeType == 'application/pdf'
                ? 1500 // prompt + PDF page
                : docs[i].mimeType.startsWith('audio/')
                    ? 4000 // prompt + a few minutes of transcribed speech
                    : GeminiRateTracker.estimateTokens(docBytes.length) + 500;
        tracker.recordRequest(estimatedTokens: estimatedTokens);

        allPii.addAll(extraction.strippedPiiCategories);

        final res = extraction.result;
        if (res.documentRelevant) {
          anyRelevant = true;
        } else {
          irrelevantKind ??= res.documentKind;
        }

        if (merged == null) {
          merged = res;
        } else {
          merged = merged.merge(res);
        }
      }

      if (cancelled()) return;
      _piiStripped = allPii;

      // No uploaded file was a health/care document — refuse to use any of it.
      if (!anyRelevant) {
        setState(() {
          final kind = (irrelevantKind != null && irrelevantKind.isNotEmpty)
              ? ' (it looks like a $irrelevantKind)'
              : '';
          _error = docs.length == 1
              ? "This doesn't look like a health or medical document$kind, so "
                  'nothing was used. Upload a medical record, medication or '
                  'allergy list, or an existing advance directive.'
              : "These don't look like health or medical documents$kind, so "
                  'nothing was used.';
          _step = _PipelineStep.pick;
        });
        return;
      }

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
      if (cancelled()) return;

      // Build review data + reconcile against the directive's current values
      _validated = validated;
      _buildReviewData(validated);
      // Keyless geo backfill: when the AI read a ZIP but missed the city /
      // state / county, fill them from the ZIP (Zippopotam + FCC) so the
      // declarant + designated people land more complete. Best-effort.
      await _geoBackfillReview();
      if (cancelled()) return;
      await _buildReconciliation();
      if (cancelled()) return;

      setState(() => _step = _PipelineStep.review);
    } catch (e) {
      // A cancelled run's failure must not clobber the pick step's state.
      if (mounted && runId == _processingRunId) {
        setState(() {
          _error = FriendlyError.from(e);
          _step = _PipelineStep.pick;
        });
      }
    } finally {
      extractor?.dispose();
    }
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
          if (_step == _PipelineStep.generating) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please wait while processing...')),
            );
          } else {
            // Back during extract/validate = cancel back to the pick step
            // (UX audit B8) — the user can then leave normally.
            _cancelProcessing();
          }
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
                        fontFamily: kSansFamily,
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

  /// Append newly picked/dropped/pasted/snapped documents to the kept list
  /// (de-duplication lives in [KeptDocumentsNotifier.addAll]). Nothing is sent
  /// to the AI here — the user reads the batch explicitly via [_readPendingDocs].
  void _addPending(List<PickedDocument> docs) {
    if (docs.isEmpty) return;
    setState(() => _error = null);
    ref.read(keptDocumentsProvider.notifier).addAll(docs);
  }

  void _removePending(PickedDocument doc) {
    ref.read(keptDocumentsProvider.notifier).remove(doc);
  }

  void _clearPending() {
    ref.read(keptDocumentsProvider.notifier).clear();
  }

  /// The explicit "send to AI" action. Snapshots the held tray (so removing a
  /// pending file mid-extraction can't mutate what's being read) and runs the
  /// extraction → validate → review pipeline over it.
  void _readPendingDocs() {
    if (_pendingDocs.isEmpty) return;
    _startPipeline(List<PickedDocument>.of(_pendingDocs));
  }


}

/// Form-type chooser shown BEFORE autofill, so the AI only reads/returns the
/// fields that form uses. No AI suggestion is available yet (the document
/// hasn't been read), so it opens on the broadest option, Combined.
class _FormTypeChooser extends StatefulWidget {
  const _FormTypeChooser();

  @override
  State<_FormTypeChooser> createState() => _FormTypeChooserState();
}

class _FormTypeChooserState extends State<_FormTypeChooser> {
  FormType _selected = FormType.combined;

  String _title(FormType ft) => switch (ft) {
        FormType.combined => 'Combined',
        FormType.declaration => 'Declaration only',
        FormType.poa => 'Power of Attorney only',
      };

  String _subtitle(FormType ft) => switch (ft) {
        FormType.combined =>
          'Treatment preferences AND a decision-maker (broadest).',
        FormType.declaration =>
          'Treatment preferences, without naming an agent.',
        FormType.poa => 'Name a decision-maker, without listing preferences.',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AlertDialog(
      title: const Text('Which form do you want to fill?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose your form first — the AI will then read only the parts that '
            'form needs. Combined is the broadest; you can change this later.',
          ),
          const SizedBox(height: 8),
          for (final ft in FormType.values)
            InkWell(
              onTap: () => setState(() => _selected = ft),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _selected == ft
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 20,
                      color: _selected == ft ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_title(ft),
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          Text(_subtitle(ft),
                              style: TextStyle(
                                  fontSize: 12, color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
