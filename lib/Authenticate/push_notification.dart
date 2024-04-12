
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

class LocalNotificationService {

  static String serverKey='AAAAmmMXiYo:APA91bF_LD8ezhyH9-V9NaRzZJCa0HpfWtQDOpetoY6iyOa8BkqwdO6Ju2Xc1TihOveeDhlVezshDTReCkhedLlCTmuew77y9TPSy_Nks_0KkIYx-Qs7peCj2TuUD3Q4fu5J6yOQTlYi';

  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static void initialize() {
    final InitializationSettings initializationSettings =
    InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/ic_launcher"));
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async{
    try {
      print("In Notification method");
      Random random = new Random();
      int id = random.nextInt(1000);
      const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            "mychanel",
            "my chanel",
            importance: Importance.max,
            priority: Priority.high,
              playSound: true,
              enableVibration: true,
          )
      );
      print("my id is ${id.toString()}");
      await _flutterLocalNotificationsPlugin.show(
        id,
        message.notification!.title,
        message.notification!.body,
        notificationDetails,);
    } on Exception catch (e) {
      print('Error>>>$e');
    }
  }
  static Future<void> sendNotification({String? title,String? message,String? token}) async{
        final data = {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "id": "1",
          "status": "done",
          "message": message
        };

        try {
          final headers = {
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey',
          };
          http.Response response = await http.post(
            Uri.parse('https://fcm.googleapis.com/fcm/send'),
            headers: headers,
            body: jsonEncode(<String, dynamic>{
              'notification': <String, dynamic>{'body': message, 'title': title},
              'priority': 'high',
              'data': data,
              'to': "$token"
            }),
          );
          print('FCM response: ${response.body}');
          if(response.statusCode==200){
            print('done');
          }else{
            print(response.statusCode);
          }
        } catch (e) {
          print('Error sending FCM notification: $e');
        }
  }
}