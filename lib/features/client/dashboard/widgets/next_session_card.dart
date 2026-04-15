import 'package:flutter/material.dart';

class NextSessionCard extends StatelessWidget {
  final String doctorName;
  final String time;
  final VoidCallback onJoin;

  const NextSessionCard({
    super.key,
    required this.doctorName,
    required this.time,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = w < 380 ? 16.0 : 20.0;

    return Container(
      margin: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF2EC4B6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.videocam_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Session',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.black.withValues(alpha: 0.62),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctorName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.black.withValues(alpha: 0.50),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        time,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.black.withValues(alpha: 0.62),
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 34,
            child: ElevatedButton(
              onPressed: onJoin,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B9AAA),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                'Join Now',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

