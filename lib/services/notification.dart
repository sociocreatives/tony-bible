import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final int channelId = 47;

  //initialize

  Future initialize() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    AndroidInitializationSettings androidInitializationSettings = AndroidInitializationSettings("cross");

    DarwinInitializationSettings darwinInitializationSettings = DarwinInitializationSettings();

    final InitializationSettings initializationSettings = InitializationSettings(android: androidInitializationSettings, iOS: darwinInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  //Instant Notifications
  Future instantNofitication() async {
    var android = AndroidNotificationDetails("id", "channel", channelDescription: "description");

    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();

    var platform = new NotificationDetails(android: android, iOS: darwinNotificationDetails);

    await _flutterLocalNotificationsPlugin.show(channelId, "Demo instant notification", "Tap to do something", platform, payload: "Welcome to demo app");
  }

  //Image notification
  Future imageNotification() async {
    var bigPicture = BigPictureStyleInformation(DrawableResourceAndroidBitmap("cross"), largeIcon: DrawableResourceAndroidBitmap("cross"), contentTitle: "Demo image notification", summaryText: "This is some text", htmlFormatContent: true, htmlFormatContentTitle: true);

    var android = AndroidNotificationDetails("id", "channel", channelDescription:"description", styleInformation: bigPicture);

    var platform = new NotificationDetails(android: android);

    await _flutterLocalNotificationsPlugin.show(channelId, "Demo Image notification", "Tap to do something", platform, payload: "Welcome to demo app");
  }

  //Stylish Notification
  Future stylishNotification() async {
    var android = AndroidNotificationDetails("id", "channel", channelDescription: "description", color: Colors.deepOrange, enableLights: true, enableVibration: true, largeIcon: DrawableResourceAndroidBitmap("cross"), styleInformation: MediaStyleInformation(htmlFormatContent: true, htmlFormatTitle: true));

    var platform = new NotificationDetails(android: android);

    await _flutterLocalNotificationsPlugin.show(channelId, "Demo Stylish notification", "Tap to do something", platform);
  }

  //Sheduled Notification

  Future scheduledNotification() async {
    var interval = RepeatInterval.weekly;
    var android = AndroidNotificationDetails("id", "channel", channelDescription: "description");

    DarwinNotificationDetails darwinNotificationDetails = DarwinNotificationDetails();

    var platform = new NotificationDetails(android: android, iOS: darwinNotificationDetails);

    await _flutterLocalNotificationsPlugin.periodicallyShow(
      channelId,
      "Change Wallpaper",
      "Reminder to change your wallpaper.",
      interval,
      platform,
      androidAllowWhileIdle: true,
    );
  }

  //Cancel notification

  Future cancelNotification() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }
}
