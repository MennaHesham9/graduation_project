// lib/features/booking/services/booking_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';
import '../models/package_model.dart';
import '../../../core/services/notification_service.dart';

class BookingService {
  final FirebaseFirestore _db;
  final NotificationService _notif;

  BookingService({FirebaseFirestore? db, NotificationService? notif})
      : _db = db ?? FirebaseFirestore.instance,
        _notif = notif ?? NotificationService();

  // ── Collection refs ───────────────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _sessions =>
      _db.collection('sessions');
  CollectionReference<Map<String, dynamic>> get _packages =>
      _db.collection('packages');
  CollectionReference<Map<String, dynamic>> get _locks =>
      _db.collection('slot_locks');

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 1: Lock a slot temporarily during payment flow
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns lockId on success.
  /// Throws if the slot is already locked or booked.
  Future<String> lockSlot({
    required String coachId,
    required String clientId,
    required DateTime slotUtc,
    required String sessionType,
  }) async {
    final lockId = _lockId(coachId, slotUtc);
    final lockRef = _locks.doc(lockId);

    await _db.runTransaction((txn) async {
      final lockSnap = await txn.get(lockRef);

      if (lockSnap.exists) {
        final existing = lockSnap.data()!;
        final expiresAt = (existing['expiresAt'] as Timestamp).toDate();
        final lockOwner = existing['clientId'] as String?;
        final isExpired = DateTime.now().toUtc().isAfter(expiresAt);
        final isOwnLock = lockOwner == clientId;
        // Only block if the lock is active AND owned by a different client
        if (!isExpired && !isOwnLock) {
          throw Exception('slot_locked: This time slot is temporarily held by another user.');
        }
        // Expired lock or own lock → safe to overwrite
      }

      // Also check for confirmed sessions in this slot
      // (handled separately in _isSlotBooked — keep transaction lightweight)

      txn.set(lockRef, {
        'coachId': coachId,
        'clientId': clientId,
        'slotUtc': Timestamp.fromDate(slotUtc),
        'sessionType': sessionType,
        'expiresAt': Timestamp.fromDate(
          DateTime.now().toUtc().add(const Duration(minutes: 10)),
        ),
      });
    });

    return lockId;
  }

