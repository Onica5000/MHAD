import 'clipboard_paste_stub.dart'
    if (dart.library.js_interop) 'clipboard_paste_web.dart' as impl;

/// Registers a browser clipboard-paste listener that fires [onImage] with the
/// bytes + mime type whenever the user pastes an image (⌘V / Ctrl+V).
///
/// Web only — a no-op (returns a no-op disposer) on native platforms, which
/// use the camera / file picker instead. Always call the returned disposer to
/// remove the listener.
void Function() registerImagePaste(
        void Function(List<int> bytes, String mimeType) onImage) =>
    impl.registerImagePaste(onImage);
