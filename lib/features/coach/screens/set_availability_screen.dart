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

  // UI state: day → local-time slot strings the coach sees and taps.
  // These are always in the coach's LOCAL timezone (e.g. "10:00" = 10 AM local).
  // They are converted to UTC only on save, and back to local on load.
  final Map<String, List<String>> _weeklySlots = {
    'monday': [], 'tuesday': [], 'wednesday': [],
    'thursday': [], 'friday': [], 'saturday': [], 'sunday': [],
  };

  final List<String> _blockedDates = [];
  bool _loading = true;
  bool _saving = false;

  // All possible hour slots shown in the UI — these are LOCAL time labels.
  static const List<String> _allSlots = [
    '06:00','07:00','08:00','09:00','10:00','11:00','12:00','13:00',
    '14:00','15:00','16:00','17:00','18:00','19:00','20:00','21:00','22:00',
  ];

  static const List<String> _dayOrder = [
    'monday','tuesday','wednesday','thursday','friday','saturday','sunday',
  ];

  static const Map<String, String> _dayLabels = {
    'monday': 'Monday', 'tuesday': 'Tuesday', 'wednesday': 'Wednesday',
    'thursday': 'Thursday', 'friday': 'Friday', 'saturday': 'Saturday',
    'sunday': 'Sunday',
  };

  // Maps weekday index (DateTime.weekday: Mon=1 … Sun=7) to day name string.
  static const List<String> _weekdayIndexToName = [
    '', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday',
  ];

  // ── Timezone conversion helpers ───────────────────────────────────────────

  /// Converts a UTC "HH:mm" slot stored in Firestore to the coach's local
  /// "HH:mm" label for display. Returns null if the conversion is impossible
  /// (shouldn't happen with valid data).
  ///
  /// We use a fixed reference Monday (any concrete date works; we only care
  /// about the time-of-day and potential day-of-week shift).
  static final DateTime _refMonday = _findNextMonday();

  static DateTime _findNextMonday() {
    var d = DateTime.now();
    while (d.weekday != DateTime.monday) {
      d = d.add(const Duration(days: 1));
    }
    return DateTime(d.year, d.month, d.day); // midnight local, a Monday
  }

  /// Given a UTC day-name + "HH:mm" pair from Firestore, produce the
  /// corresponding local day-name + "HH:mm" pair for the UI.
  ({String day, String time}) _utcSlotToLocal(String utcDay, String utcTime) {
    final dayOffset = _dayOrder.indexOf(utcDay); // 0 = Monday … 6 = Sunday
    final parts = utcTime.split(':');
    // Build the UTC DateTime for that slot using our reference week.
    final utcDt = DateTime.utc(
      _refMonday.year,
      _refMonday.month,
      _refMonday.day + dayOffset,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final localDt = utcDt.toLocal();
    final localDay = _weekdayIndexToName[localDt.weekday];
    final localTime =
        '${localDt.hour.toString().padLeft(2, '0')}:${localDt.minute.toString().padLeft(2, '0')}';
    return (day: localDay, time: localTime);
  }

  /// Given a local day-name + "HH:mm" from the UI, produce the
  /// corresponding UTC day-name + "HH:mm" to store in Firestore.
  ({String day, String time}) _localSlotToUtc(String localDay, String localTime) {
    final dayOffset = _dayOrder.indexOf(localDay);
    final parts = localTime.split(':');
    // Build the local DateTime for that slot using our reference week.
    final localDt = DateTime(
      _refMonday.year,
      _refMonday.month,
      _refMonday.day + dayOffset,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final utcDt = localDt.toUtc();
    final utcDay = _weekdayIndexToName[utcDt.weekday];
    final utcTime =
        '${utcDt.hour.toString().padLeft(2, '0')}:${utcDt.minute.toString().padLeft(2, '0')}';
    return (day: utcDay, time: utcTime);
  }

  // ── Load / Save ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Loads UTC slots from Firestore and converts them to local-time UI state.
  Future<void> _load() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    final avail = await _service.fetchCoachAvailability(uid);
    if (avail != null && mounted) {
      // Build fresh local-time map from the stored UTC map.
      final localMap = <String, List<String>>{
        for (final d in _dayOrder) d: [],
      };
      for (final utcDay in _dayOrder) {
        for (final utcTime in (avail.weeklySlots[utcDay] ?? [])) {
          final local = _utcSlotToLocal(utcDay, utcTime);
          localMap[local.day]?.add(local.time);
        }
      }
      // Sort each day's slots so they display in order.
      for (final d in _dayOrder) {
        localMap[d]?.sort();
      }

      setState(() {
        for (final d in _dayOrder) {
          _weeklySlots[d] = localMap[d]!;
        }
        _blockedDates
          ..clear()
          ..addAll(avail.blockedDates);
      });
    }
    if (mounted) setState(() => _loading = false);
  }

  /// Converts local-time UI state to UTC slots and saves to Firestore.
  Future<void> _save() async {
    final uid = context.read<AuthProvider>().user?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      // Build the UTC map from local-time UI state.
      final utcMap = <String, List<String>>{
        for (final d in _dayOrder) d: [],
      };
      for (final localDay in _dayOrder) {
        for (final localTime in _weeklySlots[localDay]!) {
          final utc = _localSlotToUtc(localDay, localTime);
          utcMap[utc.day]?.add(utc.time);
        }
      }
      // Sort each day's UTC slots.
      for (final d in _dayOrder) {
        utcMap[d]?.sort();
      }

      final avail = AvailabilityModel(
        coachId: uid,
        weeklySlots: utcMap,
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

  // ── Build ─────────────────────────────────────────────────────────────────

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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text(
            'Select your available times. All times are in your local timezone.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ..._dayOrder.map(_buildDayCard),
          const SizedBox(height: 24),
          const Text('Blocked Dates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                    color: isActive
                        ? const Color(0xFF4A90D9)
                        : Colors.black87)),
            const Spacer(),
            if (slots.isNotEmpty)
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
                    // Display local-time label in 12h format for readability.
                    child: Text(
                      _formatLocalSlot(slot),
                      style: TextStyle(
                          color:
                          selected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                          fontSize: 13),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a local "HH:mm" string into a 12-hour label like "2:00 PM".
  String _formatLocalSlot(String slot) {
    final parts = slot.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    final period = h < 12 ? 'AM' : 'PM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final mm = m.toString().padLeft(2, '0');
    return '$h12:$mm $period';
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