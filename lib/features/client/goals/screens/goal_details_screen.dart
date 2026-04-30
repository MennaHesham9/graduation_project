// lib/features/client/goals/screens/goal_details_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';

class GoalDetailsScreen extends StatelessWidget {
  final GoalModel goal;
  const GoalDetailsScreen({super.key, required this.goal});

  // Pick a color per category
  static Color _categoryColor(String category) {
    switch (category) {
      case 'Career':
        return const Color(0xFF2F80ED);
      case 'Mental Health':
        return const Color(0xFF9B59B6);
      case 'Financial':
        return const Color(0xFF27AE60);
      case 'Fitness':
        return const Color(0xFFE67E22);
      default:
        return const Color(0xFF1B9AAA);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to live goal from provider (so toggling steps updates in real-time)
    final liveGoal = context.select<GoalProvider, GoalModel?>(
          (p) => p.goals.where((g) => g.id == goal.id).firstOrNull,
    ) ?? goal;

    final color = _categoryColor(liveGoal.category);
    final pct = (liveGoal.progress * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF4FAFF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Hero Header ─────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white, size: 18),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Goal Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Category pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      liveGoal.category,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    liveGoal.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Progress bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.w600)),
                      Text(
                        '$pct%  (${liveGoal.completedSteps}/${liveGoal.totalSteps} steps)',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: liveGoal.progress,
                      backgroundColor: Colors.white30,
                      valueColor:
                      const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Timeline Row ─────────────────────────────────────────
                    if (liveGoal.startDate != null ||
                        liveGoal.targetDate != null)
                      _InfoCard(
                        child: Row(
                          children: [
                            if (liveGoal.startDate != null)
                              Expanded(
                                child: _DateChip(
                                  icon: Icons.play_circle_outline,
                                  label: 'Started',
                                  value: _formatDate(liveGoal.startDate!),
                                  color: color,
                                ),
                              ),
                            if (liveGoal.startDate != null &&
                                liveGoal.targetDate != null)
                              Container(
                                  width: 1,
                                  height: 40,
                                  color: Colors.black12),
                            if (liveGoal.targetDate != null)
                              Expanded(
                                child: _DateChip(
                                  icon: Icons.flag_outlined,
                                  label: 'Target',
                                  value: _formatDate(liveGoal.targetDate!),
                                  color: color,
                                ),
                              ),
                          ],
                        ),
                      ),

                    // ── Description ──────────────────────────────────────────
                    if (liveGoal.description.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _SectionHeader(title: 'About this Goal'),
                      const SizedBox(height: 10),
                      _InfoCard(
                        child: Text(
                          liveGoal.description,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.5),
                        ),
                      ),
                    ],

                    // ── Action Steps ─────────────────────────────────────────
                    const SizedBox(height: 16),
                    _SectionHeader(
                      title: 'Action Steps',
                      subtitle: liveGoal.totalSteps == 0
                          ? null
                          : '${liveGoal.completedSteps} of ${liveGoal.totalSteps} completed',
                    ),
                    const SizedBox(height: 10),

                    if (liveGoal.actionSteps.isEmpty)
                      _InfoCard(
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'No action steps were added for this goal.',
                              style:
                              TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        ),
                      )
                    else
                      _InfoCard(
                        child: Column(
                          children: [
                            for (int i = 0;
                            i < liveGoal.actionSteps.length;
                            i++) ...[
                              _ActionStepTile(
                                step: liveGoal.actionSteps[i],
                                index: i,
                                goalId: liveGoal.id,
                                accentColor: color,
                              ),
                              if (i < liveGoal.actionSteps.length - 1)
                                const Divider(height: 1),
                            ],
                          ],
                        ),
                      ),

                    // ── Completion message ────────────────────────────────────
                    if (liveGoal.progress == 1.0 &&
                        liveGoal.totalSteps > 0) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withOpacity(0.7)],
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.celebration, color: Colors.white, size: 32),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '🎉 Goal Achieved!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                  Text(
                                    'You completed all action steps. Great work!',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}

// ── Action Step Tile ──────────────────────────────────────────────────────────

class _ActionStepTile extends StatelessWidget {
  final ActionStep step;
  final int index;
  final String goalId;
  final Color accentColor;

  const _ActionStepTile({
    required this.step,
    required this.index,
    required this.goalId,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<GoalProvider>().toggleStep(
        goalId: goalId,
        stepIndex: index,
      ),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: step.isDone ? accentColor : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: step.isDone ? accentColor : Colors.black26,
                  width: 2,
                ),
              ),
              child: step.isDone
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step ${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.text,
                    style: TextStyle(
                      fontSize: 15,
                      color: step.isDone
                          ? Colors.grey
                          : Colors.black87,
                      decoration: step.isDone
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SectionHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.black87),
        ),
        if (subtitle != null)
          Text(subtitle!,
              style:
              const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
              color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))
        ],
      ),
      child: child,
    );
  }
}

class _DateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _DateChip(
      {required this.icon,
        required this.label,
        required this.value,
        required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}