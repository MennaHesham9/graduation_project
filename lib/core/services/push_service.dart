// lib/core/services/push_service.dart
//
// FIXES APPLIED:
//
// 1. API KEY — The old key was an `os_v2_app_...` Management API key, which
//    is only valid for OneSignal's v2 endpoints. The /api/v1/notifications
//    endpoint requires the legacy REST API key (a plain UUID). Replace the
//    placeholder below with the value from:
//    OneSignal Dashboard → Settings → Keys & IDs → REST API Key
//
// 2. INIT RACE CONDITION — The subscription ID is almost never ready
//    synchronously at login. The old code read it immediately, found null,
//    and returned early without saving anything. The observer that fires
//    later was kept, but if init() exited before it fired, nothing was
//    persisted. Fixed by waiting up to 10 seconds via a Completer before
//    giving up, so the ID is reliably saved on first login.
//
// 3. OBSERVER LEAK — The old observer was added on every login and never
//    removed, so multiple listeners accumulated across logins. Fixed by
//    storing a reference and removing it after the ID is captured.

import 'dart:convert';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class PushService {
  static const String appId = 'ab565fd5-c0a1-4450-8fdb-3d8b55fd3794';

  // ⚠️  REPLACE THIS with your REST API Key from:
  // OneSignal Dashboard → Settings → Keys & IDs → "REST API Key"
  // It looks like: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  // Do NOT use the os_v2_app_... Management API key — that is for v2 endpoints only.
  static const String _restApiKey = 'os_v2_app_vnlf7voaufcfbd63hwfvl7jxsrfli55ewheeynuxdp6tiddi2wbsvhvzpjvuy2xsmq5xko4ok7mazuhtrf45kaui6nswc3ev3frtsya';

  static const String _apiUrl = 'https://onesignal.com/api/v1/notifications';

  final FirebaseFirestore _db;
  PushService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  // ── Init: register device and save OneSignal ID to Firestore ─────────────
  //
  // Waits up to 10 seconds for the subscription ID to become available before
  // giving up. The observer is removed once the ID is captured to avoid leaks.
  Future<void> init(String uid) async {
    try {
      await OneSignal.Notifications.requestPermission(true);

      // Check if the ID is already available synchronously
      String? onesignalId = OneSignal.User.pushSubscription.id;

      if (onesignalId == null || onesignalId.isEmpty) {
        debugPrint('⏳ OneSignal ID not ready yet — waiting for observer...');

        // Wait for the SDK to fire the subscription observer (up to 10s)
        final completer = Completer<String?>();

        late void Function(OSPushSubscriptionChangedState) observer;
        observer = (OSPushSubscriptionChangedState state) {
          final id = state.current.id;
          if (id != null && id.isNotEmpty && !completer.isCompleted) {
            completer.complete(id);
          }
        };

        OneSignal.User.pushSubscription.addObserver(observer);

        onesignalId = await completer.future.timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⚠️ OneSignal ID timed out after 10s');
            return null;
          },
        );

        // Clean up the observer now that we have the ID (or gave up)
        OneSignal.User.pushSubscription.removeObserver(observer);
      }

      if (onesignalId == null || onesignalId.isEmpty) {
        debugPrint('⚠️ OneSignal ID unavailable — push will not work for this session');
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

  // ── Send a push notification to a specific user ───────────────────────────
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
        debugPrint('⚠️ sendPush: user doc not found for uid=$toUid');
        return;
      }

      final onesignalId = userDoc.data()?['oneSignalId'] as String?;
      if (onesignalId == null || onesignalId.isEmpty) {
        debugPrint('⚠️ sendPush: no oneSignalId saved for uid=$toUid — push skipped');
        return;
      }

      final payload = <String, dynamic>{
        'app_id': appId,
        'include_subscription_ids': [onesignalId],
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

      debugPrint('📤 sendPush → uid=$toUid subscriptionId=$onesignalId');
      debugPrint('📦 Payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // FIX: Must be the legacy REST API Key (UUID format), not os_v2_app_...
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(payload),
      );

      debugPrint('📬 OneSignal response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('✅ Push delivered to uid=$toUid');
      } else if (response.statusCode == 401) {
        debugPrint(
          '🔴 401 Unauthorized — your _restApiKey is wrong.\n'
              '   Go to: OneSignal Dashboard → Settings → Keys & IDs → REST API Key\n'
              '   The key must be a UUID like xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx\n'
              '   Do NOT use the os_v2_app_... Management API key.',
        );
      } else if (response.statusCode == 400) {
        debugPrint('🔴 400 Bad Request — payload rejected: ${response.body}');
      } else {
        debugPrint('🔴 Unexpected status ${response.statusCode}: ${response.body}');
      }
    } catch (e, stack) {
      debugPrint('🔴 sendPush exception: $e');
      debugPrint('$stack');
    }
  }
}