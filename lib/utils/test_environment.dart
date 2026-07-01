/// Whether the code is running inside a Flutter/Dart test harness.
///
/// Web-safe via conditional import (the `_native` / `_web` / `_stub` pattern
/// used elsewhere in this codebase): on web — where `dart:io` is unavailable —
/// this is always `false`; on IO platforms it reads the `FLUTTER_TEST`
/// environment variable that `flutter test` sets for every test process.
///
/// Used to short-circuit native-plugin calls (e.g. `safe_device`) that would
/// otherwise throw a `MissingPluginException` and spam test output, because
/// `defaultTargetPlatform` defaults to `TargetPlatform.android` under
/// `flutter_test`.
library;

export 'test_environment_stub.dart'
    if (dart.library.io) 'test_environment_io.dart';
