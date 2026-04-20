import 'package:flutter/material.dart';

class GoalProgressSection extends StatelessWidget {
  final double communication;
  final double confidence;

  const GoalProgressSection({
    super.key,
    required this.communication,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = w < 380 ? 16.0 : 20.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 0),
      child: Container(
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
            Row(
              children: [
                Text(
                  'Goals Progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up_rounded,
                  color: const Color(0xFF2EC4B6),
                  size: 18,
                ),
              ],
            ),
            const SizedBox(height: 14),
            _GoalRow(
              label: 'Improve Communication',
              value: communication.clamp(0, 1),
              color: const Color(0xFF2EC4B6),
            ),
            const SizedBox(height: 14),
            _GoalRow(
              label: 'Build Confidence',
              value: confidence.clamp(0, 1),
              color: const Color(0xFF2F80ED),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _GoalRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withValues(alpha: 0.70),
                  ),
            ),
            const Spacer(),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) {
                final pct = (v * 100).round();
                return Text(
                  '$pct%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                      ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Container(
            height: 6,
            color: Colors.black.withValues(alpha: 0.08),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: value),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: v.clamp(0, 1),
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

