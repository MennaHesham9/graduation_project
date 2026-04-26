import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coaching_request_model.dart';
import '../../../core/services/notification_service.dart';

class CoachingRequestService {
  final _db = FirebaseFirestore.instance;
  final _notifService = NotificationService();
  // final _fcmService = FcmService(); // 🔒 uncomment when upgrading to Blaze

  // Client sends a coaching request
  Future<void> sendRequest(CoachingRequestModel request) async {
    // 1. Save request doc
    final ref = await _db.collection('coachingRequests').add(request.toMap());

    // 2. Write in-app notification to coach
    await _notifService.sendNotification(
      toUid: request.coachId,
      title: '📩 New Coaching Request',
      body: '${request.clientName} wants to work with you on "${request.primaryGoal}"',
      type: 'coaching_request',
      relatedId: ref.id,
    );

    // 🔒 Push notification — uncomment when upgrading to Blaze
    // await _fcmService.sendPush(
    //   toUid: request.coachId,
    //   title: '📩 New Coaching Request',
    //   body: '${request.clientName} wants to work with you',
    //   data: {'type': 'coaching_request', 'requestId': ref.id},
    // );
  }

  // Stream all pending requests for a coach
  Stream<List<CoachingRequestModel>> streamPendingRequests(String coachId) {
    return _db
        .collection('coachingRequests')
        .where('coachId', isEqualTo: coachId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => CoachingRequestModel.fromMap(d.id, d.data()))
        .toList());
  }

  // Stream accepted clients for a coach
  Stream<List<CoachingRequestModel>> streamAcceptedClients(String coachId) {
    return _db
        .collection('coachingRequests')
        .where('coachId', isEqualTo: coachId)
        .where('status', isEqualTo: 'accepted')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => CoachingRequestModel.fromMap(d.id, d.data()))
        .toList());
  }

  // Coach accepts a request
  Future<void> acceptRequest({
    required String requestId,
    required String clientId,
    required String coachName,
    required String clientName,
  }) async {
    // 1. Update request status
    await _db.collection('coachingRequests').doc(requestId).update({
      'status': 'accepted',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    // 2. In-app notification to client
    await _notifService.sendNotification(
      toUid: clientId,
      title: '🎉 Request Accepted!',
      body: '$coachName has accepted your coaching request.',
      type: 'request_accepted',
      relatedId: requestId,
    );

    // 🔒 Push notification — uncomment when upgrading to Blaze
    // await FcmService().sendPush(
    //   toUid: clientId,
    //   title: '🎉 Request Accepted!',
    //   body: '$coachName has accepted your coaching request.',
    //   data: {'type': 'request_accepted', 'requestId': requestId},
    // );
  }

  // Coach declines a request
  Future<void> declineRequest({
    required String requestId,
    required String clientId,
    required String coachName,
  }) async {
    await _db.collection('coachingRequests').doc(requestId).update({
      'status': 'declined',
      'respondedAt': FieldValue.serverTimestamp(),
    });

    await _notifService.sendNotification(
      toUid: clientId,
      title: '❌ Request Declined',
      body: '$coachName is not available at this time.',
      type: 'request_declined',
      relatedId: requestId,
    );

    // 🔒 Push notification — uncomment when upgrading to Blaze
    // await FcmService().sendPush(
    //   toUid: clientId,
    //   title: 'Request Update',
    //   body: '$coachName is not available at this time.',
    //   data: {'type': 'request_declined', 'requestId': requestId},
    // );
  }

  // Stream the client's own request (for my_coach_sessions_screen)
  Stream<CoachingRequestModel?> streamMyRequest(String clientId) {
    return _db
        .collection('coachingRequests')
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final d = snap.docs.first;
      return CoachingRequestModel.fromMap(d.id, d.data());
    });
  }
}