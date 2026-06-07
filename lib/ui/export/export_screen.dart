import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mhad/data/database/app_database.dart';
import 'package:mhad/domain/model/directive.dart';
import 'package:mhad/providers/app_providers.dart';
import 'package:mhad/ui/router.dart';
import 'package:mhad/ui/export/pdf/pdf_generator.dart';
import 'package:mhad/ui/export/pdf/wallet_card_generator.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/crisis_top_bar.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/ui/widgets/design/wizard_header.dart';
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
    if (directive == null || !mounted) return;

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
        '& Advocacy at 1-800-692-7443.');
    buf.writeln('');
    buf.writeln('This is a summary. Request the full directive from the principal.');

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
                'Scan to view directive summary\u2009\u2014\u2009request full copy from principal',
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
      final generator = PdfGenerator(
        includeCombined: _includeCombined,
        includeDeclaration: _includeDeclaration,
        includePoa: _includePoa,
        includeSupplementary: _includeSupplementary,
        includeNotes: _includeNotes,
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
      const generator = WalletCardGenerator();

      final directive = _directive!;
      final agents = _agents;

      final bytes = await runInBackground(
        () => generator.generate(directive: directive, agents: agents),
      );

      if (!mounted) return;

      await Printing.sharePdf(
        bytes: bytes,
        filename:
            'PA_MHAD_WalletCard_${_directive!.fullName.replaceAll(' ', '_')}.pdf',
      );
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

    final p = Theme.of(context).mhadPalette;

    // --- Shared content lists (ADDITIVE: same widgets feed both the narrow
    // single-column and the wide >=1000px two-pane layouts; zero behavior or
    // logic change — only arrangement differs by width). ---

    // Header / chrome shown above both layouts.
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
      // Disclaimer
      Semantics(
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
          ),
          const SizedBox(height: 16),

          // Principal info summary
          if (_directive != null)
            Card(
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
            ),
          const SizedBox(height: 16),
    ];

    // LEFT / "Document" pane on wide screens: pick which forms go into the
    // PDF, then preview it. (Includes the V4-M8 unencrypted-file banner.)
    final documentChildren = <Widget>[
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
          // V4-M8 — persistent banner: the PDF is unencrypted by design.
          Container(
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
          ),
    ];

    // RIGHT / "Distribution" pane on wide screens: share, QR, NFC, machine-
    // readable formats, password-protected copy, and draft review.
    final distributionChildren = <Widget>[
          Semantics(
            button: true,
            label: 'Share or print the PDF directive (unencrypted file)',
            child: OutlinedButton.icon(
              onPressed: _isGenerating ? null : _generateAndShare,
              icon: const Icon(Icons.share),
              label: const Text('Share / Print'),
            ),
          ),
          const SizedBox(height: 8),
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
              'For your records, a spreadsheet, or an electronic health record. '
              'Your PDF above is the document you sign — these are data exports.',
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
        WizardHeader(
          backLabel: 'Back',
          onBack: () => Navigator.of(context).maybePop(),
          actionLabel: '',
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Wide >=1000px: prototype `w-export` two-pane structure —
              // Document (forms + preview) on the left, Distribution
              // (share/QR/NFC/data exports) on the right. Below 1000px the
              // layout is the unchanged single stretched column.
              if (constraints.maxWidth >= 1000) {
                return ListView(
                  padding: const EdgeInsets.fromLTRB(22, 4, 22, 40),
                  children: [
                    ...headerChildren,
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 640),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: documentChildren,
                            ),
                          ),
                        ),
                        const SizedBox(width: 32),
                        SizedBox(
                          width: 360,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: distributionChildren,
                            ),
                          ),
                        ),
                      ],
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
