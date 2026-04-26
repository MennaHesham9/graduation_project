import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final _db = FirebaseFirestore.instance;

  // Path: notifications/{uid}/items/{notifId}
  CollectionReference _col(String uid) =>
      _db.collection('notifications').doc(uid).collection('items');

  // Stream all notifications for a user, newest first
  Stream<List<NotificationModel>> streamNotifications(String uid) {
    return _col(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => NotificationModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList());
  }

  // Write a notification to a user's collection
  Future<void> sendNotification({
    required String toUid,
    required String title,
    required String body,
    required String type,
    String? relatedId,
  }) async {
    await _col(toUid).add(NotificationModel(
      id: '',
      title: title,
      body: body,
      type: type,
      relatedId: relatedId,
      isRead: false,
      createdAt: DateTime.now(),
    ).toMap());
  }

  // Mark a single notification as read
  Future<void> markAsRead(String uid, String notifId) async {
    await _col(uid).doc(notifId).update({'isRead': true});
  }

  // Mark all as read
  Future<void> markAllAsRead(String uid) async {
    final batch = _db.batch();
    final snap = await _col(uid).where('isRead', isEqualTo: false).get();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // Unread count stream (for badge)
  Stream<int> streamUnreadCount(String uid) {
    return _col(uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}