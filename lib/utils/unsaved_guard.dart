import 'unsaved_guard_stub.dart'
    if (dart.library.js_interop) 'unsaved_guard_web.dart' as impl;

/// On web, toggles the browser's "Leave site? Changes may not be saved"
/// confirmation while the user has an unsaved in-memory directive (web does not
/// persist — a reload or tab-close loses the working directive). No-op on
/// native, where data is stored locally. Call with `true` when entering an edit
/// surface and `false` when leaving it.
void setUnsavedGuard(bool active) => impl.setUnsavedGuard(active);
