// lib/features/coach/screens/coach_clients_screen.dart
//
// CHANGE: _accept() now passes coachId: req.coachId to acceptRequest()
//         so the service's Firestore transaction can locate the coach doc.

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
        coachId: req.coachId, // ← ADDED: required by the transaction
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
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
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
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Decline Request'),
        content:
        Text('Decline ${req.clientName}\'s coaching request?'),
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
                    padding:
                    const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
              stream:
              _requestService.streamPendingRequests(coach.uid),
              builder: (context, snap) {
                if (snap.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final requests = snap.data ?? [];
                if (requests.isEmpty) {
                  return _emptyState(isRequests: true);
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  itemBuilder: (_, i) => _RequestCard(
                    request: requests[i],
                    isLoading:
                    _loadingIds[requests[i].id] == true,
                    onTap: () =>
                        _openDetail(requests[i], coach.fullName),
                    onAccept: () =>
                        _accept(requests[i], coach.fullName),
                    onDecline: () =>
                        _decline(requests[i], coach.fullName),
                  ),
                );
              },
            ),

            // ── TAB 2: Accepted Clients ──────────────────────────────
            Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search clients…',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<CoachingRequestModel>>(
                    stream: _requestService
                        .streamAcceptedClients(coach.uid),
                    builder: (context, snap) {
                      if (snap.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }
                      final all = snap.data ?? [];
                      final clients = _searchQuery.isEmpty
                          ? all
                          : all
                          .where((c) => c.clientName
                          .toLowerCase()
                          .contains(_searchQuery))
                          .toList();
                      if (clients.isEmpty) {
                        return _emptyState(isRequests: false);
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: clients.length,
                        itemBuilder: (_, i) => _ClientCard(
                          client: clients[i],
                          onTap: () =>
                              _openClientProfile(clients[i]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState({required bool isRequests}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isRequests
                ? Icons.inbox_outlined
                : Icons.people_outline,
            size: 60,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            isRequests
                ? 'No pending requests'
                : 'No clients yet',
            style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            isRequests
                ? 'New requests will appear here'
                : 'Accepted clients will appear here',
            style: TextStyle(
                fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request Card (Requests tab)
// ─────────────────────────────────────────────────────────────────────────────
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
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      _initials(request.clientName),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.clientName,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 3),
                      Text(
                        request.primaryGoal,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ),
                // New badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'New',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),

            if (isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(),
            ] else ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onDecline,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                            color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                        const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Decline',
                          style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding:
                        const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: const Text('Accept',
                          style: TextStyle(
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name
        .substring(0, name.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Client Card (My Clients tab)
// ─────────────────────────────────────────────────────────────────────────────
class _ClientCard extends StatelessWidget {
  final CoachingRequestModel client;
  final VoidCallback onTap;

  const _ClientCard({required this.client, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
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
                              borderRadius:
                              BorderRadius.circular(14),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
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
                                  '0 sessions',
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
                ],
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.04),
                borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(18)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Goal',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      client.primaryGoal,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
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
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name
        .substring(0, name.length >= 2 ? 2 : 1)
        .toUpperCase();
  }
}