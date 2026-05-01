// lib/features/client/dashboard/services/dashboard_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dashboard_data.dart';
import '../models/goals.dart';
import '../models/session.dart';
import '../models/stats.dart';
import '../models/user.dart';

class DashboardService {
  final FirebaseFirestore _db;

  DashboardService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Future<DashboardData> fetchDashboard({required String clientId}) async {
    final now = DateTime.now().toUtc();

    // ── Next upcoming confirmed session ─────────────────────────────────────
    Session nextSession = const Session(doctorName: '', time: '');
    try {
      final sessionSnap = await _db
          .collection('sessions')
          .where('clientId', isEqualTo: clientId)
          .where('status', whereIn: ['confirmed', 'rescheduled'])
          .orderBy('scheduledAtUtc')
          .limit(5)
          .get();

      final upcomingDocs = sessionSnap.docs.where((d) {
        final ts = d.data()['scheduledAtUtc'];
        if (ts == null) return false;
        return (ts as Timestamp).toDate().isAfter(now);
      }).toList();

      if (upcomingDocs.isNotEmpty) {
        final next = upcomingDocs.first.data();
        final dt = (next['scheduledAtUtc'] as Timestamp).toDate().toLocal();
        final coachName = next['coachName'] as String? ?? 'Your Coach';

        final isToday = dt.year == DateTime.now().year &&
            dt.month == DateTime.now().month &&
            dt.day == DateTime.now().day;

        final hour = dt.hour;
        final minute = dt.minute.toString().padLeft(2, '0');
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        final timeStr = '$displayHour:$minute $period';

        final dateLabel = isToday
            ? 'Today, $timeStr'
            : '${_monthName(dt.month)} ${dt.day}, $timeStr';

        nextSession = Session(
          doctorName: coachName,
          time: dateLabel,
          sessionId: upcomingDocs.first.id,
        );
      }
    } catch (_) {}

    // ── Today's mood (latest mood entry for today) ───────────────────────────
    String moodEmoji = '—';
    try {
      final todayStart =
      DateTime(now.year, now.month, now.day).toUtc();
      final moodSnap = await _db
          .collection('mood_entries')
          .where('clientId', isEqualTo: clientId)
          .where('createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (moodSnap.docs.isNotEmpty) {
        final data = moodSnap.docs.first.data();
        moodEmoji = data['emoji'] as String? ??
            _moodScoreToEmoji(data['score'] as int? ?? 0);
      }
    } catch (_) {}

    // ── Tasks: count tasks due today and completed today ─────────────────────
    int tasksDone = 0;
    int totalTasks = 0;
    try {
      final taskSnap = await _db
          .collection('tasks')
          .where('clientId', isEqualTo: clientId)
          .where('visibleToClient', isEqualTo: true)
          .get();

      final todayKey = _dateKey(DateTime.now());

      for (final doc in taskSnap.docs) {
        final data = doc.data();
        final repetition = data['repetition'] as String? ?? 'once';
        final startDateTs = data['startDate'] as Timestamp?;
        final endDateTs = data['endDate'] as Timestamp?;

        if (!_isTaskDueToday(repetition, startDateTs, endDateTs, data)) {
          continue;
        }
        totalTasks++;

        try {
          final compSnap = await _db
              .collection('tasks')
              .doc(doc.id)
              .collection('completions')
              .doc(todayKey)
              .get();
          if (compSnap.exists) tasksDone++;
        } catch (_) {}
      }
    } catch (_) {}

    // ── Goals: get up to 2 active goals with progress ────────────────────────
    double goal1Progress = 0.0;
    double goal2Progress = 0.0;
    String goal1Label = 'Active Goal';
    String goal2Label = 'Active Goal';
    try {
      final goalsSnap = await _db
          .collection('goals')
          .where('clientId', isEqualTo: clientId)
          .orderBy('createdAt', descending: true)
          .limit(2)
          .get();

      if (goalsSnap.docs.isNotEmpty) {
        final g1 = goalsSnap.docs.first.data();
        goal1Label = g1['title'] as String? ?? 'Goal 1';
        final steps1 = (g1['actionSteps'] as List?) ?? [];
        if (steps1.isNotEmpty) {
          final done1 =
              steps1.where((s) => (s as Map)['isDone'] == true).length;
          goal1Progress = done1 / steps1.length;
        }
      }
      if (goalsSnap.docs.length > 1) {
        final g2 = goalsSnap.docs[1].data();
        goal2Label = g2['title'] as String? ?? 'Goal 2';
        final steps2 = (g2['actionSteps'] as List?) ?? [];
        if (steps2.isNotEmpty) {
          final done2 =
              steps2.where((s) => (s as Map)['isDone'] == true).length;
          goal2Progress = done2 / steps2.length;
        }
      }
    } catch (_) {}

    return DashboardData(
      user: const User(name: ''),
      nextSession: nextSession,
      stats: Stats(
        mood: moodEmoji,
        tasksDone: tasksDone,
        totalTasks: totalTasks,
      ),
      goals: Goals(
        communication: goal1Progress,
        confidence: goal2Progress,
        label1: goal1Label,
        label2: goal2Label,
      ),
    );
  }

