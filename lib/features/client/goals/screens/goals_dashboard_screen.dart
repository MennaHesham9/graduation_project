import 'package:flutter/material.dart';
import 'create_new_goal_screen.dart';

// Ensure this import matches your project structure
// import 'create_new_goal_screen.dart';

class GoalsDashboardScreen extends StatefulWidget {
  const GoalsDashboardScreen({super.key});

  @override
  State<GoalsDashboardScreen> createState() => _GoalsDashboardScreenState();
}

class _GoalsDashboardScreenState extends State<GoalsDashboardScreen> {
  final List<_GoalVm> _goals = const [
    _GoalVm(
      iconBg: Color(0xFF1B9AAA),
      title: 'Improve Communication\nSkills',
      category: 'Personal Growth',
      progress: 0.75,
      startedLabel: 'Started',
      startedValueTop: 'Nov',
      startedValueBottom: '1',
      targetLabel: 'Target',
      targetValueTop: 'Jan',
      targetValueBottom: '31',
      barColor: Color(0xFF1B9AAA),
    ),
    _GoalVm(
      iconBg: Color(0xFF2F80ED),
      title: 'Build Self-Confidence',
      category: 'Mental Health',
      progress: 0.60,
      startedLabel: 'Started',
      startedValueTop: 'Nov',
      startedValueBottom: '15',
      targetLabel: 'Target',
      targetValueTop: 'Feb',
      targetValueBottom: '15',
      barColor: Color(0xFF2F80ED),
    ),
    _GoalVm(
      iconBg: Color(0xFF2ECC71),
      title: 'Career Transition',
      category: 'Career',
      progress: 0.40,
      startedLabel: 'Started',
      startedValueTop: 'Dec',
      startedValueBottom: '1',
      targetLabel: 'Target',
      targetValueTop: 'Mar',
      targetValueBottom: '1',
      barColor: Color(0xFF2ECC71),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Header with Title and Create Button
            _TopHeader(
              onCreate: () {
                // Navigate to your create goal screen here
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateNewGoalScreen(),
                  ),
                );
              },
            ),

            // Scrollable Content Area
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF4FAFF), Color(0xFFF8F4FF)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  children: [
                    for (final g in _goals) ...[
                      _GoalCard(
                        data: g,
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(g.title.replaceAll('\n', ' '))),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _WeeklyCheckInCard(
                      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Starting Evaluation...')),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final VoidCallback onCreate;
  const _TopHeader({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Goals',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Create New Goal',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B9AAA),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final _GoalVm data;
  final VoidCallback onTap;

  const _GoalCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pct = (data.progress * 100).round();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 4,
      shadowColor: Colors.black12,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: data.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.track_changes, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        _Pill(label: data.category),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progress', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  Text('$pct%', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              _ProgressBar(value: data.progress, color: data.barColor),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DateMini(label: data.startedLabel, value: '${data.startedValueTop} ${data.startedValueBottom}'),
                  _DateMini(label: data.targetLabel, value: '${data.targetValueTop} ${data.targetValueBottom}', color: data.barColor),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E7FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, color: Color(0xFF7A4CE0), fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _DateMini extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _DateMini({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;
  const _ProgressBar({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: Colors.black12,
      color: color,
      minHeight: 6,
      borderRadius: BorderRadius.circular(10),
    );
  }
}

class _WeeklyCheckInCard extends StatelessWidget {
  final VoidCallback onTap;
  const _WeeklyCheckInCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(colors: [Color(0xFFFF8A2A), Color(0xFFFF4D7E)]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Check-In', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const Text('How was your progress this week?', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white, elevation: 0),
              child: const Text('Complete Evaluation'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalVm {
  final Color iconBg;
  final String title;
  final String category;
  final double progress;
  final String startedLabel;
  final String startedValueTop;
  final String startedValueBottom;
  final String targetLabel;
  final String targetValueTop;
  final String targetValueBottom;
  final Color barColor;

  const _GoalVm({
    required this.iconBg,
    required this.title,
    required this.category,
    required this.progress,
    required this.startedLabel,
    required this.startedValueTop,
    required this.startedValueBottom,
    required this.targetLabel,
    required this.targetValueTop,
    required this.targetValueBottom,
    required this.barColor,
  });
}