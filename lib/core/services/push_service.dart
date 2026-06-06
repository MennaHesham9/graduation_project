import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushService {
  static const String appId = 'ab565fd5-c0a1-4450-8fdb-3d8b55fd3794';
  static const String _restApiKey = 'os_v2_app_vnlf7voaufcfbd63hwfvl7jxstncrqtgj6jedlmxjpimmeh2cjjnrf7ugd7r5o7f7dxd7tlgazx4yopagpt22npjrl66roea4ohjrpa';

  // ✅ MUST be v1 — v2 does not exist for this endpoint
  static const String _apiUrl = 'https://onesignal.com/api/v1/notifications';

  final FirebaseFirestore _db;
  PushService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<void> init(String uid) async {
    try {
      await OneSignal.Notifications.requestPermission(true);

      String? onesignalId = OneSignal.User.pushSubscription.id;

      if (onesignalId == null || onesignalId.isEmpty) {
        debugPrint('⏳ OneSignal ID not ready yet — retrying in 3s...');
        await Future.delayed(const Duration(seconds: 3));
        onesignalId = OneSignal.User.pushSubscription.id;
      }

      if (onesignalId == null || onesignalId.isEmpty) {
        debugPrint('⚠️ OneSignal ID still null after retry — push skipped for this login');
        return;
      }

      await _db.collection('users').doc(uid).update({
        'oneSignalId': onesignalId,
      });

      debugPrint('✅ OneSignal ID saved: $onesignalId');
    } catch (e) {
      debugPrint('⚠️ PushService.init error: $e');
    }
  }

  Future<void> sendPush({
    required String toUid,
    required String title,
    required String body,
    String? type,
    String? relatedId,
  }) async {
    try {
      final userDoc = await _db.collection('users').doc(toUid).get();
      if (!userDoc.exists) {
        debugPrint('⚠️ User doc not found for $toUid');
        return;
      }

      final onesignalId = userDoc.data()?['oneSignalId'] as String?;
      if (onesignalId == null || onesignalId.isEmpty) {
        debugPrint('⚠️ No oneSignalId for user $toUid — push skipped');
        return;
      }

      // 🛠️ FIX: Change 'include_aliases' to 'include_subscription_ids'
      final payload = {
        'app_id': appId,
        'include_subscription_ids': [onesignalId], // Directly targets the device's subscription string
        'target_channel': 'push',
        'headings': {'en': title},
        'contents': {'en': body},
        'priority': 10,
        'ios_sound': 'default',
        if (type != null || relatedId != null)
          'data': {
            if (type != null) 'type': type,
            if (relatedId != null) 'relatedId': relatedId,
          },
      };

      debugPrint('📤 Sending push to $toUid...');
      debugPrint('📦 Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey', // Ensure this key matches your OneSignal Dashboard key exactly
        },
        body: jsonEncode(payload),
      );

      debugPrint('📬 Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Push sent successfully to device subscription: $toUid');
      } else if (response.statusCode == 401) {
        debugPrint('🔴 401 Unauthorized — Double check your OneSignal Rest API key under settings');
      } else if (response.statusCode == 400) {
        debugPrint('🔴 400 Bad Request — Server rejected payload layout: ${response.body}');
      } else {
        debugPrint('🔴 ${response.statusCode}: ${response.body}');
      }
    } catch (e, stack) {
      debugPrint('🔴 sendPush exception: $e');
      debugPrint('$stack');
    }
  }
}