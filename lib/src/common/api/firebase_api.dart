// // ignore_for_file: unused_field

// import 'dart:convert';
// import 'dart:developer';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:tao_mobile/features/authentication/data/controller/authentication_controller.dart';

// import '../../features/authentication/data/services/authentication_local_service.dart';
// import '../../features/shared/barrel_files/_views_routes_export.dart';

// final firebaseApiProvider = Provider<FirebaseApi>((ref) {
//   return FirebaseApi(
//     ref: ref,
//   );
// });

// Future<void> handleBackgroundMessage(RemoteMessage message) async {
//   log('Title: ${message.notification?.title}');
//   log('Body: ${message.notification?.body}');
//   log('Data: ${message.data}');
// }

// class FirebaseApi {
//   final AuthenticationLocalService _authenticationLocalService;
//   final Ref _ref;
//   FirebaseApi({
//     required Ref ref,
//   })  : _authenticationLocalService =
//             ref.read(authenticationLocalServiceProvider),
//         _ref = ref {
//     // initNotification();
//   }

//   final _firebaseMessaging = FirebaseMessaging.instance;

//   final _androidChannel = const AndroidNotificationChannel(
//     'high_importance_channel', // id
//     'High Importance Notifications', // title
//     description:
//         'This channel is used for important notifications.', // description
//     importance: Importance.high,
//   );

//   final _localNotifications = FlutterLocalNotificationsPlugin();

//   handleMessage(RemoteMessage? message) {
//     if (message == null) return;

//     // navigateKey.currentState?.pushNamed(
//     //   message.data['route'],
//     //   arguments: message,
//     // );
//   }

//   Future initPushNotification() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     // Subscribe to a Firebase topic
//     await FirebaseMessaging.instance
//         .subscribeToTopic(_ref.read(authenticationControllerProvider).userId);
//     log('_ref.read(authenticationControllerProvider).userId: ${_ref.read(authenticationControllerProvider).userId}');
//     log("✅ Subscribed to topic: news");

//     FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
//     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
//     FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       final notification = message.notification;
//       final android = message.notification?.android;
//       if (notification != null && android != null) {
//         _localNotifications.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               _androidChannel.id,
//               _androidChannel.name,
//               channelDescription: _androidChannel.description,
//               icon: '@mipmap/ic_launcher',
//             ),
//           ),
//           payload: jsonEncode(message.toMap()),
//         );
//       }
//     });
//   }

//   Future intiLocalNotifications() async {
//     const iOS = DarwinInitializationSettings();
//     const android = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const settings = InitializationSettings(android: android, iOS: iOS);

//     await _localNotifications.initialize(
//       settings,
//       onDidReceiveNotificationResponse: (response) {
//         final message =
//             RemoteMessage.fromMap(jsonDecode(response.payload ?? ''));
//         handleMessage(message);
//       },
//     );

//     final platform = _localNotifications.resolvePlatformSpecificImplementation<
//         AndroidFlutterLocalNotificationsPlugin>();
//     if (platform != null) {
//       platform.createNotificationChannel(_androidChannel);
//     }
//   }

//   //initnotification
//   // Future<void> initNotification() async {
//   //   await _firebaseMessaging.requestPermission();
//   //   final fcmToken = await _firebaseMessaging.getToken();
//   //   _authenticationLocalService.saveFcmToken(fcmToken ?? '');
//   //   log('fcmToken: $fcmToken');
//   //   initPushNotification();
//   //   intiLocalNotifications();
//   // }

//   Future<void> initNotification() async {
//     await _firebaseMessaging.requestPermission();
//     final fcmToken = await _firebaseMessaging.getToken();
//     _authenticationLocalService.saveFcmToken(fcmToken ?? '');
//     log('🔑 FCM Token: $fcmToken');

//     await intiLocalNotifications();
//     await initPushNotification();
//   }
// }
