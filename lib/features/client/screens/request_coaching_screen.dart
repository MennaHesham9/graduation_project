// lib/features/client/screens/request_coaching_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/user_photo.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';

import '../models/coaching_request_model.dart';
import '../services/coaching_request_service.dart';
import '../widgets/client_nav_bar.dart';

class RequestCoachingScreen extends StatefulWidget {
  final UserModel coach; // ✅ real coach passed in

  const RequestCoachingScreen({super.key, required this.coach});

  @override
  State<RequestCoachingScreen> createState() => _RequestCoachingScreenState();
}

class _RequestCoachingScreenState extends State<RequestCoachingScreen> {
  String _selectedFrequency = 'Weekly';
  String _selectedTime = 'Morning';
  bool _isLoading = false;

  final _goalController = TextEditingController();
  final _challengesController = TextEditingController();
  final _notesController = TextEditingController();

  final List<String> _frequencies = ['Weekly', 'Twice a week', 'Flexible'];
  final List<String> _times = ['Morning', 'Afternoon', 'Evening'];

  @override
  void dispose() {
    _goalController.dispose();
    _challengesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitRequest() async {
    // ── Validation ──────────────────────────────────────
    if (_goalController.text.trim().isEmpty) {
      _showError('Please enter your primary goal.');
      return;
    }
    if (_challengesController.text.trim().isEmpty) {
      _showError('Please describe your current challenges.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final client = context.read<AuthProvider>().user;
      if (client == null) throw Exception('Not logged in');

      final request = CoachingRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: client.uid,
        clientName: client.fullName ?? 'Unknown',
        coachName: widget.coach.fullName,
        coachId: widget.coach.uid,
        primaryGoal: _goalController.text.trim(),
        currentChallenges: _challengesController.text.trim(),
        frequency: _selectedFrequency,
        preferredTime: _selectedTime,
        additionalNotes: _notesController.text.trim(),
        status: 'pending',
        createdAt: DateTime.now(),
      );

      await CoachingRequestService().sendRequest(request);

      if (!mounted) return;

      // ── Navigate to success screen ──────────────────
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RequestSentScreen(coachName: widget.coach.fullName ?? 'your coach'),
        ),
      );
    } catch (e) {
      _showError('Failed to send request. Please try again.');
    }

    setState(() => _isLoading = false);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coach = widget.coach;

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.primary, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Request Coaching',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E)),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // ── Coach Card (real data) ──────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Avatar
                          UserPhoto.square(
                            photoUrl: coach.photoUrl,
                            initials: coach.initials,
                            size: 64,
                            borderRadius: 12,
                            backgroundColor: const Color(0xFF5BB8C9),
                            initialsStyle: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                coach.fullName ?? 'Coach',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E)),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                coach.professionalTitle ??
                                    coach.coachingCategory ??
                                    'Coach',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.workspace_premium_outlined,
                                      size: 14, color: Color(0xFF888888)),
                                  const SizedBox(width: 4),
                                  Text(
                                    coach.yearsOfExperience != null
                                        ? '${coach.yearsOfExperience} yrs exp'
                                        : 'Experience N/A',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF888888)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ── Primary Goal ────────────────────────────────
                    _buildLabel('Primary Goal', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _goalController,
                      hint: 'What do you want to achieve?',
                      maxLines: 1,
                    ),

                    const SizedBox(height: 20),

                    // ── Current Challenges ──────────────────────────
                    _buildLabel('Current Challenges', required: true),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _challengesController,
                      hint: 'Describe the challenges you\'re facing...',
                      maxLines: 5,
                    ),

                    const SizedBox(height: 22),

                    // ── Frequency ───────────────────────────────────
                    _buildLabel('Preferred Session Frequency'),
                    const SizedBox(height: 10),
                    Column(
                      children: _frequencies.map((freq) {
                        final bool isSelected = _selectedFrequency == freq;
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedFrequency = freq),
                          child: Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 18),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Text(
                              freq,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF1A1A2E)),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 10),

                    // ── Preferred Time ──────────────────────────────
                    _buildLabel('Preferred Time'),
                    const SizedBox(height: 10),
                    Row(
                      children: _times.map((time) {
                        final bool isSelected = _selectedTime == time;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedTime = time),
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: time != _times.last ? 8 : 0),
                              padding:
                              const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.04),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2)),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  time,
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF1A1A2E)),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 22),

                    // ── Additional Notes ────────────────────────────
                    Row(
                      children: const [
                        Text('Additional Notes ',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A1A2E))),
                        Text('(Optional)',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF9E9E9E))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _notesController,
                      hint: 'Any other information you\'d like to share',
                      maxLines: 4,
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── Submit Button ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Icon(Icons.send_rounded, size: 20),
                  label: Text(
                    _isLoading ? 'Sending...' : 'Submit Request',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, {bool required = false}) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
        if (required)
          const Text(' *',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required int maxLines,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        minLines: maxLines,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
          const TextStyle(fontSize: 14, color: Color(0xFFBDBDBD)),
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide:
            const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Request Sent Confirmation Screen
// ─────────────────────────────────────────────────────────────────────────────
class RequestSentScreen extends StatelessWidget {
  final String coachName; // ✅ real coach name

  const RequestSentScreen({super.key, required this.coachName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 38, height: 38,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.arrow_back,
                          color: AppColors.primary, size: 20),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    color: AppColors.primary, size: 64),
              ),
              const SizedBox(height: 28),
              const Text('Request Sent!',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E))),
              const SizedBox(height: 14),
              Text(
                'Your coaching request has been\nsuccessfully sent to $coachName.\nYou\'ll hear back shortly.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 15, height: 1.6, color: Color(0xFF6B7280)),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity, height: 54,
                child: ElevatedButton(
                  onPressed: () =>
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ClientNavBar()),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Back to Home',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}