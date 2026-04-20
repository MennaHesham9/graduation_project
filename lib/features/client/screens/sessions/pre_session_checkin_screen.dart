import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PreSessionCheckinScreen extends StatefulWidget {
  const PreSessionCheckinScreen({super.key});

  @override
  State<PreSessionCheckinScreen> createState() =>
      _PreSessionCheckinScreenState();
}

class _PreSessionCheckinScreenState extends State<PreSessionCheckinScreen> {
  final _goalController = TextEditingController();
  int? _selectedMoodIndex; // 0=Very Low, 1=Low, 2=Neutral, 3=Good, 4=Great

  final List<_MoodOption> _moods = const [
    _MoodOption(emoji: '😢', label: 'Very Low'),
    _MoodOption(emoji: '😐', label: 'Low'),
    _MoodOption(emoji: '😶', label: 'Neutral'),
    _MoodOption(emoji: '🙂', label: 'Good'),
    _MoodOption(emoji: '😊', label: 'Great'),
  ];

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: SafeArea(
        child: Column(
          children: [
            // Fixed header
            _buildHeader(context),

            // Scrollable body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  children: [
                    // Upcoming Session card
                    _buildSessionCard(),
                    const SizedBox(height: 28), // increased from 16

                    // Goal card
                    _buildGoalCard(),
                    const SizedBox(height: 16),

                    // Mood card
                    _buildMoodCard(),
                    const SizedBox(height: 16),

                    // Session tip card
                    _buildTipCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Submit button pinned to bottom
      bottomNavigationBar: _buildSubmitButton(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: const Color(0xFFF0F2F8),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.07),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 18,
                    color: Color(0xFF0A0A0A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Pre-Session Check-In',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0A0A0A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Help your coach prepare for the session',
            style: TextStyle(
              fontSize: 13,
              color: Color(0x800A0A0A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Session',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.80),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Dr. Michael Chen',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 14, color: Colors.white.withValues(alpha: 0.85)),
              const SizedBox(width: 5),
              Text(
                'Today at 2:00 PM  •  60 minutes',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'What is your goal for today\'s session?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A0A0A),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _goalController,
              maxLines: 5,
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF0A0A0A),
              ),
              decoration: InputDecoration(
                hintText: 'E.g., I want to discuss my career transition and create an action plan...',
                hintStyle: const TextStyle(
                  fontSize: 14,
                  color: Color(0x800A0A0A),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How are you feeling today?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0A0A0A),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_moods.length, (index) {
              final isSelected = _selectedMoodIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _selectedMoodIndex = index),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      width: isSelected ? 62 : 54,
                      height: isSelected ? 62 : 54,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.10)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          style: TextStyle(
                            fontSize: isSelected ? 34 : 28,
                          ),
                          child: Text(_moods[index].emoji),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : const Color(0x800A0A0A),
                      ),
                      child: Text(_moods[index].label),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF4F4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('💡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session Tip',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your responses help your coach provide more personalized support during your session.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      color: const Color(0xFFF0F2F8),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            // Handle submit & join session
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_outlined, size: 18, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Submit & Join Session',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MoodOption {
  final String emoji;
  final String label;
  const _MoodOption({required this.emoji, required this.label});
}