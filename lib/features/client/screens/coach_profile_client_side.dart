// lib/features/client/screens/coach_profile_client_side.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../Request Coaching/request_form_screen.dart';
import 'booking_screen.dart';

class CoachProfileClientSide extends StatelessWidget {
  final UserModel coach; // ✅ receive real coach data

  const CoachProfileClientSide({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          // ── Teal header background ───────────────────────────────────────
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A9BAD), Color(0xFF2F8F9D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Back button ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Profile card ──────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // ── Avatar ──────────────────────────────────
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 45,
                              backgroundColor: const Color(0xFF5BB8C9),
                              backgroundImage: (coach.photoUrl != null &&
                                  coach.photoUrl!.isNotEmpty)
                                  ? NetworkImage(coach.photoUrl!)
                                  : null,
                              child: (coach.photoUrl == null ||
                                  coach.photoUrl!.isEmpty)
                                  ? Text(
                                coach.initials,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              )
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ── Name ─────────────────────────────────────
                          Text(
                            coach.fullName ?? 'Unknown Coach',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2533),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // ── Title ────────────────────────────────────
                          Text(
                            coach.professionalTitle ??
                                coach.coachingCategory ??
                                'Coach',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // ── Rating + experience ───────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Experience
                              const Icon(Icons.workspace_premium_outlined,
                                  size: 14, color: Color(0xFF9EABB8)),
                              const SizedBox(width: 3),
                              Text(
                                coach.yearsOfExperience != null
                                    ? '${coach.yearsOfExperience} yrs exp'
                                    : 'Experience N/A',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9EABB8),
                                ),
                              ),
                              const SizedBox(width: 14),
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
                            ],
                          ),

                          const SizedBox(height: 14),

                          // ── Specialty chips ───────────────────────────
                          if ((coach.coachingCategories != null &&
                              coach.coachingCategories!.isNotEmpty) ||
                              coach.coachingCategory != null)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  // show coachingCategories list if available,
                                  // else fall back to single coachingCategory
                                  ...(coach.coachingCategories?.isNotEmpty ==
                                      true
                                      ? coach.coachingCategories!
                                      : [
                                    if (coach.coachingCategory != null)
                                      coach.coachingCategory!
                                  ])
                                      .map((cat) => _SpecialtyChip(cat)),
                                ],
                              ),
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── About card ────────────────────────────────────────
                  if (coach.bio != null && coach.bio!.isNotEmpty)
                    _InfoCard(
                      title: 'About',
                      child: Text(
                        coach.bio!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF5A6A7A),
                          height: 1.6,
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── Session pricing card ──────────────────────────────
                  _InfoCard(
                    title: 'Session Pricing',
                    child: Column(
                      children: [
                        if (coach.videoPrice != null)
                          _PriceRow(
                            icon: Icons.videocam_rounded,
                            label: 'Video Session',
                            price:
                            '${coach.currency ?? '\$'}${coach.videoPrice}',
                            duration:
                            '${coach.sessionDuration ?? 60} min',
                          ),
                        if (coach.audioPrice != null)
                          _PriceRow(
                            icon: Icons.mic_rounded,
                            label: 'Audio Session',
                            price:
                            '${coach.currency ?? '\$'}${coach.audioPrice}',
                            duration:
                            '${coach.sessionDuration ?? 60} min',
                          ),
                        if (coach.packagePrice != null)
                          _PriceRow(
                            icon: Icons.inventory_2_rounded,
                            label: 'Package',
                            price:
                            '${coach.currency ?? '\$'}${coach.packagePrice}',
                            duration: 'Bundle',
                          ),
                        if (coach.videoPrice == null &&
                            coach.audioPrice == null &&
                            coach.packagePrice == null)
                          const Text(
                            'Pricing not set yet.',
                            style: TextStyle(
                                fontSize: 13, color: Color(0xFF9EABB8)),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Languages card ────────────────────────────────────
                  if (coach.languages != null &&
                      coach.languages!.isNotEmpty)
                    _InfoCard(
                      title: 'Languages',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: coach.languages!
                            .map((lang) => _SpecialtyChip(lang))
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── Book Session button ───────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: (coach.isAvailable ?? false)
                            ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RequestCoachingScreen(coach: coach),
                                  //BookingScreen(),
                              // BookingScreen(coach: coach),pass coach
                            ),
                          );
                        }
                            : null, // disabled if unavailable
                        icon: const Icon(Icons.send,
                            size: 18),

                        label: Text(
                          (coach.isAvailable ?? false)
                              ? 'Request Coaching'
                              : 'Currently Unavailable',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          const Color(0xFFD1D5DB),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specialty Chip
// ─────────────────────────────────────────────────────────────────────────────
class _SpecialtyChip extends StatelessWidget {
  final String label;
  const _SpecialtyChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info Card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2533),
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Price Row
// ─────────────────────────────────────────────────────────────────────────────
class _PriceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String price;
  final String duration;

  const _PriceRow({
    required this.icon,
    required this.label,
    required this.price,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF1A2533)),
            ),
          ),
          Text(
            duration,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF9EABB8)),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}