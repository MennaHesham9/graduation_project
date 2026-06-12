// lib/core/services/notification_service.dart
//
// FIXES APPLIED:
//
// 1. SILENT PUSH FAILURES — The unawaited _push.sendPush() call had no error
//    handler, so any exception (network error, bad response, etc.) was
//    completely swallowed with no log output whatsoever. Added .catchError()
//    so failures are always visible in debug output without blocking callers.
//
// Everything else is identical to the original.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'push_service.dart';

class NotificationService {
  final _db = FirebaseFirestore.instance;
  final _push = PushService();

  // Path: notifications/{uid}/items/{notifId}
  CollectionReference _col(String uid) =>
      _db.collection('notifications').doc(uid).collection('items');

  // ── Stream all notifications for a user, newest first ────────────────────
  Stream<List<NotificationModel>> streamNotifications(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) =>
        NotificationModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList());
  }

  // ── Write an in-app notification AND fire a push ──────────────────────────
  //
  // Step 1: Save to Firestore (powers the in-app bell). Always awaited.
  // Step 2: Send push via OneSignal. Fire-and-forget so it never delays the
  //         booking/task action that triggered this call, but errors are now
  //         caught and logged so they're visible during debugging.
  Future<void> sendNotification({
    required String toUid,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    // Step 1 — In-app notification (Firestore)
    await _col(toUid).add(NotificationModel(
      id: '',
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      isRead: false,
      createdAt: DateTime.now(),
    ).toMap());

    // Step 2 — Push notification (OneSignal, non-fatal fire-and-forget)
    // FIX: Added .catchError so failures are logged instead of silently dropped.
    _push
        .sendPush(
      toUid: toUid,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
    )
        .catchError((Object e) {
      debugPrint('⚠️ Push notification failed for uid=$toUid: $e');
    });
  }

  // ── Mark a single notification as read ───────────────────────────────────
  Future<void> markAsRead(String uid, String notifId) async {
    await _col(uid).doc(notifId).update({'isRead': true});
  }

  // ── Mark all as read ──────────────────────────────────────────────────────
  Future<void> markAllAsRead(String uid) async {
    final batch = _db.batch();
    final snap = await _col(uid).where('isRead', isEqualTo: false).get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ── Unread count stream (for badge on bell icon) ──────────────────────────
  Stream<int> streamUnreadCount(String uid) {
    return _col(uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}