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
import 'package:mhad/providers/kept_documents_provider.dart';
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

part 'pipeline_apply_service.dart';
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

    // Single, accurate consent + data notice for the autofill upload. This is
    // the ONE AI path that sends the document's personal details to Google
    // (every other path strips PII), so it has its own notice rather than the
    // generic showAiConsentDialog, whose "never send personal info" wording
    // would contradict how autofill works. Shown before each read; on accept we
    // also record the session AI-consent flag so chat/suggest don't re-prompt.
    final authorized = await showAutofillConsentDialog(context);
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

  Widget _buildPickStep() {
    final p = Theme.of(context).mhadPalette;
    final hasKey = ref.watch(apiKeyProvider).valueOrNull?.isNotEmpty == true;
    // Watch (not read) so the kept-documents tray rebuilds as docs are added/
    // removed and stays in sync across navigation back to this page.
    final kept = ref.watch(keptDocumentsProvider);
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
                  fontFamily: kSansFamily,
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
                        fontFamily: kSansFamily,
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
              // Every document kept this session (session-scoped provider, so
              // it persists across navigation into the wizard and back). The AI
              // is only called when the user taps "Read … with AI" in the tray.
              if (kept.isNotEmpty) ...[
                const SizedBox(height: 22),
                _pendingDocsTray(p, hasKey, kept),
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

  // The kept-documents tray: every file the user selected/dropped/pasted/
  // snapped this session, held in memory and listed here whether or not it has
  // been read yet. Each row can be removed; the primary button is the only
  // thing that actually calls the extractor (_readPendingDocs).
  Widget _pendingDocsTray(MhadPalette p, bool hasKey, List<PickedDocument> kept) {
    final n = kept.length;
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
              const SectionLabel('Your documents'),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$n FILE${n == 1 ? '' : 'S'} · KEPT IN MEMORY',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: kMonoFamily,
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
          for (final d in kept) _pendingDocRow(p, d),
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
                          'Read — then it goes to Google\'s AI to read.'
                      : 'Held on this device. Reading needs AI set up first '
                          '(free, ~30 seconds) — nothing is sent until then.',
                  style: TextStyle(
                    fontFamily: kSansFamily,
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
                    fontFamily: kSansFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.text,
                  ),
                ),
                if (size.isNotEmpty)
                  Text(
                    '${_docKind(d)} · $size',
                    style: TextStyle(
                      fontFamily: kSansFamily,
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
                    fontFamily: kSansFamily,
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
              fontFamily: kSansFamily,
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
                fontFamily: kSansFamily,
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
                fontFamily: kSansFamily,
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
                        fontFamily: kSansFamily,
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
                      fontFamily: kSansFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.$3,
                    style: TextStyle(
                      fontFamily: kSansFamily,
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
                          fontFamily: kSansFamily,
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
                          fontFamily: kSansFamily,
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
                fontFamily: kSansFamily,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: kSansFamily,
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
                                  fontFamily: kSansFamily,
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
                                    fontFamily: kMonoFamily,
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
                            fontFamily: kSansFamily,
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
                fontFamily: kSansFamily,
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
                      fontFamily: kSansFamily,
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
                                fontFamily: kSansFamily,
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
                    fontFamily: kSansFamily,
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
                    fontFamily: kSansFamily,
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
                  fontFamily: kSansFamily,
                  fontSize: 12.5,
                  height: 1.45,
                  color: p.textMuted,
                ),
              ),
            ),
          ],
        ),
      );

}
