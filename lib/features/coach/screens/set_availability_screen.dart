import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../booking/models/availability_model.dart';
import '../../booking/services/availability_service.dart';

class SetAvailabilityScreen extends StatefulWidget {
  const SetAvailabilityScreen({super.key});

  @override
  State<SetAvailabilityScreen> createState() => _SetAvailabilityScreenState();
}

class _SetAvailabilityScreenState extends State<SetAvailabilityScreen> {
  final AvailabilityService _service = AvailabilityService();

  // day → selected time slots
  final Map<String, List<String>> _weeklySlots = {
    'monday': [], 'tuesday': [], 'wednesday': [],
    'thursday': [], 'friday': [], 'saturday': [], 'sunday': [],
  };

  final List<String> _blockedDates = [];
  bool _loading = true;
  bool _saving = false;

  // All possible hour slots
  static const List<String> _allSlots = [
    '08:00','09:00','10:00','11:00','12:00','13:00',
    '14:00','15:00','16:00','17:00','18:00','19:00','20:00',
  ];

  static const List<String> _dayOrder = [
    'monday','tuesday','wednesday','thursday','friday','saturday','sunday',
  ];

  static const Map<String, String> _dayLabels = {
    'monday': 'Monday', 'tuesday': 'Tuesday', 'wednesday': 'Wednesday',
    'thursday': 'Thursday', 'friday': 'Friday', 'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    final avail = await _service.fetchCoachAvailability(uid);
    if (avail != null && mounted) {
      setState(() {
        for (final day in _dayOrder) {
          _weeklySlots[day] = List<String>.from(avail.weeklySlots[day] ?? []);
        }
        _blockedDates
          ..clear()
          ..addAll(avail.blockedDates);
      });
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      final avail = AvailabilityModel(
        coachId: uid,
        weeklySlots: Map.from(_weeklySlots),
        blockedDates: List.from(_blockedDates),
        updatedAt: DateTime.now().toUtc(),
      );
      await _service.saveAvailability(avail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Availability saved!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _pickBlockedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    final key =
        '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    if (!_blockedDates.contains(key)) {
      setState(() => _blockedDates.add(key));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Set Availability',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          _saving
              ? const Padding(
            padding: EdgeInsets.all(14),
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)),
          )
              : TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    color: Color(0xFF4A90D9), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Weekly Schedule',
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Select which time slots you are available each day.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ..._dayOrder.map(_buildDayCard),
          const SizedBox(height: 24),
          const Text('Blocked Dates',
              style:
              TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Dates you will not accept any bookings.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),
          _buildBlockedDatesCard(),
        ],
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final slots = _weeklySlots[day]!;
    final isActive = slots.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? const Color(0xFF4A90D9) : Colors.grey.shade200,
          width: isActive ? 1.5 : 1,
        ),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Text(_dayLabels[day]!,
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isActive ? const Color(0xFF4A90D9) : Colors.black87)),
            const Spacer(),
            if (slots.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${slots.length} slots',
                    style: const TextStyle(
                        fontSize: 12, color: Color(0xFF4A90D9))),
              ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _allSlots.map((slot) {
                final selected = slots.contains(slot);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (selected) {
                        slots.remove(slot);
                      } else {
                        slots.add(slot);
                        slots.sort();
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFF4A90D9)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(slot,
                        style: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.w500,
                            fontSize: 13)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedDatesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_blockedDates.isEmpty)
            const Text('No blocked dates.',
                style: TextStyle(color: Colors.grey)),
          ..._blockedDates.map((d) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text(d, style: const TextStyle(fontSize: 14)),
            trailing: IconButton(
              icon: const Icon(Icons.close, size: 18, color: Colors.red),
              onPressed: () => setState(() => _blockedDates.remove(d)),
            ),
          )),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickBlockedDate,
            icon: const Icon(Icons.add),
            label: const Text('Block a Date'),
          ),
        ],
      ),
    );
  }
}