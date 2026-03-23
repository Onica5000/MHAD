import 'dart:async';

Future<T> runInBackground<T>(FutureOr<T> Function() callback) =>
    throw UnsupportedError('Platform not supported');
