import 'package:flutter/material.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onMyCoachesSessions;
  final VoidCallback onExploreCoaches;
  final VoidCallback onAssessments;

  const ActionButtonsRow({
    super.key,
    required this.onMyCoachesSessions,
    required this.onExploreCoaches,
    required this.onAssessments,
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
            child: _ActionCard(
              title: 'My Coaches & Sessions',
              icon: Icons.radio_button_checked_rounded,
              color: const Color(0xFF1E6091),
              onTap: onExploreCoaches,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionCard(
              title: 'Explore Coaches',
              icon: Icons.radio_button_checked_rounded,
              color: const Color(0xFF2ECC71),
              onTap: onExploreCoaches,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ActionCard(
              title: 'Assessments',
              icon: Icons.auto_awesome_outlined,
              color: const Color(0xFFF39C12),
              onTap: onAssessments,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
            color: Colors.white,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black.withValues(alpha: 0.70),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

