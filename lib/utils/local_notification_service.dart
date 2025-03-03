import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  // Singleton pattern
  static final LocalNotificationService _instance = LocalNotificationService._internal();

  factory LocalNotificationService() {
    return _instance;
  }

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Initialize the notifications
  Future<void> init() async {
    // Initialize timezone data for scheduled notifications
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("Notification clicked!");
      },
    );
  }

  // Show a instant notification
  Future<void> showInstantNotification({required String title, required String body}) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_importance_channel', // Channel ID
      'High Importance Notifications', // Channel name
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Notification title
      body, // Notification body
      notificationDetails,
    );
  }

  // Show a scheduled notification
  Future<void> showScheduledNotification({
    required String title,
    required String body,
    required int secondsFromNow,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel', // Channel ID for scheduled notifications
      'Scheduled Notifications', // Channel name
      channelDescription: 'This channel is used for scheduled notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      1, // Notification ID
      title, // Notification title
      body, // Notification body
      tz.TZDateTime.now(tz.local).add(Duration(seconds: secondsFromNow)), // Schedule time
      notificationDetails, // Ensure the notification shows even in Doze mode
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}
