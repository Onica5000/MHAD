import 'package:web/web.dart' as web;

import 'key_value_store.dart';

KeyValueStore deviceStore() => _BrowserStore(() => web.window.localStorage);
KeyValueStore tabStore() => _BrowserStore(() => web.window.sessionStorage);

/// `localStorage` / `sessionStorage`. Every call is guarded: a private window
/// or blocked site data can make the accessor itself throw.
class _BrowserStore implements KeyValueStore {
  _BrowserStore(this._storage);
  final web.Storage Function() _storage;

  @override
  String? read(String key) {
    try {
      return _storage().getItem(key);
    } catch (_) {
      return null;
    }
  }

  @override
  bool write(String key, String value) {
    try {
      _storage().setItem(key, value);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void remove(String key) {
    try {
      _storage().removeItem(key);
    } catch (_) {}
  }
}
