import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

   Future<void> initializeNotifications() async {
    var initializationSettingsAndroid =
    AndroidInitializationSettings('codex_logo');
    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {
          String? payload = notificationResponse.payload;
          if (payload != null) {
            debugPrint('notification payload: ' + payload);
          }
        });
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // await flutterLocalNotificationsPlugin.initialize(
    //     initializationSettings,
    //     onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
    //   if (notificationResponse.payload != null) {
    //     switch (notificationResponse.actionId) {
    //       case 'ACTION_SKIP':
    //         print('SKIP');
    //         break;
    //       case 'ACTION_PAUSE':
    //         print('PAUSE');
    //         break;
    //       default:
    //       // Xử lý thông báo thông thường
    //         break;
    //     }
    //   }
    //   }
    // );
  }



