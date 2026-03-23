import 'dart:async';

/// On web, Isolate is not available. Runs in the main thread.
/// Handles both sync and async callbacks.
Future<T> runInBackground<T>(FutureOr<T> Function() callback) async =>
    await callback();
