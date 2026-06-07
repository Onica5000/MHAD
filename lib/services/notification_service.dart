import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:timezone/data/latest_all.dart' as tz;

/// Initializes the local-notification stack and cancels any stray scheduled
/// notifications.
///
/// NOTE: the app deliberately does **not** schedule OS notifications for
/// expiry/check-in reminders — those fire in-app on launch via
/// `services/reminder_scheduler.dart` (per the 2026-06-02 decision). The old
/// `scheduleExpirationReminders` / `scheduleWitnessReminder` methods were
/// removed in the 2026-06-07 cleanup; only init, permission, and
/// [cancelReminders] remain (the latter clears any reminders left over from
/// builds that did schedule them).
///
/// **Platform support**: this service uses `flutter_local_notifications`,
/// which through v18 still only declares Android / iOS / macOS / Linux as
/// `flutter.plugin.platforms`. **Windows is not supported by the plugin.**
/// On Windows, [isSupported] returns false and every public method is a
/// safe no-op. Adopting a separate Windows toast plugin (e.g.
/// `local_notifier` or `windows_notification`) is the path forward if
/// Windows users need expiry reminders — see the 2026-06-04 audit row in
/// CLAUDE.md / docs/GAP_ANALYSIS_V4.md for context. Web is also a no-op
/// (the browser drops scheduled state on tab close anyway, so the
/// reminder model doesn't apply).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationChannel(
    'mhad_expiry',
    'Directive Expiry Reminders',
    description:
        'Reminds you when your Mental Health Advance Directive is about to expire.',
    importance: Importance.high,
  );

  /// Whether the local-notification stack is reachable on this platform.
  ///
  /// Returns true only for the platforms the underlying plugin actually
  /// supports: Android, iOS, macOS. Windows + Web are explicitly false —
  /// see the class-level comment for why and what to do about it.
  static bool get isSupported =>
      !kIsWeb && (platformIsAndroid || platformIsIOS || platformIsMacOS);

  Future<void> initialize() async {
    if (!isSupported) return;
    try {
      tz.initializeTimeZones();

      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );

      // Create the Android notification channel (no-op on iOS)
      final androidImpl = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImpl?.createNotificationChannel(_channel);
    } catch (e) {
      // Non-fatal — the app functions without notifications
      debugPrint('NotificationService init error: $e');
    }
  }

  /// Request runtime notification permission (Android 13+ / iOS).
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>();

      final androidGranted =
          await android?.requestNotificationsPermission() ?? true;
      final iosGranted =
          await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
              true;
      return androidGranted && iosGranted;
    } catch (e) {
      debugPrint('NotificationService permission error: $e');
      return false;
    }
  }

  /// Cancels any reminders previously scheduled for [directiveId].
  Future<void> cancelReminders(int directiveId) async {
    try {
      await _plugin.cancel(directiveId * 10 + 1);
      await _plugin.cancel(directiveId * 10 + 2);
      await _plugin.cancel(directiveId * 10 + 3);
    } catch (e) {
      debugPrint('NotificationService cancel error: $e');
    }
  }
}
