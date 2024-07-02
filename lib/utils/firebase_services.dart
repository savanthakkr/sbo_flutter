import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseService {
  static FirebaseMessaging? _firebaseMessaging;
  static FirebaseMessaging get firebaseMessaging => FirebaseService._firebaseMessaging ?? FirebaseMessaging.instance;
  static FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initializeFirebase() async {

    FirebaseOptions options = const FirebaseOptions(
        apiKey: "AIzaSyCm5KubGZ74DvKp9bVSIbyjvJLvykN2Zo8",
        projectId: "sbonew-7a724",
        messagingSenderId: "802980808854",
        appId: "1:802980808854:android:d54e351a765b71a1d05ab7");

    await Firebase.initializeApp(options: options);
    FirebaseService._firebaseMessaging = FirebaseMessaging.instance;
    await FirebaseService.initializeLocalNotifications();
    await FirebaseService.onMessage();
    await FirebaseService.onBackgroundMsg();
  }

  Future<String?> getDeviceToken() async => await FirebaseMessaging.instance.getToken();



  static Future<void> initializeLocalNotifications() async {
    final InitializationSettings _initSettings = InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"),
        iOS: DarwinInitializationSettings()
    );
    /// on did receive notification response = for when app is opened via notification while in foreground on android
    await FirebaseService._localNotificationsPlugin.initialize(_initSettings);
    /// need this for ios foregournd notification
    await FirebaseService.firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );
  }

  static NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      "high_importance_channel", "High Importance Notifications", priority: Priority.max, importance: Importance.max,
    ),
  );

  static Future<void> onMessage() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (Platform.isAndroid) {
        // if this is available when Platform.isIOS, you'll receive the notification twice

        String? title = message.notification!.title;
        String? msg = message.notification!.body;

        await FirebaseService._localNotificationsPlugin.show(
          0, title, msg, FirebaseService.platformChannelSpecifics,
          payload: message.data.toString(),
        );
        // await FirebaseService._localNotificationsPlugin.show(
        //   0, message.notification!.title, message.notification!.body, FirebaseService.platformChannelSpecifics,
        //   payload: message.data.toString(),
        // );
      }
    });
  }

  static Future<void> onBackgroundMsg() async {
    Stream<RemoteMessage> _stream = FirebaseMessaging.onMessageOpenedApp;
    _stream.listen((RemoteMessage event) async {
      if (event.data != null) {
        if (Platform.isAndroid) {
          // if this is available when Platform.isIOS, you'll receive the notification twice
          print("Message ${event.notification!.title}");
          // String title = event.data['title'];
          // String msg = event.data['body'];
          String? title = event.notification!.title;
          String? msg = event.notification!.body;

          await FirebaseService._localNotificationsPlugin.show(
            0, title, msg, FirebaseService.platformChannelSpecifics,
            payload: event.data.toString(),
          );
          // await FirebaseService._localNotificationsPlugin.show(
          //   0, message.notification!.title, message.notification!.body, FirebaseService.platformChannelSpecifics,
          //   payload: message.data.toString(),
          // );
        }
      }
    });
  }

  // SaveNotification(String nTitle,String nMsg) async {
  //   DatabaseHelper databaseHelper = DatabaseHelper.instance;
  //   final box = GetStorage();
  //   String uId = box.read(Prefs.UID);
  //
  //   Map<String, dynamic> row = {
  //     'user_id': uId,
  //     'ntf_title': nTitle,
  //     'ntf_msg': nMsg,
  //   };
  //
  //   NotificationModel myNotificationModel = NotificationModel.fromMap(row);
  //   var id = await databaseHelper.insert(myNotificationModel);
  //
  //   print("Data $id");
  //
  // }

}