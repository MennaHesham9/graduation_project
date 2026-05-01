// lib/features/coach/services/wallet_service.dart
//
// Reads confirmed/completed session documents from the `sessions` collection
// to compute the coach's real earnings and transaction history.

import 'package:cloud_firestore/cloud_firestore.dart';

class WalletTransaction {
  final String id;
  final String clientName;
  final DateTime date;
  final double amount;
  final String currency;
  final String sessionType; // 'audio' | 'video'
  final String planType;    // 'single' | 'package'
  final String status;      // booking status string

  const WalletTransaction({
    required this.id,
    required this.clientName,
    required this.date,
    required this.amount,
    required this.currency,
    required this.sessionType,
    required this.planType,
    required this.status,
  });
}

class WalletSummary {
  final double availableBalance;
  final double thisMonthEarnings;
  final double totalEarnings;
  final int thisMonthSessions;
  final int totalSessions;
  final List<WalletTransaction> transactions;

  const WalletSummary({
    required this.availableBalance,
    required this.thisMonthEarnings,
    required this.totalEarnings,
    required this.thisMonthSessions,
    required this.totalSessions,
    required this.transactions,
  });
}

class WalletService {
  final FirebaseFirestore _db;

  WalletService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  /// Fetches all paid sessions for [coachId] (confirmed + completed),
  /// computes balance, monthly stats, and returns a [WalletSummary].
  Future<WalletSummary> fetchSummary(String coachId) async {
    // Query sessions where this coach is the coach AND status is paid
    final snap = await _db
        .collection('sessions')
        .where('coachId', isEqualTo: coachId)
        .where('status', whereIn: ['confirmed', 'completed'])
        .orderBy('scheduledAtUtc', descending: true)
        .get();

    final now = DateTime.now().toUtc();
    final monthStart = DateTime.utc(now.year, now.month, 1);

    double totalEarnings = 0;
    double thisMonthEarnings = 0;
    int totalSessions = 0;
    int thisMonthSessions = 0;
    final List<WalletTransaction> transactions = [];

    for (final doc in snap.docs) {
      final data = doc.data();
      final price = (data['price'] as num?)?.toDouble() ?? 0.0;
      final scheduledAt =
          (data['scheduledAtUtc'] as Timestamp?)?.toDate() ?? now;
      final clientName = data['clientName'] as String? ?? 'Unknown Client';
      final currency = data['currency'] as String? ?? 'USD';
      final sessionType = data['type'] as String? ?? 'audio';
      final planType = data['planType'] as String? ?? 'single';
      final status = data['status'] as String? ?? 'confirmed';

      totalEarnings += price;
      totalSessions++;

      if (scheduledAt.isAfter(monthStart)) {
        thisMonthEarnings += price;
        thisMonthSessions++;
      }

      transactions.add(WalletTransaction(
        id: doc.id,
        clientName: clientName,
        date: scheduledAt,
        amount: price,
        currency: currency,
        sessionType: sessionType,
        planType: planType,
        status: status,
      ));
    }

    // Available balance = total earnings (no withdrawal tracking yet)
    return WalletSummary(
      availableBalance: totalEarnings,
      thisMonthEarnings: thisMonthEarnings,
      totalEarnings: totalEarnings,
      thisMonthSessions: thisMonthSessions,
      totalSessions: totalSessions,
      transactions: transactions,
    );
  }

  /// Real-time stream version — rebuilds UI whenever a session changes.
  Stream<WalletSummary> summaryStream(String coachId) {
    return _db
        .collection('sessions')
        .where('coachId', isEqualTo: coachId)
        .where('status', whereIn: ['confirmed', 'completed'])
        .orderBy('scheduledAtUtc', descending: true)
        .snapshots()
        .map((snap) {
      final now = DateTime.now().toUtc();
      final monthStart = DateTime.utc(now.year, now.month, 1);

      double totalEarnings = 0;
      double thisMonthEarnings = 0;
      int totalSessions = 0;
      int thisMonthSessions = 0;
      final List<WalletTransaction> transactions = [];

      for (final doc in snap.docs) {
        final data = doc.data();
        final price = (data['price'] as num?)?.toDouble() ?? 0.0;
        final scheduledAt =
            (data['scheduledAtUtc'] as Timestamp?)?.toDate() ?? now;
        final clientName = data['clientName'] as String? ?? 'Unknown Client';
        final currency = data['currency'] as String? ?? 'USD';
        final sessionType = data['type'] as String? ?? 'audio';
        final planType = data['planType'] as String? ?? 'single';
        final status = data['status'] as String? ?? 'confirmed';

        totalEarnings += price;
        totalSessions++;

        if (scheduledAt.isAfter(monthStart)) {
          thisMonthEarnings += price;
          thisMonthSessions++;
        }

        transactions.add(WalletTransaction(
          id: doc.id,
          clientName: clientName,
          date: scheduledAt,
          amount: price,
          currency: currency,
          sessionType: sessionType,
          planType: planType,
          status: status,
        ));
      }

      return WalletSummary(
        availableBalance: totalEarnings,
        thisMonthEarnings: thisMonthEarnings,
        totalEarnings: totalEarnings,
        thisMonthSessions: thisMonthSessions,
        totalSessions: totalSessions,
        transactions: transactions,
      );
    });
  }
}