import 'package:flutter/material.dart';


class MindWellApp extends StatelessWidget {
  const MindWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindWell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const ExploreCoachesScreen(),
    );
  }
}

class ExploreCoachesScreen extends StatefulWidget {
  const ExploreCoachesScreen({super.key});

  @override
  State<ExploreCoachesScreen> createState() => _ExploreCoachesScreenState();
}

class _ExploreCoachesScreenState extends State<ExploreCoachesScreen> {
  int _selectedFilter = 0;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Life',
    'Career',
    'Health',
    'Relationships',
    'Mindfulness',
  ];

  final List<Map<String, dynamic>> _coaches = [
    {
      'name': 'Dr. Michael Chen',
      'specialty': 'Life & Career Coaching',
      'rating': 4.9,
      'reviews': 156,
      'price': '\$75/session',
      'image': 'assets/images/coach1.jpg',
    },
    {
      'name': 'Sarah Williams',
      'specialty': 'Mental Health & Wellness',
      'rating': 4.8,
      'reviews': 203,
      'price': '\$85/session',
      'image': 'assets/images/coach2.jpg',
    },
    {
      'name': 'Dr. James Anderson',
      'specialty': 'Executive Coaching',
      'rating': 5.0,
      'reviews': 92,
      'price': '\$120/session',
      'image': 'assets/images/coach3.jpg',
    },
    {
      'name': 'Emily Rodriguez',
      'specialty': 'Relationship Coaching',
      'rating': 4.7,
      'reviews': 178,
      'price': '\$70/session',
      'image': 'assets/images/coach4.jpg',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── APP BAR ──
            _buildAppBar(),

            // ── SEARCH BAR ──
            _buildSearchBar(),

            // ── FILTER CHIPS ──
            _buildFilterChips(),

            const SizedBox(height: 10),

            // ── COACH LIST ──
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                itemCount: _coaches.length,
                itemBuilder: (context, index) {
                  return _CoachCard(coach: _coaches[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────
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
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // SEARCH BAR
  // ─────────────────────────────────────────
  Widget _buildSearchBar() {
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
                decoration: const InputDecoration(
                  hintText: 'Search by name or specialty...',
                  hintStyle: TextStyle(
                    color: Color(0xFF9CA3AF),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1A1A2E),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // FILTER CHIPS
  // ─────────────────────────────────────────
  Widget _buildFilterChips() {
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
                onTap: () => setState(() => _selectedFilter = i),
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

// ─────────────────────────────────────────────────────────────────
// COACH CARD
// ─────────────────────────────────────────────────────────────────
class _CoachCard extends StatelessWidget {
  final Map<String, dynamic> coach;

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
          // ── Coach info row ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFFE5E7EB),
                    child: Image.asset(
                      coach['image'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFD1D5DB),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF9CA3AF),
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                // Name, specialty, rating, price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        coach['name'] as String,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        coach['specialty'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFFF59E0B), size: 16),
                          const SizedBox(width: 3),
                          Text(
                            '${coach['rating']}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            ' (${coach['reviews']})',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9CA3AF),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            coach['price'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1EAABB),
                            ),
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
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Color(0xFF1EAABB),
                      Color(0xFF178A9A),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'View Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}