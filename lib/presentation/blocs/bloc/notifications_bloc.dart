import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:notifications/config/local_notification/local_notification.dart';
import 'package:notifications/domaun/entities/push_message.dart';
import 'package:notifications/firebase_options.dart';


part 'notifications_event.dart';
part 'notifications_state.dart';

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  int pushNumberId = 0;

  NotificationsBloc() : super(NotificationsState()) {

    on<NotificationStatusChanged>(_onNotificationStatusChanged);

    on<NotificationReceived>(_onPushMessageReceived);

    //Verificar estado de la notificaciones
    _initialStatusCheck();

    //Listener para notificaciones en foreground
    _onForegroundMessage();
  }

  static Future<void> initializeFCM() async{
    await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  }

  void _onNotificationStatusChanged ( NotificationStatusChanged event, Emitter<NotificationsState> emit){
    emit(
      state.copyWith(
        status: event.status
      )
    );
    _getFCMToken();
  }

  void _onPushMessageReceived( NotificationReceived event, Emitter<NotificationsState> emit){
    emit(
      state.copyWith(
        notifications: [event.message, ... state.notifications]
      )
    );

  }

  void _initialStatusCheck() async{
    final settings = await messaging.getNotificationSettings();
    add(NotificationStatusChanged(settings.authorizationStatus));

  }

  void _getFCMToken() async{
    if (state.status != AuthorizationStatus.authorized) return;

    final token = await messaging.getToken();
    print('Token: $token **');
  }

  void handleRemoteMessage(RemoteMessage message){
    if (message.notification == null) return; 
    final notification = PushMessage(
      messageId: message.messageId
      ?.replaceAll(':', '').replaceAll('%', '')
      ?? '',
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
      deteTime: message.sentTime ?? DateTime.now(),
      data: message.data,
      imageUrl: Platform.isAndroid
        ? message.notification!.android?.imageUrl 
        :  message.notification!.apple?.imageUrl
      );

    LocalNotification.showLocalNotification(
      id: ++pushNumberId,
      body: notification.body,
      data: notification.data.toString(),
      title: notification.title
    );
    add(NotificationReceived(notification));
  }

  void _onForegroundMessage(){
    FirebaseMessaging.onMessage.listen(handleRemoteMessage);
  }


  void requestPermision() async{
  
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: true,
      provisional: false,
      sound: true,
    );


    //Solicitar permiso a las local notification
    await LocalNotification.requestPermissionLocalNotifications();
    add(NotificationStatusChanged(settings.authorizationStatus));

  }

  PushMessage? getMessageById(String pushmessageid){
    final exist = state.notifications.any((element)=> element.messageId == pushmessageid);
    if(!exist) return null;

    return state.notifications.firstWhere((element) => element.messageId == pushmessageid );
  }

}
