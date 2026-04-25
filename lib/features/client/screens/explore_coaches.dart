import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/coaches_provider.dart';
import '../../../core/models/user_model.dart';
import 'coach_profile_client_side.dart';

class ExploreCoachesScreen extends StatefulWidget {
  const ExploreCoachesScreen({super.key});

  @override
  State<ExploreCoachesScreen> createState() => _ExploreCoachesScreenState();
}

class _ExploreCoachesScreenState extends State<ExploreCoachesScreen> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All', 'Life', 'Career', 'Health', 'Relationships', 'Mindfulness',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch on first load
    Future.microtask(() =>
        context.read<CoachesProvider>().fetchCoaches());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CoachesProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppBar(),
            _buildSearchBar(provider),
            _buildFilterChips(provider),
            const SizedBox(height: 10),
            Expanded(child: _buildBody(provider)),
          ],
        ),
      ),
    );
  }

  // ── BODY (loading / error / list) ──────────────────────────
  Widget _buildBody(CoachesProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1EAABB)),
      );
    }

    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: Color(0xFF9CA3AF), size: 48),
            const SizedBox(height: 12),
            Text(provider.error!,
                style: const TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.fetchCoaches(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1EAABB)),
              child: const Text('Retry',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (provider.coaches.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded,
                color: Color(0xFF9CA3AF), size: 48),
            SizedBox(height: 12),
            Text('No coaches found',
                style: TextStyle(
                    color: Color(0xFF6B7280), fontSize: 15)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
      itemCount: provider.coaches.length,
      itemBuilder: (context, index) {
        return _CoachCard(coach: provider.coaches[index]);
      },
    );
  }

  // ── APP BAR ─────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(4, 10, 16, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF1A1A2E)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Explore Coaches',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
    );
  }

  // ── SEARCH BAR ──────────────────────────────────────────────
  Widget _buildSearchBar(CoachesProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 14),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6F9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.search_rounded,
                color: Color(0xFF9CA3AF), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: (val) => provider.setSearch(val),
                decoration: const InputDecoration(
                  hintText: 'Search by name or specialty...',
                  hintStyle: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 13,
                      fontWeight: FontWeight.w400),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF1A1A2E)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── FILTER CHIPS ────────────────────────────────────────────
  Widget _buildFilterChips(CoachesProvider provider) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Row(
          children: List.generate(_filters.length, (i) {
            final selected = _selectedFilter == i;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () {
                  setState(() => _selectedFilter = i);
                  provider.setCategory(_filters[i]);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF1EAABB)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1EAABB)
                          : const Color(0xFFE5E7EB),
                      width: 1.2,
                    ),
                  ),
                  child: Text(
                    _filters[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ── COACH CARD ───────────────────────────────────────────────────
class _CoachCard extends StatelessWidget {
  final UserModel coach;
  const _CoachCard({required this.coach});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Avatar ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFE5E7EB),
                    child: coach.photoUrl != null && coach.photoUrl!.isNotEmpty
                        ? Image.network(
                      coach.photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _avatarFallback(coach),
                    )
                        : _avatarFallback(coach),
                  ),
                ),

                const SizedBox(width: 14),

                // ── Info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach.fullName ?? 'Unknown Coach',
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E)),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coach.professionalTitle ??
                            coach.coachingCategory ??
                            'Coach',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6B7280),
                            fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          // Availability badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (coach.isAvailable ?? false)
                                  ? const Color(0xFFD1FAE5)
                                  : const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              (coach.isAvailable ?? false)
                                  ? 'Available'
                                  : 'Unavailable',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: (coach.isAvailable ?? false)
                                    ? const Color(0xFF059669)
                                    : const Color(0xFFDC2626),
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Price
                          Text(
                            coach.videoPrice != null
                                ? '\$${coach.videoPrice}/${coach.sessionDuration ?? 60}min'
                                : 'Price N/A',
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1EAABB)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── View Profile button ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              height: 42,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1EAABB), Color(0xFF178A9A)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CoachProfileClientSide(coach: coach), // pass coach
                            //CoachProfileClientSide(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Initials fallback avatar
  Widget _avatarFallback(UserModel coach) {
    return Container(
      color: const Color(0xFF1EAABB).withOpacity(0.15),
      child: Center(
        child: Text(
          coach.initials,  // from UserModel computed property
          style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1EAABB)),
        ),
      ),
    );
  }
}