// import 'dart:math';

// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import '../../salon_app.dart';
// import '../../screens/notifications_screen.dart';
// import '../../widgets/bottom_navbar.dart';

// class AwesomeNotifcationService {
//   static const channelKeys = {'user_notifications': 'user_notifications'};

//   static Future<void> initializeNotification() async {
//     await AwesomeNotifications().initialize(
//       'resource://mipmap/launcher_icon',
//       [
//         NotificationChannel(
//           channelGroupKey: channelKeys['user_notifications'],
//           channelKey: channelKeys['user_notifications'],
//           channelName: 'user_notifications',
//           channelDescription: 'App Notifications',
//           importance: NotificationImportance.Max,
//           channelShowBadge: true,
//           onlyAlertOnce: true,
//           playSound: true,
//           criticalAlerts: true,
//         ),
//       ],
//       channelGroups: [
//         NotificationChannelGroup(
//           channelGroupKey: channelKeys['user_notifications'].toString(),
//           channelGroupName: 'Group 1',
//         ),
//       ],
//       debug: true,
//     );

//     await AwesomeNotifications().isNotificationAllowed().then((
//       isAllowed,
//     ) async {
//       if (!isAllowed) {
//         await AwesomeNotifications().requestPermissionToSendNotifications();
//       }
//     });

//     await AwesomeNotifications().setListeners(
//       onActionReceivedMethod: onActionReceivedMethod,
//       onNotificationCreatedMethod: onNotificationCreatedMethod,
//       onNotificationDisplayedMethod: onNotificationDisplayedMethod,
//       onDismissActionReceivedMethod: onDismissActionReceivedMethod,
//     );
//   }

//   static Future<void> onNotificationCreatedMethod(
//     ReceivedNotification receivedNotification,
//   ) async {
//     debugPrint('onNotificationCreatedMethod');
//   }

//   static Future<void> onNotificationDisplayedMethod(
//     ReceivedNotification receivedNotification,
//   ) async {
//     debugPrint('onNotificationDisplayedMethod');
//   }

//   /// ✅ لما اليوزر يمسح الإشعار من الـ tray → ما نمسحوش من الداتابيز
//   /// بس نسجّل إنه اتعرض (مش لازم نعمل حاجة هنا)
//   static Future<void> onDismissActionReceivedMethod(
//     ReceivedAction receivedAction,
//   ) async {
//     debugPrint(
//       'onDismissActionReceivedMethod - notification dismissed from tray only',
//     );
//     // ✅ عمداً فاضية - الإشعار يفضل في الداتابيز
//     // اليوزر لازم يدخل صفحة الإشعارات ويضغط عليه عشان يتمسح
//   }

//   /// ✅ لما اليوزر يضغط على الإشعار → علّم كمقروء في الداتابيز وروّح لصفحة الإشعارات
//   static Future<void> onActionReceivedMethod(
//     ReceivedAction receivedAction,
//   ) async {
//     final payload = receivedAction.payload;
//     final appointmentId = payload?['appointment_id'];
//     final notificationDbId =
//         payload?['notification_db_id']; // ✅ ID من جدول notifications
//     final action = receivedAction.buttonKeyPressed;

//     // ─── تحديث حالة الموعد (تأكيد/إلغاء) ─────────────────────────────────
//     if (appointmentId != null) {
//       if (action == 'confirm') {
//         await Supabase.instance.client
//             .from('appointments')
//             .update({'attendance_confirmed': true})
//             .eq('id', appointmentId);
//       } else if (action == 'cancel') {
//         await Supabase.instance.client
//             .from('appointments')
//             .update({'attendance_confirmed': false, 'status': 'cancelled'})
//             .eq('id', appointmentId);
//       }
//     }

//     // ─── ✅ علّم الإشعار كمقروء في الداتابيز لما اليوزر يضغط عليه ──────────
//     // بس لو ضغط على الإشعار نفسه (مش زرار action)
//     if (notificationDbId != null && action.isEmpty) {
//       await Supabase.instance.client
//           .from('notifications')
//           .update({'is_read': true})
//           .eq('id', notificationDbId);
//     }

//     // ─── التوجيه لصفحة الإشعارات ────────────────────────────────────────────
//     navigatorKey.currentState?.pushAndRemoveUntil(
//       MaterialPageRoute(builder: (_) => BottomNavBar()),
//       (route) => route.isFirst,
//     );
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(builder: (_) => const NotificationsScreen()),
//     );
//   }

//   static Future<void> showNotification({
//     required final String title,
//     required final String body,
//     required final String chanelKay,
//     final String? summary,
//     final Map<String, String>? payload,
//     final ActionType actionType = ActionType.Default,
//     final NotificationLayout notificationLayout = NotificationLayout.Default,
//     final NotificationCategory? category,
//     final String? bigPicture,
//     final List<NotificationActionButton>? actionButtons,
//     final int? id,
//   }) async {
//     await AwesomeNotifications().createNotification(
//       content: NotificationContent(
//         id: id!,
//         channelKey: chanelKay,
//         title: title,
//         body: body,
//         actionType: actionType,
//         notificationLayout: notificationLayout,
//         summary: summary,
//         category: category,
//         payload: payload,
//         bigPicture: bigPicture,
//         wakeUpScreen: true,
//         groupKey: 'chat_messages',
//       ),
//       actionButtons: actionButtons,
//     );
//   }

//   static Future<void> handleNotification(RemoteMessage message) async {
//     try {
//       RemoteNotification? notification = message.notification;
//       if (notification != null) {
//         // ✅ مرّر الـ notification_db_id في الـ payload عشان نقدر نعلّمه كمقروء لما اليوزر يضغط
//         final data = message.data;
//         await showNotification(
//           chanelKay: 'user_notifications',
//           title: notification.title ?? 'No Title',
//           body: notification.body ?? 'No Body',
//           id: Random().nextInt(1000000),
//           payload: {
//             if (data['appointment_id'] != null)
//               'appointment_id': data['appointment_id'],
//             if (data['notification_db_id'] != null)
//               'notification_db_id': data['notification_db_id'],
//             if (data['type'] != null) 'type': data['type'],
//           },
//         );
//       }
//     } catch (e) {
//       debugPrint('Error handling notification: $e');
//     }
//   }
// }
