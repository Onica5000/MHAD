import 'dart:js_interop';

import 'package:web/web.dart' as web;

/// Web implementation: listens for the document `paste` event and, for any
/// pasted image, reads its bytes and calls [onImage]. Returns a disposer that
/// removes the listener.
void Function() registerImagePaste(
    void Function(List<int> bytes, String mimeType) onImage) {
  void onPaste(web.Event event) {
    final clipboard = (event as web.ClipboardEvent).clipboardData;
    if (clipboard == null) return;
    final items = clipboard.items;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      if (item.kind != 'file' || !item.type.startsWith('image/')) continue;
      final file = item.getAsFile();
      if (file == null) continue;
      final mime = item.type;
      final reader = web.FileReader();
      reader.onload = (web.Event _) {
        final result = reader.result;
        if (result.isA<JSArrayBuffer>()) {
          final bytes = (result as JSArrayBuffer).toDart.asUint8List();
          onImage(bytes, mime);
        }
      }.toJS;
      reader.readAsArrayBuffer(file);
    }
  }

  final listener = onPaste.toJS;
  web.document.addEventListener('paste', listener);
  return () => web.document.removeEventListener('paste', listener);
}
