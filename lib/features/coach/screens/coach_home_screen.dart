import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'coach_calandar_screen.dart';
import 'coach_clients_screen.dart';
import 'coach_wallet_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/screens/notification_screen.dart';

// ─── Data Models ─────────────────────────────────────────────────────────────

class _TodaySession {
  final String clientName;
  final String time;
  final String topic;
  final bool isActive;

  const _TodaySession({
    required this.clientName,
    required this.time,
    required this.topic,
    this.isActive = false,
  });
}

class _QuickAction {
  final String label;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  final Widget? destination;

  const _QuickAction({
    required this.label,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    this.destination,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CoachHomeScreen extends StatefulWidget {
  const CoachHomeScreen({super.key});

  @override
  State<CoachHomeScreen> createState() => _CoachHomeScreenState();
}

class _CoachHomeScreenState extends State<CoachHomeScreen> {

  // ── Static data ────────────────────────────────────────────────────────────
  static final List<_TodaySession> _sessions = const [
    _TodaySession(
      clientName: 'Sarah Johnson',
      time: '2:00 PM',
      topic: 'Career Transition Coaching',
      isActive: true,
    ),
    _TodaySession(
      clientName: 'James Miller',
      time: '4:00 PM',
      topic: 'Life Balance Assessment',
    ),
    _TodaySession(
      clientName: 'Emma Davis',
      time: '6:00 PM',
      topic: 'Relationship Coaching',
    ),
  ];

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.65, -1),
            end: Alignment(1, 1),
            colors: [
              Color(0xFFFAF5FF),
              Color(0xFFEFF6FF),
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeroHeader(context),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    children: [
                      _buildSessionsCard(context),
                      const SizedBox(height: 20),
                      _buildQuickActionsGrid(context),
                      const SizedBox(height: 20),
                      _buildPerformanceCard(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero Header ────────────────────────────────────────────────────────────
  Widget _buildHeroHeader(BuildContext context) {
    final fullName =
        context.watch<AuthProvider>().user?.fullName ?? 'Coach';
    final firstName = fullName.trim().split(' ').first;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(1, 1),
          colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, $firstName 👋',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Here's your coaching overview",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xE6FFFFFF),
                        height: 1.43,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationScreen()),
                ),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _statCard(value: '24', label: 'Active\nClients'),
              const SizedBox(width: 12),
              _statCard(value: '\$3.2k', label: 'This Month'),
              const SizedBox(width: 12),
              _statCard(value: '5', label: 'Today'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCard({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xE6FFFFFF),
                height: 1.33,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Today's Sessions Card ──────────────────────────────────────────────────
  Widget _buildSessionsCard(BuildContext context) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Sessions",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                  height: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CoachCalendarScreen(),
                  ),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  size: 20,
                  color: Color(0xFF4A5565),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: _sessions.asMap().entries.map((entry) {
              final i = entry.key;
              final session = entry.value;
              return Padding(
                padding: EdgeInsets.only(
                    bottom: i < _sessions.length - 1 ? 12 : 0),
                child: session.isActive
                    ? _activeSessionTile(context, session)
                    : _upcomingSessionTile(session),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _activeSessionTile(
      BuildContext context, _TodaySession session) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.8, -1),
          end: Alignment(1, 1),
          colors: [Color(0xFFEFF6FF), Color(0xFFECFEFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          left: BorderSide(color: Color(0xFF2B7FFF), width: 4),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(session.clientName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828))),
              Text(session.time,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF155DFC),
                      fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(session.topic,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5565),
                    height: 1.43)),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(-0.8, -1),
                    end: Alignment(1, 1),
                    colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4)),
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2)),
                  ],
                ),
                child: const Text('Start Session',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _upcomingSessionTile(_TodaySession session) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(session.clientName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828))),
              Text(session.time,
                  style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4A5565),
                      height: 1.43)),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(session.topic,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5565),
                    height: 1.43)),
          ),
        ],
      ),
    );
  }

  // ── Quick Actions Grid ─────────────────────────────────────────────────────
  Widget _buildQuickActionsGrid(BuildContext context) {
    final actions = [
      _QuickAction(
        label: 'Clients',
        subtitle: 'Manage client profiles',
        gradientColors: const [Color(0xFF2F8F9D), Color(0xFF1E6091)],
        icon: Icons.people_outline_rounded,
        destination: const CoachClientsScreen(),
      ),
      _QuickAction(
        label: 'Calendar',
        subtitle: 'View schedule',
        gradientColors: const [Color(0xFF51A2FF), Color(0xFF00D3F3)],
        icon: Icons.calendar_today_outlined,
        destination: const CoachCalendarScreen(),
      ),
      _QuickAction(
        label: 'Wallet',
        subtitle: 'Earnings & payouts',
        gradientColors: const [Color(0xFF05DF72), Color(0xFF00D492)],
        icon: Icons.account_balance_wallet_outlined,
        destination: const CoachWalletScreen(),
      ),
      _QuickAction(
        label: 'Messages',
        subtitle: 'Client communications',
        gradientColors: const [Color(0xFFFF8904), Color(0xFFFFB900)],
        icon: Icons.chat_bubble_outline_rounded,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: actions
          .map((action) => _quickActionCard(context, action))
          .toList(),
    );
  }

  Widget _quickActionCard(BuildContext context, _QuickAction action) {
    return GestureDetector(
      onTap: action.destination != null
          ? () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => action.destination!))
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 10)),
            BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 4)),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: action.gradientColors,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child:
              Icon(action.icon, color: Colors.white, size: 24),
            ),
            const Spacer(),
            Text(action.label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                    height: 1.5)),
            const SizedBox(height: 4),
            Text(action.subtitle,
                style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF4A5565),
                    height: 1.33)),
          ],
        ),
      ),
    );
  }

  // ── Performance Card ───────────────────────────────────────────────────────
  Widget _buildPerformanceCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("This Month's Performance",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF101828),
                      height: 1.5)),
              Icon(Icons.bar_chart_rounded,
                  size: 20, color: Color(0xFF4A5565)),
            ],
          ),
          const SizedBox(height: 16),
          _progressRow(
            label: 'Sessions Completed',
            value: '28/30',
            fraction: 28 / 30,
            gradientColors: const [
              Color(0xFF2B7FFF),
              Color(0xFF00B8DB)
            ],
          ),
          const SizedBox(height: 12),
          _progressRow(
            label: 'Client Satisfaction',
            value: '4.9/5.0',
            fraction: 4.9 / 5.0,
            gradientColors: const [
              Color(0xFF00C950),
              Color(0xFF00BC7D)
            ],
          ),
        ],
      ),
    );
  }

  Widget _progressRow({
    required String label,
    required String value,
    required double fraction,
    required List<Color> gradientColors,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF4A5565),
                    height: 1.43)),
            Text(value,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                    height: 1.43)),
          ],
        ),
        const SizedBox(height: 4),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
                Container(
                  height: 8,
                  width: constraints.maxWidth * fraction,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradientColors),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // ── Shared Glass Card ──────────────────────────────────────────────────────
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 25,
              offset: const Offset(0, 20)),
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 8)),
        ],
      ),
      child: child,
    );
  }
}