import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../booking/models/booking_model.dart';
import '../../booking/providers/booking_provider.dart';
import '../booking/screens/select_plan_screen.dart';
import 'sessions/manage_session_screen.dart'; // Updated path
import 'coach_profile_client_side.dart';
import 'explore_coaches.dart';

class ClientSessionsScreen extends StatefulWidget {
  const ClientSessionsScreen({super.key});

  @override
  State<ClientSessionsScreen> createState() => _ClientSessionsScreenState();
}

class _ClientSessionsScreenState extends State<ClientSessionsScreen> {
  @override
  void initState() {
    super.initState();
    // ✅ Logic: Start listening to real session data when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().user?.uid;
      if (uid != null) {
        context.read<BookingProvider>().listenToClientSessions(uid);
      }
    });
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

                final data = snap.data!.data() as Map<String, dynamic>;
                final myCoaches = List<String>.from(data['myCoaches'] ?? []);

                if (myCoaches.isEmpty) {
                  return const _NoCoachEmptyState();
                }

                return StreamBuilder<DocumentSnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(myCoaches.first)
                      .snapshots(),
                  builder: (context, coachSnap) {
                    if (coachSnap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!coachSnap.hasData || !coachSnap.data!.exists) {
                      return const _NoCoachEmptyState();
                    }

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
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, size: 18, color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Coach & Sessions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
              SizedBox(height: 2),
              Text('Your coaching journey at a glance',
                  style: TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoachSessionsBody extends StatelessWidget {
  final UserModel coach;
  const _CoachSessionsBody({required this.coach});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    // ✅ Logic: Find the very next upcoming session
    final nextSession = provider.upcomingSessions.isNotEmpty ? provider.upcomingSessions.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      child: Column(
        children: [
          _buildCoachCard(context),
          const SizedBox(height: 20),
          _buildNextSessionCard(context, nextSession),
          const SizedBox(height: 20),
          _buildCalendarCard(provider),
          const SizedBox(height: 20),
          _buildSessionHistoryRow(provider.pastSessions.length),
          const SizedBox(height: 20),
          _buildQuickActions(context),
        ],
      ),
    );
  }

  // ── COACH CARD (Keep Old UI) ──────────────────────────────────────────────
  Widget _buildCoachCard(BuildContext context) {
    final specialty = coach.professionalTitle ?? coach.coachingCategory ?? 'Life Coach';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: coach.photoUrl != null && coach.photoUrl!.isNotEmpty
                    ? Image.network(coach.photoUrl!, width: 80, height: 80, fit: BoxFit.cover)
                    : Container(width: 80, height: 80, color: AppColors.primary, child: Center(child: Text(coach.initials, style: const TextStyle(fontSize: 28, color: Colors.white)))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(coach.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(specialty, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CoachProfileClientSide(coach: coach))),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('View Profile', style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── NEXT SESSION CARD (Merged Real Logic) ──────────────────────────────────
  Widget _buildNextSessionCard(BuildContext context, BookingModel? session) {
    final bool hasSession = session != null;
    final String title = hasSession ? 'Upcoming Video Call' : 'Next Session';
    final String subtitle = hasSession
        ? DateFormat('EEEE, MMM d · h:mm a').format(session.scheduledAtUtc.toLocal())
        : 'Not scheduled yet';

    return GestureDetector(
      onTap: hasSession ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => ManageSessionScreen(session: session))) : null,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.videocam_outlined, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8))),
                    const SizedBox(height: 2),
                    Text(hasSession ? 'Call with ${coach.fullName}' : 'No Sessions Booked',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(Icons.calendar_today_outlined, subtitle),
            const SizedBox(height: 8),
            _infoRow(Icons.access_time, hasSession ? '${session.durationMinutes} Minutes' : 'Book your first session below'),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.18), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
        ],
      ),
    );
  }

  // ── CALENDAR CARD (Using real dots for session days) ──────────────────────
  Widget _buildCalendarCard(BookingProvider provider) {
    // Note: In a full version, we'd calculate which of these 7 days have sessions
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 22, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('Sessions Calendar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          // We keep the old UI day cells
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _generateWeekDays(provider).map((d) => _buildDayCell(d)).toList(),
          ),
        ],
      ),
    );
  }

  List<_CalendarDay> _generateWeekDays(BookingProvider provider) {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      final hasSession = [
        ...provider.upcomingSessions,
        ...provider.pastSessions
      ].any((s) =>
      s.scheduledAtUtc.day == date.day &&
          s.scheduledAtUtc.month == date.month &&
          s.scheduledAtUtc.year == date.year // Also check year for accuracy
      );
      return _CalendarDay(
        label: DateFormat('E').format(date),
        day: date.day,
        hasSession: hasSession,
        isSelected: i == 0,
      );
    });
  }

  Widget _buildDayCell(_CalendarDay day) {
    return Column(
      children: [
        Text(day.label, style: TextStyle(fontSize: 12, color: day.isSelected ? AppColors.primary : Colors.grey)),
        const SizedBox(height: 6),
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: day.isSelected ? AppColors.primary : Colors.transparent, shape: BoxShape.circle),
          child: Center(child: Text('${day.day}', style: TextStyle(color: day.isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(height: 4),
        if (day.hasSession) Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
      ],
    );
  }

  // ── QUICK ACTIONS (The Gradients you liked) ────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _buildActionTile(
          icon: Icons.calendar_month_outlined, label: 'Book\nSession',
          gradient: const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF42A5F5)]),
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SelectPlanScreen(coach: coach))),
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildActionTile(
          icon: Icons.manage_history_outlined, label: 'Manage\nSession',
          gradient: LinearGradient(colors: [AppColors.primary, const Color(0xFF26C6DA)]),
          onTap: () {
            // Take them to the tabbed view if they want to see all sessions
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ClientSessionsScreen()));
          },
        )),
      ],
    );
  }

  Widget _buildActionTile({required IconData icon, required String label, required LinearGradient gradient, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(18)),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionHistoryRow(int count) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const Icon(Icons.history, color: Colors.grey),
          const SizedBox(width: 12),
          const Text('Session History', style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('$count sessions', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// ── REUSABLE COMPONENTS (Empty States & Data Models) ──────────────────────────

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
            Icon(Icons.person_search_outlined, size: 80, color: AppColors.primary.withOpacity(0.2)),
            const SizedBox(height: 20),
            const Text('No Coach Assigned Yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Explore our coaches to get started.', textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ExploreCoachesScreen())),
              child: const Text('Explore Coaches'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarDay {
  final String label;
  final int day;
  final bool hasSession;
  final bool isSelected;
  const _CalendarDay({required this.label, required this.day, this.hasSession = false, this.isSelected = false});
}