import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
  }

  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Test karne ke liye — 5 second baad notification
  Future<void> showTestNotification() async {
    final granted = await requestPermission();
    if (!granted) return;

    await _plugin.show(
      99,
      '🍽️ Test Notification',
      'working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Test',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  Future<void> scheduleAllMealNotifications() async {
    final granted = await requestPermission();
    if (!granted) return;

    await _scheduleDaily(
      id: 1,
      hour: 8,
      minute: 0,
      title: '🌅 Breakfast Time!',
      body: 'Start your day right — check today\'s breakfast recipe!',
    );

    await _scheduleDaily(
      id: 2,
      hour: 14,
      minute: 0,
      title: '☀️ Lunch Time!',
      body: 'What\'s for lunch? Discover a new recipe now!',
    );

    await _scheduleDaily(
      id: 3,
      hour: 19,
      minute: 0,
      title: '🌇 Dinner Time!',
      body: 'Time to cook! See tonight\'s dinner suggestion.',
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year, now.month, now.day,
      hour, minute,
    );

    // Agar time nikal gaya — kal ke liye schedule karo
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_reminders_$id',
          'Meal Reminders',
          channelDescription: 'Daily meal time recipe suggestions',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();
}