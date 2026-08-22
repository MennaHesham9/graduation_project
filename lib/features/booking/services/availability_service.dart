// lib/features/booking/services/availability_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/availability_model.dart';
import '../../../core/services/notification_service.dart';

class AvailabilityService {
  final FirebaseFirestore _db;

  AvailabilityService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _avail =>
      _db.collection('coach_availability');

  // ── Fetch / Stream ────────────────────────────────────────────────────────

  Future<AvailabilityModel?> fetchCoachAvailability(String coachId) async {
    final doc = await _avail.doc(coachId).get();
    if (!doc.exists) return null;
    return AvailabilityModel.fromMap(coachId, doc.data()!);
  }

  Stream<AvailabilityModel?> streamCoachAvailability(String coachId) {
    return _avail.doc(coachId).snapshots().map((snap) {
      if (!snap.exists) return null;
      return AvailabilityModel.fromMap(coachId, snap.data()!);
    });
  }

  // ── Save (Coach sets availability) ────────────────────────────────────────

  Future<void> saveAvailability(AvailabilityModel availability) async {
    await _avail.doc(availability.coachId).set(
      availability.toMap(),
      SetOptions(merge: true),
    );
  }

  Future<void> updateWeeklySlots(
      String coachId, Map<String, List<String>> slots) async {
    await _avail.doc(coachId).set(
      {'weeklySlots': slots, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  Future<void> blockDate(String coachId, DateTime date) async {
    final key = _dateKey(date);
    await _avail.doc(coachId).set(
      {
        'blockedDates': FieldValue.arrayUnion([key]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<void> unblockDate(String coachId, DateTime date) async {
    final key = _dateKey(date);
    await _avail.doc(coachId).set(
      {
        'blockedDates': FieldValue.arrayRemove([key]),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ── Compute available slots for a given date ──────────────────────────────

  /// Returns slots (HH:mm) that are available on [date] for [coachId].
  /// Filters out: already-booked slots, blocked dates, notice window, future window.
  // lib/features/booking/services/availability_service.dart

  Future<List<String>> getAvailableSlotsForDate({
    required String coachId,
    required DateTime date,
    required Set<String> alreadyBookedSlots,
    AvailabilityModel? cachedAvail, // Add this optional parameter
  }) async {
    // Use cachedAvail if provided to save network requests
    final avail = cachedAvail ?? await fetchCoachAvailability(coachId);
    if (avail == null) return [];

    // ... rest of the method remains the same
    final now = DateTime.now().toUtc();

    // Check constraints
    if (avail.isDateBlocked(date)) return [];
    if (date.isAfter(now.add(Duration(days: avail.maxBookingWindowDays)))) return [];

    final rawSlots = avail.slotsForDate(date);
    final result = <String>[];

    for (final timeStr in rawSlots) {
      if (alreadyBookedSlots.contains(timeStr)) continue;

      // Parse slot as UTC DateTime for that date
      final parts = timeStr.split(':');
      final slotUtc = DateTime.utc(
        date.year, date.month, date.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );

      // Minimum notice check
      if (slotUtc.difference(now).inHours < avail.minBookingNoticeHours) continue;

      result.add(timeStr);
    }

    return result;
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}