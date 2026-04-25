import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../screens/client_sessions_screen.dart';
import '../../screens/explore_coaches.dart';
import '../../screens/sessions/assessments_screen.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/action_buttons_row.dart';
import '../widgets/dashboard_header_card.dart';
import '../widgets/goal_progress_section.dart';
import '../widgets/next_session_card.dart';
import '../widgets/stat_cards_row.dart';

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
    context.read<DashboardProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    // ── Always read live from AuthProvider ──────────────────────────────────
    final fullName = context.watch<AuthProvider>().user?.fullName ?? 'there';
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
                      Text('Something went wrong',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(vm.error!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                            color: Colors.black.withValues(alpha: 0.62),
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 14),
                      ElevatedButton(
                        onPressed: vm.load,
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

            return RefreshIndicator(
              color: const Color(0xFF1B9AAA),
              onRefresh: vm.load,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Column(
                        children: [
                          DashboardHeaderCard(
                            userName: firstName, // ← always live from AuthProvider
                            onBellTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Notifications')),
                              );
                            },
                          ),
                          const SizedBox(height: 54),
                        ],
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: -32,
                        child: NextSessionCard(
                          doctorName: data.nextSession.doctorName,
                          time: data.nextSession.time,
                          onJoin: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Joining session...')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  StatCardsRow(
                    moodEmoji: data.stats.mood,
                    tasksDone: data.stats.tasksDone,
                    totalTasks: data.stats.totalTasks,
                  ),
                  const SizedBox(height: 14),
                  GoalProgressSection(
                    communication: data.goals.communication,
                    confidence: data.goals.confidence,
                  ),
                  const SizedBox(height: 14),
                  ActionButtonsRow(
                    onMyCoaches_Sessions: () => Navigator.push(
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