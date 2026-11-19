import 'dart:js_interop';

import 'package:web/web.dart' as web;

void Function() listenPageVisibility({
  required void Function() onHidden,
  required void Function() onVisible,
}) {
  final onChange = ((web.Event _) {
    if (web.document.visibilityState == 'hidden') {
      onHidden();
    } else {
      onVisible();
    }
  }).toJS;
  // `pagehide` also fires when the tab is closed or navigated away, in
  // browsers that skip `visibilitychange` there.
  final onPageHide = ((web.Event _) => onHidden()).toJS;
  web.document.addEventListener('visibilitychange', onChange);
  web.window.addEventListener('pagehide', onPageHide);
  return () {
    web.document.removeEventListener('visibilitychange', onChange);
    web.window.removeEventListener('pagehide', onPageHide);
  };
}

bool get pageIsVisible => web.document.visibilityState != 'hidden';
