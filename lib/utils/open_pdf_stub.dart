import 'dart:typed_data';

/// Native stub: there is no browser tab to open the PDF in, so return false and
/// let the caller fall back to the print / save-as-PDF preview.
Future<bool> openPdfInViewer(Uint8List bytes,
        {String filename = 'directive.pdf'}) async =>
    false;
