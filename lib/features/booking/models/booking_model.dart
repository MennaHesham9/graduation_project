// lib/features/booking/models/booking_model.dart
//
// FIX: Removed syntax error — `required ,` on line 138 (stray comma after
//      `required` keyword that caused a parse error). Replaced with just the
//      correct named parameter `required this.clientAllowsAnalysis`.
//
// Added `clientAllowsAnalysis` field so the coach-side VideoSessionScreen can
// receive the *client's* privacy flag from the booking document instead of
// incorrectly reading the coach's own UserModel.
//
// When a booking is created (booking_service.dart), write this field from
// the client's UserModel.allowSessionAnalysis at that point in time.
// It defaults to false so existing bookings are safe.

import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus {
  pendingPayment,
  confirmed,
  completed,
  cancelled,
  rescheduled,
  missed,
}

enum SessionType { audio, video }

enum PlanType { single, package }

class RescheduleEntry {
  final DateTime fromUtc;
  final DateTime toUtc;
  final String requestedBy; // "client" | "coach"
  final String reason;
  final DateTime changedAt;

  const RescheduleEntry({
    required this.fromUtc,
    required this.toUtc,
    required this.requestedBy,
    required this.reason,
    required this.changedAt,
  });

  factory RescheduleEntry.fromMap(Map<String, dynamic> m) => RescheduleEntry(
    fromUtc: (m['fromUtc'] as Timestamp).toDate(),
    toUtc: (m['toUtc'] as Timestamp).toDate(),
    requestedBy: m['requestedBy'] as String,
    reason: m['reason'] as String? ?? '',
    changedAt: (m['changedAt'] as Timestamp).toDate(),
  );

  Map<String, dynamic> toMap() => {
    'fromUtc': Timestamp.fromDate(fromUtc),
    'toUtc': Timestamp.fromDate(toUtc),
    'requestedBy': requestedBy,
    'reason': reason,
    'changedAt': Timestamp.fromDate(changedAt),
  };
}

class BookingModel {
  final String id;

  // Identity
  final String clientId;
  final String clientName;
  final String coachId;
  final String coachName;

  // Booking details
  final SessionType type;
  final PlanType planType;
  final String? packageId;
  final int? packageSize;
  final int? sessionIndexInPackage;

  // Timing
  final DateTime scheduledAtUtc;
  final int durationMinutes;
  final String timezone;

  // Status
  final SessionStatus status;

  // Payment
  final double price;
  final String currency;
  final String? paymentRef;

  // Rescheduling
  final int rescheduleCount;
  final List<RescheduleEntry> rescheduleHistory;
  final bool rescheduleRequestPending;
  final List<DateTime> coachProposedSlots;

  // Cancellation
  final String? cancelledBy;
  final String? cancellationReason;
  final DateTime? cancelledAt;
  final String? refundStatus;

  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;

  // Client's emotion-analysis consent — snapshotted from
  // UserModel.allowSessionAnalysis when the booking is created.
  // Defaults to false so existing documents without this field are safe.
  final bool clientAllowsAnalysis;

