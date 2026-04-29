import 'package:flutter/material.dart';
import 'package:mindwell/features/client/screens/sessions/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../booking/providers/booking_provider.dart';
import '../../booking/services/availability_service.dart';
import '../../booking/services/booking_service.dart';
import 'client_sessions_screen.dart';

class BookingScreen extends StatefulWidget {
  final UserModel coach;
  const BookingScreen({super.key, required this.coach});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final BookingService _bookingService = BookingService();
  final AvailabilityService _availService = AvailabilityService();

  DateTime _selectedDate = DateTime.now();
  List<String> _availableSlots = [];
  bool _loadingSlots = false;

  @override
  void initState() {
    super.initState();
    _loadSlots(_selectedDate);
  }

  Future<void> _loadSlots(DateTime date) async {
    setState(() => _loadingSlots = true);
    try {
      final booked = await _bookingService.fetchBookedSlots(
          widget.coach.uid, date);
      final available = await _availService.getAvailableSlotsForDate(
        coachId: widget.coach.uid,
        date: date,
        alreadyBookedSlots: booked,
      );
      if (mounted) setState(() => _availableSlots = available);
    } catch (e) {
      if (mounted) setState(() => _availableSlots = []);
    }
    if (mounted) setState(() => _loadingSlots = false);
  }

  DateTime _slotToUtc(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime.utc(_selectedDate.year, _selectedDate.month,
        _selectedDate.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final isPackage = provider.isPackagePlan;
    final required = provider.requiredSlots;
    final selected = provider.selectedSlots;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(isPackage ? 'Pick $required Dates' : 'Pick a Date',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isPackage)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${selected.length}/$required',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildDateStrip(),
          const Divider(height: 1),
          Expanded(
            child: _loadingSlots
                ? const Center(child: CircularProgressIndicator())
                : _buildSlotGrid(provider),
          ),
          _buildBottomBar(context, provider),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    final today = DateTime.now();
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: 30,
        itemBuilder: (_, i) {
          final date = today.add(Duration(days: i));
          final isSelected =
          DateUtils.isSameDay(date, _selectedDate);
          return GestureDetector(
            onTap: () {
              setState(() => _selectedDate = date);
              _loadSlots(date);
            },
            child: Container(
              width: 52,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4A90D9)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4A90D9)
                        : Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat('EEE').format(date),
                      style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? Colors.white70
                              : Colors.grey)),
                  const SizedBox(height: 4),
                  Text('${date.day}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isSelected
                              ? Colors.white
                              : Colors.black87)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSlotGrid(BookingProvider provider) {
    if (_availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text('No available slots on this day',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemCount: _availableSlots.length,
      itemBuilder: (_, i) {
        final slot = _availableSlots[i];
        final slotUtc = _slotToUtc(slot);
        final isSelected = provider.selectedSlots.contains(slotUtc);
        final isFull = !isSelected &&
            provider.selectedSlots.length >= provider.requiredSlots;

        return GestureDetector(
          onTap: isFull ? null : () => provider.toggleSlot(slotUtc),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF4A90D9)
                  : isFull
                  ? Colors.grey.shade100
                  : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF4A90D9)
                    : Colors.grey.shade200,
              ),
            ),
            child: Center(
              child: Text(slot,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : isFull
                          ? Colors.grey.shade400
                          : Colors.black87)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingProvider provider) {
    final canContinue = provider.slotsComplete;
    final client = context.read<AuthProvider>().user;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(provider.error!,
                  style: const TextStyle(color: Colors.red, fontSize: 13)),
            ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: canContinue
                    ? const Color(0xFF4A90D9)
                    : Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: canContinue
                  ? () async {
                final success =
                await provider.lockSelectedSlots(
                  coachId: widget.coach.uid,
                  clientId: client?.uid ?? '',
                );
                if (success && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(
                        coach: widget.coach,
                      ),
                    ),
                  );
                }
              }
                  : null,
              child: provider.isLoading
                  ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : Text(
                canContinue
                    ? 'Continue to Payment'
                    : '${provider.selectedSlots.length}/${provider.requiredSlots} slots selected',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}