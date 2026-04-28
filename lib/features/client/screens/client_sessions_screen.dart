// lib/features/client/screens/client_sessions_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';          // ✅ AuthProvider
import '../../coach/screens/clients/manage_session_screen.dart';
import 'booking_screen.dart';
import 'coach_profile_client_side.dart';
import 'explore_coaches.dart';

class MyCoachSessionsScreen extends StatelessWidget {
  const MyCoachSessionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ AuthProvider, not AppAuthProvider
    final uid = context.read<AuthProvider>().user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: uid.isEmpty
                ? _NoCoachEmptyState()
                : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                if (!snap.hasData || !snap.data!.exists) {
                  return _NoCoachEmptyState();
                }

                final data =
                snap.data!.data() as Map<String, dynamic>;
                // ✅ myCoaches array from UserModel / Firestore
                final myCoaches =
                List<String>.from(data['myCoaches'] ?? []);

                if (myCoaches.isEmpty) {
                  return _NoCoachEmptyState();
                }

                // Load first assigned coach's document
                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(myCoaches.first)
                      .snapshots(),
                  builder: (context, coachSnap) {
                    if (coachSnap.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }
                    if (!coachSnap.hasData ||
                        !coachSnap.data!.exists) {
                      return _NoCoachEmptyState();
                    }

                    // ✅ UserModel.fromMap(uid, data) — your factory
                    final coach = UserModel.fromMap(
                      coachSnap.data!.id,
                      coachSnap.data!.data() as Map<String, dynamic>,
                    );
                    return _CoachSessionsBody(coach: coach);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

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
              child: const Icon(Icons.arrow_back,
                  size: 18, color: Colors.white),
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
                    color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                'Your coaching journey at a glance',
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.80)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── EMPTY STATE — no coach yet ─────────────────────────────────────────────────

class _NoCoachEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE6F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_search_outlined,
                size: 60,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Coach Assigned Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A0A0A),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't been connected with a coach yet. "
                  "Explore our coaches and send a coaching request to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ExploreCoachesScreen()),
                ),
                icon: const Icon(Icons.search),
                label: const Text(
                  'Explore Coaches',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── FULL BODY WHEN A COACH IS ASSIGNED ────────────────────────────────────────

class _CoachSessionsBody extends StatefulWidget {
  final UserModel coach;
  const _CoachSessionsBody({required this.coach});

  @override
  State<_CoachSessionsBody> createState() => _CoachSessionsBodyState();
}

class _CoachSessionsBodyState extends State<_CoachSessionsBody> {
  // Static week — replace with real session data when sessions feature lands
  final List<_CalendarDay> _weekDays = const [
    _CalendarDay(label: 'Mon', day: 2),
    _CalendarDay(label: 'Tue', day: 3, hasSession: true),
    _CalendarDay(label: 'Wed', day: 4),
    _CalendarDay(label: 'Thu', day: 5),
    _CalendarDay(label: 'Fri', day: 6),
    _CalendarDay(label: 'Sat', day: 7, hasSession: true, isSelected: true),
    _CalendarDay(label: 'Sun', day: 8),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      child: Column(
        children: [
          _buildCoachCard(context),
          const SizedBox(height: 20),
          _buildNextSessionCard(),
          const SizedBox(height: 20),
          _buildCalendarCard(),
          const SizedBox(height: 20),
          _buildSessionHistoryRow(),
          const SizedBox(height: 20),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  // ── COACH CARD ─────────────────────────────────────────────────────────────
  Widget _buildCoachCard(BuildContext context) {
    final coach = widget.coach;
    // ✅ correct field names
    final specialty =
        coach.professionalTitle ?? coach.coachingCategory ?? 'Life Coach';

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
              // Avatar
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: coach.photoUrl != null &&
                        coach.photoUrl!.isNotEmpty
                        ? Image.network(coach.photoUrl!,
                        width: 90, height: 90, fit: BoxFit.cover)
                        : Container(
                      width: 90,
                      height: 90,
                      color: const Color(0xFF2A7A7A),
                      child: Center(
                        child: Text(
                          coach.initials,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
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
                              blurRadius: 4),
                        ],
                      ),
                      child: Icon(Icons.verified,
                          size: 24, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 18),

              // Name + specialty + placeholder rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.fullName,   // ✅ fullName
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      specialty,
                      style: const TextStyle(
                          fontSize: 14,
                          color: Color(0x990A0A0A),
                          height: 1.4),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 18, color: Color(0xFFFFC107)),
                        const SizedBox(width: 3),
                        const Text('4.9',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Text('reviews',
                            style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Bio — only shown if present
          if (coach.bio != null && coach.bio!.isNotEmpty)
            Text(
              coach.bio!,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black54, height: 1.45),
            ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CoachProfileClientSide(coach: coach),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('View Profile',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: Icon(Icons.chat_bubble_outline,
                        size: 16, color: Colors.grey.shade700),
                    label: Text('Message',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade700)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
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

  // ── NEXT SESSION CARD ──────────────────────────────────────────────────────
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
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.videocam_outlined,
                    color: Colors.white, size: 22),
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
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Video Call with\n${widget.coach.fullName}', // ✅ fullName
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _infoRow(Icons.calendar_today_outlined, 'Not scheduled yet'),
          const SizedBox(height: 8),
          _infoRow(Icons.access_time, 'Book your first session below'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Tap "Book Session" below to get started',
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.90),
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.white.withValues(alpha: 0.90)),
          const SizedBox(width: 8),
          Text(text,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
        ],
      ),
    );
  }

  // ── CALENDAR CARD ──────────────────────────────────────────────────────────
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 22, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Sessions Calendar',
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays.map(_buildDayCell).toList(),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'No sessions scheduled yet.',
              style:
              TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
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
                color: day.isSelected
                    ? Colors.white
                    : const Color(0xFF0A0A0A),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
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

  // ── SESSION HISTORY ROW ────────────────────────────────────────────────────
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.description_outlined,
              size: 22, color: AppColors.primary),
          const SizedBox(width: 8),
          const Text('Session History',
              style:
              TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const Spacer(),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F5F5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '0 sessions',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTIONS ──────────────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildActionTile(
            icon: Icons.calendar_month_outlined,
            label: 'Book\nSession',
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BookingScreen())),
          ),
        ),
        const SizedBox(width: 12),
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
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ManageSessionScreen())),
          ),
        ),
        const SizedBox(width: 12),
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
                  height: 1.35),
            ),
          ],
        ),
      ),
    );
  }
}

// ── DATA MODEL ────────────────────────────────────────────────────────────────

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