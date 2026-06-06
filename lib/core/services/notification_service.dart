// lib/core/services/notification_service.dart
//
// UPDATED: sendNotification() now also fires a real push notification via
// OneSignal (through PushService). Every existing caller — BookingService,
// CoachingRequestService, TaskService, QuestionnaireService — automatically
// gets push delivery with zero changes to their code.
//
// In-app (Firestore) notification is always written first.
// Push is attempted second and is non-fatal if it fails.

import 'package:cloud_firestore/cloud_firestore.dart';
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
  // Step 1: Save the notification to Firestore (powers the in-app bell).
  // Step 2: Send a real push via OneSignal (delivers when app is closed).
  //
  // Push is fire-and-forget — a push failure never blocks the primary action
  // (booking, task assignment, etc.) that triggered this call.
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

    // Step 2 — Push notification (OneSignal, non-fatal)
    // Using unawaited fire-and-forget so booking/task flows are not delayed
    _push.sendPush(
      toUid: toUid,
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
    );
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