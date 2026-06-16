import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/app_data/app_data.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/agent_ext.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/export/pdf/pdf_generator.dart';
import 'package:mhad/ui/export/pdf/pdf_helpers.dart';
import 'package:mhad/ui/export/pdf/wallet_card_generator.dart';
import 'package:mhad/ui/export/pdf/wallet_card_service.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/responsive_shell.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
import 'package:mhad/services/directive_export_service.dart';
import 'package:mhad/services/export_encryption_service.dart';
import 'package:mhad/services/export_formats_service.dart';
import 'package:mhad/services/fhir_export_service.dart';
import 'package:mhad/ui/export/nfc_write_button.dart';
import 'package:mhad/utils/background_runner.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  /// Draft watermark applied to the printable PDF.
  DraftMode _draftMode = DraftMode.finalCopy;

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
    final directive = await repo.getDirectiveById(widget.directiveId);
    if (!mounted) return;
    if (directive == null) {
      // The id didn't resolve (e.g. a stale link, or the in-memory web DB was
      // cleared). Don't spin forever — surface a graceful empty state.
      setState(() {
        _loading = false;
        _notFound = true;
      });
      return;
    }

    final formType = FormType.values.firstWhere(
      (e) => e.name == directive.formType,
      orElse: () => FormType.combined,
    );

    final agents = await repo.getAgents(widget.directiveId);
    final prefs = await repo.getPreferences(widget.directiveId);
    final additional = await repo.getAdditionalInstructions(widget.directiveId);
    final guardian = await repo.getGuardianNomination(widget.directiveId);
    final medications = await repo.watchMedications(widget.directiveId).first;
    final witnesses = await repo.getWitnesses(widget.directiveId);
    final diagnoses = await repo.getDiagnoses(widget.directiveId);

    if (mounted) {
      setState(() {
        _directive = directive;
        _agents = agents;
        _prefs = prefs;
        _additional = additional;
        _guardian = guardian;
        _medications = medications;
        _witnesses = witnesses;
        _diagnoses = diagnoses;
        _loading = false;

        // Pre-select the form type the user filled in
        _includeCombined = formType == FormType.combined;
        _includeDeclaration = formType == FormType.declaration;
        _includePoa = formType == FormType.poa;
      });
    }
  }

  Future<void> _generateAndShare() async {
    if (!_includeCombined && !_includeDeclaration && !_includePoa &&
        !_includeSupplementary && !_includeNotes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one section to include.')),
      );
      return;
    }

    // Completeness check — warn about missing critical fields
    final warnings = <String>[];
    if (_directive != null) {
      if (_directive!.fullName.isEmpty) warnings.add('Full name');
      if (_directive!.dateOfBirth.isEmpty) warnings.add('Date of birth');
      if (_directive!.effectiveCondition.isEmpty) {
        warnings.add('Effective condition');
      }
      if (_directive!.status == 'draft') {
        final hasSignatures = _witnesses.any(
            (w) => w.signatureBase64 != null && w.signatureBase64!.isNotEmpty);
        if (!hasSignatures) warnings.add('Witness signatures');
      }
    }
    if (warnings.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Incomplete Directive'),
          content: Text(
            'The following fields are empty or missing:\n\n'
            '${warnings.map((w) => '  \u2022 $w').join('\n')}\n\n'
            'An incomplete directive may not be legally valid under '
            'PA Act 194. Export anyway?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Go Back'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(ctx, false);
                context.go(AppRoutes.wizardRoute(widget.directiveId));
              },
              child: const Text('Edit Directive'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Export Anyway'),
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
          title: const Text('Exported file is not encrypted'),
          content: const Text(
            'The PDF you are about to share contains your full mental-health '
            'directive (names, agents, medications, signatures). It is '
            'generated unencrypted because the underlying PDF library does '
            'not support password protection.\n\n'
            'Share only via channels you trust (e.g., direct hand-off, a '
            'secure email to a specific provider). Avoid public uploads, '
            'cloud links, or untrusted messaging apps.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('I understand, continue'),
            ),
          ],
        ),
      );
      if (ackd != true || !mounted) return;
      _unprotectedAcked = true;
    }

    setState(() => _isGenerating = true);

    try {
      final generator = PdfGenerator(
        includeCombined: _includeCombined,
        includeDeclaration: _includeDeclaration,
        includePoa: _includePoa,
        includeSupplementary: _includeSupplementary,
        includeNotes: _includeNotes,
        draftMode: _draftMode,
      );

      final directive = _directive!;
      final agents = _agents;
      final prefs = _prefs;
      final additional = _additional;
      final guardian = _guardian;
      final medications = _medications;
      final witnesses = _witnesses;

      final bytes = await runInBackground(() => generator.generate(
        directive: directive,
        agents: agents,
        prefs: prefs,
        additional: additional,
        guardian: guardian,
        medications: medications,
        witnesses: witnesses,
        diagnoses: _diagnoses,
      ));

      if (!mounted) return;

      await Printing.sharePdf(
        bytes: bytes,
        filename: 'PA_MHAD_${_directive!.fullName.replaceAll(' ', '_')}.pdf',
      );
      if (kIsWeb && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF downloaded to your Downloads folder.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showQrCode() {
    if (_directive == null) return;

    final directive = _directive!;
    final formType = FormType.values.firstWhere(
      (e) => e.name == directive.formType,
      orElse: () => FormType.combined,
    );

    final agentName = _agents.isNotEmpty ? _agents.first.fullName : null;
    final agentPhone = _agents.isNotEmpty
        ? [_agents.first.cellPhone, _agents.first.homePhone, _agents.first.workPhone]
            .firstWhere((p) => p.isNotEmpty, orElse: () => '')
        : '';

    final execDate = directive.executionDate != null
        ? DateTime.fromMillisecondsSinceEpoch(directive.executionDate!)
        : null;
    final expDate = directive.expirationDate != null
        ? DateTime.fromMillisecondsSinceEpoch(directive.expirationDate!)
        : null;

    final buf = StringBuffer();
    buf.writeln('PA MENTAL HEALTH ADVANCE DIRECTIVE');
    buf.writeln('');
    buf.writeln('I, ${directive.fullName}, have executed an advance directive '
        'specifying my decisions about my mental health care.');
    buf.writeln('');
    if (agentName != null && agentName.isNotEmpty) {
      buf.writeln('My Mental Health Care Agent is $agentName.');
      if (agentPhone.isNotEmpty) {
        buf.writeln('Contact Agent at: $agentPhone');
      }
      buf.writeln('');
    }
    buf.writeln('Form: ${formType.displayName}');
    if (execDate != null) {
      buf.writeln('Executed: ${execDate.month}/${execDate.day}/${execDate.year}');
    }
    if (expDate != null) {
      buf.writeln('Expires: ${expDate.month}/${expDate.day}/${expDate.year}');
    }
    buf.writeln('');
    buf.writeln('If the hospital has questions, contact PA Protection '
        '& Advocacy at ${appData.phoneOf('paProtectionAdvocacy')}.');
    buf.writeln('');
    buf.writeln('This is a summary. Request the full directive from the '
        'person who made it.');

    final payload = buf.toString();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Directive QR Code'),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LayoutBuilder(
                builder: (ctx, constraints) => QrImageView(
                  data: payload,
                  version: QrVersions.auto,
                  size: constraints.maxWidth.clamp(160, 240),
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Scan to view directive summary\u2009\u2014\u2009request the full copy from the person who made it',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
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
      draftMode: _draftMode,
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

  Agent? get _primaryAgent => _agents.primaryAgent;

  String _agentPhoneFor(Agent? a) => a?.bestPhone ?? '';


  Future<void> _previewPdf() async {
    if (!_includeCombined && !_includeDeclaration && !_includePoa &&
        !_includeSupplementary && !_includeNotes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one section to preview.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final bytes = await _buildPdfBytes();

      if (!mounted) return;

      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _PdfPreviewScreen(pdfBytes: bytes),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _generateWalletCard() async {
    if (_directive == null) return;

    setState(() => _isGenerating = true);

    try {
      await WalletCardService.generateAndShare(_directive!, _agents);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating wallet card: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: Semantics(
            label: 'Loading',
            child: const CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_notFound || _directive == null) {
      final p = Theme.of(context).mhadPalette;
      return Scaffold(
        backgroundColor: p.scaffoldBackground,
        body: Column(
          children: [
            const CrisisTopBar(compact: true),
            WizardHeader(
              backLabel: 'Back',
              onBack: () => Navigator.of(context).maybePop(),
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
                        'Nothing to download yet',
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: p.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start a directive first — then come back here to '
                        'preview, download, and print it.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 13,
                          height: 1.4,
                          color: p.textMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FilledButton.icon(
                        onPressed: () =>
                            context.go(AppRoutes.home),
                        icon: const Icon(Icons.add),
                        label: const Text('Start your directive'),
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

    final p = Theme.of(context).mhadPalette;

    // --- Shared content lists (ADDITIVE: same widgets feed both the narrow
    // single-column and the wide >=1000px two-pane layouts; zero behavior or
    // logic change — only arrangement differs by width). ---

    // Header / chrome shown above both layouts.
    // --- Reusable chrome pieces shared by both the narrow single-column and
    // the wide two-pane layouts. ---

    // Legal "before sharing" disclaimer (PA Act 194 — legally substantive).
    final legalDisclaimerCard = Semantics(
      label: 'Important: Before sharing, ensure this directive has been '
          'signed, dated, and witnessed by two adults as required by '
          'PA Act 194. Give copies to your agent, physician, and '
          'support people.',
      container: true,
      child: Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            'Before sharing: ensure this directive has been signed, dated, '
            'and witnessed by two adults (18+) as required by PA Act 194. '
            'Give copies to your agent, physician, and support people.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );

    // Principal info summary.
    final Widget principalCard = _directive == null
        ? const SizedBox.shrink()
        : Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Principal',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(_directive!.fullName,
                      style: const TextStyle(fontSize: 13)),
                  if (_directive!.executionDate != null)
                    Text(
                      'Executed: ${DateTime.fromMillisecondsSinceEpoch(_directive!.executionDate!).toString().split(' ').first}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  if (_directive!.expirationDate != null)
                    Text(
                      'Expires: ${DateTime.fromMillisecondsSinceEpoch(_directive!.expirationDate!).toString().split(' ').first}',
                      style: const TextStyle(fontSize: 12),
                    ),
                ],
              ),
            ),
          );

    // V4-M8 — persistent banner: the PDF is unencrypted by design.
    final unencryptedBanner = Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_open_outlined,
              size: 18,
              color: Theme.of(context).colorScheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'The exported PDF is not encrypted. Share only via '
              'channels you trust.',
              style: TextStyle(
                fontSize: 12.5,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );

    final headerChildren = <Widget>[
      const SectionLabel('Export & share'),
      EditorialHeading(
        textSpan: TextSpan(
          children: [
            const TextSpan(text: 'Your directive,\n'),
            TextSpan(
              text: 'on paper.',
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
          child: LinearProgressIndicator(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      legalDisclaimerCard,
      const SizedBox(height: 16),
      principalCard,
      const SizedBox(height: 16),
    ];

    // Form/section pickers — the "Include sections" list. Shared by the
    // narrow Document column and the wide right-hand control rail.
    final sectionCheckboxChildren = <Widget>[
          // Form selection
          Text('Select forms to include:',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _FormCheckbox(
            title: 'Combined Declaration & Power of Attorney',
            subtitle: 'Declaration + Power of Attorney (most complete)',
            value: _includeCombined,
            onChanged: (v) => setState(() => _includeCombined = v ?? false),
            warning: _includeCombined && _agents.isEmpty
                ? 'No agent designated — agent sections will be blank'
                : null,
          ),
          _FormCheckbox(
            title: 'Declaration Only',
            subtitle: 'Treatment preferences only (no agent)',
            value: _includeDeclaration,
            onChanged: (v) => setState(() => _includeDeclaration = v ?? false),
          ),
          _FormCheckbox(
            title: 'Power of Attorney Only',
            subtitle: 'Agent authority only (no personal preferences)',
            value: _includePoa,
            onChanged: (v) => setState(() => _includePoa = v ?? false),
            warning: _includePoa && _agents.isEmpty
                ? 'No agent designated — agent sections will be blank'
                : null,
          ),
          const SizedBox(height: 16),

          // Additional pages
          Text('Additional Pages:',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _FormCheckbox(
            title: 'Supplementary Legal Information',
            subtitle: 'Additional legal reference information',
            value: _includeSupplementary,
            onChanged: (v) =>
                setState(() => _includeSupplementary = v ?? false),
          ),
          _FormCheckbox(
            title: 'Distribution Checklist & Notes',
            subtitle: 'Blank pages for handwritten notes',
            value: _includeNotes,
            onChanged: (v) => setState(() => _includeNotes = v ?? false),
          ),
    ];

    // Narrow single-column "Document" block: section pickers, a Preview
    // button (full-screen preview), then the unencrypted-file banner.
    final documentChildren = <Widget>[
          ...sectionCheckboxChildren,
          const SizedBox(height: 24),

          // Action buttons
          Semantics(
            button: true,
            label: _isGenerating
                ? 'Generating PDF preview'
                : 'Preview PDF before sharing',
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _previewPdf,
              icon: _isGenerating
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: Semantics(
                        label: 'Loading',
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.preview),
              label: const Text('Preview PDF'),
            ),
          ),
          const SizedBox(height: 8),
          unencryptedBanner,
    ];

    // RIGHT / "Distribution" pane on wide screens: share, QR, NFC, machine-
    // readable formats, password-protected copy, and draft review.
    final distributionChildren = <Widget>[
          Semantics(
            button: true,
            label: 'Download or print the PDF directive (unencrypted file)',
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _generateAndShare,
              icon: const Icon(Icons.download),
              label: const Text('Download PDF'),
            ),
          ),
          const SizedBox(height: 12),
          // Live gradient wallet-card preview (Claude Design `WebExport` right
          // column) — shows what the generated credit-card-sized PDF carries.
          if (_directive != null) ...[
            Text(
              'WALLET CARD',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontFamilyFallback: const ['Consolas', 'monospace'],
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            _WalletCardPreview(
              directive: _directive!,
              agentName: _primaryAgent?.fullName,
              agentPhone: _agentPhoneFor(_primaryAgent),
            ),
            const SizedBox(height: 10),
          ],
          Semantics(
            button: true,
            label: 'Generate a printable wallet card with essential directive info',
            child: OutlinedButton.icon(
              onPressed: _isGenerating ? null : _generateWalletCard,
              icon: const Icon(Icons.credit_card),
              label: const Text('Generate Wallet Card'),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              'Credit-card-sized PDF with essential directive info',
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Semantics(
            button: true,
            label: 'Generate a QR code with directive summary',
            child: OutlinedButton.icon(
              onPressed: _directive != null ? _showQrCode : null,
              icon: const Icon(Icons.qr_code),
              label: const Text('Generate QR Code'),
            ),
          ),
          if (_directive != null) ...[
            if (platformIsMobile) ...[
            const SizedBox(height: 8),
            Semantics(
              button: true,
              label: 'Write directive summary to NFC tag',
              child: NfcWriteButton(
                principalName: _directive!.fullName,
                formType: _directive!.formType,
                executionDate: _directive!.executionDate != null
                    ? DateTime.fromMillisecondsSinceEpoch(
                            _directive!.executionDate!)
                        .toIso8601String()
                    : null,
                agentName: _agents.isNotEmpty ? _agents.first.fullName : null,
                agentPhone: _agents.isNotEmpty ? _agents.first.cellPhone : null,
              ),
            ),
            ],
            const SizedBox(height: 16),
            Text('Machine-readable formats',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Your PDF above is the document you sign — these are data exports '
              'for your records, a spreadsheet, or a health system. FHIR is the '
              'standard format hospitals use to exchange medical records; CSV is '
              'a spreadsheet file (opens in Excel or Google Sheets).',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Semantics(
                  button: true,
                  label: 'Export as FHIR JSON for electronic health records',
                  child: OutlinedButton.icon(
                    onPressed: _exportFhir,
                    icon: const Icon(Icons.integration_instructions),
                    label: const Text('FHIR JSON'),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Export as FHIR XML for electronic health records',
                  child: OutlinedButton.icon(
                    onPressed: _exportFhirXml,
                    icon: const Icon(Icons.code),
                    label: const Text('FHIR XML'),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Export as CSV spreadsheet',
                  child: OutlinedButton.icon(
                    onPressed: _exportCsv,
                    icon: const Icon(Icons.table_chart_outlined),
                    label: const Text('CSV'),
                  ),
                ),
                Semantics(
                  button: true,
                  label:
                      'Download everything (PDF, JSON, XML, CSV) as a zip bundle',
                  child: OutlinedButton.icon(
                    onPressed: _isGenerating ? null : _exportZipBundle,
                    icon: const Icon(Icons.folder_zip_outlined),
                    label: const Text('.zip bundle'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Printed copy type',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'A draft prints a light "DRAFT" watermark on every page — for '
              'sending a copy while you keep the signed paper original.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Final copy'),
                  selected: _draftMode == DraftMode.finalCopy,
                  onSelected: (_) =>
                      setState(() => _draftMode = DraftMode.finalCopy),
                ),
                ChoiceChip(
                  label: const Text('Draft'),
                  selected: _draftMode == DraftMode.draftGeneral,
                  onSelected: (_) =>
                      setState(() => _draftMode = DraftMode.draftGeneral),
                ),
                ChoiceChip(
                  label: const Text('Draft · signed copy exists'),
                  selected: _draftMode == DraftMode.draftSignedAvailable,
                  onSelected: (_) => setState(
                      () => _draftMode = DraftMode.draftSignedAvailable),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Save an editable copy',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Download a file you keep. Re-upload it later (or on another '
              'device) to continue editing — nothing is stored online. '
              'Encrypting hinders others from reading it; the app still opens '
              'it with no passphrase.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Checkbox(
                  value: _encryptEditableCopy,
                  onChanged: (v) =>
                      setState(() => _encryptEditableCopy = v ?? true),
                ),
                const Expanded(child: Text('Encrypt the file')),
                Semantics(
                  button: true,
                  label: 'Download an editable copy of your directive',
                  child: FilledButton.tonalIcon(
                    onPressed: _isGenerating ? null : _downloadEditableCopy,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Download'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Password-protect a copy',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'Encrypt your data export with a passphrase (AES-256) before you '
              'share it. Send the passphrase separately — anyone with the file '
              'and passphrase can open it here under “Unlock”.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Semantics(
                  button: true,
                  label: 'Password-protect an encrypted data export',
                  child: OutlinedButton.icon(
                    onPressed: _passwordProtectExport,
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Encrypt export'),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Unlock an encrypted data export',
                  child: OutlinedButton.icon(
                    onPressed: _unlockEncryptedExport,
                    icon: const Icon(Icons.lock_open_outlined),
                    label: const Text('Unlock'),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          Text('Share for Review',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          Text(
            'Share a read-only summary with your agent, therapist, or '
            'family member for feedback before signing.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Semantics(
            button: true,
            label: 'Share a draft summary for review',
            child: OutlinedButton.icon(
              onPressed: _directive != null && _directive!.status == 'draft'
                  ? _shareDraftSummary
                  : null,
              icon: const Icon(Icons.rate_review_outlined),
              label: const Text('Share Draft for Review'),
            ),
          ),
    ];

    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Prototype Export-class screens (ScrPdfPreview L1132+, ScrAppleWallet
      // mobile-extra2.jsx L5-113) sit CrisisBar at the top with a thin
      // in-body back chevron, not a Material AppBar.
      body: Column(children: [
        const CrisisTopBar(compact: true),
        // The wide layout moves Back into the preview's left panel, so the
        // full-width header is only needed in the narrow single-column layout.
        if (MediaQuery.sizeOf(context).width < kWideLayoutBreakpoint)
          WizardHeader(
            backLabel: 'Back',
            onBack: () => Navigator.of(context).maybePop(),
            actionLabel: '',
          ),
        Expanded(
          child: Builder(
            builder: (context) {
              // Decide wide vs narrow off the TOTAL window width (the
              // desktop-shell signal), NOT this screen's post-sidebar content
              // width. The persistent `WebSidebar` already eats 232px, so a
              // content-based `>=1000` check only flips to the two-pane
              // artboard layout above a ~1232px window — leaving a dead band
              // (1000–1231px) where the sidebar shows but export still rendered
              // the narrow single column (no inline preview, just a "Preview
              // PDF" button). Whenever the shell is active we render the
              // prototype `w-export` grid: the live PDF preview DOMINATES the
              // left pane (heading + zoom/page-counter/page-rail) and a fixed
              // control rail sits on the right. Below the shell breakpoint it's
              // the single stretched column (header + document + distribution).
              if (MediaQuery.sizeOf(context).width >= kWideLayoutBreakpoint) {
                final anySelected = _includeCombined ||
                    _includeDeclaration ||
                    _includePoa ||
                    _includeSupplementary ||
                    _includeNotes;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LEFT + MIDDLE — the preview widget renders its own
                    // control panel (Export & share, Back, heading, page
                    // counter, zoom, and the vertical page-thumbnail selector)
                    // on the left and the page image, fit to width, in the
                    // middle. The right rail below is the third column.
                    Expanded(
                      child: _ExportPdfPreview(
                        signature: _selectionSignature(),
                        buildBytes: _buildPdfBytes,
                        hasSelection: anySelected,
                        ready: _directive != null,
                        onClose: () => Navigator.of(context).maybePop(),
                      ),
                    ),
                    // RIGHT — control rail.
                    Container(
                      width: 300,
                      decoration: BoxDecoration(
                        color: p.card,
                        border: Border(left: BorderSide(color: p.border)),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_isGenerating)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: LinearProgressIndicator(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            legalDisclaimerCard,
                            const SizedBox(height: 16),
                            ...sectionCheckboxChildren,
                            const SizedBox(height: 16),
                            unencryptedBanner,
                            const SizedBox(height: 4),
                            ...distributionChildren,
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return ListView(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 16),
                children: [
                  ...headerChildren,
                  ...documentChildren,
                  ...distributionChildren,
                  const SizedBox(height: 40),
                ],
              );
            },
          ),
        ),
      ]),
    );
  }

  /// Share text content, with clipboard fallback on platforms where
  /// the Web Share API is unavailable.
  Future<void> _shareText(String text, String subject) async {
    try {
      await Share.share(text, subject: subject);
    } catch (e) {
      debugPrint('Share API unavailable, falling back to clipboard: $e');
      await Clipboard.setData(ClipboardData(text: text));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Copied to clipboard.')),
        );
      }
    }
  }

  /// Build + download the portable directive file (encrypted or plaintext per
  /// [_encryptEditableCopy]). Re-importable via "Continue from a saved file".
  Future<void> _downloadEditableCopy() async {
    try {
      final repo = ref.read(directiveRepositoryProvider);
      final bytes = await DirectiveExportService(repo).buildFile(
        widget.directiveId,
        encrypted: _encryptEditableCopy,
        nowMillis: DateTime.now().millisecondsSinceEpoch,
      );
      final name =
          _encryptEditableCopy ? 'directive.mhad' : 'directive-readable.mhad';
      await Share.shareXFiles(
        [
          XFile.fromData(bytes,
              mimeType: 'application/octet-stream', name: name)
        ],
        subject: 'MHAD editable directive copy',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create the file: $e')),
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
    await _shareText(json, 'MHAD FHIR Consent Resource');
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
    await _shareText(xml, 'MHAD FHIR Consent Resource (XML)');
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
    await _shareText(csv, 'MHAD directive (CSV)');
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
        draftMode: _draftMode,
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
      await Share.shareXFiles(
        [
          XFile.fromData(
            Uint8List.fromList(zip),
            name: 'PA_MHAD_$safe.zip',
            mimeType: 'application/zip',
          ),
        ],
        subject: 'PA MHAD directive bundle',
      );
    } catch (e) {
      debugPrint('Zip bundle export failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not build the .zip bundle.')),
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

  /// Build the plaintext bundle that password-protection encrypts — the CSV
  /// (complete structured data) plus a readable header.
  String _exportBundle() {
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
    return 'PA Mental Health Advance Directive — data export\r\n'
        'Encrypted copy. Not a signed legal document.\r\n\r\n$csv';
  }

  Future<void> _passwordProtectExport() async {
    if (_directive == null) return;
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Encrypt export'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose a passphrase. You’ll need it (and this app, or the '
                '“Unlock” action) to open the file. We can’t recover it.',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passCtrl,
                obscureText: true,
                autofillHints: const [],
                decoration: const InputDecoration(
                  labelText: 'Passphrase',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.length < 8)
                    ? 'Use at least 8 characters'
                    : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: confirmCtrl,
                obscureText: true,
                autofillHints: const [],
                decoration: const InputDecoration(
                  labelText: 'Confirm passphrase',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v != passCtrl.text ? 'Passphrases don’t match' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                Navigator.pop(dialogCtx, true);
              }
            },
            child: const Text('Encrypt & share'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final envelope = ExportEncryptionService.encryptToEnvelope(
        _exportBundle(),
        passCtrl.text,
      );
      await _shareText(envelope, 'MHAD encrypted export (.mhadenc)');
    }
    passCtrl.dispose();
    confirmCtrl.dispose();
  }

  Future<void> _unlockEncryptedExport() async {
    final envCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogCtx) {
        String? error;
        return StatefulBuilder(
          builder: (ctx, setLocal) => AlertDialog(
            title: const Text('Unlock encrypted export'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: envCtrl,
                    maxLines: 4,
                    autofillHints: const [],
                    decoration: const InputDecoration(
                      labelText: 'Paste the encrypted export',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    autofillHints: const [],
                    decoration: InputDecoration(
                      labelText: 'Passphrase',
                      border: const OutlineInputBorder(),
                      errorText: error,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: const Text('Close'),
              ),
              FilledButton(
                onPressed: () {
                  try {
                    final text = ExportEncryptionService.decryptEnvelope(
                      envCtrl.text.trim(),
                      passCtrl.text,
                    );
                    Navigator.pop(dialogCtx, text);
                  } on ExportDecryptException {
                    setLocal(() => error = 'Wrong passphrase.');
                  } on FormatException catch (e) {
                    setLocal(() => error = e.message);
                  }
                },
                child: const Text('Unlock'),
              ),
            ],
          ),
        );
      },
    );
    envCtrl.dispose();
    passCtrl.dispose();
    if (result != null && mounted) {
      await showDialog<void>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Decrypted export'),
          content: SingleChildScrollView(
            child: SelectableText(
              result,
              style: const TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: result));
                Navigator.pop(dialogCtx);
              },
              child: const Text('Copy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _shareDraftSummary() async {
    if (_directive == null) return;
    final d = _directive!;
    final buf = StringBuffer();
    buf.writeln('DRAFT — PA Mental Health Advance Directive');
    buf.writeln('This is a DRAFT for review. NOT a signed legal document.\n');
    buf.writeln('Principal: ${d.fullName.isNotEmpty ? d.fullName : "(not yet entered)"}');
    buf.writeln('Form Type: ${d.formType}');
    buf.writeln('Effective Condition: ${d.effectiveCondition.isNotEmpty ? d.effectiveCondition : "(not yet entered)"}');
    if (_medications.isNotEmpty) {
      buf.writeln('\nMedications:');
      for (final m in _medications) {
        final type = m.entryType == 'preferred' ? 'Preferred' : m.entryType == 'exception' ? 'AVOID' : 'Limitation';
        buf.writeln('  [$type] ${m.medicationName}${m.reason.isNotEmpty ? " — ${m.reason}" : ""}');
      }
    }
    if (_agents.isNotEmpty) {
      buf.writeln('\nAgents:');
      for (final a in _agents) {
        buf.writeln('  ${a.agentType}: ${a.fullName} (${a.relationship})');
      }
    }
    if (_additional != null) {
      if (_additional!.healthHistory.isNotEmpty) {
        buf.writeln('\nHealth History: ${_additional!.healthHistory}');
      }
      if (_additional!.crisisIntervention.isNotEmpty) {
        buf.writeln('Crisis Intervention: ${_additional!.crisisIntervention}');
      }
    }
    buf.writeln('\n--- END DRAFT ---');
    buf.writeln('Please review and provide feedback to the principal.');

    await _shareText(buf.toString(), 'MHAD Draft for Review');
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
                  const Icon(Icons.warning_amber, size: 14, color: Colors.orange),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      warning!,
                      style: const TextStyle(fontSize: 11, color: Colors.orange),
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

class _PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  const _PdfPreviewScreen({required this.pdfBytes});

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    return Scaffold(
      backgroundColor: p.scaffoldBackground,
      // Editorial AppBar — matches prototype `ScrPdfPreview` top toolbar:
      // X close, "Preview" 16pt bold, mono "US LETTER · 8.5×11"" sub,
      // share action on the right. Drops the stock "PDF Preview" Material
      // chrome.
      appBar: AppBar(
        backgroundColor: p.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close preview',
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            Text(
              'US LETTER · 8.5×11"',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontFamilyFallback: const [
                  'Consolas',
                  'Menlo',
                  'Courier New',
                  'monospace',
                ],
                fontSize: 10,
                letterSpacing: 0.5,
                color: p.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: 'Share',
            onPressed: () => Printing.sharePdf(
              bytes: pdfBytes,
              filename: 'PA_MHAD.pdf',
            ),
          ),
        ],
      ),
      body: PdfPreview(
        build: (_) async => pdfBytes,
        allowPrinting: false,
        allowSharing: false,
        canChangePageFormat: false,
        canChangeOrientation: false,
        // Hide PdfPreview's built-in toolbar; the editorial AppBar above
        // and the bottomNavigationBar below take its place.
        useActions: false,
        scrollViewDecoration: BoxDecoration(color: p.scaffoldBackground),
        pdfPreviewPageDecoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: p.border),
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        loadingWidget: Center(
          child: CircularProgressIndicator(color: p.primary),
        ),
      ),
      // Editorial action bar — matches prototype's 3-button Save / Print /
      // **Share (primary)** footer.
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          decoration: BoxDecoration(
            color: p.card,
            border: Border(top: BorderSide(color: p.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'PA_MHAD.pdf',
                  ),
                  icon: const Icon(Icons.download_outlined, size: 17),
                  label: const Text('Save'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Printing.layoutPdf(
                    onLayout: (_) async => pdfBytes,
                    name: 'PA_MHAD',
                  ),
                  icon: const Icon(Icons.print_outlined, size: 17),
                  label: const Text('Print'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () => Printing.sharePdf(
                    bytes: pdfBytes,
                    filename: 'PA_MHAD.pdf',
                  ),
                  icon: const Icon(Icons.ios_share, size: 17),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dominant live PDF preview for the wide export layout — rasterises the
/// generated PDF and shows one page at a time with a page counter, − / FIT / +
/// zoom controls, and a tappable page-rail of thumbnails. Mirrors the Claude
/// Design `WebExport` left pane (re-renders when the selection changes).
class _ExportPdfPreview extends StatefulWidget {
  final String signature;
  final Future<Uint8List> Function() buildBytes;
  final bool hasSelection;
  final bool ready;

  /// Called when the user taps "Back" in the left control panel — leaves the
  /// Export screen. In the wide layout the full-width header is hidden, so this
  /// is the screen's back affordance.
  final VoidCallback onClose;
  const _ExportPdfPreview({
    required this.signature,
    required this.buildBytes,
    required this.hasSelection,
    required this.ready,
    required this.onClose,
  });

  @override
  State<_ExportPdfPreview> createState() => _ExportPdfPreviewState();
}

class _ExportPdfPreviewState extends State<_ExportPdfPreview> {
  List<Uint8List> _pages = const [];
  int _current = 0;
  double _zoom = 1.0; // 1.0 == FIT
  bool _error = false;
  String? _renderedSig;
  int _renderToken = 0;

  // The middle preview stacks every page in one continuous vertical scroll.
  // These cache the per-page layout metrics (set during build) so the scroll
  // listener can derive the in-view page and the thumbnails can jump to one.
  final ScrollController _vCtrl = ScrollController();
  double _topPad = 16.0;
  double _pageStride = 1.0; // page height + inter-page gap, in px

  static const double _kPageRatio = 8.5 / 11.0; // width / height

  @override
  void initState() {
    super.initState();
    _vCtrl.addListener(_syncCurrentFromScroll);
    _maybeRender();
  }

  @override
  void dispose() {
    _vCtrl.removeListener(_syncCurrentFromScroll);
    _vCtrl.dispose();
    super.dispose();
  }

  // Keep "Page X of Y" + the highlighted thumbnail in sync with scrolling.
  void _syncCurrentFromScroll() {
    if (!_vCtrl.hasClients || _pages.isEmpty) return;
    final idx = ((_vCtrl.offset - _topPad + _pageStride / 2) / _pageStride)
        .floor()
        .clamp(0, _pages.length - 1);
    if (idx != _current) setState(() => _current = idx);
  }

  // Scroll the continuous preview to a given page (from a thumbnail tap).
  void _jumpToPage(int i) {
    setState(() => _current = i);
    if (!_vCtrl.hasClients) return;
    final target =
        (_topPad + i * _pageStride).clamp(0.0, _vCtrl.position.maxScrollExtent);
    _vCtrl.animateTo(
      target,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(covariant _ExportPdfPreview old) {
    super.didUpdateWidget(old);
    if (old.signature != widget.signature ||
        old.hasSelection != widget.hasSelection ||
        old.ready != widget.ready) {
      _maybeRender();
    }
  }

  Future<void> _maybeRender() async {
    if (!widget.ready || !widget.hasSelection) {
      if (mounted) {
        setState(() {
          _pages = const [];
          _renderedSig = null;
          _error = false;
        });
      }
      return;
    }
    if (_renderedSig == widget.signature && _pages.isNotEmpty) return;

    final token = ++_renderToken;
    setState(() {
      _pages = const [];
      _error = false;
    });
    try {
      final bytes = await widget.buildBytes();
      final pages = <Uint8List>[];
      await for (final raster in Printing.raster(bytes, dpi: 120)) {
        if (token != _renderToken) return; // superseded by a newer render
        pages.add(await raster.toPng());
      }
      if (!mounted || token != _renderToken) return;
      setState(() {
        _pages = pages;
        _current = 0;
        _renderedSig = widget.signature;
      });
      // Fresh render (e.g. selection changed) — scroll back to the top so the
      // page counter and the view agree.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_vCtrl.hasClients) _vCtrl.jumpTo(0);
      });
    } catch (_) {
      if (mounted && token == _renderToken) {
        setState(() => _error = true);
      }
    }
  }

  void _setZoom(double z) => setState(
      () => _zoom = ((z * 10).roundToDouble() / 10).clamp(0.5, 2.5));

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    // Two columns: a fixed-width control panel on the LEFT (Export & share,
    // Back, heading, page counter, zoom, and the vertical page-thumbnail
    // selector) and the page image in the MIDDLE (fit to width). The screen's
    // right-hand rail is a sibling added by the parent, giving a 3-column feel.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: 236,
          decoration: BoxDecoration(
            color: p.card,
            border: Border(right: BorderSide(color: p.border)),
          ),
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: _controlPanel(p),
        ),
        Expanded(
          child: ClipRect(
            child: Container(
              color: p.surface,
              child: _pageArea(p),
            ),
          ),
        ),
      ],
    );
  }

  /// MIDDLE column — every page stacked in one continuous vertical scroll
  /// (not page-limited), each fit to the width of the pane so the text is
  /// readable; the ± zoom scales them all. Falls back to a status note while
  /// it renders.
  Widget _pageArea(MhadPalette p) {
    if (!widget.ready) return _centeredNote('Loading…', p);
    if (!widget.hasSelection) {
      return _centeredNote('Select a section to preview.', p);
    }
    if (_error) return _centeredNote('Could not render the preview.', p);
    if (_pages.isEmpty) {
      return Center(child: CircularProgressIndicator(color: p.primary));
    }
    return LayoutBuilder(
      builder: (context, c) {
        const hPad = 6.0;
        const vPad = 16.0;
        const gap = 16.0;
        final availW = (c.maxWidth - hPad * 2).clamp(1.0, double.infinity);
        // Fit each page to the FULL width of the pane so it fills the center
        // section edge-to-edge (no hard cap, only a hairline gutter); the ±
        // zoom scales from there, and − zooms back out if it ever feels too
        // large.
        final double w = availW * _zoom;
        final double h = w / _kPageRatio;
        // Cache metrics for the scroll listener / thumbnail jumps.
        _topPad = vPad;
        _pageStride = h + gap;
        // A SINGLE vertical scroll view (one clean viewport for the Scrollbar
        // to measure). Earlier this nested a horizontal SingleChildScrollView
        // *inside* the vertical one — the inner viewport then had an unbounded
        // height, a fragile arrangement that could leave a RenderBox un-laid-
        // out during scroll/hover gesture handling ("RenderBox was not laid
        // out"). When the page is zoomed wider than the pane, only THAT page
        // scrolls horizontally, inside its own fixed-height (h) viewport — so
        // no scroll view is ever given an unbounded cross-axis.
        return Scrollbar(
          controller: _vCtrl,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _vCtrl,
            scrollDirection: Axis.vertical,
            padding:
                const EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                for (var i = 0; i < _pages.length; i++) ...[
                  if (i > 0) const SizedBox(height: gap),
                  if (w <= availW)
                    _pageCard(p, _pages[i], w, h)
                  else
                    SizedBox(
                      width: availW,
                      height: h,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: _pageCard(p, _pages[i], w, h),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pageCard(MhadPalette p, Uint8List bytes, double w, double h) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.memory(bytes, fit: BoxFit.fill, gaplessPlayback: true),
    );
  }

  /// LEFT column — title + Back, heading/caption, page counter, zoom, and the
  /// vertical page-thumbnail selector (stacked top to bottom).
  Widget _controlPanel(MhadPalette p) {
    final hasPages = _pages.isNotEmpty;
    final pageCount = _pages.length;
    final pct = (_zoom * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title row — "Export & share" on the left, Back on the opposite right.
        Row(
          children: [
            const Expanded(child: SectionLabel('Export & share')),
            TextButton.icon(
              onPressed: widget.onClose,
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text('Back'),
              style: TextButton.styleFrom(
                foregroundColor: p.text,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        EditorialHeading(
          textSpan: TextSpan(
            children: [
              const TextSpan(text: 'Your directive, '),
              TextSpan(text: 'on paper.', style: TextStyle(color: p.primary)),
            ],
          ),
          size: 24,
          height: 1.05,
          letterSpacing: -0.5,
        ),
        const SizedBox(height: 6),
        Text(
          'Sized for US Letter (8.5 × 11″) with 1-inch margins. The preview '
          'fills the width — use − / + to zoom.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 12,
            height: 1.4,
            color: p.textMuted,
          ),
        ),
        if (hasPages) ...[
          const SizedBox(height: 16),
          Divider(height: 1, color: p.border),
          const SizedBox(height: 14),
          Text(
            'Page ${_current + 1} of $pageCount',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: p.text,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _zoomBtn(p, '−', _zoom > 0.5, () => _setZoom(_zoom - 0.1)),
              const SizedBox(width: 6),
              _fitToggle(p, pct),
              const SizedBox(width: 6),
              _zoomBtn(p, '+', _zoom < 2.5, () => _setZoom(_zoom + 0.1)),
            ],
          ),
        ],
        if (hasPages && pageCount > 1) ...[
          const SizedBox(height: 18),
          Text(
            'PAGES',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontFamilyFallback: const ['Consolas', 'monospace'],
              fontSize: 10,
              letterSpacing: 1,
              fontWeight: FontWeight.w700,
              color: p.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          // Page selectors stacked top to bottom — each thumbnail fills the
          // panel width (true 8.5 × 11 aspect) with a "Page N" label, so they
          // fill the panel and are easy to read. The list scrolls when the
          // pages don't all fit the panel height.
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: pageCount,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final selected = i == _current;
                return GestureDetector(
                  onTap: () => _jumpToPage(i),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: _kPageRatio,
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selected ? p.primary : p.border,
                              width: selected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.memory(
                            _pages[i],
                            fit: BoxFit.cover,
                            gaplessPlayback: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Page ${i + 1}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 11.5,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? p.primary : p.textMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _centeredNote(String text, MhadPalette p) => Container(
        color: p.surface,
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            color: p.textMuted,
          ),
        ),
      );

  Widget _zoomBtn(
      MhadPalette p, String label, bool enabled, VoidCallback onTap) {
    return SizedBox(
      width: 30,
      height: 30,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(30, 30),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: p.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            height: 1,
            color: enabled ? p.text : p.border,
          ),
        ),
      ),
    );
  }

  Widget _fitToggle(MhadPalette p, int pct) {
    final isFit = _zoom == 1.0;
    return GestureDetector(
      onTap: () => _setZoom(1.0),
      child: Container(
        constraints: const BoxConstraints(minWidth: 64),
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isFit ? p.primaryTint : p.card,
          border: Border.all(color: isFit ? p.primary : p.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isFit ? 'FIT' : '$pct%',
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontFamilyFallback: const ['Consolas', 'monospace'],
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: isFit ? p.primary : p.text,
          ),
        ),
      ),
    );
  }
}

/// On-screen gradient wallet-card preview — mirrors the Claude Design
/// `WebExport` wallet card. Read-only; the printable copy is still produced by
/// [WalletCardGenerator] via the "Generate Wallet Card" button.
class _WalletCardPreview extends StatelessWidget {
  final Directive directive;
  final String? agentName;
  final String? agentPhone;
  const _WalletCardPreview({
    required this.directive,
    this.agentName,
    this.agentPhone,
  });

  String? _agentLine() {
    final name = agentName?.trim() ?? '';
    if (name.isEmpty) return null;
    final phone = agentPhone?.trim() ?? '';
    return phone.isEmpty ? 'Agent: $name' : 'Agent: $name · $phone';
  }

  String _typeLabel() =>
      formTypeFromName(directive.formType)?.shortName ?? 'PA MHAD';

  String _validLabel() {
    final exp = directive.expirationDate;
    if (exp == null || exp == 0) return 'sign to activate';
    final d = DateTime.fromMillisecondsSinceEpoch(exp);
    final mm = d.month.toString().padLeft(2, '0');
    return 'valid $mm/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final p = Theme.of(context).mhadPalette;
    final name =
        directive.fullName.trim().isEmpty ? 'Your name' : directive.fullName;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [p.primary, p.primaryDark],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -22,
              child: Text(
                'MH',
                style: TextStyle(
                  fontFamily: 'Instrument Serif',
                  fontStyle: FontStyle.italic,
                  fontSize: 92,
                  height: 1,
                  color: p.onPrimary.withValues(alpha: 0.10),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'PA MHAD · ACT 194',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontFamilyFallback: const ['Consolas', 'monospace'],
                      fontSize: 9,
                      letterSpacing: 1,
                      color: p.onPrimary.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: p.onPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _typeLabel(),
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 11,
                      color: p.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                  if (_agentLine() != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      _agentLine()!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'DM Sans',
                        fontSize: 10.5,
                        color: p.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_2, size: 22, color: p.primaryDark),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'scan to verify · ${_validLabel()}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontFamilyFallback: const [
                                'Consolas',
                                'monospace'
                              ],
                              fontSize: 10,
                              color: p.primaryDark,
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
        ),
      ),
    );
  }
}
