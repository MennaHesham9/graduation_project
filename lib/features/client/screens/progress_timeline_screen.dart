import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class ProgressTimelineScreen extends StatelessWidget {
  const ProgressTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(context),
        Expanded(
          child: _buildBody(context),
        ),
      ],
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
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
      padding: const EdgeInsets.only(
        top: 48,
        left: 24,
        right: 24,
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 16,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Progress Timeline',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF101828),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 48),
            child: Text(
              'Your journey at a glance',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF4A5565),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Body ───────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.95, -1.0),
          end: Alignment(0.95, 1.0),
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFEFF6FF),
            Color(0xFFFDF2F8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          _buildTimeline(),
          const SizedBox(height: 24),
          _buildLoadEarlierButton(context),
        ],
      ),
    );
  }

  // ─── Timeline ───────────────────────────────────────────────────────────────

  Widget _buildTimeline() {
    const events = [
      _TimelineEvent(
        title: 'Coaching Session Completed',
        description: 'Video session with Dr. Michael Chen',
        date: 'Wednesday, Dec 3, 2025',
        time: '2:00 PM',
        gradientColors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
        iconType: _EventIcon.session,
      ),
      _TimelineEvent(
        title: 'Task Completed',
        description: 'Completed career assessment worksheet',
        date: 'Wednesday, Dec 3, 2025',
        time: '10:30 AM',
        gradientColors: [Color(0xFF00C950), Color(0xFF00BC7D)],
        iconType: _EventIcon.task,
      ),
      _TimelineEvent(
        title: 'Mood Entry',
        description: 'Feeling great after productive morning',
        date: 'Wednesday, Dec 3, 2025',
        time: '9:00 AM',
        gradientColors: [Color(0xFFF6339A), Color(0xFFFF2056)],
        iconType: _EventIcon.mood,
      ),
      _TimelineEvent(
        title: 'Goal Milestone Reached',
        description: 'Communication skills goal reached 75%',
        date: 'Tuesday, Dec 2, 2025',
        time: '5:00 PM',
        gradientColors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)],
        iconType: _EventIcon.goal,
      ),
      _TimelineEvent(
        title: 'Message from Coach',
        description: 'Dr. Chen sent you encouragement and tips',
        date: 'Tuesday, Dec 2, 2025',
        time: '11:00 AM',
        gradientColors: [Color(0xFFFF6900), Color(0xFFFE9A00)],
        iconType: _EventIcon.message,
      ),
      _TimelineEvent(
        title: 'Task Completed',
        description: 'Daily meditation practice logged',
        date: 'Monday, Dec 1, 2025',
        time: '7:00 AM',
        gradientColors: [Color(0xFF00C950), Color(0xFF00BC7D)],
        iconType: _EventIcon.task,
      ),
      _TimelineEvent(
        title: 'Coaching Session Completed',
        description: 'Discussed career transition strategies',
        date: 'Sunday, Nov 30, 2025',
        time: '3:00 PM',
        gradientColors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
        iconType: _EventIcon.session,
        isLast: true,
      ),
    ];

    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          // Vertical gradient line at x=24 (center of 48px dot)
          Positioned(
            left: 23,
            top: 24,
            bottom: 0,
            child: Container(
              width: 2,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFDAB2FF),
                    Color(0xFFFDA5D5),
                    Color(0xFF8EC5FF),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          // Event items
          Column(
            children: events
                .map((event) => _TimelineEventItem(event: event))
                .toList(),
          ),
        ],
      ),
    );
  }

  // ─── Load Earlier Button ────────────────────────────────────────────────────

  Widget _buildLoadEarlierButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Loading earlier events...'),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 28),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Text(
            'Load Earlier Events',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFF364153),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Timeline Event Item ────────────────────────────────────────────────────

class _TimelineEventItem extends StatelessWidget {
  final _TimelineEvent event;

  const _TimelineEventItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: event.isLast ? 0 : 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient circle icon (48×48), sits on top of the vertical line
          _buildDot(),
          const SizedBox(width: 16),
          // Card
          Expanded(child: _buildCard()),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: event.gradientColors,
        ),
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
      child: Icon(
        _iconData(event.iconType),
        size: 24,
        color: Colors.white,
      ),
    );
  }

  Widget _buildCard() {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row with time
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  event.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF101828),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  event.time,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6A7282),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Description
          Text(
            event.description,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0xFF4A5565),
              height: 1.43,
            ),
          ),
          const SizedBox(height: 10),
          // Date
          Text(
            event.date,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF6A7282),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconData(_EventIcon type) {
    switch (type) {
      case _EventIcon.session:
        return Icons.video_camera_front_outlined;
      case _EventIcon.task:
        return Icons.check_circle_outline_rounded;
      case _EventIcon.mood:
        return Icons.sentiment_satisfied_alt_outlined;
      case _EventIcon.goal:
        return Icons.flag_outlined;
      case _EventIcon.message:
        return Icons.chat_bubble_outline_rounded;
    }
  }
}

// ─── Data Models ────────────────────────────────────────────────────────────

enum _EventIcon { session, task, mood, goal, message }

class _TimelineEvent {
  final String title;
  final String description;
  final String date;
  final String time;
  final List<Color> gradientColors;
  final _EventIcon iconType;
  final bool isLast;

  const _TimelineEvent({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.gradientColors,
    required this.iconType,
    this.isLast = false,
  });
}