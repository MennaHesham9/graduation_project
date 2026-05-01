// lib/features/client/dashboard/screens/mental_wellness_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../screens/client_sessions_screen.dart';
import '../../screens/client_task_screen.dart';
import '../../screens/explore_coaches.dart';
import '../../screens/mood_tracking.dart';

import '../../goals/screens/goals_dashboard_screen.dart';
import '../../screens/sessions/assessments_screen.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/action_buttons_row.dart';
import '../widgets/dashboard_header_card.dart';
import '../widgets/goal_progress_section.dart';
import '../widgets/next_session_card.dart';
import '../widgets/stat_cards_row.dart';
import '../../../../core/screens/notification_screen.dart';

class MentalWellnessDashboardScreen extends StatefulWidget {
  const MentalWellnessDashboardScreen({super.key});

  @override
  State<MentalWellnessDashboardScreen> createState() =>
      _MentalWellnessDashboardScreenState();
}

class _MentalWellnessDashboardScreenState
    extends State<MentalWellnessDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  // Change this:
  // void _load() {
  //   final uid = context.read<AuthProvider>().user?.uid;
  //   if (uid != null) {
  //     context.read<DashboardProvider>().load(clientId: uid);
  //   }
  // }

// To this:
  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid != null) {
      // Await the provider call so the RefreshIndicator knows when data is ready
      await context.read<DashboardProvider>().load(clientId: uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.watch<AuthProvider>().user;
    final fullName = authUser?.fullName ?? 'there';
    final firstName = fullName.trim().split(' ').first;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: SafeArea(
        bottom: false,
        child: Consumer<DashboardProvider>(
          builder: (context, vm, _) {
            if (vm.isLoading && vm.data == null) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF1B9AAA)),
              );
            }

            if (vm.error != null && vm.data == null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Something went wrong',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        vm.error!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.62),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: _load,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B9AAA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = vm.data!;
            final hasNextSession = data.nextSession.doctorName.isNotEmpty;

            return RefreshIndicator(
              color: const Color(0xFF1B9AAA),
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          DashboardHeaderCard(
                            userName: firstName,
                            onBellTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const NotificationScreen()),
                            ),
                          ),
                          SizedBox(height: hasNextSession ? 54 : 16),
                        ],
                      ),
                      if (hasNextSession)
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: -32,
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyCoachSessionsScreen()),
                            ),
                            child: NextSessionCard(
                              doctorName: data.nextSession.doctorName,
                              time: data.nextSession.time,
                              onJoin: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                    const MyCoachSessionsScreen()),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: hasNextSession ? 48 : 12),
                  StatCardsRow(
                    moodEmoji: data.stats.mood,
                    tasksDone: data.stats.tasksDone,
                    totalTasks: data.stats.totalTasks,
                    onMoodTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MoodTrackingScreen()),
                    ),
                    onTasksTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClientTasksScreen()),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GoalsDashboardScreen()),
                    ),
                    child: GoalProgressSection(
                      communication: data.goals.communication,
                      confidence: data.goals.confidence,
                      label1: data.goals.label1,
                      label2: data.goals.label2,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ActionButtonsRow(
                    onMyCoachesSessions: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyCoachSessionsScreen()),
                    ),
                    onExploreCoaches: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExploreCoachesScreen()),
                    ),
                    onAssessments: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AssessmentsScreen()),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
