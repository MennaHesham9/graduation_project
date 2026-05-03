import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FcmService {
  final _messaging = FirebaseMessaging.instance;
  final _db = FirebaseFirestore.instance;

  // Saves FCM token to Firestore on login
  // Keep this active — token will be ready when you upgrade to Blaze
  Future<void> initToken(String uid) async {
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    if (token != null) {
      await _db.collection('users').doc(uid).update({'fcmToken': token});
    }

    _messaging.onTokenRefresh.listen((newToken) {
      _db.collection('users').doc(uid).update({'fcmToken': newToken});
    });
  }

// 🔒 Sending push — requires Blaze plan + Cloud Functions
// Future<void> sendPush({
//   required String toUid,
//   required String title,
//   required String body,
//   Map<String, String>? data,
// }) async {
//   try {
//     final callable = FirebaseFunctions.instance.httpsCallable('sendPushNotification');
//     await callable.call({
//       'toUid': toUid,
//       'title': title,
//       'body': body,
//       'data': data ?? {},
//     });
//   } catch (e) {
//     print('FCM push failed: $e');
//   }
// }
}