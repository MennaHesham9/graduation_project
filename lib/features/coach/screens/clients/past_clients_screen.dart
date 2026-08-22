import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PastClientsScreen extends StatefulWidget {
  const PastClientsScreen({super.key});

  @override
  State<PastClientsScreen> createState() => _PastClientsScreenState();
}

class _PastClientsScreenState extends State<PastClientsScreen> {
  int _selectedFilter = 2; // 0=Last Month, 1=Last 6 Months, 2=All Time
  final List<String> _filters = ['Last Month', 'Last 6 Months', 'All Time'];

  static const List<_ClientRecord> _clients = [
    _ClientRecord(initials: 'MJ', name: 'Michael Johnson', period: 'Jan – Mar 2026', sessions: 12, goals: 3, progress: 100, badge: 'Goals Achieved', badgeColor: Color(0xFF27AE60), note: 'Completed career transition coaching', avatarColor: Color(0xFF27AE60)),
    _ClientRecord(initials: 'SA', name: 'Sarah Anderson',  period: 'Nov 2025 – Feb 2026', sessions: 16, goals: 5, progress: 100, badge: 'Program Completed', badgeColor: Color(0xFF3B82F6), note: 'Successfully built new habits', avatarColor: Color(0xFF3B82F6)),
    _ClientRecord(initials: 'DC', name: 'David Chen',      period: 'Sep – Dec 2025', sessions: 10, goals: 2, progress: 100, badge: 'Early Completion', badgeColor: Color(0xFFF5A623), note: 'Reached objectives ahead of schedule', avatarColor: AppColors.primary),
    _ClientRecord(initials: 'EW', name: 'Emma Williams',   period: 'Jul – Oct 2025', sessions: 14, goals: 4, progress: 100, badge: 'Goals Achieved', badgeColor: Color(0xFF27AE60), note: 'Improved work-life balance', avatarColor: Color(0xFF27AE60)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(child: Text('Past Clients', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)))),
                  const Icon(Icons.search, color: Color(0xFF8A8A9A)),
                ],
              ),
            ),

            // ── Filter tabs ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(_filters.length, (i) {
                  final selected = _selectedFilter == i;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = i),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _filters[i],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : const Color(0xFF8A8A9A),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 12),

            // ── Client list + summary ──
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  ..._clients.map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _ClientCard(client: c),
                  )),

                  // ── All-time summary ──
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2F8F9D), Color(0xFF1A6B78)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('All-Time Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _SummaryCell(value: '52', label: 'Total Past Clients'),
                            const SizedBox(width: 12),
                            _SummaryCell(value: '628', label: 'Sessions Delivered'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _SummaryCell(value: '4.9', label: 'Avg Rating'),
                            const SizedBox(width: 12),
                            _SummaryCell(value: '94%', label: 'Goal Success Rate'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final _ClientRecord client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: client.avatarColor,
                child: Text(client.initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(client.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: client.badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                          child: Text(client.badge, style: TextStyle(fontSize: 10, color: client.badgeColor, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFFB0B0C0)),
                        const SizedBox(width: 4),
                        Text(client.period, style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9A))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stats
          Row(
            children: [
              _StatCell(value: client.sessions.toString(), label: 'Sessions', color: AppColors.primary),
              _StatCell(value: client.goals.toString(), label: 'Goals', color: const Color(0xFF3B82F6)),
              _StatCell(value: '${client.progress}%', label: 'Progress', color: const Color(0xFF27AE60)),
            ],
          ),
          const SizedBox(height: 12),

          // Note
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.description_outlined, size: 14, color: Color(0xFF8A8A9A)),
              const SizedBox(width: 6),
              const Text('Coach Notes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF8A8A9A))),
            ],
          ),
          const SizedBox(height: 4),
          Text(client.note, style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A9A), fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),

          // View button
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF8FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('View Full History', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.chevron_right, color: AppColors.primary, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatCell({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8A8A9A))),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

class _ClientRecord {
  final String initials, name, period, badge, note;
  final int sessions, goals, progress;
  final Color badgeColor, avatarColor;

  const _ClientRecord({
    required this.initials, required this.name, required this.period,
    required this.sessions, required this.goals, required this.progress,
    required this.badge, required this.badgeColor, required this.note,
    required this.avatarColor,
  });
}