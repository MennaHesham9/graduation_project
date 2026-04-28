// lib/features/client/screens/task_detail_screen.dart
//
// Client-facing task detail screen.
// • Shows full task info (title, description, dates, repetition).
// • "Mark as Complete" writes to tasks/{id}/completions/{YYYY-MM-DD}.
// • Once completed for today, the button changes to "Completed ✓".
// • Client can add a short note when completing.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/utils/task_logic.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel task;

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _isCompletedToday {
    final provider = context.read<TaskProvider>();
    return provider.completedTasks.any((t) => t.id == widget.task.id);
  }

  Future<void> _markComplete() async {
    if (_submitting) return;
    setState(() => _submitting = true);

    final clientId = context.read<AuthProvider>().user!.uid;
    final provider = context.read<TaskProvider>();

    final success = await provider.completeTask(
      taskId: widget.task.id,
      clientId: clientId,
      clientNote: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    setState(() => _submitting = false);

    if (!mounted) return;

    if (success) {
      _showSuccess();
      // Small delay so user sees the success state, then pop
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Something went wrong'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  void _showSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('Task completed! Great job 🎉'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final alreadyDone = context
        .watch<TaskProvider>()
        .completedTasks
        .any((t) => t.id == task.id);
    final streak =
    context.watch<TaskProvider>().streakFor(task.id, task);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    _buildTaskCard(task, streak),
                    const SizedBox(height: 12),
                    _buildScheduleCard(task),
                    const SizedBox(height: 12),
                    if (!alreadyDone) ...[
                      _buildNoteCard(),
                      const SizedBox(height: 12),
                    ],
                    if (alreadyDone) _buildCompletedBanner(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildBottomButton(alreadyDone),
          ],
        ),
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.arrow_back_ios,
                size: 18, color: Color(0xFF5A6A7A)),
          ),
          const SizedBox(width: 8),
          const Text('Task Details',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748))),
        ],
      ),
    );
  }

  // ─── Main Task Card ───────────────────────────────────────────────────────

  Widget _buildTaskCard(TaskModel task, int streak) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  task.title,
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748)),
                ),
              ),
              if (streak > 0 &&
                  (task.repetition == RepetitionType.daily ||
                      task.repetition == RepetitionType.weekly))
                _StreakBadge(streak: streak),
            ],
          ),

          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              task.description,
              style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF718096),
                  height: 1.6),
            ),
          ],

          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _TagChip(
                icon: Icons.repeat_outlined,
                label: task.repetition.label,
                backgroundColor: const Color(0xFFE8F4F8),
                textColor: AppColors.primary,
                iconColor: AppColors.primary,
              ),
              _TagChip(
                icon: Icons.flag_outlined,
                label: '${task.priority.label} Priority',
                backgroundColor: _priorityBg(task.priority),
                textColor: _priorityColor(task.priority),
                iconColor: _priorityColor(task.priority),
              ),
              _TagChip(
                icon: Icons.timer_outlined,
                label: task.effort.label,
                backgroundColor: const Color(0xFFF3F4F6),
                textColor: const Color(0xFF4A5568),
                iconColor: const Color(0xFF6A7282),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Schedule Card ────────────────────────────────────────────────────────

  Widget _buildScheduleCard(TaskModel task) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Schedule',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748))),
          const SizedBox(height: 14),
          _scheduleRow(
            Icons.calendar_today_outlined,
            'Start Date',
            _formatDate(task.startDate.toLocal()),
          ),
          const SizedBox(height: 10),
          _scheduleRow(
            Icons.event_outlined,
            'End Date',
            task.endDate != null
                ? _formatDate(task.endDate!.toLocal())
                : 'No end date',
          ),
          if (task.repetition == RepetitionType.custom &&
              task.selectedDays.isNotEmpty) ...[
            const SizedBox(height: 10),
            _scheduleRow(
              Icons.view_week_outlined,
              'Active Days',
              _daysLabel(task.selectedDays),
            ),
          ],
          const SizedBox(height: 10),
          _scheduleRow(
            Icons.person_outline,
            'Assigned by',
            task.coachName,
          ),
        ],
      ),
    );
  }

  Widget _scheduleRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFFA0AEC0)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF4A5568))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF2D3748))),
        ),
      ],
    );
  }

  // ─── Note Card ────────────────────────────────────────────────────────────

  Widget _buildNoteCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add a Note (Optional)',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748))),
          const SizedBox(height: 4),
          const Text(
            'Share your reflections or any challenges you faced',
            style: TextStyle(fontSize: 12, color: Color(0xFF718096)),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
            decoration: InputDecoration(
              hintText: 'Write your thoughts here...',
              hintStyle: const TextStyle(
                  fontSize: 13, color: Color(0xFFBDC7D3)),
              filled: true,
              fillColor: const Color(0xFFF7FAFC),
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Completed Banner ─────────────────────────────────────────────────────

  Widget _buildCompletedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF86EFAC)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_rounded,
              color: Color(0xFF16A34A), size: 24),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Completed for today!',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF16A34A))),
              SizedBox(height: 2),
              Text('Great work keeping up with your tasks',
                  style: TextStyle(
                      fontSize: 12, color: Color(0xFF4A5568))),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Bottom Button ────────────────────────────────────────────────────────

  Widget _buildBottomButton(bool alreadyDone) {
    return Container(
      color: const Color(0xFFF0F4F8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: alreadyDone ? null : _markComplete,
          style: ElevatedButton.styleFrom(
            backgroundColor:
            alreadyDone ? Colors.grey.shade300 : AppColors.primary,
            foregroundColor:
            alreadyDone ? Colors.grey.shade600 : Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: _submitting
              ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                alreadyDone
                    ? Icons.check_circle_outline
                    : Icons.task_alt_rounded,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                alreadyDone
                    ? 'Completed for Today ✓'
                    : 'Mark as Complete',
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return const Color(0xFFE53E3E);
      case TaskPriority.medium:
        return const Color(0xFFD97706);
      case TaskPriority.low:
        return const Color(0xFF38A169);
    }
  }

  Color _priorityBg(TaskPriority p) {
    switch (p) {
      case TaskPriority.high:
        return const Color(0xFFFFF0F0);
      case TaskPriority.medium:
        return const Color(0xFFFEF3C7);
      case TaskPriority.low:
        return const Color(0xFFE6F7F0);
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  String _daysLabel(List<int> days) {
    const names = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    return days.map((d) => names[d - 1]).join(', ');
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2)),
      ],
    ),
    child: child,
  );
}

class _TagChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;

  const _TagChip({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: textColor)),
      ],
    ),
  );
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge({required this.streak});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFFFECC92)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🔥', style: TextStyle(fontSize: 14)),
        const SizedBox(width: 4),
        Text('$streak day streak',
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFD97706),
                fontWeight: FontWeight.w600)),
      ],
    ),
  );
}