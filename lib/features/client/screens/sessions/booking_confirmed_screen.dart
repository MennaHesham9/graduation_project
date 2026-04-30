import 'package:flutter/material.dart';
import 'package:mindwell/features/client/widgets/client_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/user_model.dart';
import '../../../booking/providers/booking_provider.dart';

class BookingConfirmedScreen extends StatelessWidget {
  final UserModel coach;
  const BookingConfirmedScreen({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<BookingProvider>();
    final slots = provider.selectedSlots;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.green, size: 54),
              ),
              const SizedBox(height: 24),
              const Text('Booking Confirmed!',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(
                'Your session${slots.length > 1 ? 's are' : ' is'} confirmed with ${coach.fullName ?? 'your coach'}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 32),
              // Sessions list
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: slots
                      .asMap()
                      .entries
                      .map((e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90D9)
                                .withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${e.key + 1}',
                                style: const TextStyle(
                                    color: Color(0xFF4A90D9),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('EEE, MMM d · h:mm a')
                              .format(e.value.toLocal()),
                          style: const TextStyle(
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ))
                      .toList(),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    provider.resetBookingWizard();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ClientNavBar()),
                          (_) => false,
                    );
                  },
                  child: const Text('Back to Home',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}