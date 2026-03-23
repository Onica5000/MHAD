import 'dart:async';
import 'dart:isolate';

/// Runs [callback] in a background isolate on native platforms.
/// Handles both sync and async callbacks (matching Isolate.run's signature).
Future<T> runInBackground<T>(FutureOr<T> Function() callback) =>
    Isolate.run(callback);
