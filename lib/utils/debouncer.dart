import 'dart:async';

/// Coalesces rapid calls: [run] schedules [action] and resets the timer on each
/// call, so [action] fires only after [delay] of quiet. Used by the search /
/// autocomplete fields (medications, diagnoses, allergies) that previously each
/// hand-rolled the same `Timer? _debounce` pattern.
///
/// Remember to [dispose] (or [cancel]) in the owner's `dispose()`.
class Debouncer {
  Debouncer({this.delay = const Duration(milliseconds: 350)});

  final Duration delay;
  Timer? _timer;

  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancel any pending action without firing it.
  void cancel() => _timer?.cancel();

  void dispose() => _timer?.cancel();
}
