import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mhad/services/draft_recovery_service.dart';

/// Mix into every wizard step State to give the WizardScreen a uniform
/// interface for validation + saving before navigating forward.
mixin WizardStepMixin {
  /// Validate the current step's form and persist data to the database.
  /// Returns [true] if valid and saved successfully, [false] otherwise.
  Future<bool> validateAndSave();
}

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

/// Guards the "save-before-load" race. Wizard steps read their persisted data in
/// a post-frame callback (an async DB read), but the persistent nav bar lets the
/// user hit Next/Save immediately — before that load runs. A destructive
/// [WizardStepMixin.validateAndSave] (delete-all-then-insert, full-row overwrite,
/// or insert-new) fired in that window would wipe or duplicate the not-yet-loaded
/// data.
///
/// Steps mix this in, call [markLoaded] once their load has read the DB (even if
/// there was nothing to load), and begin `validateAndSave` with
/// `if (!isLoaded) return true;` — reporting "valid, nothing to save" so the
/// wizard still advances while the on-disk data is left untouched. (The window is
/// sub-frame, so a user who has actually typed anything is always past it; this
/// only defends against instant/rapid navigation over an unloaded step.)
mixin WizardStepLoadGuard<T extends StatefulWidget> on State<T> {
  bool _wizardStepLoaded = false;

  /// True once the step's initial async load has completed.
  bool get isLoaded => _wizardStepLoaded;

  /// Call at the end of the step's async load (after the DB read).
  void markLoaded() => _wizardStepLoaded = true;
}
