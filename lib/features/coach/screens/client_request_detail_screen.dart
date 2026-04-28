// lib/features/coach/screens/client_request_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../client/models/coaching_request_model.dart';
import '../../client/services/coaching_request_service.dart';

class ClientRequestDetailScreen extends StatefulWidget {
  final CoachingRequestModel request;
  final String coachName;

  const ClientRequestDetailScreen({
    super.key,
    required this.request,
    required this.coachName,
  });

  @override
  State<ClientRequestDetailScreen> createState() =>
      _ClientRequestDetailScreenState();
}

class _ClientRequestDetailScreenState
    extends State<ClientRequestDetailScreen> {
  final _requestService = CoachingRequestService();
  bool _isLoading = false;

  Future<void> _accept() async {
    setState(() => _isLoading = true);
    try {
      await _requestService.acceptRequest(
        requestId: widget.request.id,
        clientId: widget.request.clientId,
        coachId: widget.request.coachId, // ← ADDED: needed for transaction
        coachName: widget.coachName,
        clientName: widget.request.clientName,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${widget.request.clientName} accepted!'),
            backgroundColor: Colors.green.shade700,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _decline() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reject Request'),
        content: Text(
            'Are you sure you want to reject ${widget.request.clientName}\'s request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reject',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _requestService.declineRequest(
        requestId: widget.request.id,
        clientId: widget.request.clientId,
        coachName: widget.coachName,
      );
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final req = widget.request;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFAF5FF),
                      Color(0xFFEFF6FF),
                      Color(0xFFFDF2F8),
                    ],
                    stops: [0.0, 0.5, 1.0],
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileCard(req),
                      const SizedBox(height: 20),
                      _buildGoalsCard(req),
                      const SizedBox(height: 20),
                      _buildSessionPrefsCard(req),
                      if (req.additionalNotes?.isNotEmpty == true) ...[
                        const SizedBox(height: 20),
                        _buildNoteCard(req.additionalNotes!),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  // ── APP BAR ──
  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 69,
      padding: const EdgeInsets.fromLTRB(8, 0, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.898),
        border: const Border(
            bottom: BorderSide(color: Color(0xFFEFF6FF), width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 18, color: Color(0xFF1A1A2E)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            'Client Request',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
    );
  }

  // ── PROFILE CARD ──
  Widget _buildProfileCard(CoachingRequestModel req) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    _initials(req.clientName),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.clientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                            width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle,
                              size: 6, color: AppColors.primary),
                          const SizedBox(width: 5),
                          Text(
                            'New Request',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatDate(req.createdAt),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    'Requested Date',
                    style: TextStyle(
                        fontSize: 11, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── GOALS CARD ──
  Widget _buildGoalsCard(CoachingRequestModel req) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Goals & Challenges',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 14),
          _GoalTile(label: req.primaryGoal),
          const SizedBox(height: 8),
          _GoalTile(label: req.currentChallenges),
        ],
      ),
    );
  }

  // ── SESSION PREFERENCES CARD ──
  Widget _buildSessionPrefsCard(CoachingRequestModel req) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Preferences',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 14),
          _prefRow(Icons.repeat_outlined, 'Frequency', req.frequency),
          const SizedBox(height: 10),
          _prefRow(Icons.access_time_outlined, 'Preferred Time',
              req.preferredTime),
        ],
      ),
    );
  }

  Widget _prefRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF1A1A2E))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF4B5563))),
        ),
      ],
    );
  }

  // ── NOTE CARD ──
  Widget _buildNoteCard(String note) {
    return _DetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Note from Client',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FFFE),
              borderRadius: BorderRadius.circular(10),
              border:
              Border.all(color: const Color(0xFFEFF6FF), width: 1),
            ),
            child: Text(
              '"$note"',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w400,
                height: 1.6,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── BOTTOM ACTIONS ──
  Widget _buildBottomActions() {
    if (_isLoading) {
      return Container(
        height: 120,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.949),
          border: const Border(
              top: BorderSide(color: Color(0xFFEFF6FF), width: 1)),
        ),
        child: const CircularProgressIndicator(),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 21, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.949),
        border: const Border(
            top: BorderSide(color: Color(0xFFEFF6FF), width: 1)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Accept button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8)
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ElevatedButton(
                onPressed: _accept,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_outline_rounded,
                        color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Accept Client',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Reject button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _decline,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                    color: Color(0xFFEF4444), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined,
                      color: Color(0xFFEF4444), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Reject Request',
                    style: TextStyle(
                      color: Color(0xFFEF4444),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name
        .substring(0, name.length >= 2 ? 2 : 1)
        .toUpperCase();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

// ── Reusable card wrapper ──
class _DetailCard extends StatelessWidget {
  final Widget child;
  const _DetailCard({required this.child});

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
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GoalTile extends StatelessWidget {
  final String label;
  const _GoalTile({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: const Color(0xFF1EAABB).withOpacity(0.15), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF1A1A2E),
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}