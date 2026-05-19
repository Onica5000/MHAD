import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:safe_device/safe_device.dart';

/// Service that checks for root/jailbreak and warns the user.
///
/// This is a non-blocking warning — the user can dismiss and continue.
/// Detection runs once on app startup via [checkAndWarn].
class DeviceSecurityService {
  DeviceSecurityService._();

  static final DeviceSecurityService instance = DeviceSecurityService._();

  /// Whether we have already shown the warning this session.
  bool _hasWarned = false;

  /// Runs root/jailbreak detection and shows a warning dialog if the device
  /// appears compromised. Safe to call multiple times — only warns once.
  ///
  /// [context] must be from a widget that is already mounted in the tree
  /// (e.g. after the first frame of the home screen).
  Future<void> checkAndWarn(BuildContext context) async {
    if (_hasWarned) return;

    // Skip on desktop / web / test host to avoid false positives.
    //
    // V4-L14 — Flutter widget tests run on the Dart VM with the host OS
    // (Windows/macOS/Linux), so `defaultTargetPlatform` is *not* Android/iOS
    // and `_isMobilePlatform()` already short-circuits this method before
    // `SafeDevice.isJailBroken` is called. The "Error checking JailBroken
    // status: MissingPluginException" line that may appear in test output
    // is logged by the plugin's own native side during plugin registration
    // and is harmless — there is no Dart-side change that can suppress it
    // without dropping the dependency.
    if (kIsWeb) return;
    if (!_isMobilePlatform()) return;

    try {
      final bool isJailBroken = await SafeDevice.isJailBroken;

      if (isJailBroken && context.mounted) {
        _hasWarned = true;
        await _showWarningDialog(context);
      }
    } catch (e) {
      // Detection failure should never crash the app.
      // On unsupported platforms or permission issues, silently continue.
      debugPrint('Device security check failed: $e');
    }
  }

  bool _isMobilePlatform() {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _showWarningDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.security_rounded,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('Device Security Warning'),
        content: const Text(
          'Your device appears to be rooted/jailbroken. '
          'This may put your sensitive health data at risk. '
          'Consider using a non-modified device for storing '
          'advance directives.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('I Understand'),
          ),
        ],
      ),
    );
  }
}
