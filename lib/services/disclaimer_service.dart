import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has accepted the first-launch legal disclaimer.
/// Used as a GoRouter [refreshListenable] to redirect unauthenticated users
/// to the disclaimer screen before they can access the app.
class DisclaimerNotifier extends ChangeNotifier {
  static const _key = 'disclaimer_accepted';

  bool _accepted;

  DisclaimerNotifier({required bool initialValue}) : _accepted = initialValue;

  bool get accepted => _accepted;

  /// Loads the persisted acceptance state.  Returns a notifier initialized
  /// with the stored value (or false if not yet accepted).
  static Future<DisclaimerNotifier> load() async {
    final prefs = await SharedPreferences.getInstance();
    return DisclaimerNotifier(
      initialValue: prefs.getBool(_key) ?? false,
    );
  }

  /// Persists acceptance and notifies GoRouter to re-evaluate the redirect.
  Future<void> accept() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    _accepted = true;
    notifyListeners();
  }
}
