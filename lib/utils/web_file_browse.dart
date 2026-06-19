import 'dart:typed_data';

import 'web_file_browse_stub.dart'
    if (dart.library.js_interop) 'web_file_browse_web.dart' as impl;

/// Opens a native browser file picker (`<input type="file">`) and returns the
/// chosen files as name + bytes. This sidesteps `file_picker`, whose web
/// implementation was throwing at runtime on this app ("couldn't open the file
/// picker"), while drag-and-drop worked.
///
/// Returns `null` when the user cancels, and on NATIVE platforms (where the
/// stub is compiled in) so the caller falls back to `file_picker`. Returns an
/// empty list when files were chosen but none could be read.
Future<List<({String name, Uint8List bytes})>?> browseWebFiles({
  required String accept,
  bool multiple = true,
}) =>
    impl.browseWebFiles(accept: accept, multiple: multiple);