  const BookingModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.coachId,
    required this.coachName,
    required this.type,
    required this.planType,
    this.packageId,
    this.packageSize,
    this.sessionIndexInPackage,
    required this.scheduledAtUtc,
    required this.durationMinutes,
    required this.timezone,
    required this.status,
    required this.price,
    required this.currency,
    this.paymentRef,
    this.rescheduleCount = 0,
    this.rescheduleHistory = const [],
    this.rescheduleRequestPending = false,
    this.coachProposedSlots = const [],
    this.cancelledBy,
    this.cancellationReason,
    this.cancelledAt,
    this.refundStatus,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.clientAllowsAnalysis = false, // FIX: removed stray `required ,`
  });

  // ── Computed helpers ──────────────────────────────────────────────────────

  bool get isUpcoming =>
      status == SessionStatus.confirmed &&
          scheduledAtUtc.isAfter(DateTime.now().toUtc());

  bool get canReschedule =>
      rescheduleCount < 2 &&
          scheduledAtUtc.difference(DateTime.now().toUtc()).inHours >= 6;

  bool get canCancel =>
      scheduledAtUtc.difference(DateTime.now().toUtc()).inHours >= 12;

  bool get isActive =>
      status == SessionStatus.confirmed || status == SessionStatus.rescheduled;

  bool get isJoinable {
    final now = DateTime.now().toUtc();
    final startWindow = scheduledAtUtc.subtract(const Duration(minutes: 5));
    final endWindow = scheduledAtUtc.add(Duration(minutes: durationMinutes));
    return now.isAfter(startWindow) &&
        now.isBefore(endWindow) &&
        (status == SessionStatus.confirmed ||
            status == SessionStatus.rescheduled);
  }

  // ── Firestore ↔ Model ─────────────────────────────────────────────────────

  factory BookingModel.fromMap(String id, Map<String, dynamic> m) {
    return BookingModel(
      id: id,
      clientId: m['clientId'] as String,
      clientName: m['clientName'] as String? ?? '',
      coachId: m['coachId'] as String,
      coachName: m['coachName'] as String? ?? '',
      type: m['type'] == 'video' ? SessionType.video : SessionType.audio,
      planType:
      m['planType'] == 'package' ? PlanType.package : PlanType.single,
      packageId: m['packageId'] as String?,
      packageSize: m['packageSize'] as int?,
      sessionIndexInPackage: m['sessionIndexInPackage'] as int?,
      scheduledAtUtc: (m['scheduledAtUtc'] as Timestamp).toDate(),
      durationMinutes: m['durationMinutes'] as int? ?? 60,
      timezone: m['timezone'] as String? ?? 'UTC',
      status: _statusFromString(m['status'] as String? ?? 'pending_payment'),
      price: (m['price'] as num).toDouble(),
      currency: m['currency'] as String? ?? 'USD',
      paymentRef: m['paymentRef'] as String?,
      rescheduleCount: m['rescheduleCount'] as int? ?? 0,
      rescheduleHistory: (m['rescheduleHistory'] as List? ?? [])
          .map((e) => RescheduleEntry.fromMap(e as Map<String, dynamic>))
          .toList(),
      rescheduleRequestPending:
      m['rescheduleRequestPending'] as bool? ?? false,
      coachProposedSlots: (m['coachProposedSlots'] as List? ?? [])
          .map((e) => (e as Timestamp).toDate())
          .toList(),
      cancelledBy: m['cancelledBy'] as String?,
      cancellationReason: m['cancellationReason'] as String?,
      cancelledAt: m['cancelledAt'] != null
          ? (m['cancelledAt'] as Timestamp).toDate()
          : null,
      refundStatus: m['refundStatus'] as String?,
      createdAt: (m['createdAt'] as Timestamp).toDate(),
      updatedAt: (m['updatedAt'] as Timestamp).toDate(),
      notes: m['notes'] as String?,
      // Read the client's consent flag; default false for old docs.
      clientAllowsAnalysis: m['clientAllowsAnalysis'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'clientId': clientId,
    'clientName': clientName,
    'coachId': coachId,
    'coachName': coachName,
    'type': type == SessionType.video ? 'video' : 'audio',
    'planType': planType == PlanType.package ? 'package' : 'single',
    if (packageId != null) 'packageId': packageId,
    if (packageSize != null) 'packageSize': packageSize,
    if (sessionIndexInPackage != null)
      'sessionIndexInPackage': sessionIndexInPackage,
    'scheduledAtUtc': Timestamp.fromDate(scheduledAtUtc),
    'durationMinutes': durationMinutes,
    'timezone': timezone,
    'status': _statusToString(status),
    'price': price,
    'currency': currency,
    if (paymentRef != null) 'paymentRef': paymentRef,
    'rescheduleCount': rescheduleCount,
    'rescheduleHistory': rescheduleHistory.map((e) => e.toMap()).toList(),
    'rescheduleRequestPending': rescheduleRequestPending,
    'coachProposedSlots':
    coachProposedSlots.map((d) => Timestamp.fromDate(d)).toList(),
    if (cancelledBy != null) 'cancelledBy': cancelledBy,
    if (cancellationReason != null)
      'cancellationReason': cancellationReason,
    if (cancelledAt != null)
      'cancelledAt': Timestamp.fromDate(cancelledAt!),
    if (refundStatus != null) 'refundStatus': refundStatus,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    if (notes != null) 'notes': notes,
    // Always write this field so it's queryable.
    'clientAllowsAnalysis': clientAllowsAnalysis,
  };

  static SessionStatus _statusFromString(String s) => switch (s) {
    'confirmed' => SessionStatus.confirmed,
    'completed' => SessionStatus.completed,
    'cancelled' => SessionStatus.cancelled,
    'rescheduled' => SessionStatus.rescheduled,
    'missed' => SessionStatus.missed,
    _ => SessionStatus.pendingPayment,
  };

  static String _statusToString(SessionStatus s) => switch (s) {
    SessionStatus.confirmed => 'confirmed',
    SessionStatus.completed => 'completed',
    SessionStatus.cancelled => 'cancelled',
    SessionStatus.rescheduled => 'rescheduled',
    SessionStatus.missed => 'missed',
    SessionStatus.pendingPayment => 'pending_payment',
  };
}
