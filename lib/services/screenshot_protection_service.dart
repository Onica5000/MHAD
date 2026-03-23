import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mhad/utils/platform_utils.dart';

/// Manages FLAG_SECURE on Android to prevent screenshots and screen
/// recording of sensitive directive data. Toggle is user-controlled.
///
/// On non-Android platforms this is a no-op.
class ScreenshotProtectionService {
  ScreenshotProtectionService._();

  static const _channel = MethodChannel('com.mhad/screenshot_protection');

  static bool _enabled = false;

  /// Whether screenshot protection is currently active.
  static bool get isEnabled => _enabled;

  /// Enable screenshot / screen-recording protection.
  static Future<void> enable() async {
    if (!platformIsAndroid) return;
    try {
      await _channel.invokeMethod('enableProtection');
      _enabled = true;
    } catch (e) {
      debugPrint('Failed to enable screenshot protection: $e');
    }
  }

  /// Disable screenshot / screen-recording protection.
  static Future<void> disable() async {
    if (!platformIsAndroid) return;
    try {
      await _channel.invokeMethod('disableProtection');
      _enabled = false;
    } catch (e) {
      debugPrint('Failed to disable screenshot protection: $e');
    }
  }

  /// Toggle screenshot protection on or off. Returns the new state.
  static Future<bool> toggle() async {
    if (_enabled) {
      await disable();
    } else {
      await enable();
    }
    return _enabled;
  }
}
