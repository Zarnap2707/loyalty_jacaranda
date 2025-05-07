import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // ✅ Request permission
    await messaging.requestPermission();

    // ✅ Get and print FCM token
    String? token = await messaging.getToken();
    print("📱 FCM Token: $token");

    // ✅ Setup local notification settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _localNotificationsPlugin.initialize(initSettings);

    // ✅ Foreground handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📥 Foreground message: ${message.notification?.title}");
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("🟢 App opened via notification: ${message.notification?.body}");
    });
  }

  static void showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'channel_id',
      'Loyalty Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      0,
      message.notification?.title ?? 'No Title',
      message.notification?.body ?? 'No Body',
      details,
    );
  }
}
