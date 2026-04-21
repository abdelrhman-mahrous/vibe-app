// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../../salon_app.dart';
// import '../../screens/notifications_screen.dart';
// import '../../widgets/bottom_navbar.dart';
// import 'awesome_notifcation_service.dart';

// class FirebaseMessagingService {
//   static Future<void> initializeFirebaseMessaging() async {
//     await FirebaseMessaging.instance
//         .setForegroundNotificationPresentationOptions(
//           alert: true,
//           badge: true,
//           sound: true,
//         );
//     FirebaseMessaging.onBackgroundMessage(
//       FirebaseMessagingService.firebaseMessagingBackgroundHandler,
//     );
//     FirebaseMessaging.onMessage.listen(
//       AwesomeNotifcationService.handleNotification,
//     );

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       _handleNavigationFromMessage(message);
//     });

//     // لما التطبيق يتفتح من إشعار وهو مقفول
//     FirebaseMessaging.instance.getInitialMessage().then((message) {
//       if (message != null) {
//         _handleNavigationFromMessage(message);
//       }
//     });
//   }

//   static void _handleNavigationFromMessage(RemoteMessage message) {
//     navigatorKey.currentState?.pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => BottomNavBar()),
//       (route) => route.isFirst,
//     );

//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (_) => const NotificationsScreen()),
//     );
//   }

//   static Future<void> firebaseMessagingBackgroundHandler(
//     RemoteMessage message,
//   ) async {
//     await AwesomeNotifcationService.initializeNotification();
//     AwesomeNotifcationService.handleNotification(message);
//   }

//   static Future<void> subscribeToTopic(String topic) async {
//     try {
//       await FirebaseMessaging.instance.subscribeToTopic(topic);
//       // print('Successfully subscribed to topic: $topic');
//     } catch (e) {
//       // print('Error subscribing to topic $topic: $e');
//     }
//   }

//   static Future<void> saveTokenToDatabase(String userId) async {
//     final token = await FirebaseMessaging.instance.getToken();
//     if (token != null) {
//       await Supabase.instance.client
//           .from('users')
//           .update({'fcm_token': token})
//           .eq('id', userId);
//     }

//     // تحديث التوكن لو اتغير
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//       await Supabase.instance.client
//           .from('users')
//           .update({'fcm_token': newToken})
//           .eq('id', userId);
//     });
//   }

//   static Future<void> unsubscribeFromTopic(String topic) async {
//     try {
//       await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
//       // print('Successfully unsubscribed from topic: $topic');
//     } catch (e) {
//       // print('Error unsubscribing from topic $topic: $e');
//     }
//   }
// }
