import 'goals.dart';
import 'session.dart';
import 'stats.dart';
import 'user.dart';

class DashboardData {
  final User user;
  final Session nextSession;
  final Stats stats;
  final Goals goals;

  const DashboardData({
    required this.user,
    required this.nextSession,
    required this.stats,
    required this.goals,
  });
}

