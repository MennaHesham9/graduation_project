// lib/features/client/screens/coach_profile_client_side.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'booking_screen.dart';

class CoachProfileClientSide extends StatelessWidget {
  const CoachProfileClientSide({super.key});

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
                  // ── Back button ────────────────────────────────────────
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

                  // ── Profile card (overlapping the teal header) ─────────
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

                          // Avatar
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
                              child: const Text(
                                'MC',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              // Uncomment when you have a real image:
                              // backgroundImage: AssetImage('assets/images/coach_michael.jpg'),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Name
                          const Text(
                            'Dr. Michael Chen',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2533),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Title
                          Text(
                            'Certified Life & Career Coach',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Rating + experience row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star_rounded,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 3),
                              const Text(
                                '4.9',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2533),
                                ),
                              ),
                              const Text(
                                ' (156 reviews)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9EABB8),
                                ),
                              ),
                              const SizedBox(width: 14),
                              const Icon(Icons.workspace_premium_outlined,
                                  size: 14, color: Color(0xFF9EABB8)),
                              const SizedBox(width: 3),
                              const Text(
                                '8 years exp',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF9EABB8),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Specialty chips
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 8,
                              runSpacing: 8,
                              children: const [
                                _SpecialtyChip('Life Coaching'),
                                _SpecialtyChip('Career'),
                                _SpecialtyChip('Personal Growth'),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── About card ─────────────────────────────────────────
                  _InfoCard(
                    title: 'About',
                    child: const Text(
                      'With over 8 years of experience, I specialize in helping professionals navigate career transitions and achieve work-life balance. My approach combines evidence-based techniques with personalized strategies tailored to your unique goals.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF5A6A7A),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Certifications card ────────────────────────────────
                  _InfoCard(
                    title: 'Certifications',
                    child: Column(
                      children: const [
                        _CertItem('ICF Certified Professional Coach'),
                        _CertItem('Master NLP Practitioner'),
                        _CertItem('Psychology Degree, Stanford University'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Book Session button ────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BookingScreen()),
                          );
                        },
                        icon: const Icon(Icons.calendar_today_rounded,
                            size: 18),
                        label: const Text(
                          'Book Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
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
// Certification Item
// ─────────────────────────────────────────────────────────────────────────────
class _CertItem extends StatelessWidget {
  final String label;
  const _CertItem(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded,
              size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1A2533),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}