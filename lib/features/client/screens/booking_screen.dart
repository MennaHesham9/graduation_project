// lib/features/client/screens/booking_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // ── State ─────────────────────────────────────────────────────────────────
  late DateTime _focusedMonth;
  DateTime? _selectedDay;
  String? _selectedTime;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
  }

  // ── Dummy available days per month (day numbers) ──────────────────────────
  // In a real app these come from the coach's availability API
  List<int> get _availableDaysInMonth {
    final m = _focusedMonth.month;
    // Mock: odd months have different available days
    if (m % 2 == 0) {
      return [2, 5, 7, 9, 12, 14, 16, 19, 21, 23, 26, 28];
    } else {
      return [1, 3, 5, 8, 10, 13, 15, 17, 20, 22, 24, 27, 29];
    }
  }

  // ── Dummy available times ─────────────────────────────────────────────────
  final List<String> _availableTimes = [
    '09:00 AM', '10:00 AM', '11:00 AM',
    '02:00 PM', '03:00 PM', '04:00 PM',
    '05:00 PM', '06:00 PM',
  ];

  // ── Helpers ───────────────────────────────────────────────────────────────
  String get _monthLabel {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[_focusedMonth.month - 1]} ${_focusedMonth.year}';
  }

  String get _selectedDateLabel {
    if (_selectedDay == null) return '—';
    const days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    final wd = _selectedDay!.weekday - 1;
    return '${days[wd]}, ${months[_selectedDay!.month - 1]} ${_selectedDay!.day}, ${_selectedDay!.year}';
  }

  // Days visible in the horizontal strip: start from today or 1st of month
  List<DateTime> get _stripDays {
    final now = DateTime.now();
    final isCurrentMonth = _focusedMonth.year == now.year &&
        _focusedMonth.month == now.month;
    final startDay = isCurrentMonth ? now.day : 1;
    final daysInMonth =
    DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);

    return List.generate(
      daysInMonth - startDay + 1,
          (i) => DateTime(_focusedMonth.year, _focusedMonth.month, startDay + i),
    );
  }

  String _dayLabel(DateTime d) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return labels[d.weekday - 1];
  }

  void _prevMonth() {
    final now = DateTime.now();
    final prev = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    if (prev.isBefore(DateTime(now.year, now.month))) return;
    setState(() {
      _focusedMonth = prev;
      _selectedDay = null;
      _selectedTime = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth =
          DateTime(_focusedMonth.year, _focusedMonth.month + 1);
      _selectedDay = null;
      _selectedTime = null;
    });
  }

  bool _isDayAvailable(DateTime day) =>
      _availableDaysInMonth.contains(day.day);

  bool get _canContinue => _selectedDay != null && _selectedTime != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── App Bar ────────────────────────────────────────────────────
            _BookingAppBar(onBack: () => Navigator.of(context).pop()),

            // ── Scrollable content ─────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Month Picker + Day Strip ──────────────────────────
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Month navigation row
                          Row(
                            children: [
                              Icon(Icons.calendar_month_outlined,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _monthLabel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A2533),
                                  ),
                                ),
                              ),
                              _MonthNavBtn(
                                icon: Icons.chevron_left_rounded,
                                onTap: _prevMonth,
                              ),
                              const SizedBox(width: 6),
                              _MonthNavBtn(
                                icon: Icons.chevron_right_rounded,
                                onTap: _nextMonth,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Horizontal day strip
                          SizedBox(
                            height: 72,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _stripDays.length,
                              itemBuilder: (context, index) {
                                final day = _stripDays[index];
                                final available = _isDayAvailable(day);
                                final selected = _selectedDay != null &&
                                    _selectedDay!.day == day.day &&
                                    _selectedDay!.month == day.month &&
                                    _selectedDay!.year == day.year;

                                return GestureDetector(
                                  onTap: available
                                      ? () => setState(() {
                                    _selectedDay = day;
                                    _selectedTime = null;
                                  })
                                      : null,
                                  child: AnimatedContainer(
                                    duration:
                                    const Duration(milliseconds: 200),
                                    width: 54,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.primary
                                          : available
                                          ? Colors.white
                                          : const Color(0xFFF8FAFC),
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.primary
                                            : available
                                            ? const Color(0xFFE2E8F0)
                                            : const Color(0xFFF0F4F8),
                                      ),
                                      boxShadow: selected
                                          ? [
                                        BoxShadow(
                                          color: AppColors.primary
                                              .withOpacity(0.3),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        )
                                      ]
                                          : [],
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _dayLabel(day),
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: selected
                                                ? Colors.white
                                                : available
                                                ? const Color(0xFF9EABB8)
                                                : const Color(0xFFD0D8E0),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${day.day}',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: selected
                                                ? Colors.white
                                                : available
                                                ? const Color(0xFF1A2533)
                                                : const Color(0xFFD0D8E0),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Available Times ───────────────────────────────────
                    _WhiteCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              const Text(
                                'Available Times',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1A2533),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _selectedDay == null
                              ? Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              child: Text(
                                'Please select a day first',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: const Color(0xFF9EABB8),
                                ),
                              ),
                            ),
                          )
                              : Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: _availableTimes.map((time) {
                              final selected =
                                  _selectedTime == time;
                              return GestureDetector(
                                onTap: () => setState(
                                        () => _selectedTime = time),
                                child: AnimatedContainer(
                                  duration: const Duration(
                                      milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 11),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : const Color(0xFFF0F4F8),
                                    borderRadius:
                                    BorderRadius.circular(10),
                                    boxShadow: selected
                                        ? [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withOpacity(0.25),
                                        blurRadius: 6,
                                        offset:
                                        const Offset(0, 2),
                                      )
                                    ]
                                        : [],
                                  ),
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: selected
                                          ? Colors.white
                                          : const Color(0xFF5A6A7A),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Session Summary ───────────────────────────────────
                    if (_selectedDay != null && _selectedTime != null)
                      _SessionSummary(
                        date: _selectedDateLabel,
                        time: _selectedTime!,
                      ),

                    if (_selectedDay != null && _selectedTime != null)
                      const SizedBox(height: 24),

                    // ── Continue to Payment button ─────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _canContinue
                            ? () {
                          // TODO: navigate to payment screen
                        }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                          const Color(0xFFB0D8DD),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Continue to Payment',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App Bar
// ─────────────────────────────────────────────────────────────────────────────
class _BookingAppBar extends StatelessWidget {
  final VoidCallback onBack;
  const _BookingAppBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  size: 16, color: Color(0xFF1A2533)),
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose Date & Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2533),
                ),
              ),
              Text(
                'Select your preferred session time',
                style: TextStyle(
                    fontSize: 12, color: Color(0xFF9EABB8)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Month Nav Button
// ─────────────────────────────────────────────────────────────────────────────
class _MonthNavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MonthNavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F4F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1A2533)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Session Summary Card
// ─────────────────────────────────────────────────────────────────────────────
class _SessionSummary extends StatelessWidget {
  final String date;
  final String time;
  const _SessionSummary({required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Summary',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A2533),
            ),
          ),
          const SizedBox(height: 14),
          _SummaryRow(label: 'Coach',    value: 'Dr. Michael Chen'),
          _SummaryRow(label: 'Date',     value: date),
          _SummaryRow(label: 'Time',     value: time),
          _SummaryRow(label: 'Duration', value: '60 minutes'),
          const Divider(height: 20, color: Color(0xFFF0F4F8)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2533),
                ),
              ),
              Text(
                '\$75',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Color(0xFF9EABB8)),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A2533),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// White Card wrapper
// ─────────────────────────────────────────────────────────────────────────────
class _WhiteCard extends StatelessWidget {
  final Widget child;
  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}