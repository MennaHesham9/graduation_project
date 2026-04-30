// lib/features/coach/widgets/coach_client_tasks_panel.dart
//
// Drop-in widget for CoachClientProfileScreen → _buildTasksAssignedCard().
// Shows real Firestore tasks with compliance rate and streak.
// Tap "+" header icon or the card's own button to open AssignTaskScreen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../client/models/coaching_request_model.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/screens/assign_task_screen.dart';
import '../../tasks/utils/task_logic.dart';

class CoachClientTasksPanel extends StatefulWidget {
  final CoachingRequestModel client;

  const CoachClientTasksPanel({super.key, required this.client});

  @override
  State<CoachClientTasksPanel> createState() =>
      _CoachClientTasksPanelState();
}

class _CoachClientTasksPanelState extends State<CoachClientTasksPanel> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final coachId = context.read<AuthProvider>().user?.uid;
      if (coachId != null) {
        context.read<TaskProvider>().listenToCoachClientTasks(
          coachId: coachId,
          clientId: widget.client.clientId,
        );
      }
    });
  }

  void _openAssignTask() async {
    final coach = context.read<AuthProvider>().user!;
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => TaskProvider(),
          child: AssignTaskScreen(
            clientId: widget.client.clientId,
            clientName: widget.client.clientName,
            clientGoal: widget.client.primaryGoal,
          ),
        ),
      ),
    );
    // result == true means a task was successfully assigned → refresh
    if (result == true && mounted) {
      context.read<TaskProvider>().listenToCoachClientTasks(
        coachId: coach.uid,
        clientId: widget.client.clientId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(builder: (context, provider, _) {
      return _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('tasks Assigned',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF101828))),
                GestureDetector(
                  onTap: _openAssignTask,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add_task_rounded,
                        size: 18, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Loading
            if (provider.isLoading)
              const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ))
            // Empty state
            else if (provider.allTasks.isEmpty)
              _emptyState()
            // Task list
            else
              ...provider.allTasks.map(
                    (task) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CoachTaskRow(
                    task: task,
                    complianceLabel: provider.complianceLabelFor(
                        task.id, task),
                    streak: provider.streakFor(task.id, task),
                    onDelete: () => _confirmDelete(task, provider),
                  ),
                ),
              ),

            // Assign button at bottom
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: OutlinedButton.icon(
                onPressed: _openAssignTask,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Assign New Task'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _confirmDelete(TaskModel task, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Task'),
        content: Text('Remove "${task.title}" from this client?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteTask(task.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(Icons.assignment_outlined,
                size: 48, color: Colors.grey.shade300),
            const SizedBox(height: 8),
            Text('No tasks assigned yet',
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.8),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 10)),
        BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 4)),
      ],
    ),
    child: child,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual task row (coach view)
// ─────────────────────────────────────────────────────────────────────────────

class _CoachTaskRow extends StatelessWidget {
  final TaskModel task;
  final String complianceLabel;
  final int streak;
  final VoidCallback onDelete;

  const _CoachTaskRow({
    required this.task,
    required this.complianceLabel,
    required this.streak,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(task);
    final statusLabel = _statusLabel(task);
    final bgColor = _statusBg(task);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: title + status + delete
          Row(
            children: [
              Expanded(
                child: Text(task.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF364153)),
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete_outline,
                    size: 16, color: Color(0xFFCBD5E0)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: repetition + compliance + streak
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _chip(Icons.repeat_outlined, task.repetition.label,
                  const Color(0xFF6A7282)),
              _chip(Icons.bar_chart_rounded, complianceLabel,
                  AppColors.primary),
              if (streak > 0 &&
                  (task.repetition == RepetitionType.daily ||
                      task.repetition == RepetitionType.weekly))
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('🔥 $streak streak',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFFD97706))),
                ),
              // End date
              if (task.endDate != null)
                _chip(Icons.event_outlined,
                    'Until ${_fmtDate(task.endDate!.toLocal())}',
                    const Color(0xFF6A7282)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(fontSize: 11, color: color)),
      ],
    ),
  );

  // Determine if the task is active, completed, or overdue
  String _statusLabel(TaskModel task) {
    final now = DateTime.now();
    if (task.endDate != null && task.endDate!.toLocal().isBefore(now)) {
      return 'Ended';
    }
    if (isTaskDueToday(task)) return 'Due Today';
    return 'Scheduled';
  }

  Color _statusColor(TaskModel task) {
    final label = _statusLabel(task);
    switch (label) {
      case 'Due Today':
        return AppColors.primary;
      case 'Ended':
        return const Color(0xFF6A7282);
      default:
        return const Color(0xFF16A34A);
    }
  }

  Color _statusBg(TaskModel task) {
    final label = _statusLabel(task);
    switch (label) {
      case 'Due Today':
        return const Color(0xFFEFF6FF);
      case 'Ended':
        return const Color(0xFFF9FAFB);
      default:
        return const Color(0xFFF0FDF4);
    }
  }

  String _fmtDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}