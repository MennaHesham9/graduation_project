// lib/features/client/screens/client_task_screen.dart
//
// Client-facing task list.
// • Streams TaskTemplates from Firestore.
// • Applies isTaskDueToday() locally (no extra Firestore index).
// • Pending tab  → tasks due today that aren't completed yet.
// • Completed tab → tasks completed today + past completions this week.
// • Streak badge shown on each daily/weekly task.

import 'package:flutter/material.dart';
import 'package:mindwell/features/client/screens/task_details_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/providers/task_provider.dart';



class ClientTasksScreen extends StatefulWidget {
  const ClientTasksScreen({super.key});

  @override
  State<ClientTasksScreen> createState() => _ClientTasksScreenState();
}

class _ClientTasksScreenState extends State<ClientTasksScreen> {
  int _selectedTab = 0; // 0=Pending, 1=Completed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clientId = context.read<AuthProvider>().user?.uid;
      if (clientId != null) {
        context.read<TaskProvider>().listenToClientTasks(clientId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(child: _buildBody()),
      ],
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Consumer<TaskProvider>(builder: (context, provider, _) {
      final pending = provider.pendingTodayTasks.length;
      final completed = provider.completedTasks.length;

      return Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + 12,
          left: 24,
          right: 24,
          bottom: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My tasks',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828))),
            const SizedBox(height: 4),
            Text(
              'Today • ${_todayLabel()}',
              style:
              const TextStyle(fontSize: 12, color: Color(0xFF718096)),
            ),
            const SizedBox(height: 16),
            _buildTabBar(pending, completed),
          ],
        ),
      );
    });
  }

  Widget _buildTabBar(int pending, int completed) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTab(0, 'Pending ($pending)'),
          _buildTab(1, 'Completed ($completed)'),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? AppColors.primary
                  : const Color(0xFF4A5565),
            ),
          ),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFAF5FF), Color(0xFFEFF6FF), Color(0xFFFDF2F8)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Consumer<TaskProvider>(builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final tasks = _selectedTab == 0
            ? provider.pendingTodayTasks
            : provider.completedTasks;

        if (tasks.isEmpty) {
          return _emptyState(_selectedTab == 0);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: tasks.length,
          itemBuilder: (_, i) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _TaskCard(
              task: tasks[i],
              isCompleted: _selectedTab == 1,
              streak: provider.streakFor(tasks[i].id, tasks[i]),
              onTap: () => _openTaskDetail(tasks[i]),
            ),
          ),
        );
      }),
    );
  }

  Widget _emptyState(bool isPending) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPending
                ? Icons.task_alt_outlined
                : Icons.check_circle_outline,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isPending ? 'No tasks due today 🎉' : 'No completed tasks yet',
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            isPending
                ? 'Your coach will assign tasks here'
                : 'Complete a task to see it here',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  void _openTaskDetail(TaskModel task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: task),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Card
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskModel task;
  final bool isCompleted;
  final int streak;
  final VoidCallback onTap;

  const _TaskCard({
    required this.task,
    required this.isCompleted,
    required this.streak,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFFF0FDF4).withOpacity(0.9)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: isCompleted
              ? Border.all(color: const Color(0xFF86EFAC), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 15,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicator
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primary
                      : const Color(0xFFD1D5DB),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isCompleted
                          ? const Color(0xFF4A5565)
                          : const Color(0xFF101828),
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF4A5565)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Meta row
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _MetaChip(
                        icon: Icons.repeat_outlined,
                        label: task.repetition.label,
                      ),
                      _PriorityBadge(priority: task.priority),
                      _MetaChip(
                        icon: Icons.timer_outlined,
                        label: task.effort.label,
                      ),
                      // Streak badge (daily/weekly only, streak > 0)
                      if (streak > 0 &&
                          (task.repetition == RepetitionType.daily ||
                              task.repetition == RepetitionType.weekly))
                        _StreakBadge(streak: streak),
                    ],
                  ),
                ],
              ),
            ),

            // Arrow
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFCBD5E0), size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: const Color(0xFF6A7282)),
          const SizedBox(width: 3),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF6A7282))),
        ],
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color bg, border, text;
    switch (priority) {
      case TaskPriority.high:
        bg = const Color(0xFFFEF2F2);
        border = const Color(0xFFFFC9C9);
        text = const Color(0xFFE7000B);
        break;
      case TaskPriority.medium:
        bg = const Color(0xFFFFF7ED);
        border = const Color(0xFFFFD6A8);
        text = const Color(0xFFF54900);
        break;
      case TaskPriority.low:
        bg = const Color(0xFFF0FDF4);
        border = const Color(0xFFBBF7D0);
        text = const Color(0xFF16A34A);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.flag_rounded, size: 11, color: text),
          const SizedBox(width: 3),
          Text(priority.label,
              style: TextStyle(fontSize: 11, color: text)),
        ],
      ),
    );
  }
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFECC92)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 3),
          Text('$streak streak',
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}