import 'dart:typed_data';

/// Native stub: there is no browser file input, so return null and let the
/// caller use `file_picker` (which works fine on native platforms).
Future<List<({String name, Uint8List bytes})>?> browseWebFiles({
  required String accept,
  bool multiple = true,
}) async =>
    null;
