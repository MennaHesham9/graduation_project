// lib/features/client/screens/client_sessions_screen.dart

import 'package:flutter/material.dart';
import 'package:mindwell/features/client/screens/sessions/client_video_session_screen.dart';
import '../../../core/widgets/user_photo.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../booking/models/booking_model.dart';
import '../../booking/providers/booking_provider.dart';
import '../../questionnaire/models/questionnaire_model.dart';
import '../../questionnaire/screens/client_answer_questionnaire_screen.dart';
import '../../questionnaire/services/questionnaire_service.dart';
import '../booking/screens/select_plan_screen.dart';
import 'sessions/manage_session_screen.dart';
import 'coach_profile_client_side.dart';
import 'explore_coaches.dart';

class MyCoachSessionsScreen extends StatefulWidget {
  const MyCoachSessionsScreen({super.key});


  @override
  State<MyCoachSessionsScreen> createState() => _MyCoachSessionsScreenState();
}

class _MyCoachSessionsScreenState extends State<MyCoachSessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<BookingProvider>().listenToClientSessions(uid);
      }
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = context.read<AuthProvider>().user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: uid.isEmpty
                ? const _NoCoachEmptyState()
                : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || !snap.data!.exists) {
                  return const _NoCoachEmptyState();
                }

                final data =
                snap.data!.data() as Map<String, dynamic>;
                final myCoaches =
                List<String>.from(data['myCoaches'] ?? []);

                if (myCoaches.isEmpty) {
                  return const _NoCoachEmptyState();
                }

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
                      return const _NoCoachEmptyState();
                    }

                    final coach = UserModel.fromMap(
                      coachSnap.data!.id,
                      coachSnap.data!.data()
                      as Map<String, dynamic>,
                    );
                    return _CoachSessionsBody(
                      coach: coach,
                      tabs: _tabs,
                    );
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
        bottom: 0,
      ),
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 16),
          TabBar(
            controller: _tabs,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Past'),
            ],
          ),
        ],
      ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class _NoCoachEmptyState extends StatelessWidget {
  const _NoCoachEmptyState();

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
              decoration: const BoxDecoration(
                color: Color(0xFFE6F5F5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_search_outlined,
                  size: 60, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Coach Assigned Yet',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0A0A0A)),
            ),
            const SizedBox(height: 12),
            Text(
              "You haven't been connected with a coach yet. "
                  "Explore our coaches and send a coaching request to get started.",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade600, height: 1.5),
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
                label: const Text('Explore Coaches',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
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

// ── BODY WHEN COACH IS ASSIGNED ───────────────────────────────────────────────

class _CoachSessionsBody extends StatefulWidget {
  final UserModel coach;
  final TabController tabs;
  const _CoachSessionsBody({required this.coach, required this.tabs});

  @override
  State<_CoachSessionsBody> createState() => _CoachSessionsBodyState();
}

class _CoachSessionsBodyState extends State<_CoachSessionsBody> {
  // ── Calendar state ─────────────────────────────────────────────────────────
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay; // null = no day selected (show all upcoming)

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    return TabBarView(
      controller: widget.tabs,
      children: [
        _buildUpcomingTab(context, provider),
        _buildPastTab(provider),
      ],
    );
  }

  // ── UPCOMING TAB ──────────────────────────────────────────────────────────
  Widget _buildUpcomingTab(BuildContext context, BookingProvider provider) {
    final pending = provider.pendingReschedules;
    final allUpcoming = provider.upcomingSessions;

    // Filter sessions for the selected day (or show all)
    final filtered = _selectedDay == null
        ? allUpcoming
        : allUpcoming.where((s) {
      final local = s.scheduledAtUtc.toLocal();
      return local.year == _selectedDay!.year &&
          local.month == _selectedDay!.month &&
          local.day == _selectedDay!.day;
    }).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      child: Column(
        children: [
          // Reschedule banners
          if (pending.isNotEmpty) ...[
            ...pending.map((s) => _RescheduleBanner(session: s)),
            const SizedBox(height: 8),
          ],

          // ── Questionnaire banners ──────────────────────────────────
          _QuestionnaireBanner(clientId: context.read<AuthProvider>().user?.uid ?? ''),
          const SizedBox(height: 8),

          // Coach card
          _buildCoachCard(context),
          const SizedBox(height: 20),

          // Next session card
          _buildNextSessionCard(allUpcoming),
          const SizedBox(height: 20),

          // ── FULL DYNAMIC CALENDAR ──────────────────────────────────────
          _buildFullCalendarCard(allUpcoming, provider.pastSessions),
          const SizedBox(height: 20),

          // Sessions list (filtered by day or all)
          if (allUpcoming.isNotEmpty) ...[
            _buildSectionHeader(
              _selectedDay == null
                  ? 'All Upcoming Sessions'
                  : 'Sessions on ${DateFormat('MMM d').format(_selectedDay!)}',
              trailing: _selectedDay != null
                  ? GestureDetector(
                onTap: () => setState(() => _selectedDay = null),
                child: Text('Show all',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.primary)),
              )
                  : null,
            ),
            const SizedBox(height: 12),
            if (filtered.isEmpty)
              _buildNoSessionsOnDay()
            else
              ...filtered.map(
                      (s) => _SessionCard(session: s, isUpcoming: true)),
            const SizedBox(height: 8),
          ],

          // Quick actions
          _buildQuickActions(context, allUpcoming),
        ],
      ),
    );
  }

  // ── PAST TAB ──────────────────────────────────────────────────────────────
  Widget _buildPastTab(BookingProvider provider) {
    final past = provider.pastSessions;

    if (past.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_outlined,
                  size: 60, color: Colors.grey.shade300),
              const SizedBox(height: 16),
              const Text('No Past Sessions',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Completed and cancelled sessions will appear here',
                textAlign: TextAlign.center,
                style:
                TextStyle(color: Colors.grey.shade500, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 0),
          child: _buildSessionHistoryRow(past.length),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 32),
            itemCount: past.length,
            itemBuilder: (_, i) =>
                _SessionCard(session: past[i], isUpcoming: false),
          ),
        ),
      ],
    );
  }

  // ── FULL MONTH CALENDAR ───────────────────────────────────────────────────
  Widget _buildFullCalendarCard(
      List<BookingModel> upcoming, List<BookingModel> past) {
    final allSessions = [...upcoming, ...past];

    // Build a set of "yyyy-MM-dd" keys for days that have sessions
    final sessionDays = <String>{};
    for (final s in allSessions) {
      final local = s.scheduledAtUtc.toLocal();
      sessionDays.add(
          '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}');
    }

    final firstDay =
    DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
        _focusedMonth.year, _focusedMonth.month);
    // weekday: Mon=1, Sun=7 → we want Sun=0 offset
    final startOffset = (firstDay.weekday % 7);

    final today = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha:0.06),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(Icons.calendar_month_outlined,
                  size: 22, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Sessions Calendar',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              // Month navigation
              _MonthNavButton(
                icon: Icons.chevron_left,
                onTap: () => setState(() {
                  _focusedMonth = DateTime(
                      _focusedMonth.year, _focusedMonth.month - 1);
                  _selectedDay = null;
                }),
              ),
              const SizedBox(width: 4),
              Text(
                DateFormat('MMM yyyy').format(_focusedMonth),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 4),
              _MonthNavButton(
                icon: Icons.chevron_right,
                onTap: () => setState(() {
                  _focusedMonth = DateTime(
                      _focusedMonth.year, _focusedMonth.month + 1);
                  _selectedDay = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Day-of-week header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']
                .map((l) => SizedBox(
              width: 36,
              child: Center(
                child: Text(l,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 8),

          // Calendar grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: startOffset + daysInMonth,
            itemBuilder: (_, index) {
              if (index < startOffset) return const SizedBox();

              final day = index - startOffset + 1;
              final date = DateTime(
                  _focusedMonth.year, _focusedMonth.month, day);
              final key =
                  '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

              final isToday = DateUtils.isSameDay(date, today);
              final isSelected = _selectedDay != null &&
                  DateUtils.isSameDay(date, _selectedDay!);
              final hasSession = sessionDays.contains(key);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    // Tap same day = deselect (show all)
                    if (_selectedDay != null &&
                        DateUtils.isSameDay(date, _selectedDay!)) {
                      _selectedDay = null;
                    } else {
                      _selectedDay = date;
                    }
                  });
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                            ? AppColors.primary.withValues(alpha:0.12)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : isToday
                                ? AppColors.primary
                                : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Session dot
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: hasSession
                            ? (isSelected
                            ? Colors.white
                            : AppColors.primary)
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 12),

          // Summary row
          Row(
            children: [
              // Legend
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary),
                  ),
                  const SizedBox(width: 5),
                  const Text('Session day',
                      style:
                      TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
              const Spacer(),
              Text(
                _selectedDay != null
                    ? 'Tap day again to show all'
                    : upcoming.isEmpty
                    ? 'No upcoming sessions'
                    : '${upcoming.length} upcoming',
                style: TextStyle(
                  fontSize: 13,
                  color: upcoming.isEmpty
                      ? Colors.grey
                      : AppColors.primary,
                  fontWeight: upcoming.isEmpty
                      ? FontWeight.normal
                      : FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoSessionsOnDay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.event_available_outlined,
              size: 36, color: Colors.grey.shade300),
          const SizedBox(height: 8),
          Text(
            'No sessions on ${DateFormat('MMM d').format(_selectedDay!)}',
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── SECTION HEADER ────────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, {Widget? trailing}) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w700)),
        const Spacer(),
        if (trailing != null) trailing,
      ],
    );
  }

  // ── COACH CARD ────────────────────────────────────────────────────────────
  Widget _buildCoachCard(BuildContext context) {
    final coach = widget.coach;
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  UserPhoto.square(
                    photoUrl: coach.photoUrl,
                    initials: coach.initials,
                    size: 90,
                    borderRadius: 20,
                    backgroundColor: const Color(0xFF2A7A7A),
                    initialsStyle: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coach.fullName,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0A0A0A)),
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
          if (coach.bio != null && coach.bio!.isNotEmpty)
            Text(coach.bio!,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.45)),
          const SizedBox(height: 16),
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
                              CoachProfileClientSide(coach: coach)),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
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
                            fontSize: 14,
                            color: Colors.grey.shade700)),
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

  // ── NEXT SESSION CARD ─────────────────────────────────────────────────────
  Widget _buildNextSessionCard(List<BookingModel> upcoming) {
    final next = upcoming.isNotEmpty ? upcoming.first : null;
    final isVideo = next?.type == SessionType.video;

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
              offset: const Offset(0, 6)),
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
                child: Icon(
                  next != null
                      ? (isVideo
                      ? Icons.videocam_outlined
                      : Icons.headset_mic_outlined)
                      : Icons.videocam_outlined,
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
                        fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    next != null
                        ? '${isVideo ? 'Video' : 'Audio'} Call with\n${widget.coach.fullName}'
                        : 'Video Call with\n${widget.coach.fullName}',
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
          if (next != null) ...[
            _infoRow(
              Icons.calendar_today_outlined,
              DateFormat('EEE, MMM d · h:mm a')
                  .format(next.scheduledAtUtc.toLocal()),
            ),
            const SizedBox(height: 8),
            _infoRow(
              Icons.info_outline,
              next.planType == PlanType.package &&
                  next.sessionIndexInPackage != null
                  ? 'Session ${next.sessionIndexInPackage} of ${next.packageSize}'
                  : 'Single Session',
            ),
            const SizedBox(height: 12),
            // replace everything from `const SizedBox(height: 12),` before the
// 'Manage Session →' GestureDetector with this:

            const SizedBox(height: 12),

// Join button — only for video sessions, active 5 min before start
            if (isVideo) ...[
              Builder(builder: (_) {
                final diff = next.scheduledAtUtc.toLocal()
                    .difference(DateTime.now()).inMinutes;
                final canJoin = diff <= 5 && diff > -60;
                return ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canJoin ? Colors.white : Colors.white24,
                    foregroundColor: canJoin
                        ? AppColors.primary
                        : Colors.white60,
                    minimumSize: const Size(double.infinity, 44),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.videocam_rounded, size: 18),
                  label: Text(
                    canJoin ? 'Join Session Now' : 'Join Session (opens 5 min before)',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  onPressed: canJoin
                      ? () => Navigator.push(
                    context,
                    ClientVideoSessionScreen.route(
                      bookingId: next.id,
                      channelName: 'session_${next.id}',
                      coachName: widget.coach.fullName,
                    ),
                  )
                      : null,
                );
              }),
              const SizedBox(height: 8),
            ],

// Manage Session always stays below
            GestureDetector(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => ManageSessionScreen(session: next))),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    'Manage Session →',
                    style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ] else ...[
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
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── SESSION HISTORY ROW ───────────────────────────────────────────────────
  Widget _buildSessionHistoryRow(int count) {
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
              '$count session${count != 1 ? 's' : ''}',
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

  // ── QUICK ACTIONS ─────────────────────────────────────────────────────────
  Widget _buildQuickActions(
      BuildContext context, List<BookingModel> upcoming) {
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
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        SelectPlanScreen(coach: widget.coach))),
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
            onTap: upcoming.isNotEmpty
                ? () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ManageSessionScreen(
                        session: upcoming.first)))
                : null,
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
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: isDisabled ? 0.5 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 22),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: isDisabled
                ? []
                : [
              BoxShadow(
                color:
                gradient.colors.first.withValues(alpha: 0.30),
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
      ),
    );
  }
}

