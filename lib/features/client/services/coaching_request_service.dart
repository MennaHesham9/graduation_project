// lib/features/client/services/coaching_request_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coaching_request_model.dart';
import '../../../core/services/notification_service.dart';

class CoachingRequestService {
  final _db = FirebaseFirestore.instance;
  final _notifService = NotificationService();

  // ── Send Request ──────────────────────────────────────────────────────────
  //
  // Enforces the single-request-per-coach rule before writing.
  // Requires a composite Firestore index on (clientId, coachId, status).
  // Firestore will print a console link to create it on first run.
  Future<void> sendRequest(CoachingRequestModel request) async {
    // 1. Single-request enforcement
    final existing = await _db
        .collection('coachingRequests')
        .where('clientId', isEqualTo: request.clientId)
        .where('coachId', isEqualTo: request.coachId)
        .where('status', whereIn: ['pending', 'accepted'])
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception(
        'You already have an active or pending request with this coach.',
      );
    }

    // 2. Save request document
    // ✅ coachName must be included in request.toMap() so the banner
    //    can display it without an extra Firestore read.
    final ref = await _db
        .collection('coachingRequests')
        .add(request.toMap());

    // 3. In-app notification to coach
    await _notifService.sendNotification(
      toUid: request.coachId,
      title: '📩 New Coaching Request',
      body:
      '${request.clientName} wants to work with you on '
          '"${request.primaryGoal}"',
      type: 'coaching_request',
      relatedId: ref.id,
    );
  }

  // ── Cancel Request (client) ───────────────────────────────────────────────
  //
  // Hard-deletes the request document.
  // Only expose this in client UI — never in coach UI.
  Future<void> cancelRequest(String requestId) async {
    await _db.collection('coachingRequests').doc(requestId).delete();
  }

  // ── Accept Request (coach) ────────────────────────────────────────────────
  //
  // Uses a single Firestore Transaction to atomically:
  //   1. Update the request status to "accepted".
  //   2. Add coachId to the client's myCoaches array.
  //   3. Add clientId to the coach's myClients array.
  //
  // If any write fails the entire transaction rolls back.
  Future<void> acceptRequest({
    required String requestId,
    required String clientId,
    required String coachId,
    required String coachName,
    required String clientName,
  }) async {
    final requestRef = _db.collection('coachingRequests').doc(requestId);
    final clientRef  = _db.collection('users').doc(clientId);
    final coachRef   = _db.collection('users').doc(coachId);

    await _db.runTransaction((txn) async {
      txn.update(requestRef, {
        'status': 'accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // arrayUnion is idempotent — safe to call multiple times
      txn.update(clientRef, {
        'myCoaches': FieldValue.arrayUnion([coachId]),
      });

      txn.update(coachRef, {
        'myClients': FieldValue.arrayUnion([clientId]),
      });
    });

    // In-app notification to client (outside transaction — non-critical)
    await _notifService.sendNotification(
      toUid: clientId,
      title: '🎉 Request Accepted!',
      body: '$coachName has accepted your coaching request.',
      type: 'request_accepted',
      relatedId: requestId,
    );
  }

  // ── Decline Request (coach) ───────────────────────────────────────────────
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
  }

  // ── Stream pending requests for a coach ───────────────────────────────────
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

  // ── Stream accepted clients for a coach ───────────────────────────────────
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

  // ── Stream a client's latest overall request ──────────────────────────────
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

  // ── Stream highest-priority active request across ALL coaches ─────────────
  //
  // Used by ExploreCoachesScreen to show the pending/accepted/declined banner.
  // Priority: pending > accepted > declined (most actionable first).
  //
  // ✅ Collection name fixed to 'coachingRequests' (matches every other method)
  // ✅ Uses fromMap(id, data) (matches your CoachingRequestModel factory)
  // Requires a composite Firestore index on (clientId ASC, status ASC).
  // Firestore will print a console link to create it on first run.
  Stream<CoachingRequestModel?> streamAnyActiveRequest(String clientId) {
    return _db
        .collection('coachingRequests')           // ✅ fixed — was 'coaching_requests'
        .where('clientId', isEqualTo: clientId)
        .where('status', whereIn: ['pending', 'accepted', 'declined'])
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;

      const priority = {'pending': 0, 'accepted': 1, 'declined': 2};
      final sorted = snap.docs.toList()
        ..sort((a, b) {
          final pa = priority[a['status'] as String] ?? 9;
          final pb = priority[b['status'] as String] ?? 9;
          return pa.compareTo(pb);
        });

      final top = sorted.first;
      return CoachingRequestModel.fromMap(   // ✅ fixed — was fromFirestore()
        top.id,
        top.data(),
      );
    });
  }

  // ── Stream a client's request to ONE specific coach ───────────────────────
  //
  // Used by CoachProfileClientSide to show the Pending / Accepted card.
  // Requires a composite Firestore index on (clientId ASC, coachId ASC).
  // Priority: pending > accepted > declined (most actionable first).
  Stream<CoachingRequestModel?> streamRequestToCoach({
    required String clientId,
    required String coachId,
  }) {
    return _db
        .collection('coachingRequests')
        .where('clientId', isEqualTo: clientId)
        .where('coachId', isEqualTo: coachId)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;

      final docs = snap.docs
          .map((d) => CoachingRequestModel.fromMap(d.id, d.data()))
          .toList();

      // Return the most actionable status
      final pending = docs.where((d) => d.status == 'pending').toList();
      if (pending.isNotEmpty) return pending.first;

      final accepted = docs.where((d) => d.status == 'accepted').toList();
      if (accepted.isNotEmpty) return accepted.first;

      return docs.first; // declined or unknown
    });
  }
}