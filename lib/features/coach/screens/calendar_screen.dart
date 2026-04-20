import 'package:flutter/material.dart';

void main() {
  runApp(const MindWellApp());
}

class MindWellApp extends StatelessWidget {
  const MindWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindWell',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const CalendarScreen(),
    );
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDay = 4;
  bool _availableForBookings = true;
  int _selectedNavIndex = 1;

  // December 2025 starts on Monday (weekday index 1 in DateTime)
  // We show Sun=0 ... Sat=6, so Dec 1 falls on column index 1 (Mon)
  final int _firstWeekdayOffset = 1; // Mon
  final int _daysInMonth = 31;

  // Days that have session dots
  final Set<int> _sessionDays = {4, 5, 8, 12, 19, 22, 26, 29};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR ──
            _buildAppBar(),

            // ── SCROLLABLE CONTENT ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Column(
                  children: [
                    const SizedBox(height: 14),

                    // Month navigator
                    _buildMonthNavigator(),

                    const SizedBox(height: 12),

                    // Available for bookings toggle
                    _buildAvailabilityToggle(),

                    const SizedBox(height: 12),

                    // Calendar grid
                    _buildCalendarGrid(),

                    const SizedBox(height: 14),

                    // Today's schedule
                    _buildTodaysSchedule(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // ── BOTTOM NAV ──
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // APP BAR
  // ─────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(6, 10, 14, 10),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF1A1A2E)),
            onPressed: () {},
          ),
          const Expanded(
            child: Text(
              'Calendar',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFF1EAABB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // MONTH NAVIGATOR
  // ─────────────────────────────────────────
  Widget _buildMonthNavigator() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.chevron_left,
                color: Color(0xFF6B7280), size: 24),
          ),
          const Text(
            'December 2025',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: const Icon(Icons.chevron_right,
                color: Color(0xFF6B7280), size: 24),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // AVAILABILITY TOGGLE
  // ─────────────────────────────────────────
  Widget _buildAvailabilityToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Available for Bookings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1A1A2E),
            ),
          ),
          Switch(
            value: _availableForBookings,
            onChanged: (v) => setState(() => _availableForBookings = v),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF1EAABB),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFD1D5DB),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // CALENDAR GRID
  // ─────────────────────────────────────────
  Widget _buildCalendarGrid() {
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
      child: Column(
        children: [
          // Weekday headers
          Row(
            children: weekdays.map((d) {
              return Expanded(
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),

          // Day grid
          _buildDayGrid(),
        ],
      ),
    );
  }

  Widget _buildDayGrid() {
    // Build a flat list of cells: offset blanks + day cells
    final totalCells = _firstWeekdayOffset + _daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: List.generate(7, (col) {
              final cellIndex = row * 7 + col;
              final day = cellIndex - _firstWeekdayOffset + 1;

              // Blank cells (before month starts or after month ends)
              if (day < 1 || day > _daysInMonth) {
                return Expanded(
                  child: _DayCell(
                    day: day < 1
                        ? (30 + day) // previous month tail days
                        : day - _daysInMonth, // not shown
                    isCurrentMonth: false,
                    isSelected: false,
                    hasDot: false,
                  ),
                );
              }

              final isSelected = day == _selectedDay;
              final hasDot = _sessionDays.contains(day);

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedDay = day),
                  child: _DayCell(
                    day: day,
                    isCurrentMonth: true,
                    isSelected: isSelected,
                    hasDot: hasDot,
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────
  // TODAY'S SCHEDULE
  // ─────────────────────────────────────────
  Widget _buildTodaysSchedule() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Schedule",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 14),
          _ScheduleTile(
            name: 'Sarah Johnson',
            time: '2:00 PM',
            detail: 'Career Transition • 60 min',
            accentColor: const Color(0xFF1EAABB),
            bgColor: const Color(0xFFF0FBFD),
          ),
          const SizedBox(height: 10),
          _ScheduleTile(
            name: 'James Miller',
            time: '4:00 PM',
            detail: 'Life Balance • 60 min',
            accentColor: const Color(0xFF8B5CF6),
            bgColor: const Color(0xFFF5F3FF),
          ),
          const SizedBox(height: 10),
          _ScheduleTile(
            name: 'Emma Davis',
            time: '6:00 PM',
            detail: 'Relationships • 60 min',
            accentColor: const Color(0xFF22C55E),
            bgColor: const Color(0xFFF0FDF4),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // BOTTOM NAV
  // ─────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Calendar'},
      {'icon': Icons.people_alt_outlined, 'label': 'Clients'},
      {'icon': Icons.account_balance_wallet_outlined, 'label': 'Wallet'},
      {'icon': Icons.person_outline_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final selected = _selectedNavIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _selectedNavIndex = i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 60,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        items[i]['icon'] as IconData,
                        size: 22,
                        color: selected
                            ? const Color(0xFF1EAABB)
                            : const Color(0xFFB0B8C1),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        items[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? const Color(0xFF1EAABB)
                              : const Color(0xFFB0B8C1),
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// DAY CELL
// ─────────────────────────────────────────────────────────────────
class _DayCell extends StatelessWidget {
  final int day;
  final bool isCurrentMonth;
  final bool isSelected;
  final bool hasDot;

  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isSelected,
    required this.hasDot,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: isSelected
                ? const BoxDecoration(
              color: Color(0xFF1EAABB),
              shape: BoxShape.circle,
            )
                : null,
            child: Center(
              child: Text(
                isCurrentMonth ? '$day' : '',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? Colors.white
                      : isCurrentMonth
                      ? const Color(0xFF1A1A2E)
                      : const Color(0xFFD1D5DB),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          if (hasDot && !isSelected)
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: Color(0xFF1EAABB),
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SCHEDULE TILE
// ─────────────────────────────────────────────────────────────────
class _ScheduleTile extends StatelessWidget {
  final String name;
  final String time;
  final String detail;
  final Color accentColor;
  final Color bgColor;

  const _ScheduleTile({
    required this.name,
    required this.time,
    required this.detail,
    required this.accentColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 4,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                bottomLeft: Radius.circular(10),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          time,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}