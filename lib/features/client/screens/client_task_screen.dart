// lib/features/client/screens/client_task_screen.dart
//
// Client-facing task list.
// • Streams TaskTemplates from Firestore.
// • Applies isTaskDueToday() locally (no extra Firestore index).
// • Pending tab  → tasks due today that aren't completed yet.
// • Completed tab → tasks completed today.
// • Streak badge shown on each daily/weekly task.
// • Quick-complete: tap the checkbox on the card → bottom sheet with optional
//   note → mark complete without opening the detail screen.
// • Full detail: tap anywhere else on the card → TaskDetailScreen.

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
  int _selectedTab = 0;

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
              style: const TextStyle(fontSize: 12, color: Color(0xFF718096)),
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
                  color: Colors.black.withValues(alpha: 0.08),
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
              color: isSelected ? AppColors.primary : const Color(0xFF4A5565),
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
              onQuickComplete: _selectedTab == 0
                  ? () => _showQuickCompleteSheet(tasks[i])
                  : null,
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
            isPending ? Icons.task_alt_outlined : Icons.check_circle_outline,
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
      MaterialPageRoute(builder: (_) => TaskDetailScreen(task: task)),
    );
  }

  // ── Quick-complete bottom sheet ───────────────────────────────────────────

  void _showQuickCompleteSheet(TaskModel task) {
    final noteController = TextEditingController();
    bool submitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (sheetCtx, setSheet) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Title
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.task_alt_rounded,
                              size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Complete Task',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF101828))),
                              Text(
                                task.title,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13, color: Color(0xFF718096)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Note field
                    const Text('Add a Note (Optional)',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748))),
                    const SizedBox(height: 4),
                    const Text(
                      'Share your reflections or any challenges you faced',
                      style:
                      TextStyle(fontSize: 12, color: Color(0xFF718096)),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF4A5568)),
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
                    const SizedBox(height: 20),

                    // Mark complete button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: submitting
                            ? null
                            : () async {
                          setSheet(() => submitting = true);

                          final clientId = context
                              .read<AuthProvider>()
                              .user!
                              .uid;
                          final provider =
                          context.read<TaskProvider>();
                          final note =
                          noteController.text.trim().isEmpty
                              ? null
                              : noteController.text.trim();

                          final success = await provider.completeTask(
                            taskId: task.id,
                            clientId: clientId,
                            clientNote: note,
                          );

                          if (!sheetCtx.mounted) return;
                          Navigator.pop(sheetCtx);

                          if (!context.mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('Task completed! Great job 🎉'),
                                  ],
                                ),
                                backgroundColor:
                                Colors.green.shade600,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(12)),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.error ??
                                    'Something went wrong'),
                                backgroundColor: Colors.red.shade600,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: submitting
                            ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                            : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.task_alt_rounded, size: 18),
                            SizedBox(width: 8),
                            Text('Mark as Complete',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _todayLabel() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Task Card
// ─────────────────────────────────────────────────────────────────────────────

class _TaskCard extends StatefulWidget {
  final TaskModel task;
  final bool isCompleted;
  final int streak;
  final VoidCallback onTap;

  /// Null when the task is already completed (completed tab) — hides checkbox.
  final VoidCallback? onQuickComplete;

  const _TaskCard({
    required this.task,
    required this.isCompleted,
    required this.streak,
    required this.onTap,
    required this.onQuickComplete,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard> {
  bool _checkLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Tap on the card body → open detail screen
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.isCompleted
              ? const Color(0xFFF0FDF4).withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          border: widget.isCompleted
              ? Border.all(color: const Color(0xFF86EFAC), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Checkbox / status indicator ───────────────────────────────
            GestureDetector(
              // Only intercept the tap if not already completed
              onTap: widget.onQuickComplete != null && !widget.isCompleted
                  ? () {
                // Prevent the card's own onTap from firing
                widget.onQuickComplete!();
              }
                  : null,
              // absorb the tap so it doesn't bubble to the card GestureDetector
              behavior: HitTestBehavior.opaque,
              child: Padding(
                // Extra padding makes it easier to tap on mobile
                padding: const EdgeInsets.only(right: 12, top: 1),
                child: _checkLoading
                    ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary))
                    : Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: widget.isCompleted
                        ? AppColors.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: widget.isCompleted
                          ? AppColors.primary
                          : const Color(0xFFD1D5DB),
                      width: 2,
                    ),
                  ),
                  child: widget.isCompleted
                      ? const Icon(Icons.check,
                      size: 13, color: Colors.white)
                      : null,
                ),
              ),
            ),

            // ── Content ───────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: widget.isCompleted
                          ? const Color(0xFF4A5565)
                          : const Color(0xFF101828),
                      decoration: widget.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: const Color(0xFF9CA3AF),
                    ),
                  ),
                  if (widget.task.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      widget.task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF4A5565)),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _MetaChip(
                          icon: Icons.repeat_outlined,
                          label: widget.task.repetition.label),
                      _PriorityBadge(priority: widget.task.priority),
                      _MetaChip(
                          icon: Icons.timer_outlined,
                          label: widget.task.effort.label),
                      if (widget.streak > 0 &&
                          (widget.task.repetition == RepetitionType.daily ||
                              widget.task.repetition ==
                                  RepetitionType.weekly))
                        _StreakBadge(streak: widget.streak),
                    ],
                  ),
                ],
              ),
            ),

            // ── Arrow ─────────────────────────────────────────────────────
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
              style: const TextStyle(fontSize: 11, color: Color(0xFF6A7282))),
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