  // ── Stats for client profile counters ─────────────────────────────────────
  Future<ClientStats> fetchClientStats({required String clientId}) async {
    int totalSessions = 0;
    int totalGoals = 0;
    int tasksDoneCount = 0;

    // Total completed sessions
    try {
      final snap = await _db
          .collection('sessions')
          .where('clientId', isEqualTo: clientId)
          .where('status', isEqualTo: 'completed')
          .get();
      totalSessions = snap.docs.length;
    } catch (_) {}

    // Total goals
    try {
      final snap = await _db
          .collection('goals')
          .where('clientId', isEqualTo: clientId)
          .get();
      totalGoals = snap.docs.length;
    } catch (_) {}

    // Total completed task instances (count completion sub-docs)
    try {
      final taskSnap = await _db
          .collection('tasks')
          .where('clientId', isEqualTo: clientId)
          .get();
      for (final doc in taskSnap.docs) {
        try {
          final compSnap = await _db
              .collection('tasks')
              .doc(doc.id)
              .collection('completions')
              .get();
          tasksDoneCount += compSnap.docs.length;
        } catch (_) {}
      }
    } catch (_) {}

    return ClientStats(
      sessions: totalSessions,
      goals: totalGoals,
      tasksDone: tasksDoneCount,
    );
  }

