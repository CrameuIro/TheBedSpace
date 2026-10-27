import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// ---------------------------------------------------------------------------
/// Local sleep / wake reminders. Everything is scheduled on-device — no push
/// server is involved (the online backend is out of scope for the MVP).
/// ---------------------------------------------------------------------------
class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool available = false;

  /// The in-flight (or completed) initialisation. Caching the *future* rather
  /// than a "done" flag means a second caller waits for the first attempt
  /// instead of racing ahead while `available` is still false.
  static Future<void>? _initFuture;

  static const _channel = AndroidNotificationDetails(
    'thebedspace_reminders',
    'Sleep reminders',
    channelDescription: 'Bedtime and wake-up reminders for TheBedSpace',
    importance: Importance.high,
    priority: Priority.high,
  );

  static Future<void> init() {
    // The browser has no local-notification plugin; `available` stays false so
    // the UI disables the reminder switch instead of failing.
    if (kIsWeb) return Future.value();
    return _initFuture ??= _doInit();
  }

  static Future<void> _doInit() async {
    try {
      tzdata.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwin = DarwinInitializationSettings();
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: android,
          iOS: darwin,
          macOS: darwin,
        ),
      );
      available = true;
    } catch (e) {
      available = false;
      debugPrint('NotificationService.init failed: $e');
    }
  }

  /// Android 13+ requires a runtime permission for notifications.
  static Future<bool> requestPermission() async {
    if (!available) return false;
    try {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      if (ios != null) {
        final granted = await ios.requestPermissions(alert: true, sound: true);
        return granted ?? false;
      }
      final macos = _plugin
          .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin
          >();
      if (macos != null) {
        final granted = await macos.requestPermissions(
          alert: true,
          sound: true,
        );
        return granted ?? false;
      }
      return true;
    } catch (e) {
      debugPrint('requestPermission failed: $e');
      return false;
    }
  }

  /// Schedules a daily repeating notification at [hour]:[minute] local time.
  static Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!available) return;
    try {
      final now = DateTime.now();
      var next = DateTime(now.year, now.month, now.day, hour, minute);
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
      // Converting into the tz database preserves the absolute instant, so the
      // reminder fires at the correct local moment even though we never query
      // the device timezone name.
      final scheduled = tz.TZDateTime.from(next, tz.local);
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: _channel,
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('scheduleDaily failed: $e');
    }
  }

  static Future<void> cancelAll() async {
    if (!available) return;
    try {
      await _plugin.cancelAll();
    } catch (e) {
      debugPrint('cancelAll failed: $e');
    }
  }
}
