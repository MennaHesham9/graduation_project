import 'package:flutter/material.dart';

import '../../screens/sessions/client_video_session_screen.dart';


class NextSessionCard extends StatelessWidget {
  final String doctorName;
  final String time;
  final String? sessionId;
  final DateTime? scheduledAt;
  final bool isVideoSession;
  final VoidCallback onJoin; // kept as fallback (e.g. audio sessions)

  const NextSessionCard({
    super.key,
    required this.doctorName,
    required this.time,
    required this.onJoin,
    this.sessionId,
    this.scheduledAt,
    this.isVideoSession = true,
  });

  bool get _canJoin {
    if (scheduledAt == null) return false;
    final diff = scheduledAt!.difference(DateTime.now()).inMinutes;
    return diff <= 5 && diff > -60; // within 5 min before, up to 60 min after start
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = w < 380 ? 16.0 : 20.0;
    final canJoin = _canJoin;

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
            child: Icon(
              isVideoSession ? Icons.videocam_rounded : Icons.headset_mic_rounded,
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
                    Icon(Icons.calendar_today_outlined,
                        size: 14, color: Colors.black.withValues(alpha: 0.50)),
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
              onPressed: canJoin && isVideoSession && sessionId != null
                  ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ClientVideoSessionScreen(
                    bookingId: sessionId!,
                    channelName: 'session_$sessionId',
                    coachName: doctorName,
                  ),
                ),
              )
                  : canJoin
                  ? onJoin   // audio session — handle separately
                  : null,    // greyed out, not time yet
              style: ElevatedButton.styleFrom(
                backgroundColor: canJoin
                    ? const Color(0xFF1B9AAA)
                    : Colors.grey.shade300,
                foregroundColor: canJoin ? Colors.white : Colors.grey.shade500,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                canJoin ? 'Join Now' : 'Soon',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}