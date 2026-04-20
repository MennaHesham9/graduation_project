// import 'package:flutter/material.dart';
// import '../../../../core/widgets/placeholder_screen.dart';
//
// class ClientTasksScreen extends StatelessWidget {
//   const ClientTasksScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const PlaceholderScreen(name: 'Tasks Screen');
//   }
// }

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ClientTasksScreen extends StatefulWidget {
  const ClientTasksScreen({super.key});

  @override
  State<ClientTasksScreen> createState() => _TasksListScreenState();
}

class _TasksListScreenState extends State<ClientTasksScreen> {
  int _selectedTab = 0; // 0 = Pending, 1 = Completed

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: _buildTaskList(),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white.withOpacity(0.8),
      padding: const EdgeInsets.only(
        top: 48,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Tasks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
            ),
          ),
          const SizedBox(height: 16),
          _buildTabBar(),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTab(index: 0, label: 'Pending (3)'),
          _buildTab(index: 1, label: 'Completed (2)'),
        ],
      ),
    );
  }

  Widget _buildTab({required int index, required String label}) {
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 4),
              ),
            ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.primary : const Color(0xFF4A5565),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFEFF6FF),
            Color(0xFFFDF2F8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _TaskCard(
            title: 'Practice daily meditation',
            subtitle: '10 minutes each morning',
            dueDate: 'Due Dec 8',
            priority: TaskPriority.high,
          ),
          SizedBox(height: 12),
          _TaskCard(
            title: 'Write down 3 gratitude items',
            subtitle: 'Reflect on positive moments',
            dueDate: 'Due Dec 7',
            priority: TaskPriority.medium,
          ),
          SizedBox(height: 12),
          _TaskCard(
            title: 'Read chapter on communication',
            subtitle: 'From the recommended book',
            dueDate: 'Due Dec 10',
            priority: TaskPriority.medium,
          ),
        ],
      ),
    );
  }
}

enum TaskPriority { high, medium, low }

class _TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String dueDate;
  final TaskPriority priority;

  const _TaskCard({
    required this.title,
    required this.subtitle,
    required this.dueDate,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CheckboxButton(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5565),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Color(0xFF6A7282),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dueDate,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF6A7282),
                      ),
                    ),
                    const SizedBox(width: 12),
                    _PriorityBadge(priority: priority),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckboxButton extends StatefulWidget {
  @override
  State<_CheckboxButton> createState() => _CheckboxButtonState();
}

class _CheckboxButtonState extends State<_CheckboxButton> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _checked = !_checked),
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: _checked ? AppColors.primary : const Color(0xFFD1D5DB),
            width: 2,
          ),
          color: _checked ? AppColors.primary : Colors.transparent,
        ),
        child: _checked
            ? const Icon(Icons.check, size: 14, color: Colors.white)
            : null,
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final TaskPriority priority;

  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    final IconData icon;
    final String label;

    switch (priority) {
      case TaskPriority.high:
        bgColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFFC9C9);
        textColor = const Color(0xFFE7000B);
        icon = Icons.flag_rounded;
        label = 'High';
        break;
      case TaskPriority.medium:
        bgColor = const Color(0xFFFFF7ED);
        borderColor = const Color(0xFFFFD6A8);
        textColor = const Color(0xFFF54900);
        icon = Icons.flag_rounded;
        label = 'Medium';
        break;
      case TaskPriority.low:
        bgColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFBBF7D0);
        textColor = const Color(0xFF16A34A);
        icon = Icons.flag_rounded;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}