import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Web implementation: build a hidden `<input type="file">`, click it, and read
/// the selected files' bytes. Mirrors how `file_picker` works internally but
/// without its interop layer, which was throwing here.
Future<List<({String name, Uint8List bytes})>?> browseWebFiles({
  required String accept,
  bool multiple = true,
}) async {
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = accept
    ..multiple = multiple
    ..style.display = 'none';

  final completer = Completer<web.FileList?>();
  var done = false;
  void finish(web.FileList? files) {
    if (done) return;
    done = true;
    completer.complete(files);
  }

  input.onchange = ((web.Event _) => finish(input.files)).toJS;

  // Cancel detection: closing the OS dialog refocuses the window. If no change
  // event arrived shortly after, treat it as a cancel so the future resolves.
  late final JSFunction focusListener;
  focusListener = ((web.Event _) {
    web.window.removeEventListener('focus', focusListener);
    Future<void>.delayed(const Duration(milliseconds: 600), () => finish(null));
  }).toJS;
  web.window.addEventListener('focus', focusListener);

  web.document.body?.appendChild(input);
  input.click();

  final files = await completer.future;
  input.remove();

  if (files == null || files.length == 0) return null;

  final out = <({String name, Uint8List bytes})>[];
  for (var i = 0; i < files.length; i++) {
    final file = files.item(i);
    if (file == null) continue;
    final bytes = await _readBytes(file);
    if (bytes != null) out.add((name: file.name, bytes: bytes));
  }
  return out;
}

Future<Uint8List?> _readBytes(web.File file) {
  final c = Completer<Uint8List?>();
  final reader = web.FileReader();
  reader.onload = ((web.Event _) {
    final result = reader.result;
    if (result.isA<JSArrayBuffer>()) {
      c.complete((result as JSArrayBuffer).toDart.asUint8List());
    } else {
      c.complete(null);
    }
  }).toJS;
  reader.onerror = ((web.Event _) => c.complete(null)).toJS;
  reader.readAsArrayBuffer(file);
  return c.future;
}
