import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'coach_home_screen.dart';
import 'coach_clients_screen.dart';
import 'coach_wallet_screen.dart';
import 'coach_profile_screen.dart';

// ─── Data Models ────────────────────────────────────────────────────────────

class _Session {
  final String clientName;
  final String time;
  final String topic;
  final Color borderColor;
  final Color bgColor;
  final Color timeColor;

  const _Session({
    required this.clientName,
    required this.time,
    required this.topic,
    required this.borderColor,
    required this.bgColor,
    required this.timeColor,
  });
}

// ─── Main Screen ─────────────────────────────────────────────────────────────

class CoachCalendarScreen extends StatefulWidget {
  const CoachCalendarScreen({super.key});

  @override
  State<CoachCalendarScreen> createState() => _CoachCalendarScreenState();
}

class _CoachCalendarScreenState extends State<CoachCalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  bool _availableForBookings = true;

  /// Days that have sessions (dot indicator), keyed by day number of the month.
  final Set<int> _sessionDays = {2, 5, 8, 10, 12, 15, 17, 19, 22, 26, 29};

  /// Sample sessions per selected date (day number → list of sessions).
  final Map<int, List<_Session>> _sessionsByDay = {
    4: [
      _Session(
        clientName: 'Sarah Johnson',
        time: '2:00 PM',
        topic: 'Career Transition • 60 min',
        borderColor: const Color(0xFF2B7FFF),
        bgColor: const Color(0xFFEFF6FF),
        timeColor: const Color(0xFF155DFC),
      ),
      _Session(
        clientName: 'James Miller',
        time: '4:00 PM',
        topic: 'Life Balance • 60 min',
        borderColor: AppColors.primary,
        bgColor: const Color(0xFFFAF5FF),
        timeColor: AppColors.primary,
      ),
      _Session(
        clientName: 'Emma Davis',
        time: '6:00 PM',
        topic: 'Relationships • 60 min',
        borderColor: const Color(0xFF00C950),
        bgColor: const Color(0xFFF0FDF4),
        timeColor: const Color(0xFF00A63E),
      ),
    ],
  };

  // ── Calendar helpers ────────────────────────────────────────────────────

  int get _daysInMonth =>
      DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);

  int get _firstWeekdayOfMonth =>
      DateTime(_focusedMonth.year, _focusedMonth.month, 1).weekday % 7;

  String get _monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
      _selectedDate = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDate = null;
    });
  }

  bool _isToday(int day) {
    final now = DateTime.now();
    return _focusedMonth.year == now.year &&
        _focusedMonth.month == now.month &&
        day == now.day;
  }

  bool _isSelected(int day) =>
      _selectedDate != null &&
          _selectedDate!.year == _focusedMonth.year &&
          _selectedDate!.month == _focusedMonth.month &&
          _selectedDate!.day == day;

  List<_Session> get _todaySessions {
    if (_selectedDate != null) {
      return _sessionsByDay[_selectedDate!.day] ?? [];
    }
    final now = DateTime.now();
    if (_focusedMonth.year == now.year && _focusedMonth.month == now.month) {
      return _sessionsByDay[now.day] ?? _sessionsByDay[4] ?? [];
    }
    return _sessionsByDay[4] ?? [];
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-0.7, -1),
            end: Alignment(1, 1),
            colors: [
              Color(0xFFFAF5FF),
              Color(0xFFEFF6FF),
              Color(0xFFFDF2F8),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                  child: Column(
                    children: [
                      _buildAvailabilityToggle(),
                      const SizedBox(height: 20),
                      _buildCalendarCard(),
                      const SizedBox(height: 20),
                      _buildScheduleCard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              _iconButton(
                color: const Color(0xFFF3F4F6),
                onTap: () => Navigator.maybePop(context),
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 16,
                  color: Color(0xFF101828),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Calendar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                    height: 1.5,
                  ),
                ),
              ),
              _iconButton(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
                ),
                onTap: () {},
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Month navigation row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _iconButton(
                onTap: _previousMonth,
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  size: 20,
                  color: Color(0xFF101828),
                ),
              ),
              Text(
                _monthLabel,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828),
                  height: 1.5,
                ),
              ),
              _iconButton(
                onTap: _nextMonth,
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Color(0xFF101828),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _iconButton({
    Color? color,
    Gradient? gradient,
    required VoidCallback onTap,
    required Widget icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: gradient == null ? (color ?? Colors.transparent) : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(child: icon),
      ),
    );
  }

  // ── Availability Toggle ─────────────────────────────────────────────────

  Widget _buildAvailabilityToggle() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Available for Bookings',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF101828),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(
                    () => _availableForBookings = !_availableForBookings),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 56,
              height: 32,
              decoration: BoxDecoration(
                gradient: _availableForBookings
                    ? const LinearGradient(
                  colors: [Color(0xFF00C950), Color(0xFF00BC7D)],
                )
                    : null,
                color: _availableForBookings ? null : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                alignment: _availableForBookings
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.all(4),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Calendar Card ───────────────────────────────────────────────────────

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildWeekdayHeaders(),
          const SizedBox(height: 12),
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      children: days
          .map(
            (d) => Expanded(
          child: Center(
            child: Text(
              d,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4A5565),
                fontWeight: FontWeight.w500,
                height: 1.33,
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final totalCells = _firstWeekdayOfMonth + _daysInMonth;
    final rows = (totalCells / 7).ceil();
    final now = DateTime.now();

    return Column(
      children: List.generate(rows, (rowIdx) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(7, (colIdx) {
              final cellIdx = rowIdx * 7 + colIdx;
              final day = cellIdx - _firstWeekdayOfMonth + 1;

              if (day < 1 || day > _daysInMonth) {
                // Previous / next month overflow days
                final overflowDay = day < 1
                    ? DateUtils.getDaysInMonth(
                    _focusedMonth.year, _focusedMonth.month - 1) +
                    day
                    : day - _daysInMonth;
                return Expanded(
                  child: _calendarCell(
                    label: '$overflowDay',
                    isOverflow: true,
                  ),
                );
              }

              final selected = _isSelected(day);
              final today = _isToday(day);
              final hasSession = _sessionDays.contains(day);

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate =
                          DateTime(_focusedMonth.year, _focusedMonth.month, day);
                    });
                  },
                  child: _calendarCell(
                    label: '$day',
                    isSelected: selected,
                    isToday: today,
                    hasSession: hasSession,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _calendarCell({
    required String label,
    bool isOverflow = false,
    bool isSelected = false,
    bool isToday = false,
    bool hasSession = false,
  }) {
    Color textColor;
    Decoration? decoration;

    if (isSelected) {
      textColor = Colors.white;
      decoration = BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else if (isOverflow) {
      textColor = const Color(0xFF99A1AF);
      decoration = null;
    } else {
      textColor = const Color(0xFF101828);
      decoration = BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
      );
    }

    return Container(
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: decoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
              fontWeight: FontWeight.w500,
              height: 1.43,
            ),
          ),
          if (hasSession) ...[
            const SizedBox(height: 2),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFF2B7FFF),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Schedule Card ───────────────────────────────────────────────────────

  Widget _buildScheduleCard() {
    final sessions = _todaySessions;
    final label = _selectedDate != null
        ? '${_selectedDate!.day} ${_monthLabel.split(' ').first} Schedule'
        : "Today's Schedule";

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF101828),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          if (sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'No sessions scheduled',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF99A1AF),
                  ),
                ),
              ),
            )
          else
            ...sessions.asMap().entries.map((entry) {
              final i = entry.key;
              final s = entry.value;
              return Padding(
                padding: EdgeInsets.only(bottom: i < sessions.length - 1 ? 12 : 0),
                child: _buildSessionTile(s),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSessionTile(_Session session) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
      decoration: BoxDecoration(
        color: session.bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border(
          left: BorderSide(color: session.borderColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  session.clientName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF101828),
                    height: 1.5,
                  ),
                ),
                Text(
                  session.time,
                  style: TextStyle(
                    fontSize: 14,
                    color: session.timeColor,
                    fontWeight: FontWeight.w500,
                    height: 1.43,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                session.topic,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4A5565),
                  height: 1.43,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}