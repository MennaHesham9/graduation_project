// lib/features/tasks/screens/assign_task_screen.dart
//
// Coach-facing "Assign Task" screen.
// Accepts [clientId], [clientName], [coachId], [coachName] as named params.
// On submit: checks schedule overlap → writes one TaskTemplate to Firestore.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';

class AssignTaskScreen extends StatefulWidget {
  final String clientId;
  final String clientName;
  final String? clientGoal;

  const AssignTaskScreen({
    super.key,
    required this.clientId,
    required this.clientName,
    this.clientGoal,
  });

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _privateNoteController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ── Schedule ──────────────────────────────────────────────────────────────
  RepetitionType _repetition = RepetitionType.daily;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _noEndDate = false;

  // Custom days (1=Mon … 7=Sun)
  final Set<int> _selectedDays = {};
  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  // ── Priority & Effort ─────────────────────────────────────────────────────
  TaskPriority _priority = TaskPriority.medium;
  TaskEffort _effort = TaskEffort.fifteen;

  // ── Reminders ─────────────────────────────────────────────────────────────
  bool _remindersEnabled = true;
  TimeOfDay? _reminderTime;

  // ── Visibility ────────────────────────────────────────────────────────────
  bool _visibleToClient = true;

  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _privateNoteController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null) {
      _showError('Please pick a start date.');
      return;
    }
    if (_repetition == RepetitionType.custom && _selectedDays.isEmpty) {
      _showError('Please select at least one day for custom repetition.');
      return;
    }

    final coach = context.read<AuthProvider>().user!;
    final provider = context.read<TaskProvider>();

    final newTask = TaskModel(
      id: '',
      coachId: coach.uid,
      coachName: coach.fullName,
      clientId: widget.clientId,
      clientName: widget.clientName,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      privateCoachNote: _privateNoteController.text.trim().isEmpty
          ? null
          : _privateNoteController.text.trim(),
      repetition: _repetition,
      selectedDays: _selectedDays.toList()..sort(),
      startDate: _startDate!.toUtc(),
      endDate: _noEndDate ? null : _endDate?.toUtc(),
      priority: _priority,
      effort: _effort,
      remindersEnabled: _remindersEnabled,
      reminderTime: _reminderTime != null
          ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
          : null,
      visibleToClient: _visibleToClient,
      createdAt: DateTime.now().toUtc(),
    );

    // Overlap check
    final overlaps = await provider.wouldOverlap(
        newTask: newTask, clientId: widget.clientId);

    if (overlaps && mounted) {
      final proceed = await _showOverlapWarning();
      if (proceed != true) return;
    }

    setState(() => _submitting = true);

    final taskId = await provider.assignTask(task: newTask);

    setState(() => _submitting = false);

    if (!mounted) return;

    if (taskId != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅ Task assigned successfully!'),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      Navigator.pop(context, true); // signal refresh to caller
    } else {
      _showError(provider.error ?? 'Failed to assign task.');
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<bool?> _showOverlapWarning() => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      title: const Row(children: [
        Text('⚠️ Schedule Conflict'),
      ]),
      content: Text(
          '${widget.clientName} already has tasks scheduled on the same days. '
              'Are you sure you want to add another?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Assign Anyway'),
        ),
      ],
    ),
  );

  // ── Date pickers ──────────────────────────────────────────────────────────

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final initial = _endDate ?? (_startDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _pickReminderTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  // ── UI ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  children: [
                    _buildClientCard(),
                    const SizedBox(height: 12),
                    _buildTaskDetailsCard(),
                    const SizedBox(height: 12),
                    _buildScheduleCard(),
                    const SizedBox(height: 12),
                    _buildPriorityCard(),
                    const SizedBox(height: 12),
                    _buildRemindersCard(),
                    const SizedBox(height: 12),
                    _buildVisibilityCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            _buildAssignButton(),
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child:
              const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assign Task',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              SizedBox(height: 2),
              Text(
                'Create a task to help your client stay on track',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Client Card ──────────────────────────────────────────────────────────

  Widget _buildClientCard() {
    return _SectionCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _initials(widget.clientName),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.clientName,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3748))),
              const SizedBox(height: 4),
              Row(
                children: [
                  _pill('Active', const Color(0xFFE6F7F0),
                      const Color(0xFF38A169)),
                  if (widget.clientGoal != null) ...[
                    const SizedBox(width: 6),
                    Text('• ${widget.clientGoal}',
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF718096))),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(String label, Color bg, Color fg) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
        color: bg, borderRadius: BorderRadius.circular(20)),
    child: Text(label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: fg)),
  );

  // ─── Task Details ──────────────────────────────────────────────────────────

  Widget _buildTaskDetailsCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Task Details'),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Task Title *'),
          const SizedBox(height: 6),
          TextFormField(
            controller: _titleController,
            maxLength: 60,
            validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'Title is required' : null,
            style: const TextStyle(fontSize: 13, color: Color(0xFF2D3748)),
            decoration: _inputDecoration(hint: 'e.g. Daily gratitude journaling'),
          ),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Task Description'),
          const SizedBox(height: 6),
          TextField(
            controller: _descriptionController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
            decoration: _inputDecoration(
              hint:
              'Help your client understand the purpose and approach...',
            ),
          ),
        ],
      ),
    );
  }

  // ─── Schedule & Repetition ────────────────────────────────────────────────

  Widget _buildScheduleCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.calendar_month_outlined,
                color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            const _SectionTitle(title: 'Schedule & Repetition'),
          ]),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Repetition Rate'),
          const SizedBox(height: 8),
          _buildRepetitionSelector(),
          // Custom day picker
          if (_repetition == RepetitionType.custom) ...[
            const SizedBox(height: 12),
            const _FieldLabel(label: 'Select Days'),
            const SizedBox(height: 8),
            _buildDayPicker(),
          ],
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Start Date *'),
          const SizedBox(height: 6),
          _buildDateTile(
            label: _startDate == null
                ? 'Select start date'
                : _formatDate(_startDate!),
            onTap: _pickStartDate,
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _FieldLabel(label: 'End Date'),
              Row(
                children: [
                  Switch(
                    value: _noEndDate,
                    onChanged: (v) => setState(() => _noEndDate = v),
                    activeColor: AppColors.primary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 4),
                  const Text('No end date',
                      style:
                      TextStyle(fontSize: 12, color: Color(0xFF4A5568))),
                ],
              ),
            ],
          ),
          if (!_noEndDate) ...[
            const SizedBox(height: 6),
            _buildDateTile(
              label: _endDate == null
                  ? 'Select end date'
                  : _formatDate(_endDate!),
              onTap: _pickEndDate,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRepetitionSelector() {
    const options = [
      RepetitionType.once,
      RepetitionType.daily,
      RepetitionType.weekly,
      RepetitionType.custom,
    ];
    return Row(
      children: options.map((opt) {
        final isSelected = _repetition == opt;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _repetition = opt),
            child: Container(
              margin: EdgeInsets.only(right: opt == options.last ? 0 : 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                ),
              ),
              child: Center(
                child: Text(opt.label,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4A5568))),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = i + 1; // 1=Mon … 7=Sun
        final isSelected = _selectedDays.contains(day);
        return GestureDetector(
          onTap: () => setState(() {
            if (isSelected) {
              _selectedDays.remove(day);
            } else {
              _selectedDays.add(day);
            }
          }),
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primary : Colors.white,
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Center(
              child: Text(
                _dayLabels[i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color:
                  isSelected ? Colors.white : const Color(0xFF4A5568),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDateTile({required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 13,
                    color: label.startsWith('Select')
                        ? const Color(0xFFBDC7D3)
                        : const Color(0xFF2D3748))),
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Color(0xFFA0AEC0)),
          ],
        ),
      ),
    );
  }

  // ─── Priority & Effort ─────────────────────────────────────────────────────

  Widget _buildPriorityCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Priority & Effort'),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Priority Level'),
          const SizedBox(height: 8),
          _buildPrioritySelector(),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Estimated Effort'),
          const SizedBox(height: 8),
          _buildEffortSelector(),
        ],
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final options = [
      (TaskPriority.low, 'Low', const Color(0xFF4A90A4),
      const Color(0xFFE8F4F8)),
      (TaskPriority.medium, 'Medium', const Color(0xFFD97706),
      const Color(0xFFFEF3C7)),
      (TaskPriority.high, 'High', const Color(0xFFE53E3E),
      const Color(0xFFFFF0F0)),
    ];
    return Row(
      children: options.map((opt) {
        final (type, label, color, bg) = opt;
        final isSelected = _priority == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = type),
            child: Container(
              margin: EdgeInsets.only(right: type == TaskPriority.high ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? color : bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? color : color.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color)),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEffortSelector() {
    const options = [
      TaskEffort.five,
      TaskEffort.fifteen,
      TaskEffort.thirty,
      TaskEffort.sixty,
    ];
    return Row(
      children: options.map((opt) {
        final isSelected = _effort == opt;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _effort = opt),
            child: Container(
              margin: EdgeInsets.only(right: opt == options.last ? 0 : 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                ),
              ),
              child: Center(
                child: Text(opt.label,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4A5568))),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Reminders ─────────────────────────────────────────────────────────────

  Widget _buildRemindersCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                const Icon(Icons.notifications_outlined,
                    color: AppColors.primary, size: 18),
                const SizedBox(width: 8),
                const _SectionTitle(title: 'Reminders'),
              ]),
              Switch(
                value: _remindersEnabled,
                onChanged: (v) => setState(() => _remindersEnabled = v),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          if (_remindersEnabled) ...[
            const SizedBox(height: 12),
            const _FieldLabel(label: 'Reminder Time'),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _pickReminderTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 13),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _reminderTime == null
                          ? 'Select time'
                          : _reminderTime!.format(context),
                      style: TextStyle(
                          fontSize: 13,
                          color: _reminderTime == null
                              ? const Color(0xFFBDC7D3)
                              : const Color(0xFF2D3748)),
                    ),
                    const Icon(Icons.access_time,
                        size: 16, color: Color(0xFFA0AEC0)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Reminders help clients stay consistent with their tasks',
              style: TextStyle(fontSize: 11, color: Color(0xFFA0AEC0)),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Visibility ────────────────────────────────────────────────────────────

  Widget _buildVisibilityCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.visibility_outlined,
                      color: AppColors.primary, size: 18),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Visible to Client',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748))),
                    SizedBox(height: 2),
                    Text("Task will appear in client's dashboard",
                        style: TextStyle(
                            fontSize: 11, color: Color(0xFF718096))),
                  ],
                ),
              ]),
              Switch(
                value: _visibleToClient,
                onChanged: (v) => setState(() => _visibleToClient = v),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const _FieldLabel(label: 'Private Coach Note'),
          const SizedBox(height: 6),
          TextField(
            controller: _privateNoteController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
            decoration: _inputDecoration(
              hint: 'Add notes for yourself about this task (not visible to client)...',
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.visibility_off_outlined,
                  size: 12, color: Color(0xFFA0AEC0)),
              SizedBox(width: 4),
              Text('Only you can see this note',
                  style:
                  TextStyle(fontSize: 11, color: Color(0xFFA0AEC0))),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Assign Button ─────────────────────────────────────────────────────────

  Widget _buildAssignButton() {
    return Container(
      color: const Color(0xFFF0F4F8),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton.icon(
          onPressed: _submitting ? null : _submit,
          icon: _submitting
              ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : const Icon(Icons.calendar_today_outlined, size: 16),
          label: Text(
            _submitting ? 'Assigning...' : 'Assign Task',
            style: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDC7D3)),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}

// ─── Reusable widgets ──────────────────────────────────────────────────────────

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

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF2D3748)));
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) => Text(label,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Color(0xFF4A5568)));
}