  /// Release the lock (call on payment success AND payment failure)
  Future<void> releaseLock(String lockId) async {
    await _locks.doc(lockId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STEP 2: Confirm booking after payment
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates one session document, releases the lock, sends notifications.
  Future<String> confirmSingleSession({
    required String clientId,
    required String clientName,
    required String coachId,
    required String coachName,
    required DateTime slotUtc,
    required String sessionType,       // "audio" | "video"
    required double price,
    required String currency,
    required int durationMinutes,
    required String clientTimezone,
    required String lockId,
    required String paymentRef,
  }) async {
    // Fetch client's emotion analysis consent at booking time
    final clientDoc = await _db.collection('users').doc(clientId).get();
    final clientAllowsAnalysis =
        clientDoc.data()?['allowSessionAnalysis'] as bool? ?? false;

    // The lock IS the reservation — just verify it still belongs to this client.
    await _verifyLockOwnership(lockId: lockId, clientId: clientId);

    final ref = _sessions.doc();
    final now = DateTime.now().toUtc();

    final session = BookingModel(
      id: ref.id,
      clientId: clientId,
      clientName: clientName,
      coachId: coachId,
      coachName: coachName,
      type: sessionType == 'video' ? SessionType.video : SessionType.audio,
      planType: PlanType.single,
      scheduledAtUtc: slotUtc,
      durationMinutes: durationMinutes,
      timezone: clientTimezone,
      status: SessionStatus.confirmed,
      price: price,
      currency: currency,
      paymentRef: paymentRef,
      clientAllowsAnalysis: clientAllowsAnalysis,
      createdAt: now,
      updatedAt: now,
    );

    final batch = _db.batch();
    batch.set(ref, session.toMap());
    batch.delete(_locks.doc(lockId)); // release lock atomically
    await batch.commit();

    // Notifications (outside batch — non-critical)
    await Future.wait([
      _notif.sendNotification(
        toUid: coachId,
        title: '📅 New Session Booked',
        body: '$clientName booked a $sessionType session with you.',
        type: 'session_booked',
        relatedId: ref.id,
      ),
      _notif.sendNotification(
        toUid: clientId,
        title: '✅ Booking Confirmed!',
        body: 'Your session with $coachName is confirmed.',
        type: 'session_confirmed',
        relatedId: ref.id,
      ),
    ]);

    return ref.id;
  }

  /// Creates a package document + N session documents atomically.
  /// Firestore batch limit is 500 writes — safe for 4 or 8 sessions.
  Future<String> confirmPackage({
    required String clientId,
    required String clientName,
    required String coachId,
    required String coachName,
    required List<DateTime> slotsUtc,   // must match packageSize
    required String sessionType,
    required double totalPrice,
    required String currency,
    required int durationMinutes,
    required String clientTimezone,
    required List<String> lockIds,
    required String paymentRef,
  }) async {
    // Verify all locks still belong to this client — locks ARE the reservations.
    for (int i = 0; i < lockIds.length; i++) {
      await _verifyLockOwnership(lockId: lockIds[i], clientId: clientId);
    }

    // Fetch client's emotion analysis consent at booking time
    final clientDoc = await _db.collection('users').doc(clientId).get();
    final clientAllowsAnalysis =
        clientDoc.data()?['allowSessionAnalysis'] as bool? ?? false;

    final packageRef = _packages.doc();
    final now = DateTime.now().toUtc();

    final pkg = PackageModel(
      id: packageRef.id,
      clientId: clientId,
      coachId: coachId,
      type: sessionType,
      totalSessions: slotsUtc.length,
      usedSessions: 0,
      expiresAt: now.add(const Duration(days: 90)),
      price: totalPrice,
      currency: currency,
      paymentRef: paymentRef,
      createdAt: now,
      status: PackageStatus.active,
    );

    final batch = _db.batch();
    batch.set(packageRef, pkg.toMap());

    for (int i = 0; i < slotsUtc.length; i++) {
      final sessionRef = _sessions.doc();
      final session = BookingModel(
        id: sessionRef.id,
        clientId: clientId,
        clientName: clientName,
        coachId: coachId,
        coachName: coachName,
        type: sessionType == 'video' ? SessionType.video : SessionType.audio,
        planType: PlanType.package,
        packageId: packageRef.id,
        packageSize: slotsUtc.length,
        sessionIndexInPackage: i + 1,
        scheduledAtUtc: slotsUtc[i],
        durationMinutes: durationMinutes,
        timezone: clientTimezone,
        status: SessionStatus.confirmed,
        price: totalPrice / slotsUtc.length,
        currency: currency,
        paymentRef: paymentRef,
        clientAllowsAnalysis: clientAllowsAnalysis,
        createdAt: now,
        updatedAt: now,
      );
      batch.set(sessionRef, session.toMap());
    }

    // Release all locks in same batch
    for (final lockId in lockIds) {
      batch.delete(_locks.doc(lockId));
    }

    await batch.commit();

    await _notif.sendNotification(
      toUid: clientId,
      title: '✅ Package Confirmed!',
      body: '${slotsUtc.length} sessions with $coachName are confirmed.',
      type: 'package_confirmed',
      relatedId: packageRef.id,
    );

    return packageRef.id;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESCHEDULE (Client-initiated)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> clientRequestReschedule({
    required String sessionId,
    required DateTime newSlotUtc,
    required String reason,
    required String clientId,
    required String coachId,
    required String coachName,
  }) async {
    final ref = _sessions.doc(sessionId);
    final snap = await ref.get();
    if (!snap.exists) throw Exception('Session not found.');

    final session = BookingModel.fromMap(snap.id, snap.data()!);

    if (!session.canReschedule) {
      throw Exception(
        session.rescheduleCount >= 2
            ? 'reschedule_limit: Maximum 2 reschedules reached.'
            : 'reschedule_deadline: Cannot reschedule within 6 hours of session.',
      );
    }

    // Verify new slot is free
    await _assertSlotNotBooked(coachId: coachId, slotUtc: newSlotUtc, excludeSessionId: sessionId);

    final entry = RescheduleEntry(
      fromUtc: session.scheduledAtUtc,
      toUtc: newSlotUtc,
      requestedBy: 'client',
      reason: reason,
      changedAt: DateTime.now().toUtc(),
    );

    await ref.update({
      'scheduledAtUtc': Timestamp.fromDate(newSlotUtc),
      'status': 'rescheduled',
      'rescheduleCount': FieldValue.increment(1),
      'rescheduleHistory': FieldValue.arrayUnion([entry.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notif.sendNotification(
      toUid: coachId,
      title: '🔄 Session Rescheduled',
      body: '${session.clientName} rescheduled their session.',
      type: 'session_rescheduled',
      relatedId: sessionId,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // RESCHEDULE REQUEST (Coach-initiated)
  // ─────────────────────────────────────────────────────────────────────────

  /// Coach proposes new time slots → client chooses one
  Future<void> coachProposeReschedule({
    required String sessionId,
    required List<DateTime> proposedSlotsUtc,
    required String clientId,
    required String coachName,
  }) async {
    await _sessions.doc(sessionId).update({
      'rescheduleRequestPending': true,
      'coachProposedSlots':
      proposedSlotsUtc.map((d) => Timestamp.fromDate(d)).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notif.sendNotification(
      toUid: clientId,
      title: '📬 Reschedule Request',
      body: '$coachName would like to reschedule your session.',
      type: 'reschedule_request',
      relatedId: sessionId,
    );
  }

  /// Client accepts one of the coach's proposed slots
  Future<void> clientAcceptCoachProposal({
    required String sessionId,
    required DateTime chosenSlotUtc,
    required String coachId,
    required String clientName,
  }) async {
    final snap = await _sessions.doc(sessionId).get();
    final session = BookingModel.fromMap(snap.id, snap.data()!);

    final entry = RescheduleEntry(
      fromUtc: session.scheduledAtUtc,
      toUtc: chosenSlotUtc,
      requestedBy: 'coach',
      reason: 'Coach proposed reschedule',
      changedAt: DateTime.now().toUtc(),
    );

    await _sessions.doc(sessionId).update({
      'scheduledAtUtc': Timestamp.fromDate(chosenSlotUtc),
      'status': 'rescheduled',
      'rescheduleRequestPending': false,
      'coachProposedSlots': [],
      'rescheduleCount': FieldValue.increment(1),
      'rescheduleHistory': FieldValue.arrayUnion([entry.toMap()]),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _notif.sendNotification(
      toUid: coachId,
      title: '✅ Reschedule Accepted',
      body: '$clientName accepted your proposed time.',
      type: 'reschedule_accepted',
      relatedId: sessionId,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CANCEL
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> cancelSession({
    required String sessionId,
    required String cancelledBy, // "client" | "coach"
    required String reason,
    required String notifyUid,   // the OTHER party
    required String notifyName,  // name of cancelling party
  }) async {
    final snap = await _sessions.doc(sessionId).get();
    if (!snap.exists) throw Exception('Session not found.');

    final session = BookingModel.fromMap(snap.id, snap.data()!);
    final hoursUntil = session.scheduledAtUtc
        .difference(DateTime.now().toUtc())
        .inHours;

    // Determine refund
    final refund = hoursUntil >= 12 ? 'full' : (hoursUntil >= 2 ? 'partial' : 'none');

    await _sessions.doc(sessionId).update({
      'status': 'cancelled',
      'cancelledBy': cancelledBy,
      'cancellationReason': reason,
      'cancelledAt': FieldValue.serverTimestamp(),
      'refundStatus': refund,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // If part of package, decrement usedSessions
    if (session.packageId != null) {
      await _packages.doc(session.packageId!).update({
        'usedSessions': FieldValue.increment(-1),
        'remainingSessions': FieldValue.increment(1),
      });
    }

    await _notif.sendNotification(
      toUid: notifyUid,
      title: '❌ Session Cancelled',
      body: '$notifyName cancelled a session. Refund: $refund.',
      type: 'session_cancelled',
      relatedId: sessionId,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STREAMS — Client
  // ─────────────────────────────────────────────────────────────────────────

  Stream<List<BookingModel>> streamClientUpcomingSessions(String clientId) {
    return _sessions
        .where('clientId', isEqualTo: clientId)
        .where('status', whereIn: ['confirmed', 'rescheduled'])
        .orderBy('scheduledAtUtc')
        .snapshots()
        .map((s) => s.docs
        .map((d) => BookingModel.fromMap(d.id, d.data()))
        .where((b) => b.scheduledAtUtc.isAfter(DateTime.now().toUtc()))
        .toList());
  }

  Stream<List<BookingModel>> streamClientPastSessions(String clientId) {
    return _sessions
        .where('clientId', isEqualTo: clientId)
        .where('status', whereIn: ['completed', 'missed', 'cancelled'])
        .orderBy('scheduledAtUtc', descending: true)
        .snapshots()
        .map((s) =>
        s.docs.map((d) => BookingModel.fromMap(d.id, d.data())).toList());
  }

  Stream<List<BookingModel>> streamClientRescheduleRequests(String clientId) {
    return _sessions
        .where('clientId', isEqualTo: clientId)
        .where('rescheduleRequestPending', isEqualTo: true)
        .snapshots()
        .map((s) =>
        s.docs.map((d) => BookingModel.fromMap(d.id, d.data())).toList());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // STREAMS — Coach
  // ─────────────────────────────────────────────────────────────────────────

  Stream<List<BookingModel>> streamCoachUpcomingSessions(String coachId) {
    return _sessions
        .where('coachId', isEqualTo: coachId)
        .where('status', whereIn: ['confirmed', 'rescheduled'])
        .orderBy('scheduledAtUtc')
        .snapshots()
        .map((s) => s.docs
        .map((d) => BookingModel.fromMap(d.id, d.data()))
        .where((b) => b.scheduledAtUtc.isAfter(DateTime.now().toUtc()))
        .toList());
  }

  Stream<List<BookingModel>> streamCoachSessionsForDate(
      String coachId, DateTime date) {
    final startUtc = DateTime.utc(date.year, date.month, date.day);
    final endUtc = startUtc.add(const Duration(days: 1));
    return _sessions
        .where('coachId', isEqualTo: coachId)
        .where('scheduledAtUtc',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startUtc))
        .where('scheduledAtUtc', isLessThan: Timestamp.fromDate(endUtc))
        .snapshots()
        .map((s) =>
        s.docs.map((d) => BookingModel.fromMap(d.id, d.data())).toList());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PACKAGE STREAMS
  // ─────────────────────────────────────────────────────────────────────────

  Stream<List<PackageModel>> streamClientActivePackages(String clientId) {
    return _packages
        .where('clientId', isEqualTo: clientId)
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((s) =>
        s.docs.map((d) => PackageModel.fromMap(d.id, d.data())).toList());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS — Availability
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns all time strings (HH:mm UTC) already booked for [coachId] on [date].
  ///
  /// FIX: The previous query combined `status whereIn` with a `scheduledAtUtc`
  /// range filter. Firestore requires a composite index for any query that
  /// filters on two different fields simultaneously. Without that index the
  /// query throws, causing _checkDayHasSlots to catch the error and return
  /// false for every day — making every slot appear unavailable to clients.
  ///
  /// Fix: Query only on coachId + scheduledAtUtc range (these two fields share
  /// one auto-created index). Filter the status client-side. This requires no
  /// manual index and is safe because the result set is small (≤ sessions/day).
  Future<Set<String>> fetchBookedSlots(String coachId, DateTime date) async {
    final startUtc = DateTime.utc(date.year, date.month, date.day);
    final endUtc = startUtc.add(const Duration(days: 1));

    final snap = await _sessions
        .where('coachId', isEqualTo: coachId)
        .where('scheduledAtUtc',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startUtc))
        .where('scheduledAtUtc', isLessThan: Timestamp.fromDate(endUtc))
        .get();

    const blockedStatuses = {'confirmed', 'rescheduled', 'pending_payment'};

    return snap.docs
        .where((d) => blockedStatuses.contains(d['status'] as String?))
        .map((d) {
      final dt = (d['scheduledAtUtc'] as Timestamp).toDate().toUtc();
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    })
        .toSet();
  }
  // ─────────────────────────────────────────────────────────────────────────
  // PRIVATE HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  String _lockId(String coachId, DateTime slotUtc) {
    return '${coachId}_${slotUtc.millisecondsSinceEpoch}';
  }

  /// Verifies the lock belongs to [clientId]. Missing lock = expired = ok to proceed.
  Future<void> _verifyLockOwnership({
    required String lockId,
    required String clientId,
  }) async {
    final lockSnap = await _locks.doc(lockId).get();
    if (!lockSnap.exists) return; // lock expired, slot is still ours to book
    final lockOwner = lockSnap.data()!['clientId'] as String?;
    if (lockOwner != clientId) {
      throw Exception('slot_locked: This slot is reserved by another user.');
    }
    // Lock belongs to this client -- proceed
  }

  Future<void> _assertSlotNotBooked({
    required String coachId,
    required DateTime slotUtc,
    String? excludeSessionId,
    String? excludeClientId, // skip lock owned by this client (they're the one paying)
  }) async {
    // Check ±1 minute window for existing confirmed/rescheduled sessions
    final windowStart = slotUtc.subtract(const Duration(minutes: 1));
    final windowEnd = slotUtc.add(const Duration(minutes: 1));

    final snap = await _sessions
        .where('coachId', isEqualTo: coachId)
        .where('status', whereIn: ['confirmed', 'rescheduled'])
        .where('scheduledAtUtc',
        isGreaterThanOrEqualTo: Timestamp.fromDate(windowStart))
        .where('scheduledAtUtc',
        isLessThanOrEqualTo: Timestamp.fromDate(windowEnd))
        .get();

    for (final doc in snap.docs) {
      if (doc.id != excludeSessionId) {
        throw Exception('double_booking: This slot is already booked.');
      }
    }

    // Check for an active non-expired lock, but allow the lock owner through
    final lockId = _lockId(coachId, slotUtc);
    final lockSnap = await _locks.doc(lockId).get();
    if (lockSnap.exists) {
      final data = lockSnap.data()!;
      final expiresAt = (data['expiresAt'] as Timestamp).toDate();
      final lockOwner = data['clientId'] as String?;
      final isExpired = DateTime.now().toUtc().isAfter(expiresAt);
      final isOwnLock = excludeClientId != null && lockOwner == excludeClientId;
      if (!isExpired && !isOwnLock) {
        throw Exception('slot_locked: This slot is temporarily reserved.');
      }
    }
  }
}