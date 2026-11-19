import 'key_value_store_memory.dart'
    if (dart.library.js_interop) 'key_value_store_web.dart' as platform;

/// A tiny string store. On the web the two instances are the browser's own:
///
/// * [deviceStore] = `localStorage` — stays on this device until erased. It
///   only ever holds the passphrase-locked copy (plus its try counter and
///   the open-tab marker), never readable directive data.
/// * [tabStore] = `sessionStorage` — survives a reload of this tab and is
///   erased when the tab is closed. Used when the person chose not to keep a
///   locked copy.
///
/// Used directly, not through shared_preferences, because that package can't
/// reach `sessionStorage`. Off the web both are in-memory maps.
abstract class KeyValueStore {
  String? read(String key);

  /// False when the browser refused (storage full, or blocked in a private
  /// window) — the caller says so instead of claiming the work was kept.
  bool write(String key, String value);

  void remove(String key);
}

final KeyValueStore deviceStore = platform.deviceStore();
final KeyValueStore tabStore = platform.tabStore();

/// An in-memory [KeyValueStore] (tests; platforms without browser storage).
class MemoryKeyValueStore implements KeyValueStore {
  final Map<String, String> values = {};
  @override
  String? read(String key) => values[key];
  @override
  bool write(String key, String value) {
    values[key] = value;
    return true;
  }

  @override
  void remove(String key) => values.remove(key);
}
