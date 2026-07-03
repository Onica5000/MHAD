import 'dart:io' show Platform;

/// `true` when `flutter test` is running — it sets `FLUTTER_TEST=true` in the
/// test process environment for every test.
bool get isRunningInTest => Platform.environment.containsKey('FLUTTER_TEST');
