import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notifications/config/router/app_router.dart';


class LocalNotification {

  static Future<void> requestPermissionLocalNotifications() async{
      FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
  }

  static Future<void> initializeLocalNotifications() async{
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    //TODO ios configuration

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      //TODO IOS
      );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  static void showLocalNotification({
    required int id,
    String? title,
    String? body,
    String? data,
  }){

    const androidDetails =  AndroidNotificationDetails(
        'channelId',
        'channelName',
        playSound: true,
        sound:  RawResourceAndroidNotificationSound('notification'),
        importance: Importance.max,
        priority: Priority.high
      );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      //TODO IOS
    ); 

    final flutterLocalNotificationPlugin = FlutterLocalNotificationsPlugin();

    flutterLocalNotificationPlugin.show(id,title,body,notificationDetails, payload: data);
  }

  static void onDidReceiveNotificationResponse(NotificationResponse response){
    appRouter.push('/push_details/${response.payload}');
  }

}