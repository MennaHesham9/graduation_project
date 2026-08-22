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
      home: const ManageSessionScreen(),
    );
  }
}

class ManageSessionScreen extends StatefulWidget {
  const ManageSessionScreen({super.key});

  @override
  State<ManageSessionScreen> createState() => _ManageSessionScreenState();
}

class _ManageSessionScreenState extends State<ManageSessionScreen> {
  DateTime? _selectedDate;
  String? _selectedTime;
  final TextEditingController _reasonController = TextEditingController();

  final List<String> _times = [
    '09:00 AM', '10:00 AM', '11:00 AM',
    '01:00 PM', '02:00 PM', '03:00 PM',
    '04:00 PM',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: Column(
          children: [
            // ── APP BAR ──
            _buildAppBar(),

            // ── SCROLLABLE BODY ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Session info card
                    _buildSessionInfoCard(),
                    const SizedBox(height: 14),

                    // Reschedule section
                    _buildRescheduleCard(),
                    const SizedBox(height: 14),

                    // Cancellation policy
                    _buildCancellationPolicy(),
                    const SizedBox(height: 10),

                    // Note
                    _buildNoteCard(),
                    const SizedBox(height: 14),

                    // Cancel session card
                    _buildCancelSessionCard(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── BOTTOM BUTTON ──
            _buildBottomButton(),
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
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF1A1A2E)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Manage My Session',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // SESSION INFO CARD
  // ─────────────────────────────────────────
  Widget _buildSessionInfoCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coach row
          Row(
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF1EAABB),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'DR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Dr. Rebecca Martinez',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Life & Career Coach',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date & Time row
          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  icon: Icons.calendar_today_outlined,
                  iconColor: const Color(0xFF1EAABB),
                  topLabel: 'Date',
                  mainValue: 'Thu, Mar 20',
                  subValue: '2026',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoChip(
                  icon: Icons.access_time_rounded,
                  iconColor: const Color(0xFF1EAABB),
                  topLabel: 'Time',
                  mainValue: '2:00 PM',
                  subValue: 'EST',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Session type chip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FBFD),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF1EAABB).withValues(alpha: 0.2), width: 1),
            ),
            child: Row(
              children: const [
                Icon(Icons.videocam_outlined,
                    color: Color(0xFF1EAABB), size: 18),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Video Session',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1EAABB),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '50 minutes • One-on-One Coaching',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // RESCHEDULE CARD
  // ─────────────────────────────────────────
  Widget _buildRescheduleCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reschedule Session',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),

          // Select New Date label
          const Text(
            'Select New Date',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),

          // Date picker field
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 90)),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            child: Container(
              width: double.infinity,
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      color: Color(0xFF9CA3AF), size: 18),
                  const SizedBox(width: 10),
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select a date',
                    style: TextStyle(
                      fontSize: 13,
                      color: _selectedDate != null
                          ? const Color(0xFF1A1A2E)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Available Times label
          const Text(
            'Available Times',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 10),

          // Time chips grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _times.map((t) {
              final selected = _selectedTime == t;
              return GestureDetector(
                onTap: () => setState(() => _selectedTime = t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF1EAABB)
                        : const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFF1EAABB)
                          : const Color(0xFFE5E7EB),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    t,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? Colors.white
                          : const Color(0xFF4B5563),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          // Reason for change
          const Text(
            'Reason for Change (Optional)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),

          TextField(
            controller: _reasonController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
            decoration: InputDecoration(
              hintText: "Let your coach know why you need to resch...",
              hintStyle: const TextStyle(
                  fontSize: 13, color: Color(0xFF9CA3AF)),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                const BorderSide(color: Color(0xFF1EAABB), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // CANCELLATION POLICY
  // ─────────────────────────────────────────
  Widget _buildCancellationPolicy() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFFF59E0B), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Cancellation Policy',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Please cancel at least 12 hours before your session to avoid being charged.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF92400E),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // NOTE CARD
  // ─────────────────────────────────────────
  Widget _buildNoteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded,
              color: Color(0xFF3B82F6), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Note',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E40AF),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Your coach will receive a notification and will confirm the new time. You'll be notified once confirmed.",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1E40AF),
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // CANCEL SESSION CARD
  // ─────────────────────────────────────────
  Widget _buildCancelSessionCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cancel Session',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Need to cancel? Remember to do so at least 12 hours in advance.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              height: 1.5,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 16),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side:
                const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Cancel This Session',
                style: TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // BOTTOM BUTTON
  // ─────────────────────────────────────────
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.refresh_rounded,
                color: Color(0xFF6B7280), size: 18),
            label: const Text(
              'Request Reschedule',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// WHITE CARD WRAPPER
// ─────────────────────────────────────────────────────────────────
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// INFO CHIP (date / time box)
// ─────────────────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String topLabel;
  final String mainValue;
  final String subValue;

  const _InfoChip({
    required this.icon,
    required this.iconColor,
    required this.topLabel,
    required this.mainValue,
    required this.subValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                topLabel,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                mainValue,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              Text(
                subValue,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}