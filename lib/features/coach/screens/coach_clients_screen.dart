import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../client/models/coaching_request_model.dart';
import '../../client/services/coaching_request_service.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Decline', style: TextStyle(color: Colors.white)),
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
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
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
                        Text('Manage your coaching relationships',
                            style: TextStyle(
                                fontSize: 14, color: Colors.white.withOpacity(0.8))),
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
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
            // ── TAB 1: Pending Requests ──────────────────────────────────
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
                  itemBuilder: (_, i) =>
                      _RequestCard(
                        request: requests[i],
                        isLoading: _loadingIds[requests[i].id] == true,
                        onAccept: () => _accept(requests[i], coach.fullName),
                        onDecline: () => _decline(requests[i], coach.fullName),
                      ),
                );
              },
            ),

            // ── TAB 2: My Clients (accepted) ────────────────────────────
            StreamBuilder<List<CoachingRequestModel>>(
              stream: _requestService.streamAcceptedClients(coach.uid),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final clients = snap.data ?? [];
                if (clients.isEmpty) return _emptyState(isRequests: false);
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: clients.length,
                  itemBuilder: (_, i) => _ClientCard(client: clients[i]),
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

// ─── Request Card ────────────────────────────────────────────────────────────

class _RequestCard extends StatelessWidget {
  final CoachingRequestModel request;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _RequestCard({
    required this.request,
    required this.isLoading,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                              fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                _detail(Icons.repeat_outlined, 'Frequency', request.frequency),
                const SizedBox(height: 10),
                _detail(Icons.access_time_outlined, 'Preferred Time',
                    request.preferredTime),
                if (request.additionalNotes?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  _detail(Icons.notes_outlined, 'Notes',
                      request.additionalNotes!),   // Line 330 — add ! here
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Accept',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87)),
        Expanded(
          child: Text(value,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ─── Client Card (accepted) ──────────────────────────────────────────────────

class _ClientCard extends StatelessWidget {
  final CoachingRequestModel client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary.withOpacity(0.15),
            child: Text(
              _initials(client.clientName),
              style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.clientName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(client.primaryGoal,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('Active',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700)),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}