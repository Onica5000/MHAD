import 'dart:js_interop';

import 'package:web/web.dart' as web;

web.EventListener? _listener;

/// Web implementation: while active, a `beforeunload` handler triggers the
/// browser's native "Leave site? / Reload site?" confirmation so the user
/// doesn't silently lose an unsaved in-memory directive. Browsers show their
/// own generic message (the string is legacy/ignored by most), but
/// preventDefault + returnValue are what arm the prompt.
void setUnsavedGuard(bool active) {
  if (active) {
    if (_listener != null) return;
    _listener = (web.Event e) {
      e.preventDefault();
      (e as web.BeforeUnloadEvent).returnValue =
          'You have an unsaved directive. Download or export it before leaving.';
    }.toJS;
    web.window.addEventListener('beforeunload', _listener);
  } else {
    if (_listener == null) return;
    web.window.removeEventListener('beforeunload', _listener);
    _listener = null;
  }
}
