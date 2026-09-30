import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mhad/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/utils/nav_utils.dart';
import 'package:mhad/ui/export/export_cards.dart';
import 'package:mhad/ui/export/pdf_preview_screen.dart';
import 'package:mhad/ui/export/pdf/pdf_generator.dart';
import 'package:mhad/ui/export/pdf/pdf_helpers.dart';
import 'package:mhad/ui/export/pdf/wallet_card_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wallet_card.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/services/blank_form_service.dart';
import 'package:mhad/services/directive_export_service.dart';
import 'package:mhad/services/export_formats_service.dart';
import 'package:mhad/services/fhir_export_service.dart';
import 'package:mhad/utils/a11y_announce.dart';
import 'package:mhad/utils/background_runner.dart';
import 'package:mhad/utils/open_pdf.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportScreen extends ConsumerStatefulWidget {
  final int directiveId;
  const ExportScreen({required this.directiveId, super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen> {
  bool _includeCombined = true;
  bool _includeDeclaration = false;
  bool _includePoa = false;
  bool _includeSupplementary = false;
  bool _includeNotes = false;
  bool _isGenerating = false;

  /// Whether the "editable copy" download is obfuscated (default) or plaintext.
  bool _encryptEditableCopy = true;

  /// Printed-copy types to produce. The user can tick more than one and get a
  /// separate PDF for each (e.g. a clean final copy AND a watermarked draft).
  final Set<DraftMode> _draftModes = {DraftMode.finalCopy};

  /// false = the canonical official form (signed/used, recommended default);
  /// true = the informational legal-language rendering. Convenience only.
  bool _legalLanguage = false;

  /// Canonical order for the copy types (used for stable file ordering + UI).
  static const _draftModeOrder = [
    DraftMode.finalCopy,
    DraftMode.draftGeneral,
    DraftMode.draftSignedAvailable,
  ];

  /// The single copy type used where only one PDF makes sense (the on-screen
  /// preview and the .zip bundle): prefer the final copy, else the first ticked.
  DraftMode get _previewMode => _draftModes.contains(DraftMode.finalCopy)
      ? DraftMode.finalCopy
      : (_draftModes.isEmpty ? DraftMode.finalCopy : _draftModes.first);

  String _draftModeLabel(DraftMode m) => switch (m) {
        DraftMode.finalCopy => context.l10n.exportDraftModeFinal,
        DraftMode.draftGeneral => context.l10n.exportDraftModeDraft,
        DraftMode.draftSignedAvailable =>
          context.l10n.exportDraftModeSignedExists,
      };

  String _draftModeFileSuffix(DraftMode m) => switch (m) {
        DraftMode.finalCopy => 'final',
        DraftMode.draftGeneral => 'draft',
        DraftMode.draftSignedAvailable => 'draft-signed-copy-available',
      };

  // The `pdf` Dart package does not support native PDF encryption, so the
  // file produced here is unprotected by design. We compensate at the UX
  // layer: a persistent banner above the share button + a one-time-per-
  // session acknowledgement before the first share (V4-M8).
  static bool _unprotectedAcked = false;

  // Loaded directive data
  Directive? _directive;
  List<Agent> _agents = [];
  DirectivePref? _prefs;
  AdditionalInstructionsTableData? _additional;
  GuardianNomination? _guardian;
  List<MedicationEntry> _medications = [];
  List<WitnessesData> _witnesses = [];
  List<DiagnosisEntry> _diagnoses = [];
  List<DirectiveAllergy> _allergies = [];
  bool _loading = true;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(directiveRepositoryProvider);
    final bundle = await repo.loadBundle(widget.directiveId);
    if (!mounted) return;
    if (bundle == null) {
      // The id didn't resolve (e.g. a stale link, or the in-memory web DB was
      // cleared). Don't spin forever — surface a graceful empty state.
      setState(() {
        _loading = false;
        _notFound = true;
      });
      return;
    }

    final directive = bundle.directive;
    final formType = FormType.values.firstWhere(
      (e) => e.name == directive.formType,
      orElse: () => FormType.combined,
    );

    setState(() {
      _directive = directive;
      _agents = bundle.agents;
      _prefs = bundle.prefs;
      _additional = bundle.additional;
      _guardian = bundle.guardian;
      _medications = bundle.medications;
      _witnesses = bundle.witnesses;
      _diagnoses = bundle.diagnoses;
      _allergies = bundle.allergies;
      _loading = false;

      // Pre-select the form type the user filled in
      _includeCombined = formType == FormType.combined;
      _includeDeclaration = formType == FormType.declaration;
      _includePoa = formType == FormType.poa;
    });
  }

  Future<void> _generateAndShare() async {
    if (!_includeCombined && !_includeDeclaration && !_includePoa &&
        !_includeSupplementary && !_includeNotes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.exportSelectAtLeastOneSection)),
      );
      return;
    }

    // Completeness check — warn about missing critical fields
    final warnings = <String>[];
    if (_directive != null) {
      if (_directive!.fullName.isEmpty) warnings.add(context.l10n.fullName);
      if (_directive!.dateOfBirth.isEmpty) warnings.add(context.l10n.dateOfBirth);
      if (_directive!.effectiveCondition.isEmpty) {
        warnings.add(context.l10n.exportEffectiveCondition);
      }
      if (_directive!.status == 'draft') {
        final hasSignatures = _witnesses.any(
            (w) => w.signatureBase64 != null && w.signatureBase64!.isNotEmpty);
        if (!hasSignatures) warnings.add(context.l10n.exportWitnessSignatures);
      }
    }
    if (warnings.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(context.l10n.exportIncompleteDirective),
          content: Text(
            context.l10n.exportTheFollowingFieldsAreEmpty(warnings.map((w) => '  \u2022 $w').join('\n')),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.exportGoBack),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx, false);
                context.go(AppRoutes.wizardRoute(widget.directiveId));
              },
              child: Text(context.l10n.exportEditDirective),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.exportExportAnyway),
            ),
          ],
        ),
      );
      if (proceed != true || !mounted) return;
    }

    // V4-M8 — one-time-per-session unprotected-file acknowledgement. The PDF
    // contains full directive PII and is shared via the OS share sheet with
    // no built-in encryption. Users must be told plainly, once.
    if (!_unprotectedAcked) {
      final ackd = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.lock_open_outlined, size: 32),
          title: Text(context.l10n.exportExportedFileIsNotEncrypted),
          content: Text(
            context.l10n.exportThePdfYouAreAbout,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(context.l10n.cancel),
            ),
            FilledButton(
              // Initial focus on the primary action (UX audit A3).
              autofocus: true,
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(context.l10n.exportIUnderstandContinue),
            ),
          ],
        ),
      );
      if (ackd != true || !mounted) return;
      _unprotectedAcked = true;
    }

    setState(() => _isGenerating = true);

    try {
      final directive = _directive!;
      final agents = _agents;
      final prefs = _prefs;
      final additional = _additional;
      final guardian = _guardian;
      final medications = _medications;
      final witnesses = _witnesses;

      // One PDF per ticked copy type (final / draft / draft-signed-available),
      // so the user can grab several at once. Suffix filenames only when more
      // than one is produced.
      final modes = _draftModeOrder.where(_draftModes.contains).toList();
      if (modes.isEmpty) modes.add(DraftMode.finalCopy);
      final safeName = directive.fullName.replaceAll(' ', '_');

      for (final mode in modes) {
        final generator = PdfGenerator(
          includeCombined: _includeCombined,
          includeDeclaration: _includeDeclaration,
          includePoa: _includePoa,
          includeSupplementary: _includeSupplementary,
          includeNotes: _includeNotes,
          draftMode: mode,
          legalLanguage: _legalLanguage,
        );
        final bytes = await runInBackground(() => generator.generate(
          directive: directive,
          agents: agents,
          prefs: prefs,
          additional: additional,
          guardian: guardian,
          medications: medications,
          witnesses: witnesses,
          diagnoses: _diagnoses,
          allergies: _allergies,
        ));
        if (!mounted) return;
        final suffix = modes.length > 1 ? '_${_draftModeFileSuffix(mode)}' : '';
        final fname = 'PA_MHAD_$safeName$suffix.pdf';
        // Open in the user's PDF viewer (a new browser tab on web) instead of
        // force-downloading — they choose Print or Download there. Fall back to
        // the print/save dialog on native or if the browser blocks the tab.
        final opened = await openPdfInViewer(bytes, filename: fname);
        if (!opened && mounted) {
          await Printing.layoutPdf(onLayout: (_) => bytes, name: fname);
        }
      }
      if (kIsWeb && mounted) {
        final msg = modes.length > 1
            ? context.l10n.exportOpenedManyPdfs(modes.length)
            : context.l10n.exportOpenedOnePdf;
        // Announce for screen readers too — the snackbar alone is not
        // reliably read on web (UX audit A4).
        announce(context, msg);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg)),
        );
      }
    } catch (e) {
      debugPrint('PDF export failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.exportCouldnTGenerateThePdf),
            action: SnackBarAction(
                label: context.l10n.retry, onPressed: _generateAndShare),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  /// Generates the selected-sections PDF bytes (off the UI thread). Shared by
  /// the inline live preview and the full-screen preview / share paths.
  Future<Uint8List> _buildPdfBytes() {
    final generator = PdfGenerator(
      includeCombined: _includeCombined,
      includeDeclaration: _includeDeclaration,
      includePoa: _includePoa,
      includeSupplementary: _includeSupplementary,
      includeNotes: _includeNotes,
      draftMode: _previewMode,
      legalLanguage: _legalLanguage,
    );
    return runInBackground(() => generator.generate(
          directive: _directive!,
          agents: _agents,
          prefs: _prefs,
          additional: _additional,
          guardian: _guardian,
          medications: _medications,
          witnesses: _witnesses,
          diagnoses: _diagnoses,
          allergies: _allergies,
        ));
  }

  /// A signature of the current section selection — used to key the inline
  /// preview so it only re-renders when the selection actually changes.
  String _selectionSignature() => [
        _includeCombined,
        _includeDeclaration,
        _includePoa,
        _includeSupplementary,
        _includeNotes,
        _directive?.updatedAt,
      ].join('|');

  Future<void> _previewPdf() async {
    if (!_includeCombined && !_includeDeclaration && !_includePoa &&
        !_includeSupplementary && !_includeNotes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.exportSelectAtLeastOneSection2)),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final bytes = await _buildPdfBytes();

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PdfPreviewScreen(pdfBytes: bytes),
        ),
      );
    } catch (e) {
      debugPrint('PDF export failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.exportCouldnTGenerateThePdf),
            action: SnackBarAction(label: context.l10n.retry, onPressed: _previewPdf),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  // ---------------------------------------------------------------------------
  // build() helpers — each returns a widget or widget list; build() composes.
  // ---------------------------------------------------------------------------

  Widget _loadingState() => Scaffold(
        body: Center(
          child: Semantics(
            label: context.l10n.reviewStepLoading,
            child: const CircularProgressIndicator(),
          ),
        ),
      );

  Widget _notFoundState() {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: Column(
        children: [
          WizardHeader(
            backLabel: context.l10n.back,
            onBack: () => safeBack(context),
            actionLabel: '',
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.description_outlined,
                        size: 48, color: p.textMuted),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.exportNothingToDownloadYet,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: p.text,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.exportStartADirectiveFirstThen,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: kSansFamily,
                        fontSize: 13,
                        height: 1.4,
                        color: p.textMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => context.go(AppRoutes.home),
                      icon: const Icon(Icons.add),
                      label: Text(context.l10n.homeStartYourDirective),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Legal “before sharing” disclaimer (PA Act 194 — legally substantive).
  // These presentational pieces live in export_cards.dart; the thin wrappers
  // keep the existing call sites unchanged.
  Widget _buildLegalDisclaimerCard() => const ExportLegalDisclaimerCard();

  Widget _buildPrincipalCard() => _directive == null
      ? const SizedBox.shrink()
      : ExportPrincipalCard(directive: _directive!);

  // V4-M8 — persistent banner: the PDF is unencrypted by design.
  Widget _buildUnencryptedBanner() => const ExportUnencryptedBanner();

  List<Widget> _buildHeaderChildren(MhadPalette p) => [
        SectionLabel(context.l10n.pdfPreviewExportShare),
        EditorialHeading(
          textSpan: TextSpan(
            children: [
              TextSpan(text: context.l10n.exportYourDirective),
              TextSpan(
                text: context.l10n.pdfPreviewOnPaper,
                style: TextStyle(color: p.primary),
              ),
            ],
          ),
          size: 36,
          height: 1.05,
          letterSpacing: -0.8,
        ),
        const SizedBox(height: 16),
        if (_isGenerating)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: LinearProgressIndicator(borderRadius: BorderRadius.circular(DesignTokens.radiusXs)),
          ),
        _buildLegalDisclaimerCard(),
        const SizedBox(height: 16),
        _buildPrincipalCard(),
        const SizedBox(height: 16),
      ];

  // Form/section pickers — shared by the narrow Document column and the wide
  // right-hand control rail.
  List<Widget> _buildSectionCheckboxChildren() => [
        Text(context.l10n.exportSelectFormsToInclude,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _FormCheckbox(
          title: context.l10n.combinedForm,
          subtitle: context.l10n.exportDeclarationPowerOfAttorneyMost,
          value: _includeCombined,
          onChanged: (v) => setState(() => _includeCombined = v ?? false),
          warning: _includeCombined && _agents.isEmpty
              ? context.l10n.exportNoAgentDesignated
              : null,
        ),
        _FormCheckbox(
          title: context.l10n.declarationOnly,
          subtitle: context.l10n.exportTreatmentPreferencesOnlyNoAgent,
          value: _includeDeclaration,
          onChanged: (v) => setState(() => _includeDeclaration = v ?? false),
        ),
        _FormCheckbox(
          title: context.l10n.poaOnly,
          subtitle: context.l10n.exportAgentAuthorityOnlyNoPersonal,
          value: _includePoa,
          onChanged: (v) => setState(() => _includePoa = v ?? false),
          warning: _includePoa && _agents.isEmpty
              ? context.l10n.exportNoAgentDesignated
              : null,
        ),
        const SizedBox(height: 16),
        Text(context.l10n.exportAdditionalPages,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _FormCheckbox(
          title: context.l10n.exportSupplementaryLegalInformation,
          subtitle: context.l10n.exportAdditionalLegalReferenceInformation,
          value: _includeSupplementary,
          onChanged: (v) => setState(() => _includeSupplementary = v ?? false),
        ),
        _FormCheckbox(
          title: context.l10n.exportDistributionChecklistNotes,
          subtitle: context.l10n.exportBlankPagesForHandwrittenNotes,
          value: _includeNotes,
          onChanged: (v) => setState(() => _includeNotes = v ?? false),
        ),
        // Blank official forms (any of the three types) — for filling in by
        // hand; separate from this directive's data.
        TextButton.icon(
          onPressed: () => showBlankFormPicker(context),
          icon: const Icon(Icons.print_outlined, size: 18),
          label: Text(context.l10n.exportPrintABlankFormFill),
        ),
      ];

  // Narrow single-column “Document” block: section pickers, Preview button,
  // unencrypted-file banner.
  List<Widget> _buildDocumentChildren() => [
        ..._buildSectionCheckboxChildren(),
        const SizedBox(height: 24),
        Semantics(
          button: true,
          label: _isGenerating
              ? context.l10n.exportGeneratingPdfPreview
              : context.l10n.exportPreviewPdfBeforeSharing,
          child: FilledButton.icon(
            onPressed: _isGenerating ? null : _previewPdf,
            icon: _isGenerating
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: Semantics(
                      label: context.l10n.reviewStepLoading,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.preview),
            label: Text(context.l10n.previewPdf),
          ),
        ),
        const SizedBox(height: 8),
        _buildUnencryptedBanner(),
      ];

  // Consistent section header + explanation styling for the distribution rail.
  Widget _railTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          text,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
      );

  Widget _railBody(String text) => Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );

  // RIGHT / “Distribution” pane, organized into three groups:
  //   1. Your official directive — configure (copy type, language) then Download.
  //   2. Keep a copy — wallet card + an editable progress file.
  //   3. Advanced — machine-readable data exports.
  List<Widget> _buildDistributionChildren() => [
        // ── 1. Your official directive ───────────────────────────────────
        // Group headers (UX audit C5): the narrow layout renders this list
        // as one long scroll, so the three groups get visible SectionLabel
        // landmarks (they read equally well in the wide rail).
        SectionLabel(context.l10n.exportYourOfficialDirective),
        const SizedBox(height: 8),
        _railTitle(context.l10n.exportPrintedCopyType),
        _railBody(
          context.l10n.exportADraftPrintsALight,
        ),
        const SizedBox(height: 4),
        for (final m in _draftModeOrder)
          CheckboxListTile(
            value: _draftModes.contains(m),
            onChanged: (v) => setState(() {
              if (v == true) {
                _draftModes.add(m);
              } else if (_draftModes.length > 1) {
                // Keep at least one selected so Download always has a copy.
                _draftModes.remove(m);
              }
            }),
            title: Text(_draftModeLabel(m)),
            dense: true,
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        const SizedBox(height: 16),
        _railTitle(context.l10n.exportDocumentLanguage),
        _railBody(
          context.l10n.exportThePlainLanguageOfficialForm,
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(
              value: false,
              label: Text(context.l10n.exportPlainSignable),
              icon: Icon(Icons.verified_outlined),
            ),
            ButtonSegment(
              value: true,
              label: Text(context.l10n.exportLegalInfoOnly),
              icon: Icon(Icons.description_outlined),
            ),
          ],
          selected: {_legalLanguage},
          onSelectionChanged: (s) => setState(() => _legalLanguage = s.first),
        ),
        if (_legalLanguage) ...[
          const SizedBox(height: 8),
          Text(
            context.l10n.exportHeadsUpTheLegalLanguage,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
          ),
        ],
        const SizedBox(height: 16),
        _railBody(
          context.l10n.exportThisOpensYourDirectiveIn,
        ),
        const SizedBox(height: 8),
        // Primary action — placed after the settings that control it. Opens the
        // PDF in a viewer rather than force-downloading (see _generateAndShare).
        Semantics(
          button: true,
          label: context.l10n.exportOpenThePdfDirectiveIn,
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _generateAndShare,
              icon: const Icon(Icons.open_in_new),
              label: Text(context.l10n.exportOpenPdf),
            ),
          ),
        ),
        if (_directive != null) ...[
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          // ── 2. Keep a copy ─────────────────────────────────────────────
          SectionLabel(context.l10n.exportKeepACopy),
          const SizedBox(height: 8),
          _railTitle(context.l10n.exportWalletCard),
          _railBody(context.l10n.exportACreditCardSizedSummary),
          const SizedBox(height: 8),
          WalletCard(
            principalName: _directive!.fullName.trim().isEmpty
                ? context.l10n.exportWalletYourName
                : _directive!.fullName,
            agentName: _walletAgent?.fullName,
            agentPhone: _walletAgent?.bestPhone,
            validThrough: _walletValidThrough(context.l10n),
            qrPayload: 'MHAD-${widget.directiveId}',
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isGenerating ? null : _generateWalletCard,
              icon: const Icon(Icons.credit_card),
              label: Text(context.l10n.exportOpenWalletCardPdf),
            ),
          ),
          const SizedBox(height: 16),
          _railTitle(context.l10n.exportSaveAnEditableCopy),
          _railBody(
            context.l10n.exportNotAFinishedDocumentThis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Checkbox(
                value: _encryptEditableCopy,
                onChanged: (v) =>
                    setState(() => _encryptEditableCopy = v ?? true),
              ),
              Expanded(child: Text(context.l10n.exportEncryptTheFile)),
            ],
          ),
          _railBody(
            context.l10n.exportEncryptingHindersOthersFromReading,
          ),
          const SizedBox(height: 8),
          Semantics(
            button: true,
            label: context.l10n.exportDownloadAnEditableCopyOf,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _isGenerating ? null : _downloadEditableCopy,
                icon: const Icon(Icons.download_outlined),
                label: Text(context.l10n.exportDownload),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          // ── 3. Advanced: machine-readable data ─────────────────────────
          SectionLabel(context.l10n.exportAdvancedDataExports),
          const SizedBox(height: 8),
          _railTitle(context.l10n.exportMachineReadableFormats),
          _railBody(
            context.l10n.exportYourPdfAboveIsThe,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Semantics(
                button: true,
                label: context.l10n.exportExportAsFhirJsonFor,
                child: OutlinedButton.icon(
                  onPressed: _exportFhir,
                  icon: const Icon(Icons.integration_instructions),
                  label: Text(context.l10n.exportFhirJson),
                ),
              ),
              Semantics(
                button: true,
                label: context.l10n.exportExportAsFhirXmlFor,
                child: OutlinedButton.icon(
                  onPressed: _exportFhirXml,
                  icon: const Icon(Icons.code),
                  label: Text(context.l10n.exportFhirXml),
                ),
              ),
              Semantics(
                button: true,
                label: context.l10n.exportExportAsCsvSpreadsheet,
                child: OutlinedButton.icon(
                  onPressed: _exportCsv,
                  icon: const Icon(Icons.table_chart_outlined),
                  label: Text(context.l10n.exportCsv),
                ),
              ),
              Semantics(
                button: true,
                label:
                    context.l10n.exportDownloadEverythingPdfJsonXml,
                child: OutlinedButton.icon(
                  onPressed: _isGenerating ? null : _exportZipBundle,
                  icon: const Icon(Icons.folder_zip_outlined),
                  label: Text(context.l10n.exportZipBundle),
                ),
              ),
            ],
          ),
        ],
        // Export is the end of the flow, so close with a clear way back home.
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        Semantics(
          button: true,
          label: context.l10n.exportDoneBackToHome,
          child: FilledButton.icon(
            onPressed: () => context.go(AppRoutes.home),
            icon: const Icon(Icons.home_outlined),
            label: Text(context.l10n.exportDoneBackToHome),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
      ];

  // Wide layout: live PDF preview (left+middle) + control rail (right).
  // Uses the TOTAL window width, not post-sidebar content width — the
  // persistent WebSidebar eats 232px, so a content-based >=1000 check would
  // only flip to two-pane above ~1232px, leaving a dead narrow-column band.
  Widget _wideLayout(MhadPalette p) {
    final anySelected = _includeCombined ||
        _includeDeclaration ||
        _includePoa ||
        _includeSupplementary ||
        _includeNotes;
    // FocusTraversalGroups (UX audit A8): Tab finishes the preview pane
    // before entering the control rail, keeping keyboard order = reading
    // order across the two panes.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT + MIDDLE — the preview widget renders its own control panel
        // (heading, page counter, zoom, page-thumbnail selector) on the left
        // and the page image in the middle.
        Expanded(
          child: FocusTraversalGroup(
            child: ExportPdfPreview(
              signature: _selectionSignature(),
              buildBytes: _buildPdfBytes,
              hasSelection: anySelected,
              ready: _directive != null,
              onClose: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
        // RIGHT — control rail.
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: p.card,
            border: Border(left: BorderSide(color: p.border)),
          ),
          child: FocusTraversalGroup(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isGenerating)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(
                          borderRadius: BorderRadius.circular(DesignTokens.radiusXs)),
                    ),
                  _buildLegalDisclaimerCard(),
                  const SizedBox(height: 16),
                  ..._buildSectionCheckboxChildren(),
                  const SizedBox(height: 16),
                  _buildUnencryptedBanner(),
                  const SizedBox(height: 4),
                  ..._buildDistributionChildren(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _narrowLayout(MhadPalette p) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        children: [
          ..._buildHeaderChildren(p),
          ..._buildDocumentChildren(),
          ..._buildDistributionChildren(),
          const SizedBox(height: 40),
        ],
      );

  @override
  Widget build(BuildContext context) {
    if (_loading) return _loadingState();
    if (_notFound || _directive == null) return _notFoundState();

    final p = Theme.of(context).mhadPalette;
    // Prototype Export-class screens (ScrPdfPreview L1132+, ScrAppleWallet
    // mobile-extra2.jsx L5-113) use a thin in-body back chevron, not an AppBar.
    final isWide =
        MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      body: Column(children: [
        // Wide layout moves Back into the preview's left panel.
        if (!isWide)
          WizardHeader(
            backLabel: context.l10n.back,
            onBack: () => safeBack(context),
            actionLabel: '',
          ),
        Expanded(child: isWide ? _wideLayout(p) : _narrowLayout(p)),
      ]),
    );
  }

  /// Share text content, with clipboard fallback on platforms where
  /// the Web Share API is unavailable.
  Future<void> _shareText(String text, String subject) async {
    try {
      await SharePlus.instance
          .share(ShareParams(text: text, subject: subject));
    } catch (e) {
      debugPrint('Share API unavailable, falling back to clipboard: $e');
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportCopiedToClipboard)),
        );
      }
    }
  }

  /// Build + download the portable directive file (encrypted or plaintext per
  /// [_encryptEditableCopy]). Re-importable via "Continue from a saved file".
  Future<void> _downloadEditableCopy() async {
    try {
      final repo = ref.read(directiveRepositoryProvider);
      final subject = context.l10n.exportShareSubjectEditable;
      final bytes = await DirectiveExportService(repo).buildFile(
        widget.directiveId,
        encrypted: _encryptEditableCopy,
        nowMillis: DateTime.now().millisecondsSinceEpoch,
      );
      final name =
          _encryptEditableCopy ? 'directive.mhad' : 'directive-readable.mhad';
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(bytes,
              mimeType: 'application/octet-stream', name: name)
        ],
        subject: subject,
      ));
    } catch (e) {
      debugPrint('Editable-file export failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(context.l10n.exportCouldnTSaveTheFile)),
        );
      }
    }
  }

  Future<void> _exportFhir() async {
    if (_directive == null) return;
    final json = FhirExportService.exportAsJson(
      directive: _directive!,
      agents: _agents,
      medications: _medications,
      prefs: _prefs,
      additional: _additional,
      witnesses: _witnesses,
      guardian: _guardian,
      diagnoses: _diagnoses,
    );
    await _shareText(json, context.l10n.exportShareSubjectFhirJson);
  }

  Future<void> _exportFhirXml() async {
    if (_directive == null) return;
    final xml = ExportFormatsService.exportAsFhirXml(
      directive: _directive!,
      agents: _agents,
      medications: _medications,
      prefs: _prefs,
      additional: _additional,
      witnesses: _witnesses,
      guardian: _guardian,
      diagnoses: _diagnoses,
    );
    await _shareText(xml, context.l10n.exportShareSubjectFhirXml);
  }

  Future<void> _exportCsv() async {
    if (_directive == null) return;
    final csv = ExportFormatsService.exportAsCsv(
      directive: _directive!,
      agents: _agents,
      medications: _medications,
      prefs: _prefs,
      additional: _additional,
      witnesses: _witnesses,
      guardian: _guardian,
      diagnoses: _diagnoses,
    );
    await _shareText(csv, context.l10n.exportShareSubjectCsv);
  }

  /// Artboard `WebDataExport` "bundle everything as a .zip" — packages the
  /// signed-form PDF plus the machine-readable copies (FHIR JSON, FHIR XML,
  /// CSV) into one .zip for handing off in a single file.
  Future<void> _exportZipBundle() async {
    if (_directive == null) return;
    setState(() => _isGenerating = true);
    try {
      final generator = PdfGenerator(
        includeCombined: _includeCombined,
        includeDeclaration: _includeDeclaration,
        includePoa: _includePoa,
        includeSupplementary: _includeSupplementary,
        includeNotes: _includeNotes,
        draftMode: _previewMode,
      );
      final pdfBytes = await runInBackground(() => generator.generate(
            directive: _directive!,
            agents: _agents,
            prefs: _prefs,
            additional: _additional,
            guardian: _guardian,
            medications: _medications,
            witnesses: _witnesses,
            diagnoses: _diagnoses,
            allergies: _allergies,
          ));
      final json = FhirExportService.exportAsJson(
        directive: _directive!,
        agents: _agents,
        medications: _medications,
        prefs: _prefs,
        additional: _additional,
        witnesses: _witnesses,
        guardian: _guardian,
        diagnoses: _diagnoses,
      );
      final xml = ExportFormatsService.exportAsFhirXml(
        directive: _directive!,
        agents: _agents,
        medications: _medications,
        prefs: _prefs,
        additional: _additional,
        witnesses: _witnesses,
        guardian: _guardian,
        diagnoses: _diagnoses,
      );
      final csv = ExportFormatsService.exportAsCsv(
        directive: _directive!,
        agents: _agents,
        medications: _medications,
        prefs: _prefs,
        additional: _additional,
        witnesses: _witnesses,
        guardian: _guardian,
        diagnoses: _diagnoses,
      );

      final safe = _directive!.fullName.trim().isEmpty
          ? 'directive'
          : _directive!.fullName.trim().replaceAll(RegExp(r'\s+'), '_');
      final archive = Archive()
        ..addFile(ArchiveFile('PA_MHAD_$safe.pdf', pdfBytes.length, pdfBytes))
        ..addFile(_textFile('mhad_fhir.json', json))
        ..addFile(_textFile('mhad_fhir.xml', xml))
        ..addFile(_textFile('mhad_directive.csv', csv));
      final zip = ZipEncoder().encode(archive);

      if (!mounted) return;
      await SharePlus.instance.share(ShareParams(
        files: [
          XFile.fromData(
            Uint8List.fromList(zip),
            name: 'PA_MHAD_$safe.zip',
            mimeType: 'application/zip',
          ),
        ],
        subject: context.l10n.exportShareSubjectBundle,
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  context.l10n.exportExportedYourDirectiveBundlePdf)),
        );
      }
    } catch (e) {
      debugPrint('Zip bundle export failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.exportCouldNotBuildTheZip)),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  ArchiveFile _textFile(String name, String content) {
    final bytes = utf8.encode(content);
    return ArchiveFile(name, bytes.length, bytes);
  }

  Agent? get _walletAgent => _agents.primaryAgent;

  String _walletValidThrough(AppLocalizations l) {
    final exp = _directive?.expirationDate;
    if (exp == null || exp == 0) return l.exportWalletSignToActivate;
    final d = DateTime.fromMillisecondsSinceEpoch(exp);
    return '${d.month.toString().padLeft(2, '0')} · ${d.year}';
  }

  Future<void> _generateWalletCard() async {
    if (_directive == null) return;
    setState(() => _isGenerating = true);
    try {
      await WalletCardService.generateAndShare(_directive!, _agents);
    } catch (e) {
      debugPrint('Wallet-card export failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(context.l10n.exportCouldnTGenerateTheWallet)),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }
}

class _FormCheckbox extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? warning;

  const _FormCheckbox({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.warning,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          CheckboxListTile(
            title: Text(title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            subtitle: Text(subtitle,
                style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant)),
            value: value,
            onChanged: onChanged,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (warning != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Icon(Icons.warning_amber,
                      size: 14,
                      color: SemanticColors.warningText(cs.brightness)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      warning!,
                      style: TextStyle(
                          fontSize: 11,
                          color: SemanticColors.warningText(cs.brightness)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
