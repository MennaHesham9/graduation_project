import '../models/dashboard_data.dart';
import '../models/goals.dart';
import '../models/session.dart';
import '../models/stats.dart';
import '../models/user.dart';

class DashboardService {
  Future<DashboardData> fetchDashboard() async {
    await Future.delayed(const Duration(milliseconds: 900));

    return const DashboardData(
      user: User(name: ''),        // ← name no longer stored here
      nextSession: Session(
        doctorName: 'Dr. Michael Chen',
        time: 'Today, 2:00 PM',
      ),
      stats: Stats(
        mood: '😊',
        tasksDone: 3,
        totalTasks: 7,
      ),
      goals: Goals(
        communication: 0.75,
        confidence: 0.60,
      ),
    );
  }
}