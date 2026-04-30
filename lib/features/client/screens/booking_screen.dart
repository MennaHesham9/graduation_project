// lib/features/client/screens/booking_screen.dart

import 'package:flutter/material.dart';
import 'package:mindwell/features/client/screens/sessions/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../booking/models/availability_model.dart';
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

  // ── NEW: track which days in the strip have any availability ──────────────
  // Key: "yyyy-MM-dd", Value: true = has slots, false = blocked/empty
  final Map<String, bool> _dayAvailability = {};
  bool _loadingDayMap = true;

  @override
  void initState() {
    super.initState();
    _loadDayAvailabilityMap();
  }

  // ── Pre-load availability for the next 30 days ────────────────────────────
  // This reads only coach_availability (1 Firestore read) + booked slots per
  // day (batched). It populates _dayAvailability so the date strip can grey
  // out days that have no open slots before the user taps them.
  Future<void> _loadDayAvailabilityMap() async {
    setState(() => _loadingDayMap = true);

    final avail = await _availService.fetchCoachAvailability(widget.coach.uid);
    if (avail == null) {
      // No availability set at all — mark every day as unavailable
      final today = DateTime.now();
      for (int i = 0; i < 30; i++) {
        final d = today.add(Duration(days: i));
        _dayAvailability[_dateKey(d)] = false;
      }
      if (mounted) setState(() => _loadingDayMap = false);
      return;
    }

    final today = DateTime.now();
    // Fetch booked slots for all 30 days in parallel
    final futures = <Future<MapEntry<String, bool>>>[];

    for (int i = 0; i < 30; i++) {
      final date = today.add(Duration(days: i));
      futures.add(_checkDayHasSlots(date, avail));
    }

    final results = await Future.wait(futures);
    for (final entry in results) {
      _dayAvailability[entry.key] = entry.value;
    }

    // Auto-select the first available day
    final firstAvailable = _firstAvailableDay(today);
    if (mounted) {
      setState(() {
        _loadingDayMap = false;
        if (firstAvailable != null) {
          _selectedDate = firstAvailable;
        }
      });
      _loadSlots(_selectedDate);
    }
  }

  // lib/features/client/screens/booking_screen.dart

  // lib/features/client/screens/booking_screen.dart

  Future<MapEntry<String, bool>> _checkDayHasSlots(
      DateTime date, AvailabilityModel avail) async { // Specify the model type
    final key = _dateKey(date);
    try {
      final booked = await _bookingService.fetchBookedSlots(widget.coach.uid, date);
      final slots = await _availService.getAvailableSlotsForDate(
        coachId: widget.coach.uid,
        date: date,
        alreadyBookedSlots: booked,
        cachedAvail: avail, // Pass the pre-loaded availability model here
      );
      return MapEntry(key, slots.isNotEmpty);
    } catch (e) {
      // Add logging to see if the query fails (e.g., due to a missing Index)
      debugPrint('Availability check failed for $key: $e');
      return MapEntry(key, false);
    }
  }

  DateTime? _firstAvailableDay(DateTime from) {
    for (int i = 0; i < 30; i++) {
      final d = from.add(Duration(days: i));
      if (_dayAvailability[_dateKey(d)] == true) return d;
    }
    return null;
  }

  // ── Load time slots for the selected day ──────────────────────────────────
  Future<void> _loadSlots(DateTime date) async {
    setState(() => _loadingSlots = true);
    try {
      final booked = await _bookingService.fetchBookedSlots(widget.coach.uid, date);
      final available = await _availService.getAvailableSlotsForDate(
        coachId: widget.coach.uid,
        date: date,
        alreadyBookedSlots: booked,
      );
      if (mounted) setState(() => _availableSlots = available);
    } catch (e) {
      debugPrint('Error loading slots: $e');
      if (mounted) setState(() => _availableSlots = []);
    }
    if (mounted) setState(() => _loadingSlots = false);
  }

  DateTime _slotToUtc(String timeStr) {
    final parts = timeStr.split(':');
    return DateTime.utc(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookingProvider>();
    final isPackage = provider.isPackagePlan;
    final required = provider.requiredSlots;
    final selected = provider.selectedSlots;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          isPackage ? 'Pick $required Dates' : 'Pick a Date',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isPackage)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
          // ── Coach availability legend ──────────────────────────────────
          if (!_loadingDayMap)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _LegendDot(color: const Color(0xFF4A90D9)),
                  const SizedBox(width: 6),
                  const Text('Available', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 16),
                  _LegendDot(color: Colors.grey.shade300),
                  const SizedBox(width: 6),
                  const Text('No slots', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          _buildDateStrip(),
          const Divider(height: 1),
          // ── Selected date label ────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            width: double.infinity,
            child: Text(
              DateFormat('EEEE, MMMM d').format(_selectedDate),
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333)),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loadingDayMap || _loadingSlots
                ? const Center(child: CircularProgressIndicator())
                : _buildSlotGrid(provider),
          ),
          _buildBottomBar(context, provider),
        ],
      ),
    );
  }

  // ── Date strip with availability colouring ────────────────────────────────
  Widget _buildDateStrip() {
    final today = DateTime.now();
    return Container(
      color: Colors.white,
      height: 90,
      child: _loadingDayMap
          ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
          : ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: 30,
        itemBuilder: (_, i) {
          final date = today.add(Duration(days: i));
          final key = _dateKey(date);
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final hasSlots = _dayAvailability[key] ?? false;
          final isToday = i == 0;

          return GestureDetector(
            onTap: hasSlots
                ? () {
              setState(() => _selectedDate = date);
              _loadSlots(date);
            }
                : null, // disabled if no slots
            child: Opacity(
              opacity: hasSlots ? 1.0 : 0.4,
              child: Container(
                width: 56,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF4A90D9)
                      : hasSlots
                      ? Colors.white
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF4A90D9)
                        : hasSlots
                        ? Colors.grey.shade200
                        : Colors.grey.shade200,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isToday ? 'Today' : DateFormat('EEE').format(date),
                      style: TextStyle(
                        fontSize: isToday ? 10 : 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? Colors.white70
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    // Green dot = has slots, grey dot = none
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.7)
                            : hasSlots
                            ? const Color(0xFF4CAF50)
                            : Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Time slot grid ────────────────────────────────────────────────────────
  Widget _buildSlotGrid(BookingProvider provider) {
    if (_availableSlots.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            const Text(
              'No available slots on this day',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 6),
            Text(
              'Try another date with a green dot',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
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
              child: Text(
                _formatSlot(slot),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : isFull
                      ? Colors.grey.shade400
                      : Colors.black87,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Convert "14:00" → "2:00 PM"
  String _formatSlot(String slot) {
    final parts = slot.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final dt = DateTime(2000, 1, 1, h, m);
    return DateFormat('h:mm a').format(dt);
  }

  // ── Bottom action bar ─────────────────────────────────────────────────────
  Widget _buildBottomBar(BuildContext context, BookingProvider provider) {
    final canContinue = provider.slotsComplete;
    final client = context.read<AuthProvider>().user;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
                final success = await provider.lockSelectedSlots(
                  coachId: widget.coach.uid,
                  clientId: client?.uid ?? '',
                );
                if (success && mounted) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PaymentScreen(coach: widget.coach),
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
                    color: Colors.white, strokeWidth: 2),
              )
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

// ── Small legend dot widget ───────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  final Color color;
  const _LegendDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}