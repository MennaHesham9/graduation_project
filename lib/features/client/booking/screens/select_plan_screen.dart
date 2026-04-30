import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/user_model.dart';
import '../../../booking/providers/booking_provider.dart';
import '../../screens/booking_screen.dart';

class SelectPlanScreen extends StatelessWidget {
  final UserModel coach;
  const SelectPlanScreen({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final currency = coach.currency ?? 'USD';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Choose a Plan',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Coach info strip
          _CoachStrip(coach: coach),
          const SizedBox(height: 24),
          const Text('Session Type',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _PlanCard(
            icon: Icons.headset_mic_outlined,
            title: 'Audio Session',
            subtitle: 'Voice call · ${coach.sessionDuration ?? 60} min',
            price: coach.singleAudioPrice,
            currency: currency,
            planType: 'single_audio',
            color: const Color(0xFF6C63FF),
          ),
          const SizedBox(height: 12),
          _PlanCard(
            icon: Icons.videocam_outlined,
            title: 'Video Session',
            subtitle: 'Video call · ${coach.sessionDuration ?? 60} min',
            price: coach.singleVideoPrice,
            currency: currency,
            planType: 'single_video',
            color: const Color(0xFF4A90D9),
          ),
          const SizedBox(height: 24),
          const Text('Packages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Save more with multi-session packages',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 12),
          _PlanCard(
            icon: Icons.star_outline,
            title: '4-Session Audio Package',
            subtitle: 'Pick 4 dates · Save 7%',
            price: coach.package4Price,
            currency: currency,
            planType: 'package_audio',
            color: const Color(0xFF43B89C),
            badge: 'SAVE 7%',
          ),
          const SizedBox(height: 12),
          _PlanCard(
            icon: Icons.workspace_premium_outlined,
            title: '8-Session Audio Package',
            subtitle: 'Pick 8 dates · Save 15%',
            price: coach.package8Price,
            currency: currency,
            planType: 'package_audio_8',
            color: const Color(0xFFFF6B6B),
            badge: 'SAVE 15%',
          ),
        ],
      ),
    );
  }
}

class _CoachStrip extends StatelessWidget {
  final UserModel coach;
  const _CoachStrip({required this.coach});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF4A90D9).withOpacity(0.15),
            child: Text(coach.initials,
                style: const TextStyle(
                    color: Color(0xFF4A90D9), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(coach.fullName ?? '',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              Text(coach.professionalTitle ?? coach.coachingCategory ?? '',
                  style:
                  const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double price;
  final String currency;
  final String planType;
  final Color color;
  final String? badge;

  const _PlanCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.currency,
    required this.planType,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // planType 'package_audio_8' → treat as package_audio with 8 slots
        final normalizedPlan =
        planType == 'package_audio_8' ? 'package_audio' : planType;
        final slots = planType == 'package_audio_8' ? 8 : null;

        context.read<BookingProvider>().selectPlan(normalizedPlan, packageSize: slots);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BookingScreen(coach: context
                .findAncestorWidgetOfExactType<SelectPlanScreen>()!
                .coach),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(badge!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style:
                      const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
            Text(
              '$currency ${price.toStringAsFixed(0)}',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}