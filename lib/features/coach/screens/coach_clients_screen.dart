import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../client/models/coaching_request_model.dart';
import '../../client/services/coaching_request_service.dart';
import 'client_request_detail_screen.dart';
import 'coach_client_profile_screen.dart';

class CoachClientsScreen extends StatefulWidget {
  const CoachClientsScreen({super.key});

  @override
  State<CoachClientsScreen> createState() => _CoachClientsScreenState();
}

class _CoachClientsScreenState extends State<CoachClientsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _requestService = CoachingRequestService();
  final Map<String, bool> _loadingIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _accept(CoachingRequestModel req, String coachName) async {
    setState(() => _loadingIds[req.id] = true);
    try {
      await _requestService.acceptRequest(
        requestId: req.id,
        clientId: req.clientId,
        coachName: coachName,
        clientName: req.clientName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${req.clientName} accepted!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingIds.remove(req.id));
    }
  }

  Future<void> _decline(CoachingRequestModel req, String coachName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Decline Request'),
        content: Text('Decline ${req.clientName}\'s coaching request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Decline',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _loadingIds[req.id] = true);
    try {
      await _requestService.declineRequest(
        requestId: req.id,
        clientId: req.clientId,
        coachName: coachName,
      );
    } finally {
      if (mounted) setState(() => _loadingIds.remove(req.id));
    }
  }

  void _openDetail(CoachingRequestModel req, String coachName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientRequestDetailScreen(
          request: req,
          coachName: coachName,
        ),
      ),
    );
  }

  void _openClientProfile(CoachingRequestModel client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CoachClientProfileScreen(client: client),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coach = context.watch<AuthProvider>().user!;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 130,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Clients',
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your coaching relationships',
                          style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [
                Tab(text: 'Requests'),
                Tab(text: 'My Clients'),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            // ── TAB 1: Pending Requests ──────────────────────────────
            StreamBuilder<List<CoachingRequestModel>>(
              stream: _requestService.streamPendingRequests(coach.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final requests = snap.data ?? [];
                if (requests.isEmpty) return _emptyState(isRequests: true);
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (_, i) => _RequestCard(
                    request: requests[i],
                    isLoading: _loadingIds[requests[i].id] == true,
                    onTap: () => _openDetail(requests[i], coach.fullName),
                    onAccept: () => _accept(requests[i], coach.fullName),
                    onDecline: () => _decline(requests[i], coach.fullName),
                  ),
                );
              },
            ),

            // ── TAB 2: My Clients (accepted) ─────────────────────────
            StreamBuilder<List<CoachingRequestModel>>(
              stream: _requestService.streamAcceptedClients(coach.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final allClients = snap.data ?? [];

                // Apply search filter
                final clients = _searchQuery.isEmpty
                    ? allClients
                    : allClients
                        .where((c) => c.clientName
                            .toLowerCase()
                            .contains(_searchQuery))
                        .toList();

                return Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search clients...',
                            hintStyle: TextStyle(
                                color: Colors.grey.shade400, fontSize: 14),
                            prefixIcon: Icon(Icons.search,
                                color: Colors.grey.shade400, size: 20),
                            border: InputBorder.none,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),

                    // List
                    Expanded(
                      child: clients.isEmpty
                          ? _emptyState(isRequests: false)
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              itemCount: clients.length,
                              itemBuilder: (_, i) => _ClientCard(
                                client: clients[i],
                                onTap: () => _openClientProfile(clients[i]),
                              ),
                            ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({required bool isRequests}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isRequests ? Icons.inbox_outlined : Icons.people_outline,
            size: 72,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isRequests ? 'No pending requests' : 'No clients yet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500),
          ),
          const SizedBox(height: 8),
          Text(
            isRequests
                ? 'New requests will appear here'
                : 'Accept a request to add your first client',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ─── Request Card ─────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final CoachingRequestModel request;
  final bool isLoading;
  final VoidCallback onTap;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.request,
    required this.isLoading,
    required this.onTap,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      _initials(request.clientName),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(request.clientName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(_timeAgo(request.createdAt),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('Pending',
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange.shade800)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text('View details',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary)),
                          const SizedBox(width: 2),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 10, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detail(Icons.flag_outlined, 'Goal', request.primaryGoal),
                  const SizedBox(height: 10),
                  _detail(Icons.psychology_outlined, 'Challenges',
                      request.currentChallenges),
                  const SizedBox(height: 10),
                  _detail(Icons.repeat_outlined, 'Frequency',
                      request.frequency),
                  const SizedBox(height: 10),
                  _detail(Icons.access_time_outlined, 'Preferred Time',
                      request.preferredTime),
                  if (request.additionalNotes?.isNotEmpty == true) ...[
                    const SizedBox(height: 10),
                    _detail(Icons.notes_outlined, 'Notes',
                        request.additionalNotes!),
                  ],
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: onDecline,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red.shade600,
                              side: BorderSide(color: Colors.red.shade300),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Decline'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: onAccept,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Accept',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold)),
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

  Widget _detail(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade500),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87)),
        Expanded(
          child: Text(value,
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2)
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Client Card (My Clients tab — new design) ────────────────────────────────

class _ClientCard extends StatelessWidget {
  final CoachingRequestModel client;
  final VoidCallback onTap;

  const _ClientCard({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Placeholder progress value — will be real data later
    const int progressScore = 75;
    const double progressValue = 0.75;
    const String nextSession = 'Today, 2:00 PM';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Top section ──
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary.withOpacity(0.7),
                                  AppColors.primary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _initials(client.clientName),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          // Online dot
                          Positioned(
                            bottom: 2,
                            right: 2,
                            child: Container(
                              width: 11,
                              height: 11,
                              decoration: BoxDecoration(
                                color: const Color(0xFF22C55E),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),

                      // Name + sessions + status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              client.clientName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '0 sessions', // placeholder — real data later
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 4,
                                  height: 4,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF22C55E),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Active',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF22C55E),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Chat icon button
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress row
                  Row(
                    children: [
                      Text(
                        'Overall Progress',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.trending_up_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 3),
                      Text(
                        '$progressScore%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressValue,
                      minHeight: 6,
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      valueColor:
                          AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            // ── Next Session footer ──
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next Session',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    nextSession,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2)
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}