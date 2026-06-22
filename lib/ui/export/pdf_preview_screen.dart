import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/ui/widgets/design/editorial_heading.dart';
import 'package:mhad/ui/widgets/design/section_label.dart';
import 'package:mhad/utils/open_pdf.dart';
import 'package:printing/printing.dart';

/// Open the PDF in the user's viewer (a new browser tab on web) so they can
/// print or save it — never an automatic download. Falls back to the print/save
/// dialog on native or if the browser blocks the tab.
Future<void> _openOrPrintPdf(Uint8List bytes) async {
  final opened = await openPdfInViewer(bytes, filename: 'PA_MHAD.pdf');
  if (!opened) {
    await Printing.layoutPdf(onLayout: (_) => bytes, name: 'PA_MHAD');
  }
}

class PdfPreviewScreen extends StatelessWidget {
  final Uint8List pdfBytes;
  const PdfPreviewScreen({required this.pdfBytes, super.key});

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
                fontFamily: kSansFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.text,
              ),
            ),
            Text(
              'US LETTER · 8.5×11"',
              style: TextStyle(
                fontFamily: kMonoFamily,
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
            onPressed: () => _openOrPrintPdf(pdfBytes),
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
                  onPressed: () => _openOrPrintPdf(pdfBytes),
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
                  onPressed: () => _openOrPrintPdf(pdfBytes),
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
class ExportPdfPreview extends StatefulWidget {
  final String signature;
  final Future<Uint8List> Function() buildBytes;
  final bool hasSelection;
  final bool ready;

  /// Called when the user taps "Back" in the left control panel — leaves the
  /// Export screen. In the wide layout the full-width header is hidden, so this
  /// is the screen's back affordance.
  final VoidCallback onClose;
  const ExportPdfPreview({
    required this.signature,
    required this.buildBytes,
    required this.hasSelection,
    required this.ready,
    required this.onClose,
    super.key,
  });

  @override
  State<ExportPdfPreview> createState() => _ExportPdfPreviewState();
}

class _ExportPdfPreviewState extends State<ExportPdfPreview> {
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
  void didUpdateWidget(covariant ExportPdfPreview old) {
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
                  fontFamily: kSansFamily,
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
            fontFamily: kSansFamily,
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
              fontFamily: kSansFamily,
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
              fontFamily: kMonoFamily,
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
                          fontFamily: kSansFamily,
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
            fontFamily: kSansFamily,
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
            fontFamily: kMonoFamily,
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
