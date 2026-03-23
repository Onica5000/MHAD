import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:mhad/utils/platform_utils.dart';

enum PrivacyMode { notSelected, publicMode, privateMode }

/// Result of a biometric/device-credential authentication attempt.
enum AuthResult {
  /// Authentication succeeded — private mode is active.
  success,

  /// User cancelled or failed the authentication prompt.
  cancelled,

  /// Biometric / device-credential authentication is not available on this
  /// device (no enrolled biometrics, no screen lock, or API error).
  /// Caller should fall back to the in-app passcode flow.
  unavailable,
}

/// Tracks the current session's privacy mode.
///
/// - [notSelected] — chosen at every app launch before the user picks a mode.
/// - [publicMode]  — in-memory database; data is lost when the app closes.
/// - [privateMode] — file-based database; requires authentication.
///
/// Used as a GoRouter [refreshListenable] so the router re-evaluates the
/// redirect after the user picks a mode.
class PrivacyModeNotifier extends ChangeNotifier {
  final LocalAuthentication _auth = LocalAuthentication();

  PrivacyMode _mode = PrivacyMode.notSelected;

  PrivacyMode get mode => _mode;
  bool get isSelected => _mode != PrivacyMode.notSelected;
  bool get isPrivate => _mode == PrivacyMode.privateMode;
  bool get isPublic => _mode == PrivacyMode.publicMode;

  /// Switch to public mode immediately — no auth required.
  void setPublicMode() {
    _mode = PrivacyMode.publicMode;
    notifyListeners();
  }

  /// Set private mode directly — call after passcode verification succeeds.
  void setPrivateMode() {
    _mode = PrivacyMode.privateMode;
    notifyListeners();
  }

  /// Attempt biometric / device-credential authentication and switch to
  /// private mode.
  ///
  /// Returns [AuthResult.success] when authenticated, [AuthResult.cancelled]
  /// when the user dismissed the prompt, or [AuthResult.unavailable] when the
  /// device cannot perform any form of biometric or credential authentication
  /// (caller should fall back to the in-app passcode flow).
  Future<AuthResult> trySetPrivateMode() async {
    // On web, biometric/device-credential auth is not available
    if (kIsWeb) return AuthResult.unavailable;

    try {
      // Quick gate: if the platform reports no capability at all, skip the
      // authenticate() call entirely.
      final canCheck = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();

      if (!canCheck && !isDeviceSupported) {
        return AuthResult.unavailable;
      }

      final authenticated = await _auth.authenticate(
        localizedReason:
            'Authenticate to access your saved Mental Health Advance Directives',
        options: const AuthenticationOptions(
          biometricOnly: false, // also allow device PIN/pattern fallback
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        _mode = PrivacyMode.privateMode;
        notifyListeners();
        return AuthResult.success;
      }
      return AuthResult.cancelled;
    } on PlatformException catch (e) {
      debugPrint('Biometric auth error: $e');
      // Common codes: NotAvailable, NotEnrolled, LockedOut,
      // PermanentlyLockedOut. Treat all as "unavailable" so the caller can
      // offer the passcode fallback.
      return AuthResult.unavailable;
    }
  }

  /// Downgrade from private → public within a session.
  /// This wipes the current in-memory view (the Riverpod appDatabaseProvider
  /// will recreate as an in-memory DB when mode changes to publicMode).
  /// Cannot be reversed without relaunching the app.
  void downgradeToPublic() {
    _mode = PrivacyMode.publicMode;
    notifyListeners();
  }
}
