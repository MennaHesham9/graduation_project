import 'package:flutter/material.dart';
import 'package:gradproject/features/client/screens/wheel_of_lise_screen.dart';
import '../../../../core/constants/app_colors.dart';

class AssessmentsScreen extends StatelessWidget {
  const AssessmentsScreen({super.key});

  static const List<_AssessmentData> _items = [
    _AssessmentData(
      title: 'Wheel of Life',
      description: 'Evaluate your life balance across 8 key areas',
      duration: '10 min',
      gradientColors: [Color(0xFF3AAAB8), Color(0xFF1F7A87)],
      icon: Icons.radio_button_checked_rounded,
      completed: false,
    ),
    _AssessmentData(
      title: 'Strengths\nAssessment',
      description: 'Discover your top personal and professional strengths',
      duration: '15 min',
      gradientColors: [Color(0xFFFFC04D), Color(0xFFF59300)],
      icon: Icons.flash_on_rounded,
      completed: true,
    ),
    _AssessmentData(
      title: 'Values Clarification',
      description: 'Identify what matters most to you in life',
      duration: '12 min',
      gradientColors: [Color(0xFFFF6EB4), Color(0xFFE4258A)],
      icon: Icons.favorite_rounded,
      completed: false,
    ),
    _AssessmentData(
      title: 'Productivity Patterns',
      description: 'Understand your peak performance times',
      duration: '8 min',
      gradientColors: [Color(0xFF5BAAEE), Color(0xFF2B7FD4)],
      icon: Icons.show_chart_rounded,
      completed: false,
    ),
    _AssessmentData(
      title: 'Energy Audit',
      description: 'Track what energizes and drains you',
      duration: '10 min',
      gradientColors: [Color(0xFF3DD68C), Color(0xFF1A9E60)],
      icon: Icons.videocam_rounded,
      completed: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECEDF4),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── App bar ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F3F8),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Assessments',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Self-discovery tools to understand\nyourself better',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF555570),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── Cards ──
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => _AssessmentCard(data: _items[i]),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Card ─────────────────────────────────────────────────────────────────────

class _AssessmentCard extends StatelessWidget {
  final _AssessmentData data;
  const _AssessmentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9090B0).withValues(alpha: 0.13),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Gradient icon box ──
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: data.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(data.icon, color: Colors.white, size: 30),
          ),

          const SizedBox(width: 16),

          // ── Content ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title + Completed badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        data.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                          height: 1.35,
                        ),
                      ),
                    ),
                    if (data.completed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F9EF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Completed',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1FAD6A),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 7),

                // Description
                Text(
                  data.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF555570),
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 14),

                // Duration + action button
                Row(
                  children: [
                    const Icon(Icons.access_time_outlined, size: 14, color: Color(0xFFAAAAAA)),
                    const SizedBox(width: 5),
                    Text(
                      data.duration,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                    const Spacer(),

                    // Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WheelOfLifeScreen(),
                            ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
                        decoration: BoxDecoration(
                          color: data.completed ? Colors.white : AppColors.primary,
                          borderRadius: BorderRadius.circular(22),
                          border: data.completed
                              ? Border.all(color: const Color(0xFFDDDDEE), width: 1.5)
                              : null,
                          boxShadow: data.completed
                              ? null
                              : [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.30),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow_rounded,
                              size: 17,
                              color: data.completed ? const Color(0xFF9A9AAF) : Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              data.completed ? 'Review' : 'Start',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: data.completed ? const Color(0xFF9A9AAF) : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ────────────────────────────────────────────────────────────────

class _AssessmentData {
  final String title;
  final String description;
  final String duration;
  final List<Color> gradientColors;
  final IconData icon;
  final bool completed;

  const _AssessmentData({
    required this.title,
    required this.description,
    required this.duration,
    required this.gradientColors,
    required this.icon,
    required this.completed,
  });
}