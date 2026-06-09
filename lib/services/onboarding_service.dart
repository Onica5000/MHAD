import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks whether the user has seen the first-touch "In your words" intro.
/// Used as a GoRouter [refreshListenable] so the intro can be a real route
/// gate (after the disclaimer + mode gates) instead of an overlay pushed on
/// top of Home — that overlay forced a Home render to sit between the
/// disclaimer and the intro, which the user saw as a page "flashing".
///
/// On **web** this always starts `false`, so the intro shows every session
/// (web data is ephemeral — same policy as the disclaimer). On native it is
/// persisted and shown only once.
class OnboardingNotifier extends ChangeNotifier {
  static const _key = 'onboarding_completed';

  bool _completed;

  OnboardingNotifier({required bool initialValue}) : _completed = initialValue;

  bool get completed => _completed;

  /// Loads the persisted completion state. Always `false` on web so the intro
  /// shows on every page load.
  static Future<OnboardingNotifier> load() async {
    if (kIsWeb) {
      return OnboardingNotifier(initialValue: false);
    }
    final prefs = await SharedPreferences.getInstance();
    return OnboardingNotifier(initialValue: prefs.getBool(_key) ?? false);
  }

  /// Marks the intro complete for this session (and persists it on native).
  /// Notifies GoRouter to re-evaluate the redirect so the gate releases.
  Future<void> complete() async {
    if (!kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_key, true);
    }
    _completed = true;
    notifyListeners();
  }
}
