import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web implementation: wrap the PDF bytes in a Blob and open the object URL in a
/// new tab. The browser's built-in PDF viewer renders it with Print + Download
/// controls; nothing downloads automatically. Returns false if the browser
/// blocked the pop-up so the caller can fall back to the print dialog.
Future<bool> openPdfInViewer(Uint8List bytes,
    {String filename = 'directive.pdf'}) async {
  final blob = web.Blob(
    <JSAny>[bytes.toJS].toJS,
    web.BlobPropertyBag(type: 'application/pdf'),
  );
  final url = web.URL.createObjectURL(blob);
  final win = web.window.open(url, '_blank');
  // Revoke once the new tab has had time to load the blob.
  Future<void>.delayed(
    const Duration(minutes: 2),
    () => web.URL.revokeObjectURL(url),
  );
  return win != null;
}
