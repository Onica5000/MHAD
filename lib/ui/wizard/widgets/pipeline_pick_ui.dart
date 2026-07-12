part of 'document_pipeline_flow.dart';

// The Pick + Processing step UI of the document pipeline. Split out of
// document_pipeline_flow.dart as an extension on the pipeline State so it
// keeps direct access to the State's private fields with no behavioral
// change (same pattern as pipeline_apply_service.dart /
// pipeline_review_widget.dart).
//
// ignore_for_file: invalid_use_of_protected_member
// (extension methods on the State legitimately call its protected setState)

extension _PipelinePickUi on _PipelineScreenState {
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
                'Drop a photo, PDF, or audio recording — ID, medication list, '
                'prescription label, an old directive, or just describe your '
                'wishes out loud — and the AI will extract what it can. You '
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
              const SizedBox(height: 10),
              // Voice path: the read-aloud questionnaire + how-to (printable).
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => appRouter.push(AppRoutes.audioGuide),
                  icon: const Icon(Icons.mic_none, size: 16),
                  label: const Text(
                    'Recording a voice file? See the questionnaire & how-to',
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: const Size(0, 36),
                    alignment: Alignment.centerLeft,
                  ),
                ),
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
    if (d.mimeType.startsWith('audio/')) return Icons.audiotrack_outlined;
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
                          'Read — then it goes to your AI provider to read.'
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
            "or PDF needs an AI key (Gemini's free tier takes about 30 "
            'seconds). You review every field before it lands in your form.',
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
                      'in it — is sent to your AI provider to read. The app saves '
                      "nothing (it's gone when this tab closes), but the provider "
                      "may retain it (Gemini's free tier does). You review "
                      'everything before it is added to your directive.',
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
                                    fontSize: 10,
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
              'Your file (including any personal details) is sent to your AI '
              'provider to read it. The app saves nothing; the provider may '
              "retain it (Gemini's free tier does). You review before anything "
              'is added.',
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
          // A long AI read shouldn't hold the user hostage (UX audit B8).
          // The generating stage (apply service) stays uncancellable — it's
          // short and its results screen has its own back affordance.
          if (_step != _PipelineStep.generating) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _cancelProcessing,
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Cancel'),
            ),
          ],
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
                          : doc.mimeType.startsWith('audio/')
                              ? Icons.audiotrack_outlined
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