// ── SMALL HELPER WIDGET ───────────────────────────────────────────────────────

class _MonthNavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthNavButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.black54),
      ),
    );
  }
}

// ── SESSION CARD ──────────────────────────────────────────────────────────────

class _SessionCard extends StatelessWidget {
  final BookingModel session;
  final bool isUpcoming;
  const _SessionCard({required this.session, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final localTime = session.scheduledAtUtc.toLocal();
    final isVideo = session.type == SessionType.video;

    return GestureDetector(
      onTap: isUpcoming
          ? () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ManageSessionScreen(session: session)),
      )
          : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isVideo
                    ? Icons.videocam_outlined
                    : Icons.headset_mic_outlined,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session.coachName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEE, MMM d · h:mm a').format(localTime),
                    style:
                    const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  if (session.planType == PlanType.package &&
                      session.sessionIndexInPackage != null)
                    Text(
                      'Session ${session.sessionIndexInPackage} of ${session.packageSize}',
                      style: TextStyle(
                          color: AppColors.primary, fontSize: 12),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _StatusChip(session.status),
                if (isUpcoming) ...[
                  const SizedBox(height: 6),
                  const Icon(Icons.chevron_right,
                      color: Colors.grey, size: 20),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── RESCHEDULE BANNER ─────────────────────────────────────────────────────────

class _RescheduleBanner extends StatelessWidget {
  final BookingModel session;
  const _RescheduleBanner({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz, color: Colors.orange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Reschedule Request',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange)),
                const SizedBox(height: 2),
                Text('${session.coachName} proposed new times.',
                    style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ManageSessionScreen(session: session)),
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}

// ── STATUS CHIP ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final SessionStatus status;
  const _StatusChip(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case SessionStatus.confirmed:
        color = Colors.green;
        label = 'Confirmed';
        break;
      case SessionStatus.rescheduled:
        color = Colors.orange;
        label = 'Rescheduled';
        break;
      case SessionStatus.completed:
        color = Colors.blue;
        label = 'Completed';
        break;
      case SessionStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
      case SessionStatus.missed:
        color = Colors.grey;
        label = 'Missed';
        break;
      default:
        color = Colors.grey;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600)),
    );
  }
}
// ── QUESTIONNAIRE BANNER ──────────────────────────────────────────────────────

class _QuestionnaireBanner extends StatefulWidget {
  final String clientId;
  const _QuestionnaireBanner({required this.clientId});

  @override
  State<_QuestionnaireBanner> createState() => _QuestionnaireBannerState();
}

class _QuestionnaireBannerState extends State<_QuestionnaireBanner> {
  late final Stream<List<QuestionnaireModel>> _stream;

  @override
  void initState() {
    super.initState();
    if (widget.clientId.isNotEmpty) {
      _stream = QuestionnaireService().streamForClient(widget.clientId);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.clientId.isEmpty) return const SizedBox.shrink();

    return StreamBuilder<List<QuestionnaireModel>>(
      stream: _stream,
      builder: (context, snap) {
        // While waiting for first data, show nothing (avoid flash).
        if (snap.connectionState == ConnectionState.waiting &&
            !snap.hasData) {
          return const SizedBox.shrink();
        }
        final pending = (snap.data ?? [])
            .where((q) => !q.isAnswered)
            .toList();

        if (pending.isEmpty) return const SizedBox.shrink();

        return Column(
          children: pending.map((q) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _QuestionnaireCard(questionnaire: q),
          )).toList(),
        );
      },
    );
  }
}

class _QuestionnaireCard extends StatelessWidget {
  final QuestionnaireModel questionnaire;
  const _QuestionnaireCard({required this.questionnaire});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ClientAnswerQuestionnaireScreen(
              questionnaire: questionnaire),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha:0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment_outlined,
                  size: 22, color: Colors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Questionnaire Pending',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    questionnaire.title,
                    style: TextStyle(fontSize: 12,
                        color: Colors.white.withValues(alpha:0.85)),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'From ${questionnaire.coachName} · ${questionnaire.questions.length} questions',
                    style: TextStyle(fontSize: 11,
                        color: Colors.white.withValues(alpha:0.7)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Answer',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                      color: Color(0xFF7C3AED))),
            ),
          ],
        ),
      ),
    );
  }
}