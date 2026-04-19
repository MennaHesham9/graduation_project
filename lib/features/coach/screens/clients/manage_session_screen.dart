import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ManageSessionScreen extends StatefulWidget {
  const ManageSessionScreen({super.key});

  @override
  State<ManageSessionScreen> createState() => _ManageSessionScreenState();
}

class _ManageSessionScreenState extends State<ManageSessionScreen> {
  int? _selectedTimeSlot;
  final _reasonController = TextEditingController();

  final List<String> _timeSlots = [
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
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 6)],
                      ),
                      child: const Icon(Icons.arrow_back, size: 18, color: Color(0xFF1A1A2E)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('Manage Session', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // ── Client + session info ──
                    _Card(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: const Color(0xFF27AE60),
                                child: const Text('EJ', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Emma Johnson', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                  Text('Client since Jan 2026', style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A))),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFFF0F8FF), borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Row(children: [
                                        Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                                        SizedBox(width: 6),
                                        Text('Date', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                                      ]),
                                      SizedBox(height: 4),
                                      Text('Thu, Mar 20', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: const Color(0xFFF0F8FF), borderRadius: BorderRadius.circular(10)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Row(children: [
                                        Icon(Icons.access_time_outlined, size: 14, color: AppColors.primary),
                                        SizedBox(width: 6),
                                        Text('Time', style: TextStyle(fontSize: 11, color: AppColors.primary)),
                                      ]),
                                      SizedBox(height: 4),
                                      Text('2:00 PM', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(10)),
                            child: Row(
                              children: const [
                                Icon(Icons.videocam_outlined, size: 16, color: Color(0xFF8A8A9A)),
                                SizedBox(width: 8),
                                Text('Video Session', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                                SizedBox(width: 8),
                                Text('50 minutes', style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Reschedule ──
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Reschedule Session', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 14),

                          const Text('New Date', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFCCCC)),
                            ),
                          ),
                          const SizedBox(height: 14),

                          const Text('Available Time Slots', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: List.generate(_timeSlots.length, (i) {
                              final selected = _selectedTimeSlot == i;
                              return GestureDetector(
                                onTap: () => setState(() => _selectedTimeSlot = i),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: selected ? AppColors.primary : const Color(0xFFE0E0EE)),
                                  ),
                                  child: Text(
                                    _timeSlots[i],
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: selected ? AppColors.primary : const Color(0xFF1A1A2E),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: const [
                              Text('Reason for Reschedule', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                              SizedBox(width: 6),
                              Text('(Optional)', style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A))),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF0F0),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFFCCCC)),
                            ),
                            child: TextField(
                              controller: _reasonController,
                              maxLines: 3,
                              style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)),
                              decoration: const InputDecoration(
                                hintText: 'Let your client know why you need to re...',
                                hintStyle: TextStyle(color: Color(0xFFB0B0C0), fontSize: 13),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Notification info ──
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFD0DEFF)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 18),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Notification', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF3B82F6))),
                                SizedBox(height: 4),
                                Text(
                                  'Your client will receive an email and in-app notification about the rescheduled session.',
                                  style: TextStyle(fontSize: 12, color: Color(0xFF3B82F6), height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Cancel session ──
                    _Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Cancel Session', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                          const SizedBox(height: 6),
                          const Text(
                            'If you need to cancel this session, please provide a reason to help your client understand.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF8A8A9A), height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFE53935)),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Cancel This Session', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Confirm button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                  label: const Text('Confirm Reschedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: child,
    );
  }
}