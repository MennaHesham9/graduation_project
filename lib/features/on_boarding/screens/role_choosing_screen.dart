// lib/features/auth/screens/role_choosing_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../authentication/screens/sign_in_screen.dart';
import '../../authentication/screens/signup_client_screen.dart';
import '../../authentication/screens/signup_coach_screen.dart';


class RoleChoosingScreen extends StatefulWidget {
  const RoleChoosingScreen({super.key});

  @override
  State<RoleChoosingScreen> createState() => _RoleChoosingScreenState();
}

class _RoleChoosingScreenState extends State<RoleChoosingScreen> {
  // null = nothing selected yet
  bool? _isClient;

  void _onContinue() {
    if (_isClient == null) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => _isClient!
            ? const SignupClientScreen()
            : const SignupCoachScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF0F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── App icon ─────────────────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(height: 24),

              // ── Title ────────────────────────────────────────────────────
              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2533),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Let's get started by understanding how\nyou'd like to use our platform",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF7A8A9A),
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 2),

              // ── Role cards ───────────────────────────────────────────────
              _RoleCard(
                selected: _isClient == true,
                onTap: () => setState(() => _isClient = true),
                iconColor: const Color(0xFFE8F5F7),
                icon: Icons.people_alt_outlined,
                iconTint: AppColors.primary,
                title: "I'm a Client",
                description:
                "I'm looking for a coach to help me achieve my personal and professional goals",
                bullets: const [
                  'Find and book certified coaches',
                  'Track goals and progress',
                  'Video sessions and chat support',
                ],
              ),

              const SizedBox(height: 16),

              _RoleCard(
                selected: _isClient == false,
                onTap: () => setState(() => _isClient = false),
                iconColor: const Color(0xFFECEBFF),
                icon: Icons.work_outline_rounded,
                iconTint: const Color(0xFF5B5BD6),
                title: "I'm a Coach",
                description:
                "I'm a professional coach ready to help clients transform their lives",
                bullets: const [
                  'Manage clients and sessions',
                  'Track client progress',
                  'Grow your coaching practice',
                ],
              ),

              const Spacer(flex: 3),

              // ── Continue button ──────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isClient != null ? _onContinue : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: const Color(0xFFD8DDE5),
                    foregroundColor: Colors.white,
                    disabledForegroundColor: const Color(0xFF9EABB8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Role Card
// ─────────────────────────────────────────────────────────────────────────────
class _RoleCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Color iconColor;
  final IconData icon;
  final Color iconTint;
  final String title;
  final String description;
  final List<String> bullets;

  const _RoleCard({
    required this.selected,
    required this.onTap,
    required this.iconColor,
    required this.icon,
    required this.iconTint,
    required this.title,
    required this.description,
    required this.bullets,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFE2E8F0),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.12),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon bubble
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: iconTint, size: 24),
            ),
            const SizedBox(width: 14),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: selected
                          ? const Color(0xFF1A2533)
                          : const Color(0xFF1A2533),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5A6A7A),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...bullets.map(
                        (b) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : const Color(0xFF9EABB8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              b,
                              style: TextStyle(
                                fontSize: 12,
                                color: selected
                                    ? const Color(0xFF3A4A5A)
                                    : const Color(0xFF7A8A9A),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
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
}