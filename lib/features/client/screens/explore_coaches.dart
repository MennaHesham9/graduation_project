// lib/features/client/screens/explore_coaches.dart
import 'package:flutter/material.dart';
import '../../../core/widgets/user_photo.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/user_model.dart';
import '../providers/coaches_provider.dart';
import '../services/coaching_request_service.dart';
import '../models/coaching_request_model.dart';
import 'coach_profile_client_side.dart';

class ExploreCoachesScreen extends StatefulWidget {
  const ExploreCoachesScreen({super.key});

  @override
  State<ExploreCoachesScreen> createState() => _ExploreCoachesScreenState();
}

class _ExploreCoachesScreenState extends State<ExploreCoachesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final CoachingRequestService _requestService = CoachingRequestService();

  final List<String> _categories = [
    'All', 'Life', 'Career', 'Health', 'Relationship'
  ];

  @override
  void initState() {
    super.initState();
    // ✅ Fetch coaches once when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CoachesProvider>().fetchCoaches();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clientId = context.read<AuthProvider>().user?.uid ?? '';
    // ✅ Read selected category from provider, not local state
    final provider = context.watch<CoachesProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: Column(
        children: [
          _buildHeader(context, provider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── PENDING / ACCEPTED / DECLINED BANNER ──────────────
                  if (clientId.isNotEmpty)
                    StreamBuilder<CoachingRequestModel?>(
                      stream: _requestService.streamAnyActiveRequest(clientId),
                      builder: (context, snap) {
                        if (!snap.hasData || snap.data == null) {
                          return const SizedBox.shrink();
                        }
                        return _PendingRequestBanner(
                          request: snap.data!,
                          requestService: _requestService,
                        );
                      },
                    ),

                  const SizedBox(height: 8),
                  const Text(
                    'Explore Coaches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0A0A0A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── COACH LIST ────────────────────────────────────────
                  if (provider.isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (provider.error != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Text(
                              provider.error!,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<CoachesProvider>().fetchCoaches(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  // ✅ Use provider.coaches directly — already filtered by provider
                  else if (provider.coaches.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.search_off,
                                  size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                'No coaches found.',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        // ✅ provider.coaches — no second local filter
                        itemCount: provider.coaches.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) =>
                            _CoachCard(coach: provider.coaches[i]),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, CoachesProvider provider) {
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
        bottom: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text(
                'Coaches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ✅ Search delegates to provider
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) =>
                  context.read<CoachesProvider>().setSearch(val),
              decoration: InputDecoration(
                hintText: 'Search by name or specialty...',
                hintStyle:
                TextStyle(fontSize: 14, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search,
                    color: Colors.grey.shade400, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ Category chips delegate to provider
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                // Read selected category from provider
                final selected =
                provider.coaches.isEmpty && cat == 'All'
                    ? true
                    : cat == _currentCategory(provider);
                return GestureDetector(
                  onTap: () =>
                      context.read<CoachesProvider>().setCategory(cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cat,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color:
                        selected ? AppColors.primary : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper: expose selected category from provider ────────────────────────
  // CoachesProvider doesn't expose _selectedCategory publicly yet — add a
  // getter to CoachesProvider (see note below) or track it here.
  String _currentCategory(CoachesProvider provider) {
    // We track it locally since provider doesn't expose it yet
    return _localCategory;
  }

  String _localCategory = 'All';
}

// ── PENDING / DECLINED / ACCEPTED BANNER ──────────────────────────────────────

class _PendingRequestBanner extends StatelessWidget {
  final CoachingRequestModel request;
  final CoachingRequestService requestService;

  const _PendingRequestBanner({
    required this.request,
    required this.requestService,
  });

  String get _coachLabel => request.coachName;

  @override
  Widget build(BuildContext context) {
    switch (request.status) {
      case 'pending':
        return _buildPendingCard(context);
      case 'accepted':
        return _buildAcceptedCard();
      case 'declined':
        return _buildDeclinedCard(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPendingCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFFFF3E0),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.schedule,
                    color: Color(0xFFFF9800), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Pending',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 13, color: Color(0x990A0A0A)),
                        children: [
                          const TextSpan(
                              text: 'Your coaching request to '),
                          TextSpan(
                            text: _coachLabel,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(text: ' is under review.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.circle, size: 8, color: Color(0xFFFF9800)),
              SizedBox(width: 6),
              Text(
                'Awaiting response',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFF9800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Cancel Request'),
                        content: const Text(
                            'Are you sure you want to cancel this coaching request?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, false),
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(context, true),
                            child: const Text('Yes, Cancel',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await requestService.cancelRequest(request.id);
                    }
                  },
                  child: const Text(
                    'Cancel Request',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.red,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'View Request Status',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
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

  Widget _buildDeclinedCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCDD2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
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
                decoration: const BoxDecoration(
                  color: Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.cancel_outlined,
                    color: Colors.red, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Request Declined',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0A0A0A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            fontSize: 13, color: Color(0x990A0A0A)),
                        children: [
                          TextSpan(
                            text: _coachLabel,
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const TextSpan(
                              text: ' has declined your request.'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => requestService.cancelRequest(request.id),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Text('Dismiss & Explore Other Coaches'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle),
            child: const Icon(Icons.check, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Request Accepted! 🎉',
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  '$_coachLabel is now your coach.',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0x990A0A0A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── COACH LIST CARD ───────────────────────────────────────────────────────────

class _CoachCard extends StatelessWidget {
  final UserModel coach;
  const _CoachCard({required this.coach});

  @override
  Widget build(BuildContext context) {
    final specialty =
        coach.professionalTitle ?? coach.coachingCategory ?? 'Life Coaching';
    final rate = coach.videoPrice?.toStringAsFixed(0) ?? '60';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          UserPhoto.square(
            photoUrl: coach.photoUrl,
            initials: coach.initials,
            size: 70,
            borderRadius: 12,
            backgroundColor: const Color(0xFF2A7A7A),
            initialsStyle: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  coach.fullName,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  specialty,
                  style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 15, color: Color(0xFFFFC107)),
                    const SizedBox(width: 3),
                    Text(
                      '4.5',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade600),
                    ),
                    const Spacer(),
                    Text(
                      '\$$rate/session',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CoachProfileClientSide(coach: coach),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('View Profile',
                  style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}