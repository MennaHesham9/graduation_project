// lib/features/booking/models/package_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum PackageStatus { active, exhausted, expired, cancelled }

class PackageModel {
  final String id;
  final String clientId;
  final String coachId;
  final String type; // "audio" | "video"
  final int totalSessions;
  final int usedSessions;
  final DateTime expiresAt;
  final double price;
  final String currency;
  final PackageStatus status;
  final String? paymentRef;
  final DateTime createdAt;

  int get remainingSessions => totalSessions - usedSessions;
  bool get isExpired => DateTime.now().toUtc().isAfter(expiresAt);
  bool get isExhausted => remainingSessions <= 0;

  const PackageModel({
    required this.id,
    required this.clientId,
    required this.coachId,
    required this.type,
    required this.totalSessions,
    required this.usedSessions,
    required this.expiresAt,
    required this.price,
    required this.currency,
    required this.status,
    this.paymentRef,
    required this.createdAt,
  });

  factory PackageModel.fromMap(String id, Map<String, dynamic> m) =>
      PackageModel(
        id: id,
        clientId: m['clientId'] as String,
        coachId: m['coachId'] as String,
        type: m['type'] as String? ?? 'audio',
        totalSessions: m['totalSessions'] as int,
        usedSessions: m['usedSessions'] as int? ?? 0,
        expiresAt: (m['expiresAt'] as Timestamp).toDate(),
        price: (m['price'] as num).toDouble(),
        currency: m['currency'] as String? ?? 'USD',
        status: _statusFromString(m['status'] as String? ?? 'active'),
        paymentRef: m['paymentRef'] as String?,
        createdAt: (m['createdAt'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
    'clientId': clientId,
    'coachId': coachId,
    'type': type,
    'totalSessions': totalSessions,
    'usedSessions': usedSessions,
    'remainingSessions': remainingSessions,
    'expiresAt': Timestamp.fromDate(expiresAt),
    'price': price,
    'currency': currency,
    'status': _statusToString(status),
    if (paymentRef != null) 'paymentRef': paymentRef,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  static PackageStatus _statusFromString(String s) => switch (s) {
    'exhausted' => PackageStatus.exhausted,
    'expired' => PackageStatus.expired,
    'cancelled' => PackageStatus.cancelled,
    _ => PackageStatus.active,
  };

  static String _statusToString(PackageStatus s) => switch (s) {
    PackageStatus.exhausted => 'exhausted',
    PackageStatus.expired => 'expired',
    PackageStatus.cancelled => 'cancelled',
    PackageStatus.active => 'active',
  };
}