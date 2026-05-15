import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has accepted the first-launch legal disclaimer.
/// Used as a GoRouter [refreshListenable] to redirect unauthenticated users
/// to the disclaimer screen before they can access the app.
///
/// On **web** the disclaimer is shown every session because web data is
/// ephemeral (public mode only, no persistent storage).  On native platforms
/// acceptance is persisted to SharedPreferences and the screen is shown only
/// once.
class DisclaimerNotifier extends ChangeNotifier {
  static const _key = 'disclaimer_accepted';

  bool _accepted;

  DisclaimerNotifier({required bool initialValue}) : _accepted = initialValue;

  bool get accepted => _accepted;

  /// Loads the persisted acceptance state.
  ///
  /// On web, always returns `false` so the disclaimer is shown on every
  /// page load (consistent with the ephemeral nature of web data).
  /// On native platforms, returns the stored value (or false if not yet
  /// accepted).
  static Future<DisclaimerNotifier> load() async {
    if (kIsWeb) {
      return DisclaimerNotifier(initialValue: false);
    }
    final prefs = await SharedPreferences.getInstance();
    return DisclaimerNotifier(
      initialValue: prefs.getBool(_key) ?? false,
    );
  }

  /// Marks acceptance for this session (and persists it on native platforms).
  /// Notifies GoRouter to re-evaluate the redirect.
  Future<void> accept() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    }
    _accepted = true;
    notifyListeners();
  }
}
