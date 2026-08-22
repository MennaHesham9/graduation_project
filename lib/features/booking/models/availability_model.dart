// lib/features/booking/models/availability_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityModel {
  final String coachId;
  final Map<String, List<String>> weeklySlots; // "monday" → ["09:00","10:00"]
  final List<String> blockedDates;             // ISO date strings "yyyy-MM-dd"
  final int minBookingNoticeHours;
  final int maxBookingWindowDays;
  final int maxSessionsPerDay;
  final DateTime updatedAt;

  const AvailabilityModel({
    required this.coachId,
    required this.weeklySlots,
    this.blockedDates = const [],
    this.minBookingNoticeHours = 2,
    this.maxBookingWindowDays = 30,
    this.maxSessionsPerDay = 4,
    required this.updatedAt,
  });

  static const List<String> weekdays = [
    'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
  ];

  List<String> slotsForDate(DateTime date) {
    final dayName = weekdays[date.weekday - 1];
    return weeklySlots[dayName] ?? [];
  }

  bool isDateBlocked(DateTime date) {
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return blockedDates.contains(key);
  }

  factory AvailabilityModel.fromMap(String coachId, Map<String, dynamic> m) {
    final raw = m['weeklySlots'] as Map<String, dynamic>? ?? {};
    final slots = raw.map(
          (k, v) => MapEntry(k, List<String>.from(v as List)),
    );
    return AvailabilityModel(
      coachId: coachId,
      weeklySlots: slots,
      blockedDates: List<String>.from(m['blockedDates'] ?? []),
      minBookingNoticeHours: m['minBookingNoticeHours'] as int? ?? 2,
      maxBookingWindowDays: m['maxBookingWindowDays'] as int? ?? 30,
      maxSessionsPerDay: m['maxSessionsPerDay'] as int? ?? 4,
      updatedAt: m['updatedAt'] != null
          ? (m['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'weeklySlots': weeklySlots,
    'blockedDates': blockedDates,
    'minBookingNoticeHours': minBookingNoticeHours,
    'maxBookingWindowDays': maxBookingWindowDays,
    'maxSessionsPerDay': maxSessionsPerDay,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}