import 'package:flutter/material.dart';

import 'create_new_goal_screen.dart';

class GoalsDashboardScreen extends StatefulWidget {
  const GoalsDashboardScreen({super.key});

  @override
  State<GoalsDashboardScreen> createState() => _GoalsDashboardScreenState();
}

class _GoalsDashboardScreenState extends State<GoalsDashboardScreen> {
  int _bottomIndex = 2;

  final List<_GoalVm> _goals = const [
    _GoalVm(
      iconBg: Color(0xFF1B9AAA),
      title: 'Improve Communication\nSkills',
      category: 'Personal Growth',
      progress: 0.75,
      startedLabel: 'Started',
      startedValueTop: 'Nov',
      startedValueBottom: '1',
      targetLabel: 'Target',
      targetValueTop: 'Jan',
      targetValueBottom: '31',
      barColor: Color(0xFF1B9AAA),
    ),
    _GoalVm(
      iconBg: Color(0xFF2F80ED),
      title: 'Build Self-Confidence',
      category: 'Mental Health',
      progress: 0.60,
      startedLabel: 'Started',
      startedValueTop: 'Nov',
      startedValueBottom: '15',
      targetLabel: 'Target',
      targetValueTop: 'Feb',
      targetValueBottom: '15',
      barColor: Color(0xFF2F80ED),
    ),
    _GoalVm(
      iconBg: Color(0xFF2ECC71),
      title: 'Career Transition',
      category: 'Career',
      progress: 0.40,
      startedLabel: 'Started',
      startedValueTop: 'Dec',
      startedValueBottom: '1',
      targetLabel: 'Target',
      targetValueTop: 'Mar',
      targetValueBottom: '1',
      barColor: Color(0xFF2ECC71),
    ),
  ];

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
                  _TopHeader(
                    onCreate: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateNewGoalScreen()),
                      );
                    },
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFF4FAFF), Color(0xFFF8F4FF)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        children: [
                          for (final g in _goals) ...[
                            _GoalCard(
                              data: g,
                              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(g.title.replaceAll('\n', ' '))),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                          _WeeklyCheckInCard(
                            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Complete Evaluation')),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                  _BottomNav(
                    selectedIndex: _bottomIndex,
                    onTap: (i) {
                      setState(() => _bottomIndex = i);
                      const labels = ['Home', 'Tasks', 'Goals', 'Sessions', 'Profile'];
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(labels[i])));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatelessWidget {
  final VoidCallback onCreate;

  const _TopHeader({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Goals',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withValues(alpha: 0.86),
                ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add, size: 18),
              label: const Text(
                'Create New Goal',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B9AAA),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final _GoalVm data;
  final VoidCallback onTap;

  const _GoalCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (data.progress * 100).round();
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: data.iconBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.radio_button_checked_rounded, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: Colors.black.withValues(alpha: 0.82),
                                height: 1.15,
                              ),
                        ),
                        const SizedBox(height: 6),
                        _Pill(label: data.category),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Progress',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.black.withValues(alpha: 0.55),
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '$pct',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withValues(alpha: 0.70),
                        ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '%',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: Colors.black.withValues(alpha: 0.30),
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _ProgressBar(value: data.progress, color: data.barColor),
              const SizedBox(height: 10),
              Row(
                children: [
                  _DateMini(
                    icon: Icons.calendar_today_outlined,
                    label: '${data.startedLabel} ${data.startedValueTop}',
                    value: data.startedValueBottom,
                  ),
                  const Spacer(),
                  _DateMini(
                    icon: Icons.track_changes_rounded,
                    label: '${data.targetLabel} ${data.targetValueTop}',
                    value: data.targetValueBottom,
                    valueColor: data.barColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;

  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1E7FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7A4CE0),
            ),
      ),
    );
  }
}

class _DateMini extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DateMini({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.black.withValues(alpha: 0.55),
        );
    final valueStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w900,
          color: valueColor ?? Colors.black.withValues(alpha: 0.70),
        );

    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black.withValues(alpha: 0.45)),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: labelStyle),
            const SizedBox(height: 2),
            Text(value, style: valueStyle),
          ],
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double value;
  final Color color;

  const _ProgressBar({
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 6,
        color: Colors.black.withValues(alpha: 0.08),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: value.clamp(0, 1),
          child: Container(color: color),
        ),
      ),
    );
  }
}

class _WeeklyCheckInCard extends StatelessWidget {
  final VoidCallback onTap;

  const _WeeklyCheckInCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFFFF8A2A), Color(0xFFFF4D7E)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.show_chart_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weekly Check-In',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'How was your progress this week?',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 32,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withValues(alpha: 0.26),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Complete Evaluation',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const teal = Color(0xFF1B9AAA);
    const unselected = Color(0xFF9AA5AE);

    Widget item({
      required int index,
      required IconData icon,
      required String label,
      bool isCenter = false,
    }) {
      final active = selectedIndex == index;
      if (isCenter) {
        return Expanded(
          child: InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 56,
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: teal,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.track_changes_rounded, color: Colors.white, size: 22),
                ),
              ),
            ),
          ),
        );
      }

      return Expanded(
        child: InkWell(
          onTap: () => onTap(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: active ? teal : unselected),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: active ? teal : unselected,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          item(index: 0, icon: Icons.home_outlined, label: 'Home'),
          item(index: 1, icon: Icons.check_box_outlined, label: 'Tasks'),
          item(index: 2, icon: Icons.track_changes_rounded, label: 'Goals', isCenter: true),
          item(index: 3, icon: Icons.videocam_outlined, label: 'Sessions'),
          item(index: 4, icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}

class _GoalVm {
  final Color iconBg;
  final String title;
  final String category;
  final double progress; // 0..1
  final String startedLabel;
  final String startedValueTop;
  final String startedValueBottom;
  final String targetLabel;
  final String targetValueTop;
  final String targetValueBottom;
  final Color barColor;

  const _GoalVm({
    required this.iconBg,
    required this.title,
    required this.category,
    required this.progress,
    required this.startedLabel,
    required this.startedValueTop,
    required this.startedValueBottom,
    required this.targetLabel,
    required this.targetValueTop,
    required this.targetValueBottom,
    required this.barColor,
  });
}

