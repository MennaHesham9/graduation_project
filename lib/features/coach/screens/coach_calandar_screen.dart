import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/auth_provider.dart';
import '../../booking/models/booking_model.dart';
import '../../booking/services/booking_service.dart';
import '../../booking/services/availability_service.dart';
import '../../../core/services/auth_service.dart';
import 'set_availability_screen.dart';

class CoachCalendarScreen extends StatefulWidget {
  const CoachCalendarScreen({super.key});

  @override
  State<CoachCalendarScreen> createState() => _CoachCalendarScreenState();
}

class _CoachCalendarScreenState extends State<CoachCalendarScreen> {
  final BookingService _bookingService = BookingService();
  final AvailabilityService _availService = AvailabilityService();
  final AuthService _authService = AuthService();

  DateTime _focusedMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();
  Map<String, bool> _daysWithSessions = {};

  @override
  void initState() {
    super.initState();
    _loadMonthDots();
  }

  String get _coachId =>
      context.read<AuthProvider>().user?.uid ?? '';

  Future<void> _loadMonthDots() async {
    if (_coachId.isEmpty) return;
    final daysInMonth = DateUtils.getDaysInMonth(
        _focusedMonth.year, _focusedMonth.month);
    final Map<String, bool> result = {};
    for (int d = 1; d <= daysInMonth; d++) {
      final date =
      DateTime(_focusedMonth.year, _focusedMonth.month, d);
      final sessions = await _bookingService
          .streamCoachSessionsForDate(_coachId, date)
          .first;
      if (sessions.isNotEmpty) {
        result['$d'] = true;
      }
    }
    if (mounted) setState(() => _daysWithSessions = result);
  }

  Future<void> _toggleAvailability(bool value) async {
    final uid = _coachId;
    if (uid.isEmpty) return;
    await _authService.updateProfile(uid, {'isAvailable': value});
    context.read<AuthProvider>().refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isAvailable = user?.isAvailable ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('My Calendar',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Row(
            children: [
              Text(isAvailable ? 'Available' : 'Unavailable',
                  style: TextStyle(
                      fontSize: 12,
                      color: isAvailable ? Colors.green : Colors.grey)),
              Switch(
                value: isAvailable,
                onChanged: _toggleAvailability,
                activeTrackColor: Colors.green,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Set Availability',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const SetAvailabilityScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCalendarHeader(),
          _buildCalendarGrid(),
          const Divider(height: 1),
          Expanded(child: _buildSessionsForDay()),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                    _focusedMonth.year, _focusedMonth.month - 1);
              });
              _loadMonthDots();
            },
          ),
          Text(
            DateFormat('MMMM yyyy').format(_focusedMonth),
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _focusedMonth = DateTime(
                    _focusedMonth.year, _focusedMonth.month + 1);
              });
              _loadMonthDots();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final firstDay =
    DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(
        _focusedMonth.year, _focusedMonth.month);
    final startOffset = (firstDay.weekday % 7); // Sun=0

    final cells = <Widget>[];
    for (final label in ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa']) {
      cells.add(Center(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey))));
    }
    for (int i = 0; i < startOffset; i++) cells.add(const SizedBox());
    for (int d = 1; d <= daysInMonth; d++) {
      final date =
      DateTime(_focusedMonth.year, _focusedMonth.month, d);
      final isSelected = DateUtils.isSameDay(date, _selectedDate);
      final isToday = DateUtils.isSameDay(date, DateTime.now());
      final hasDot = _daysWithSessions['$d'] ?? false;

      cells.add(GestureDetector(
        onTap: () => setState(() => _selectedDate = date),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? const Color(0xFF4A90D9)
                    : isToday
                    ? const Color(0xFF4A90D9).withValues(alpha: 0.1)
                    : null,
              ),
              child: Center(
                child: Text(
                  '$d',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : isToday
                          ? const Color(0xFF4A90D9)
                          : Colors.black87),
                ),
              ),
            ),
            if (hasDot)
              Container(
                width: 5,
                height: 5,
                margin: const EdgeInsets.only(top: 2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4A90D9),
                ),
              ),
          ],
        ),
      ));
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1,
        children: cells,
      ),
    );
  }

  Widget _buildSessionsForDay() {
    if (_coachId.isEmpty) return const SizedBox();
    return StreamBuilder<List<BookingModel>>(
      stream: _bookingService.streamCoachSessionsForDate(
          _coachId, _selectedDate),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = snap.data ?? [];
        if (sessions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 48, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  'No sessions on ${DateFormat('MMM d').format(_selectedDate)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (_, i) => _SessionTile(session: sessions[i]),
        );
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  final BookingModel session;
  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final localTime = session.scheduledAtUtc.toLocal();
    final timeStr = DateFormat('h:mm a').format(localTime);
    final isVideo = session.type == SessionType.video;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isVideo ? Icons.videocam_outlined : Icons.headset_mic_outlined,
              color: const Color(0xFF4A90D9),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(session.clientName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(
                  '$timeStr · ${session.durationMinutes} min · ${isVideo ? 'Video' : 'Audio'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          _StatusBadge(session.status),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SessionStatus status;
  const _StatusBadge(this.status);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case SessionStatus.confirmed:
        color = Colors.green;
        label = 'Confirmed';
        break;
      case SessionStatus.rescheduled:
        color = Colors.orange;
        label = 'Rescheduled';
        break;
      case SessionStatus.completed:
        color = Colors.blue;
        label = 'Done';
        break;
      case SessionStatus.cancelled:
        color = Colors.red;
        label = 'Cancelled';
        break;
      default:
        color = Colors.grey;
        label = 'Pending';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}