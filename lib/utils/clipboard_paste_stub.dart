/// Native (non-web) no-op: there is no browser clipboard paste event.
void Function() registerImagePaste(
        void Function(List<int> bytes, String mimeType) onImage) =>
    () {};
