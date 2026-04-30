// lib/features/client/goals/screens/create_new_goal_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/providers/auth_provider.dart';
import '../models/goal_model.dart';
import '../providers/goal_provider.dart';

class CreateNewGoalScreen extends StatefulWidget {
  const CreateNewGoalScreen({super.key});

  @override
  State<CreateNewGoalScreen> createState() => _CreateNewGoalScreenState();
}

class _CreateNewGoalScreenState extends State<CreateNewGoalScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _uuid = const Uuid();

  String _category = 'Personal Growth';
  DateTime? _startDate;
  DateTime? _targetDate;
  bool _isSaving = false;

  final List<_StepItem> _steps = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startDate : _targetDate) ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context)
              .colorScheme
              .copyWith(primary: const Color(0xFF1B9AAA)),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() => isStart ? _startDate = picked : _targetDate = picked);
  }

  Future<void> _addStep() async {
    final controller = TextEditingController();
    // Use a separate dialogContext name so we don't shadow the widget's context
    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Add Action Step'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g., Practice 10 minutes daily',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B9AAA),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (text == null || text.isEmpty) return;
    setState(() => _steps.add(_StepItem(id: _uuid.v4(), text: text)));
  }

  void _removeStep(int index) => setState(() => _steps.removeAt(index));

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a goal title.')),
      );
      return;
    }

//



    // ✅ Capture providers and messenger BEFORE any await
    final authProvider = context.read<AuthProvider>();
    final goalProvider = context.read<GoalProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    final clientId = authProvider.user?.uid;
    if (clientId == null) return;

    setState(() => _isSaving = true);

    final goal = GoalModel(
      id: '',
      clientId: clientId,
      title: title,
      description: _descController.text.trim(),
      category: _category,
      startDate: _startDate,
      targetDate: _targetDate,
      actionSteps:
      _steps.map((s) => ActionStep(id: s.id, text: s.text)).toList(),
      createdAt: DateTime.now(),
    );

    final success = await goalProvider.createGoal(goal);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Goal saved successfully!'),
          backgroundColor: Color(0xFF1B9AAA),
        ),
      );
      nav.pop();
    } else {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Failed to save goal. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Create New Goal',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _SectionCard(
                      title: 'Goal Title',
                      child: _InputField(
                        controller: _titleController,
                        hintText: 'e.g., Improve Public Speaking Skills',
                        prefixIcon: Icons.edit_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Category',
                      child: _CategoryGrid(
                        selected: _category,
                        onSelect: (c) => setState(() => _category = c),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Timeline',
                      child: Row(
                        children: [
                          Expanded(
                            child: _DateField(
                              label: 'Start Date',
                              value: _formatDate(_startDate),
                              onTap: () => _pickDate(isStart: true),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DateField(
                              label: 'Target Date',
                              value: _formatDate(_targetDate),
                              onTap: () => _pickDate(isStart: false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Description',
                      child: _InputField(
                        controller: _descController,
                        hintText: "Describe your goal and why it's important...",
                        maxLines: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SectionCard(
                      title: 'Action Steps',
                      trailing: InkWell(
                        onTap: _addStep,
                        borderRadius: BorderRadius.circular(8),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Text(
                            '+ Add Step',
                            style: TextStyle(
                                color: Color(0xFF1B9AAA),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      child: _steps.isEmpty
                          ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text(
                            'No steps yet. Tap "+ Add Step" to begin.',
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                          : Column(
                        children: [
                          for (int i = 0; i < _steps.length; i++)
                            _StepRow(
                              text: _steps[i].text,
                              index: i + 1,
                              onDelete: () => _removeStep(i),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving ? 'Saving...' : 'Save Goal',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B9AAA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day}/${d.month}/${d.year}';
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionCard({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final IconData? prefixIcon;
  const _InputField(
      {required this.controller,
        required this.hintText,
        this.maxLines = 1,
        this.prefixIcon});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(value.isEmpty ? 'Select' : value,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _CategoryGrid({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Personal Growth', 'Career', 'Mental Health', 'Financial', 'Fitness',
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories
          .map((c) => ChoiceChip(
        label: Text(c),
        selected: selected == c,
        onSelected: (_) => onSelect(c),
        selectedColor: const Color(0xFF1B9AAA),
        labelStyle:
        TextStyle(color: selected == c ? Colors.white : Colors.black),
      ))
          .toList(),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String text;
  final int index;
  final VoidCallback onDelete;
  const _StepRow({required this.text, required this.index, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF1B9AAA).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B9AAA)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
        child: Icon(icon, size: 20),
      ),
    );
  }
}

class _StepItem {
  final String id;
  final String text;
  const _StepItem({required this.id, required this.text});
}