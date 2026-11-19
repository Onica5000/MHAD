import 'page_visibility_stub.dart'
    if (dart.library.js_interop) 'page_visibility_web.dart' as platform;

/// Calls [onHidden] when the page stops being shown — switching tabs or apps,
/// locking the phone, closing the tab — and [onVisible] when it is shown
/// again. Returns a function that removes the listeners. Off the web it does
/// nothing (returns a no-op).
void Function() listenPageVisibility({
  required void Function() onHidden,
  required void Function() onVisible,
}) =>
    platform.listenPageVisibility(onHidden: onHidden, onVisible: onVisible);

/// Whether the page is in front of the person right now (always true off the
/// web).
bool get pageIsVisible => platform.pageIsVisible;
