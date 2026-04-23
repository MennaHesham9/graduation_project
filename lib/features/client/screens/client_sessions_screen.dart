import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../coach/screens/clients/manage_session_screen.dart';
import 'booking_screen.dart';

class MyCoachSessionsScreen extends StatefulWidget {
  const MyCoachSessionsScreen({super.key});

  @override
  State<MyCoachSessionsScreen> createState() => _MyCoachSessionsScreenState();
}

class _MyCoachSessionsScreenState extends State<MyCoachSessionsScreen> {
  // Calendar: week days centered on Saturday (index=5 = Sat 7)
  final List<_CalendarDay> _weekDays = const [
    _CalendarDay(label: 'Mon', day: 2, hasSession: false),
    _CalendarDay(label: 'Tue', day: 3, hasSession: true),
    _CalendarDay(label: 'Wed', day: 4, hasSession: false),
    _CalendarDay(label: 'Thu', day: 5, hasSession: false),
    _CalendarDay(label: 'Fri', day: 6, hasSession: false),
    _CalendarDay(label: 'Sat', day: 7, hasSession: true, isSelected: true),
    _CalendarDay(label: 'Sun', day: 8, hasSession: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          // Teal header
          _buildHeader(context),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
              child: Column(
                children: [
                  // Coach info card
                  _buildCoachCard(),
                  const SizedBox(height: 20),

                  // Next session card
                  _buildNextSessionCard(),
                  const SizedBox(height: 20),

                  // Sessions calendar card
                  _buildCalendarCard(),
                  const SizedBox(height: 20),

                  // Session history row
                  _buildSessionHistoryRow(),
                  const SizedBox(height: 20),

                  // Quick action buttons
                  _buildQuickActions(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── HEADER ───────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 16,
        right: 16,
        bottom: 24,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 18,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Coach & Sessions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Your coaching journey at a glance',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── COACH CARD ───────────────────────────────────────────────────────────

  Widget _buildCoachCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar — bigger
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A7A7A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Text('👨‍⚕️', style: TextStyle(fontSize: 44)),
                    ),
                  ),
                  // Verified badge
                  Positioned(
                    bottom: -7,
                    right: -7,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.10),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.verified,
                        size: 24,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),

              // Name, title, rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dr. Michael Chen',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Clinical Psychologist & Life Coach',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0x990A0A0A),
                        height: 1.4,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 18, color: Color(0xFFFFC107)),
                        const SizedBox(width: 3),
                        const Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A0A0A),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(127 reviews)',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Bio
          Text(
            'Helping professionals find balance and purpose in their careers',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 16),

          // Buttons
          Row(
            children: [
              // View Profile - teal filled
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'View Profile',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Message - outlined
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(
                      Icons.chat_bubble_outline,
                      size: 16,
                      color: Colors.grey.shade700,
                    ),
                    label: Text(
                      'Message',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── NEXT SESSION CARD ────────────────────────────────────────────────────

  Widget _buildNextSessionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + video icon
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.videocam_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Next Session',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.80),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Video Call with Dr.\nMichael Chen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 15, color: Colors.white.withValues(alpha: 0.90)),
                const SizedBox(width: 8),
                const Text(
                  'December 7, 2025',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'In 2 days',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Time row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: 15, color: Colors.white.withValues(alpha: 0.90)),
                const SizedBox(width: 8),
                const Text(
                  '2:00 PM • 60 min',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Session starts in X days - bottom pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Session starts in 2 days',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.90),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CALENDAR CARD ────────────────────────────────────────────────────────

  Widget _buildCalendarCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 22, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Sessions Calendar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Week row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map((d) => _buildDayCell(d)).toList(),
          ),

          const SizedBox(height: 16),

          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),

          // Session entry
          Row(
            children: [
              Icon(Icons.access_time_outlined,
                  size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2:00 PM',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  Text(
                    'Dr. Michael Chen',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F5F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Upcoming',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(_CalendarDay day) {
    return Column(
      children: [
        Text(
          day.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: day.isSelected ? AppColors.primary : Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: day.isSelected ? AppColors.primary : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: day.isSelected ? Colors.white : const Color(0xFF0A0A0A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        // Dot indicator for sessions
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: day.hasSession
                ? (day.isSelected ? Colors.white : AppColors.primary)
                : Colors.transparent,
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }

  // ─── SESSION HISTORY ROW ──────────────────────────────────────────────────

  Widget _buildSessionHistoryRow() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined, size: 22, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text(
            'Session History',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0A0A0A),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '4 sessions',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── QUICK ACTIONS ────────────────────────────────────────────────────────

  Widget _buildQuickActions() {
    return Row(
      children: [
        // Book Session — blue gradient
        Expanded(
          child: _buildActionTile(
            icon: Icons.calendar_month_outlined,
            label: 'Book\nSession',
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookingScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Manage Session — teal gradient
        Expanded(
          child: _buildActionTile(
            icon: Icons.manage_history_outlined,
            label: 'Manage\nSession',
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.85),
                const Color(0xFF26C6DA),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageSessionScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // Session Notes — green gradient
        Expanded(
          child: _buildActionTile(
            icon: Icons.note_alt_outlined,
            label: 'Session\nNotes',
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withValues(alpha: 0.30),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DATA MODELS ─────────────────────────────────────────────────────────────

class _CalendarDay {
  final String label;
  final int day;
  final bool hasSession;
  final bool isSelected;

  const _CalendarDay({
    required this.label,
    required this.day,
    this.hasSession = false,
    this.isSelected = false,
  });
}