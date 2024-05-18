import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static Future<void> initialize() async {
    var androidInitialize = const AndroidInitializationSettings('ic_launcher');
    var iOSInitialize = const DarwinInitializationSettings();
    var initializeSettings =
        InitializationSettings(android: androidInitialize, iOS: iOSInitialize);
    flutterLocalNotificationsPlugin.initialize(initializeSettings);
  }

  static Future<void> reset() async {
        await flutterLocalNotificationsPlugin.cancelAll();
    }
}

