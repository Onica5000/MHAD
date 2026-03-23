import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mhad/utils/platform_utils.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Manages local notifications for directive expiration reminders.
///
/// When a directive is executed, two reminders are scheduled:
///  • 60 days before expiration  (≈ 1 year 10 months after execution)
///  • 14 days before expiration  (≈ 1 year 11.5 months after execution)
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

  /// Whether notifications are supported on the current platform.
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

  /// Schedules two expiration reminders for [directiveId].
  ///
  /// [expirationDate] is the date the directive expires (2 years after execution).
  /// Call this immediately after the user executes a directive.
  Future<void> scheduleExpirationReminders(
    int directiveId,
    DateTime expirationDate,
  ) async {
    if (!isSupported) return;
    // Cancel any prior reminders for this directive before rescheduling
    await cancelReminders(directiveId);

    final remind60 = expirationDate.subtract(const Duration(days: 60));
    final remind14 = expirationDate.subtract(const Duration(days: 14));
    final now = DateTime.now();

    if (remind60.isAfter(now)) {
      await _schedule(
        id: directiveId * 10 + 1,
        title: 'Directive Expires in 60 Days',
        body: 'Your PA Mental Health Advance Directive will expire on '
            '${_fmt(expirationDate)}. Consider renewing it soon.',
        scheduledDate: remind60,
      );
    }

    if (remind14.isAfter(now)) {
      await _schedule(
        id: directiveId * 10 + 2,
        title: 'Directive Expires in 14 Days',
        body: 'Your PA Mental Health Advance Directive expires on '
            '${_fmt(expirationDate)}. Create a new directive to keep your '
            'preferences on record.',
        scheduledDate: remind14,
      );
    }
  }

  /// Schedules a reminder for the user to arrange witness signing.
  Future<void> scheduleWitnessReminder(DateTime scheduledDate) async {
    if (!isSupported) return;
    await _schedule(
      id: 99999, // Fixed ID for witness reminder
      title: 'Witness Signing Reminder',
      body: 'You scheduled a time to sign your Mental Health Advance '
          'Directive with two witnesses today. Make sure both witnesses '
          'are 18+ years old.',
      scheduledDate: scheduledDate,
    );
  }

  /// Cancels both expiration reminders for [directiveId].
  Future<void> cancelReminders(int directiveId) async {
    try {
      await _plugin.cancel(directiveId * 10 + 1);
      await _plugin.cancel(directiveId * 10 + 2);
    } catch (e) {
      debugPrint('NotificationService cancel error: $e');
    }
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      final tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tzDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('NotificationService schedule error (id=$id): $e');
    }
  }

  static String _fmt(DateTime d) =>
      '${d.month}/${d.day}/${d.year}';
}
