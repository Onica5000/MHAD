import 'dart:typed_data';

import 'open_pdf_stub.dart'
    if (dart.library.js_interop) 'open_pdf_web.dart' as impl;

/// Opens [bytes] (a generated PDF) in the user's PDF viewer rather than forcing
/// a file download.
///
/// On WEB this opens the PDF in a new browser tab — the browser's built-in PDF
/// viewer, which has its own Print and Download controls — so nothing is saved
/// to disk automatically. Returns `true` if the tab opened, `false` if the
/// browser blocked the pop-up (the caller should then fall back to the print
/// dialog).
///
/// On NATIVE the stub returns `false` so the caller falls back to the print /
/// save-as-PDF preview.
Future<bool> openPdfInViewer(Uint8List bytes,
        {String filename = 'directive.pdf'}) =>
    impl.openPdfInViewer(bytes, filename: filename);