  // ── Coach dashboard header stats ───────────────────────────────────────────
  Future<CoachDashboardStats> fetchCoachDashboardStats({
    required String coachId,
    required List<String> clientIds,
  }) async {
    final now = DateTime.now().toUtc();
    int todaySessions = 0;
    double monthEarnings = 0.0;
    int completedSessions = 0;
    int totalSessions = 0;

    // Today's sessions count
    try {
      final todayStart = DateTime(now.year, now.month, now.day).toUtc();
      final todayEnd = todayStart.add(const Duration(days: 1));
      final snap = await _db
          .collection('sessions')
          .where('coachId', isEqualTo: coachId)
          .where('scheduledAtUtc',
          isGreaterThanOrEqualTo: Timestamp.fromDate(todayStart))
          .where('scheduledAtUtc', isLessThan: Timestamp.fromDate(todayEnd))
          .get();
      todaySessions = snap.docs.length;
    } catch (_) {}

    // This month's earnings
    try {
      final monthStart = DateTime(now.year, now.month, 1).toUtc();
      final snap = await _db
          .collection('sessions')
          .where('coachId', isEqualTo: coachId)
          .where('status', isEqualTo: 'completed')
          .where('scheduledAtUtc',
          isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .get();
      for (final doc in snap.docs) {
        final price = doc.data()['price'];
        if (price != null) {
          monthEarnings += (price as num).toDouble();
        }
      }
    } catch (_) {}

    // This month performance
    try {
      final monthStart = DateTime(now.year, now.month, 1).toUtc();
      final snap = await _db
          .collection('sessions')
          .where('coachId', isEqualTo: coachId)
          .where('scheduledAtUtc',
          isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .get();
      totalSessions = snap.docs.length;
      completedSessions = snap.docs
          .where((d) => d.data()['status'] == 'completed')
          .length;
    } catch (_) {}

    return CoachDashboardStats(
      activeClients: clientIds.length,
      todaySessions: todaySessions,
      monthEarnings: monthEarnings,
      completedSessions: completedSessions,
      totalSessions: totalSessions,
    );
  }

  // ── Coach performance card (profile screen) ────────────────────────────────
  Future<CoachPerformanceStats> fetchCoachPerformanceStats({
    required String coachId,
    required List<String> clientIds,
  }) async {
    final now = DateTime.now().toUtc();
    int totalSessionsDone = 0;
    int completedThisMonth = 0;
    int totalThisMonth = 0;

    try {
      final snap = await _db
          .collection('sessions')
          .where('coachId', isEqualTo: coachId)
          .where('status', isEqualTo: 'completed')
          .get();
      totalSessionsDone = snap.docs.length;
    } catch (_) {}

    try {
      final monthStart = DateTime(now.year, now.month, 1).toUtc();
      final snap = await _db
          .collection('sessions')
          .where('coachId', isEqualTo: coachId)
          .where('scheduledAtUtc',
          isGreaterThanOrEqualTo: Timestamp.fromDate(monthStart))
          .get();
      totalThisMonth = snap.docs.length;
      completedThisMonth = snap.docs
          .where((d) => d.data()['status'] == 'completed')
          .length;
    } catch (_) {}

    return CoachPerformanceStats(
      totalClients: clientIds.length,
      totalSessionsDone: totalSessionsDone,
      completedThisMonth: completedThisMonth,
      totalThisMonth: totalThisMonth,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────
  bool _isTaskDueToday(
      String repetition,
      Timestamp? startDateTs,
      Timestamp? endDateTs,
      Map<String, dynamic> data,
      ) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (startDateTs != null) {
      final s = startDateTs.toDate().toLocal();
      if (todayDate.isBefore(DateTime(s.year, s.month, s.day))) return false;
    }
    if (endDateTs != null) {
      final e = endDateTs.toDate().toLocal();
      if (todayDate.isAfter(DateTime(e.year, e.month, e.day))) return false;
    }

    switch (repetition) {
      case 'daily':
        return true;
      case 'once':
        if (startDateTs == null) return true;
        final s = startDateTs.toDate().toLocal();
        return DateTime(s.year, s.month, s.day) == todayDate;
      case 'weekly':
        if (startDateTs == null) return false;
        return startDateTs.toDate().toLocal().weekday == today.weekday;
      case 'custom':
        final selectedDays =
            (data['selectedDays'] as List?)?.cast<String>() ?? [];
        const dayNames = [
          'Monday', 'Tuesday', 'Wednesday', 'Thursday',
          'Friday', 'Saturday', 'Sunday'
        ];
        return selectedDays.contains(dayNames[today.weekday - 1]);
      default:
        return false;
    }
  }

  String _dateKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  String _monthName(int m) {
    const n = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return n[m];
  }

  String _moodScoreToEmoji(int score) {
    if (score >= 9) return '🤩';
    if (score >= 7) return '😊';
    if (score >= 5) return '😐';
    if (score >= 3) return '😔';
    return '😢';
  }
}

// ── Value objects ──────────────────────────────────────────────────────────────

class ClientStats {
  final int sessions;
  final int goals;
  final int tasksDone;
  const ClientStats({
    required this.sessions,
    required this.goals,
    required this.tasksDone,
  });
}

class CoachDashboardStats {
  final int activeClients;
  final int todaySessions;
  final double monthEarnings;
  final int completedSessions;
  final int totalSessions;
  const CoachDashboardStats({
    required this.activeClients,
    required this.todaySessions,
    required this.monthEarnings,
    required this.completedSessions,
    required this.totalSessions,
  });
}

class CoachPerformanceStats {
  final int totalClients;
  final int totalSessionsDone;
  final int completedThisMonth;
  final int totalThisMonth;
  const CoachPerformanceStats({
    required this.totalClients,
    required this.totalSessionsDone,
    required this.completedThisMonth,
    required this.totalThisMonth,
  });
}
