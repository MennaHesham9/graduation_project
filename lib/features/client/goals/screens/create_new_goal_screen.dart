import 'package:flutter/material.dart';

class CreateNewGoalScreen extends StatefulWidget {
  const CreateNewGoalScreen({super.key});

  @override
  State<CreateNewGoalScreen> createState() => _CreateNewGoalScreenState();
}

class _CreateNewGoalScreenState extends State<CreateNewGoalScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _category = 'Personal Growth';
  DateTime? _startDate;
  DateTime? _targetDate;

  final List<_StepItem> _steps = [
    _StepItem(text: 'Define clear objective', done: false),
    _StepItem(text: 'Break into milestones', done: false),
    _StepItem(text: 'Set timeline', done: false),
  ];

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF1B9AAA),
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _targetDate = picked;
      }
    });
  }

  Future<void> _addStep() async {
    final controller = TextEditingController();
    final text = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Add Step'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'e.g., Practice 10 minutes daily',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.10)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF1B9AAA), width: 1.4),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B9AAA),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (text == null || text.isEmpty) return;
    setState(() => _steps.add(_StepItem(text: text, done: false)));
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save Goal')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final sheetWidth = w < 420 ? w - 40 : 360.0;
    final topPadding = (h * 0.05).clamp(16.0, 36.0);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            width: sheetWidth,
            margin: EdgeInsets.only(top: topPadding, bottom: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
                    child: Row(
                      children: [
                        _CircleIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          onTap: () => Navigator.maybePop(context),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Create New Goal',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black.withValues(alpha: 0.86),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.03),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.10),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
                          const SizedBox(height: 14),
                          _SectionCard(
                            title: 'Category',
                            child: _CategoryGrid(
                              selected: _category,
                              onSelect: (c) => setState(() => _category = c),
                            ),
                          ),
                          const SizedBox(height: 14),
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
                          const SizedBox(height: 14),
                          _SectionCard(
                            title: 'Description',
                            child: _InputField(
                              controller: _descController,
                              hintText: "Describe your goal and why it's\nimportant to you...",
                              maxLines: 3,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _SectionCard(
                            title: 'Action Steps',
                            trailing: InkWell(
                              onTap: _addStep,
                              borderRadius: BorderRadius.circular(999),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add, size: 16, color: Color(0xFF1B9AAA)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Add Step',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF1B9AAA),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                for (int i = 0; i < _steps.length; i++) ...[
                                  _StepRow(
                                    text: _steps[i].text,
                                    done: _steps[i].done,
                                    onTap: () => setState(() => _steps[i] = _steps[i].copyWith(done: !_steps[i].done)),
                                  ),
                                  if (i != _steps.length - 1)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: Container(height: 1, color: Colors.black.withValues(alpha: 0.06)),
                                    ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined, size: 18),
                        label: const Text(
                          'Save Goal',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1B9AAA),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withValues(alpha: 0.70),
                    ),
              ),
              const Spacer(),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
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

  const _InputField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.black.withValues(alpha: 0.80),
          ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hintText,
        hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black.withValues(alpha: 0.35),
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
        prefixIcon: prefixIcon == null
            ? null
            : Icon(prefixIcon, size: 18, color: Colors.black.withValues(alpha: 0.35)),
        prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.10)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1B9AAA), width: 1.4),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black.withValues(alpha: 0.55),
              ),
        ),
        const SizedBox(height: 8),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Ink(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: Colors.black.withValues(alpha: 0.35)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: value.isEmpty
                                ? Colors.black.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.70),
                          ),
                    ),
                  ),
                ],
              ),
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

  const _CategoryGrid({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    const categories = [
      'Personal Growth',
      'Career',
      'Mental Health',
      'Relationships',
      'Health & Fitness',
      'Financial',
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in categories)
          _Chip(
            label: c,
            selected: selected == c,
            onTap: () => onSelect(c),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF1B9AAA) : const Color(0xFFF1F3F5);
    final fg = selected ? Colors.white : Colors.black.withValues(alpha: 0.70);
    final border = selected ? Colors.transparent : Colors.black.withValues(alpha: 0.06);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String text;
  final bool done;
  final VoidCallback onTap;

  const _StepRow({
    required this.text,
    required this.done,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: done ? const Color(0xFF1B9AAA) : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: done ? const Color(0xFF1B9AAA) : Colors.black.withValues(alpha: 0.20),
                    width: 1.4,
                  ),
                ),
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Icon(Icons.check, size: 14, color: Colors.black.withValues(alpha: 0.20)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black.withValues(alpha: 0.70),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black.withValues(alpha: 0.10)),
          ),
          child: Icon(
            icon,
            size: 16,
            color: Colors.black.withValues(alpha: 0.78),
          ),
        ),
      ),
    );
  }
}

class _StepItem {
  final String text;
  final bool done;

  const _StepItem({
    required this.text,
    required this.done,
  });

  _StepItem copyWith({String? text, bool? done}) {
    return _StepItem(
      text: text ?? this.text,
      done: done ?? this.done,
    );
  }
}

