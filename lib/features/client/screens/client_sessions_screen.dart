import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../booking/models/booking_model.dart';
import '../../booking/providers/booking_provider.dart';
import 'sessions/manage_session_screen.dart';


class ClientSessionsScreen extends StatefulWidget {
  const ClientSessionsScreen({super.key});

  @override
  State<ClientSessionsScreen> createState() => _ClientSessionsScreenState();
}

class _ClientSessionsScreenState extends State<ClientSessionsScreen>
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
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('My Sessions',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: const Color(0xFF4A90D9),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4A90D9),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _buildUpcomingTab(provider),
          _buildPastTab(provider),
        ],
      ),
    );
  }

  Widget _buildUpcomingTab(BookingProvider provider) {
    // Reschedule request banner
    final pending = provider.pendingReschedules;
    final upcoming = provider.upcomingSessions;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pending.isNotEmpty) ...[
          ...pending.map((s) => _RescheduleBanner(session: s)),
          const SizedBox(height: 8),
        ],
        if (upcoming.isEmpty)
          _EmptyState(
            icon: Icons.calendar_today_outlined,
            message: 'No upcoming sessions',
            sub: 'Book a session with your coach to get started',
          )
        else
          ...upcoming.map((s) => _SessionCard(session: s, isUpcoming: true)),
      ],
    );
  }

  Widget _buildPastTab(BookingProvider provider) {
    final past = provider.pastSessions;
    if (past.isEmpty) {
      return _EmptyState(
        icon: Icons.history_outlined,
        message: 'No past sessions',
        sub: 'Completed and cancelled sessions will appear here',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: past.length,
      itemBuilder: (_, i) =>
          _SessionCard(session: past[i], isUpcoming: false),
    );
  }
}

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
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF4A90D9).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isVideo
                    ? Icons.videocam_outlined
                    : Icons.headset_mic_outlined,
                color: const Color(0xFF4A90D9),
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
                      style: const TextStyle(
                          color: Color(0xFF4A90D9), fontSize: 12),
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
                        fontWeight: FontWeight.bold, color: Colors.orange)),
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
        color: color.withOpacity(0.1),
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

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String sub;
  const _EmptyState(
      {required this.icon, required this.message, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(message,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(sub,
                textAlign: TextAlign.center,
                style:
                const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}