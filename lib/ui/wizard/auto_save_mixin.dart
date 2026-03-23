import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:mhad/services/draft_recovery_service.dart';

/// Mixin for wizard steps that auto-saves non-PII field data on change.
/// Uses a 3-second debounce to avoid excessive writes.
///
/// Usage: mix into your step State, call [registerAutoSave] in initState
/// with the directive ID and a callback that returns the current non-PII data.
mixin AutoSaveMixin<T extends StatefulWidget> on State<T> {
  Timer? _autoSaveTimer;
  int? _autoSaveDirectiveId;
  Map<String, dynamic> Function()? _autoSaveCollector;

  /// Register auto-save for this step.
  /// [collector] should return a map of safe (non-PII) field values.
  void registerAutoSave({
    required int directiveId,
    required Map<String, dynamic> Function() collector,
  }) {
    _autoSaveDirectiveId = directiveId;
    _autoSaveCollector = collector;
  }

  /// Call this when any non-PII field changes (e.g., from a controller listener).
  void triggerAutoSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(const Duration(seconds: 3), _doAutoSave);
  }

  Future<void> _doAutoSave() async {
    if (_autoSaveDirectiveId == null || _autoSaveCollector == null) return;
    if (!mounted) return;
    try {
      await DraftRecoveryService.saveDraft(
        directiveId: _autoSaveDirectiveId!,
        data: _autoSaveCollector!(),
      );
    } catch (e) {
      debugPrint('Auto-save failed: $e');
    }
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }
}
