import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mhad/ui/theme/app_theme.dart';
import 'package:mhad/utils/test_environment.dart';
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

    // Skip on web / test host to avoid false positives and plugin noise.
    //
    // V4-L14 — under `flutter_test`, `defaultTargetPlatform` defaults to
    // `TargetPlatform.android` (NOT the host OS), so `_isMobilePlatform()`
    // would pass and `SafeDevice.isJailBroken` would be invoked — throwing a
    // `MissingPluginException` (no native side registered on the test VM) that
    // spammed every test run. Guard on `isRunningInTest` (FLUTTER_TEST env var,
    // web-safe) so the native channel is never touched in tests.
    if (kIsWeb) return;
    if (isRunningInTest) return;
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
        icon: Icon(
          Icons.security_rounded,
          color: SemanticColors.warningText(Theme.of(ctx).brightness),
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
