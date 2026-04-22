import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'coach_client_profile_screen.dart';

// ─── Data Model ───────────────────────────────────────────────────────────────

enum _ClientStatus { active, paused }

class _ClientData {
  final String name;
  final String sessions;
  final _ClientStatus status;
  final double progress;
  final String nextSession;
  final String avatarInitials;
  final Color avatarColor;

  const _ClientData({
    required this.name,
    required this.sessions,
    required this.status,
    required this.progress,
    required this.nextSession,
    required this.avatarInitials,
    required this.avatarColor,
  });
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class CoachClientsScreen extends StatefulWidget {
  const CoachClientsScreen({super.key});

  @override
  State<CoachClientsScreen> createState() => _CoachClientsScreenState();
}

class _CoachClientsScreenState extends State<CoachClientsScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  static const _allClients = [
    _ClientData(
      name: 'Sarah Johnson',
      sessions: '12 sessions',
      status: _ClientStatus.active,
      progress: 0.75,
      nextSession: 'Today, 2:00 PM',
      avatarInitials: 'SJ',
      avatarColor: Color(0xFF2F8F9D),
    ),
    _ClientData(
      name: 'James Miller',
      sessions: '8 sessions',
      status: _ClientStatus.active,
      progress: 0.60,
      nextSession: 'Today, 4:00 PM',
      avatarInitials: 'JM',
      avatarColor: Color(0xFF7C3AED),
    ),
    _ClientData(
      name: 'Emma Davis',
      sessions: '15 sessions',
      status: _ClientStatus.active,
      progress: 0.85,
      nextSession: 'Today, 6:00 PM',
      avatarInitials: 'ED',
      avatarColor: Color(0xFFDB2777),
    ),
    _ClientData(
      name: 'Michael Brown',
      sessions: '5 sessions',
      status: _ClientStatus.paused,
      progress: 0.40,
      nextSession: 'Not scheduled',
      avatarInitials: 'MB',
      avatarColor: Color(0xFF99A1AF),
    ),
  ];

  List<_ClientData> get _filtered {
    if (_query.isEmpty) return _allClients;
    return _allClients
        .where((c) => c.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
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
              const Text(
                'My Clients',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search bar
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded,
                    size: 20, color: Color(0xFF9CA3AF)),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF101828),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search clients...',
                      hintStyle: TextStyle(
                        fontSize: 16,
                        color: Color(0x80101828),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_query.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF9CA3AF)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Body ──────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    final clients = _filtered;

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
      child: clients.isEmpty
          ? const Center(
        child: Text(
          'No clients found',
          style: TextStyle(fontSize: 15, color: Color(0xFF6A7282)),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        itemCount: clients.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, i) =>
            _ClientCard(client: clients[i]),
      ),
    );
  }
}

// ─── Client Card ──────────────────────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  final _ClientData client;

  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final isActive = client.status == _ClientStatus.active;
    final isScheduled = client.nextSession != 'Not scheduled';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Scaffold(
            body: CoachClientProfileScreen(),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(24),
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
            // ── Top row: avatar + info + wallet button ──────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with online/paused dot
                Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: client.avatarColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
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
                      child: Text(
                        client.avatarInitials,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: client.avatarColor,
                        ),
                      ),
                    ),
                    // Online / paused indicator dot
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFF00C950)
                              : const Color(0xFF99A1AF),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                // Name + sessions + status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF101828),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            client.sessions,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4A5565),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '•',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A5565),
                              ),
                            ),
                          ),
                          Text(
                            isActive ? 'Active' : 'Paused',
                            style: TextStyle(
                              fontSize: 14,
                              color: isActive
                                  ? const Color(0xFF00A63E)
                                  : const Color(0xFF6A7282),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Wallet / action button
                GestureDetector(
                  onTap: () => _showSnack(context, 'Opening wallet...'),
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFFBFF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 20,
                      color: Color(0xFF2F8F9D),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Progress bar row ────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Overall Progress',
                      style:
                      TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up_rounded,
                          size: 16,
                          color: Color(0xFF00A63E),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(client.progress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF00A63E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Stack(
                    children: [
                      Container(
                        height: 8,
                        width: double.infinity,
                        color: const Color(0xFFE5E7EB),
                      ),
                      FractionallySizedBox(
                        widthFactor: client.progress,
                        child: Container(
                          height: 8,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2F8F9D),
                                Color(0xFF20A8BC),
                              ],
                            ),
                            borderRadius:
                            BorderRadius.all(Radius.circular(999)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Next session pill ───────────────────────────────────────
            Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFE8FCFF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBEDBFF)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Next Session',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF364153),
                    ),
                  ),
                  Text(
                    client.nextSession,
                    style: TextStyle(
                      fontSize: 14,
                      color: isScheduled
                          ? AppColors.primary
                          : const Color(0xFF4A5565),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}