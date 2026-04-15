import 'package:flutter/material.dart';

class StatCardsRow extends StatelessWidget {
  final String moodEmoji;
  final int tasksDone;
  final int totalTasks;

  const StatCardsRow({
    super.key,
    required this.moodEmoji,
    required this.tasksDone,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = w < 380 ? 16.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 0),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: "Today's Mood",
              value: moodEmoji,
              accent: const Color(0xFF2EC4B6),
              icon: Icons.favorite_border_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              title: 'Tasks Done',
              value: '$tasksDone / $totalTasks',
              accent: const Color(0xFF2F80ED),
              icon: Icons.check_box_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color accent;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    required this.accent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.0,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black.withValues(alpha: 0.60),
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

