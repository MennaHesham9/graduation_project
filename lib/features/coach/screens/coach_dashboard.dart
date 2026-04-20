import 'package:flutter/material.dart';
import 'calendar_screen.dart';

void main() {
  runApp(const MindWellApp());
}

class MindWellApp extends StatelessWidget {
  const MindWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindWell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const CoachDashboard(),
    );
  }
}

class CoachDashboard extends StatefulWidget {
  const CoachDashboard({super.key});

  @override
  State<CoachDashboard> createState() => _CoachDashboardState();
}

class _CoachDashboardState extends State<CoachDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── HEADER ──
              _buildHeader(),

              // ── STATS ROW ──
              _buildStatsRow(),

              const SizedBox(height: 14),

              // ── TODAY'S SESSIONS ──
              _buildTodaysSessions(),

              const SizedBox(height: 14),

              // ── QUICK ACCESS GRID ──
              _buildQuickAccess(),

              const SizedBox(height: 14),

              // ── PERFORMANCE ──
              _buildPerformance(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─────────────────────────────────────────────
  // HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F8F9D),
            Color(0xFF1EAABB),
            Color(0xFF1A7FA8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Text(
                      'Welcome back, Dr. Chen ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text('👋', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  "Here's your coaching overview",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.settings_outlined,
                color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // STATS ROW
  // ─────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2F8F9D),
            Color(0xFF1EAABB),
            Color(0xFF1A7FA8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
      child: Row(
        children: [
          _StatCard(value: '24', label: 'Active\nClients'),
          const SizedBox(width: 10),
          _StatCard(value: '\$3.2k', label: 'This Month'),
          const SizedBox(width: 10),
          _StatCard(value: '5', label: 'Today'),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // TODAY'S SESSIONS
  // ─────────────────────────────────────────────
  Widget _buildTodaysSessions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Today's Sessions",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Icon(Icons.access_time_rounded,
                      color: const Color(0xFF1EAABB), size: 20),
                ],
              ),
            ),

            // Session 1 — active (highlighted)
            _SessionTile(
              name: 'Sarah Johnson',
              time: '2:00 PM',
              subtitle: 'Career Transition Coaching',
              isActive: true,
            ),

            _divider(),

            // Session 2
            _SessionTile(
              name: 'James Miller',
              time: '4:00 PM',
              subtitle: 'Life Balance Assessment',
              isActive: false,
            ),

            _divider(),

            // Session 3
            _SessionTile(
              name: 'Emma Davis',
              time: '6:00 PM',
              subtitle: 'Relationship Coaching',
              isActive: false,
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    thickness: 0.8,
    indent: 16,
    endIndent: 16,
    color: Color(0xFFF0F0F0),
  );

  // ─────────────────────────────────────────────
  // QUICK ACCESS GRID
  // ─────────────────────────────────────────────
  Widget _buildQuickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: _QuickCard(
                  icon: Icons.people_alt_outlined,
                  label: 'Clients',
                  sublabel: 'Manage client profiles',
                  iconBg: Color(0xFFE8F4FF),
                  iconColor: Color(0xFF3B82F6),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Calendar',
                  sublabel: 'View schedule',
                  iconBg: Color(0xFFE6F7FF),
                  iconColor: Color(0xFF1EAABB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _QuickCard(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Wallet',
                  sublabel: 'Earnings & payouts',
                  iconBg: Color(0xFFE8FFF0),
                  iconColor: Color(0xFF22C55E),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Messages',
                  sublabel: 'Client communications',
                  iconBg: Color(0xFFFFF3E0),
                  iconColor: Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // PERFORMANCE
  // ─────────────────────────────────────────────
  Widget _buildPerformance() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "This Month's Performance",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Icon(Icons.trending_up_rounded,
                    color: const Color(0xFF22C55E), size: 20),
              ],
            ),
            const SizedBox(height: 16),

            // Sessions Completed
            _ProgressRow(
              label: 'Sessions Completed',
              valueText: '28/30',
              progress: 28 / 30,
              color: const Color(0xFF1EAABB),
            ),

            const SizedBox(height: 14),

            // Client Satisfaction
            _ProgressRow(
              label: 'Client Satisfaction',
              valueText: '4.9/5.0',
              progress: 4.9 / 5.0,
              color: const Color(0xFF22C55E),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Calendar'},
      {'icon': Icons.people_alt_outlined, 'label': 'Clients'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedIndex = i);
                  if (i == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CalendarScreen()),
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 22,
                        color: selected
                            ? const Color(0xFF1EAABB)
                            : const Color(0xFFB0B8C1),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? const Color(0xFF1EAABB)
                              : const Color(0xFFB0B8C1),
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// STAT CARD
// ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String value;
  final String label;

  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SESSION TILE
// ─────────────────────────────────────────────────────────────────
class _SessionTile extends StatelessWidget {
  final String name;
  final String time;
  final String subtitle;
  final bool isActive;

  const _SessionTile({
    required this.name,
    required this.time,
    required this.subtitle,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF0FBFD) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(color: const Color(0xFF1EAABB).withOpacity(0.3), width: 1)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                time,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1EAABB),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
          if (isActive) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 32,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1EAABB), Color(0xFF178A9A)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Start Session',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// QUICK ACCESS CARD
// ─────────────────────────────────────────────────────────────────
class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color iconBg;
  final Color iconColor;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sublabel,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF9CA3AF),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// PROGRESS ROW
// ─────────────────────────────────────────────────────────────────
class _ProgressRow extends StatelessWidget {
  final String label;
  final String valueText;
  final double progress;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.valueText,
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              valueText,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 7,
            backgroundColor: const Color(0xFFF0F0F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}