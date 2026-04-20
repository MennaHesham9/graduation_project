import 'package:flutter/material.dart';

class DashboardHeaderCard extends StatelessWidget {
  final String userName;
  final VoidCallback onBellTap;

  const DashboardHeaderCard({
    super.key,
    required this.userName,
    required this.onBellTap,
  });

  static const _c1 = Color(0xFF2EC4B6);
  static const _c2 = Color(0xFF1B9AAA);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = w < 380 ? 16.0 : 20.0;
    final radius = BorderRadius.circular(24);

    return Container(
      margin: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 0),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_c1, _c2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 56),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $userName 👋',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Let's make today amazing",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600,
                        height: 1.15,
                      ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                      children: [
                        TextSpan(
                          text: '“The only way to do great work is to love\nwhat you do.”  ',
                          style: const TextStyle(fontStyle: FontStyle.italic),
                        ),
                        TextSpan(
                          text: '— Steve Jobs',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.white.withValues(alpha: 0.92),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBellTap,
                borderRadius: BorderRadius.circular(999),
                child: Ink(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.22),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    color: Colors.white.withValues(alpha: 0.95),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

