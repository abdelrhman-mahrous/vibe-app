// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart' as auth;

// class PushNotifcationService {
//   static Future<String> getAccessToken() async {
//     final serviceAccountJson = {
//       "type": "service_account",
//       "project_id": "project_id-f9e2b",
//       "private_key_id": "private_key_id",
//       "private_key": "private_key",
//       "client_email": "client_email",
//       "client_id": "client_id",
//       "auth_uri": "https://accounts.google.com/o/oauth2/auth",
//       "token_uri": "https://oauth2.googleapis.com/token",
//       "auth_provider_x509_cert_url":
//           "https://www.googleapis.com/oauth2/v1/certs",
//       "client_x509_cert_url":
//           "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xn350%40test-f9e2b.iam.gserviceaccount.com",
//       "universe_domain": "googleapis.com",
//     };

//     List<String> scopes = [
//       "https://www.googleapis.com/auth/firebase.messaging",
//     ];

//     http.Client client = await auth.clientViaServiceAccount(
//       auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//       scopes,
//     );

//     auth.AccessCredentials credentials = await auth
//         .obtainAccessCredentialsViaServiceAccount(
//           auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
//           scopes,
//           client,
//         );

//     client.close();

//     return credentials.accessToken.data;
//   }

//   static Future<void> sendUserNotifcation({
//     required UserNotifcationBody userMessage,
//   }) async {
//     final String serverAccessTokenKay = await getAccessToken();

//     String endpointFirebaseCloudMessaging =
//         'https://fcm.googleapis.com/v1/projects/salon-alaraby/messages:send';

//     final Map<String, dynamic> message = {
//       'message': {
//         'token': userMessage.deviceFcmToken,
//         'notification': {'title': "Test App", 'body': userMessage.body},
//         'data': {'title': userMessage.title, 'body': userMessage.body},
//       },
//     };

//     final http.Response response = await http.post(
//       Uri.parse(endpointFirebaseCloudMessaging),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'Bearer $serverAccessTokenKay',
//       },
//       body: jsonEncode(message),
//     );

//     if (response.statusCode == 200) {
//       print('Notification sent successfully.');
//     } else {
//       print('Notification not sent. Status code: ${response.statusCode}');
//     }
//   }

//   static Future<void> sendTopicNotification({
//     required String topic,
//     required String title,
//     required String body,
//   }) async {
//     final String serverAccessTokenKay = await getAccessToken();

//     String endpointFirebaseCloudMessaging =
//         'https://fcm.googleapis.com/v1/projects/{your_project_id}/messages:send';

//     final Map<String, dynamic> message = {
//       'message': {
//         'topic': topic,
//         'notification': {'title': "صالون مينا العربي", 'body': body},
//         'data': {'title': title, 'body': body},
//       },
//     };

//     final http.Response response = await http.post(
//       Uri.parse(endpointFirebaseCloudMessaging),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//         'Authorization': 'Bearer $serverAccessTokenKay',
//       },
//       body: jsonEncode(message),
//     );

//     if (response.statusCode == 200) {
//       print('Notification sent successfully to topic: $topic');
//     } else {
//       print(
//         'Notification not sent to topic. Status code: ${response.statusCode}, Reason: ${response.reasonPhrase}',
//       );
//     }
//   }
// }

// class UserNotifcationBody {
//   final String title;
//   final String body;
//   final String deviceFcmToken;

//   UserNotifcationBody({
//     required this.title,
//     required this.body,
//     required this.deviceFcmToken,
//   });
// }
