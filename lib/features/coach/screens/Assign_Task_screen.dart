import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  // Task Details
  final TextEditingController _titleController =
  TextEditingController(text: 'Daily gratitude journaling');
  final TextEditingController _descriptionController = TextEditingController();

  // Schedule
  String _repetitionRate = 'Daily';
  bool _noEndDate = true;

  // Priority & Effort
  String _priorityLevel = 'Medium';
  String _estimatedEffort = '15 min';

  // Reminders
  bool _remindersEnabled = true;

  // Visibility
  bool _visibleToClient = true;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  _buildAttachmentCard(),
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
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
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
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
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
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Create a task to help your client stay on track',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Client Card ───────────────────────────────────────────────────────────

  Widget _buildClientCard() {
    return _SectionCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('🧑', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sarah Mitchell',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F7F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF38A169),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '• Goal: Improve Work-\nLife Balance',
                    style: TextStyle(fontSize: 11, color: Color(0xFF718096)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Task Details ──────────────────────────────────────────────────────────

  Widget _buildTaskDetailsCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Task Details'),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Task Title'),
          const SizedBox(height: 6),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 13, color: Color(0xFF2D3748)),
            decoration: _inputDecoration(hint: ''),
          ),
          const SizedBox(height: 4),
          const Text(
            '0/60 characters',
            style: TextStyle(fontSize: 11, color: Color(0xFFA0AEC0)),
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
              'Write 3 things you are grateful for each day. This helps build positive mindset and emotional resilience...',
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Help your client understand the purpose and approach',
            style: TextStyle(fontSize: 11, color: Color(0xFFA0AEC0)),
          ),
        ],
      ),
    );
  }

  // ─── Schedule & Repetition ─────────────────────────────────────────────────

  Widget _buildScheduleCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              const _SectionTitle(title: 'Schedule & Repetition'),
            ],
          ),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Repetition Rate'),
          const SizedBox(height: 8),
          _buildRepetitionSelector(),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Start Date'),
          const SizedBox(height: 6),
          _buildDateField(),
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
                  const Text(
                    'No end date',
                    style: TextStyle(fontSize: 12, color: Color(0xFF4A5568)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildDateField(),
        ],
      ),
    );
  }

  Widget _buildRepetitionSelector() {
    const options = ['Once', 'Daily', 'Weekly', 'Custom'];
    return Row(
      children: options.map((option) {
        final isSelected = _repetitionRate == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _repetitionRate = option),
            child: Container(
              margin: EdgeInsets.only(right: option == options.last ? 0 : 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                ),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF4A5568),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateField() {
    return TextField(
      readOnly: true,
      style: const TextStyle(fontSize: 13),
      decoration: _inputDecoration(hint: '').copyWith(
        suffixIcon: Icon(Icons.calendar_today_outlined,
            size: 16, color: const Color(0xFFA0AEC0)),
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
      {'label': 'Low', 'color': const Color(0xFF4A90A4), 'bg': const Color(0xFFE8F4F8)},
      {'label': 'Medium', 'color': const Color(0xFFD97706), 'bg': const Color(0xFFFEF3C7)},
      {'label': 'High', 'color': const Color(0xFFE53E3E), 'bg': const Color(0xFFFFF0F0)},
    ];
    return Row(
      children: options.map((opt) {
        final label = opt['label'] as String;
        final isSelected = _priorityLevel == label;
        final color = opt['color'] as Color;
        final bg = opt['bg'] as Color;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priorityLevel = label),
            child: Container(
              margin: EdgeInsets.only(right: label == 'High' ? 0 : 8),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? color : bg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: isSelected ? color : color.withValues(alpha: 0.3)),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEffortSelector() {
    const options = ['5 min', '15 min', '30 min', '60 min'];
    return Row(
      children: options.map((option) {
        final isSelected = _estimatedEffort == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _estimatedEffort = option),
            child: Container(
              margin: EdgeInsets.only(right: option == options.last ? 0 : 6),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                ),
              ),
              child: Center(
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF4A5568),
                  ),
                ),
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
              Row(
                children: [
                  Icon(Icons.notifications_outlined,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  const _SectionTitle(title: 'Reminders'),
                ],
              ),
              Switch(
                value: _remindersEnabled,
                onChanged: (v) => setState(() => _remindersEnabled = v),
                activeColor: AppColors.primary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _FieldLabel(label: 'Reminder Time'),
          const SizedBox(height: 6),
          TextField(
            readOnly: true,
            decoration: _inputDecoration(hint: '').copyWith(
              suffixIcon: const Icon(Icons.access_time,
                  size: 16, color: Color(0xFFA0AEC0)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildNotificationChip(Icons.notifications_outlined, 'Push')),
              const SizedBox(width: 10),
              Expanded(child: _buildNotificationChip(Icons.email_outlined, 'Email')),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Reminders help clients stay consistent with their tasks',
            style: TextStyle(fontSize: 11, color: Color(0xFFA0AEC0)),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Attachment & Resources ────────────────────────────────────────────────

  Widget _buildAttachmentCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(title: 'Attachment & Resources'),
          const SizedBox(height: 14),
          _buildAttachmentRow(
            icon: Icons.attach_file_outlined,
            title: 'Upload File',
            subtitle: 'PDF, image, or worksheet',
          ),
          const SizedBox(height: 12),
          _buildAttachmentRow(
            icon: Icons.link_outlined,
            title: 'Add Link',
            subtitle: 'External resource or article',
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4F8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Color(0xFF718096)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Visibility & Notes ────────────────────────────────────────────────────

  Widget _buildVisibilityCard() {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F4F8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.visibility_outlined,
                        color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Visible to Client',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3748),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Task will appear in\nclient's dashboard",
                        style: TextStyle(fontSize: 11, color: Color(0xFF718096)),
                      ),
                    ],
                  ),
                ],
              ),
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
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: Color(0xFF4A5568)),
            decoration: _inputDecoration(
              hint: 'Add notes for yourself about this task (not visi...',
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.visibility_off_outlined, size: 12, color: Color(0xFFA0AEC0)),
              SizedBox(width: 4),
              Text(
                'Only you can see this note',
                style: TextStyle(fontSize: 11, color: Color(0xFFA0AEC0)),
              ),
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
          onPressed: () {},
          icon: const Icon(Icons.calendar_today_outlined, size: 16),
          label: const Text(
            'Assign Task',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFBDC7D3)),
      filled: true,
      fillColor: const Color(0xFFF7FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
        borderSide: BorderSide(color: AppColors.primary),
      ),
    );
  }
}

// ─── Reusable Widgets ──────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2D3748),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Color(0xFF4A5568),
      ),
    );
  }
}