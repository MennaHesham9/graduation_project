// lib/features/client/screens/coach_profile_client_side.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/user_photo.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../client/models/coaching_request_model.dart';
import '../../client/services/coaching_request_service.dart';
import '../Request Coaching/request_form_screen.dart';

class CoachProfileClientSide extends StatelessWidget {
  final UserModel coach;

  const CoachProfileClientSide({super.key, required this.coach});

  @override
  Widget build(BuildContext context) {
    // Grab the current client's uid once — safe in a StatelessWidget because
    // AuthProvider is always populated by the time this screen is reachable.
    final clientUid = context.read<AuthProvider>().user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Stack(
        children: [
          // ── Teal header background ─────────────────────────────────────
          Container(
            height: 220,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3A9BAD), Color(0xFF2F8F9D)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // ── Back button ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 10),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Profile card ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.07),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // Avatar
                          Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border:
                              Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: UserPhoto(
                              photoUrl: coach.photoUrl,
                              initials: coach.initials,
                              radius: 45,
                              backgroundColor: const Color(0xFF5BB8C9),
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Name
                          Text(
                            coach.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A2533),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Title
                          Text(
                            coach.professionalTitle ??
                                coach.coachingCategory ??
                                'Coach',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Experience + availability badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.workspace_premium_outlined,
                                  size: 14, color: Color(0xFF9EABB8)),
                              const SizedBox(width: 3),
                              Text(
                                coach.yearsOfExperience != null
                                    ? '${coach.yearsOfExperience} yrs exp'
                                    : 'Experience N/A',
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF9EABB8)),
                              ),
                              const SizedBox(width: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (coach.isAvailable ?? false)
                                      ? const Color(0xFFD1FAE5)
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  (coach.isAvailable ?? false)
                                      ? 'Available'
                                      : 'Unavailable',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: (coach.isAvailable ?? false)
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          // Specialty chips
                          if ((coach.coachingCategories != null &&
                              coach.coachingCategories!.isNotEmpty) ||
                              coach.coachingCategory != null)
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: (coach.coachingCategories?.isNotEmpty
                                    == true
                                    ? coach.coachingCategories!
                                    : [coach.coachingCategory!])
                                    .map((c) => _SpecialtyChip(c))
                                    .toList(),
                              ),
                            ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Bio card ───────────────────────────────────────────
                  if (coach.bio != null && coach.bio!.isNotEmpty)
                    _InfoCard(
                      title: 'About',
                      child: Text(
                        coach.bio!,
                        style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF4B5563)),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── Pricing card ───────────────────────────────────────
                  if (coach.videoPrice != null ||
                      coach.audioPrice != null ||
                      coach.packagePrice != null)
                    _InfoCard(
                      title: 'Session Pricing',
                      child: Column(
                        children: [
                          if (coach.videoPrice != null)
                            _PriceRow(
                              icon: Icons.videocam_outlined,
                              label: 'Video Session',
                              price:
                              '${coach.currency ?? '\$'}${coach.videoPrice!.toStringAsFixed(0)}',
                              duration:
                              '${coach.sessionDuration ?? 60} min',
                            ),
                          if (coach.audioPrice != null)
                            _PriceRow(
                              icon: Icons.phone_outlined,
                              label: 'Audio Session',
                              price:
                              '${coach.currency ?? '\$'}${coach.audioPrice!.toStringAsFixed(0)}',
                              duration:
                              '${coach.sessionDuration ?? 60} min',
                            ),
                          if (coach.packagePrice != null)
                            _PriceRow(
                              icon: Icons.inventory_2_outlined,
                              label: 'Package',
                              price:
                              '${coach.currency ?? '\$'}${coach.packagePrice!.toStringAsFixed(0)}',
                              duration: '4 sessions',
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ── Languages card ─────────────────────────────────────
                  if (coach.languages != null && coach.languages!.isNotEmpty)
                    _InfoCard(
                      title: 'Languages',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: coach.languages!
                            .map((lang) => _SpecialtyChip(lang))
                            .toList(),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // ── Request / Status section ───────────────────────────
                  // StreamBuilder watches for an existing request between
                  // this client and coach in real time.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: StreamBuilder<CoachingRequestModel?>(
                      stream: CoachingRequestService()
                          .streamRequestToCoach(
                        clientId: clientUid,
                        coachId: coach.uid,
                      ),
                      builder: (context, snap) {
                        // While loading, show a neutral button placeholder
                        if (snap.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox(
                            height: 54,
                            child: Center(
                                child: CircularProgressIndicator()),
                          );
                        }

                        final request = snap.data;

                        // ── CASE 1: Accepted ─────────────────────────
                        if (request?.status == 'accepted') {
                          return _StatusCard(
                            icon: Icons.handshake_rounded,
                            iconColor: const Color(0xFF059669),
                            backgroundColor: const Color(0xFFD1FAE5),
                            borderColor: const Color(0xFF6EE7B7),
                            title: 'You\'re connected!',
                            subtitle:
                            '${coach.fullName} is your coach.',
                          );
                        }

                        // ── CASE 2: Pending ──────────────────────────
                        if (request?.status == 'pending') {
                          return _PendingRequestCard(
                            request: request!,
                            coachName: coach.fullName,
                          );
                        }

                        // ── CASE 3: No request / declined ────────────
                        // Show the regular "Request Coaching" button.
                        return SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: (coach.isAvailable ?? false)
                                ? () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    RequestCoachingScreen(
                                        coach: coach),
                              ),
                            )
                                : null,
                            icon: const Icon(Icons.send, size: 18),
                            label: Text(
                              (coach.isAvailable ?? false)
                                  ? 'Request Coaching'
                                  : 'Currently Unavailable',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                              const Color(0xFFD1D5DB),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pending Request Card
// Shows the request details and a "Cancel Request" button.
// ─────────────────────────────────────────────────────────────────────────────
class _PendingRequestCard extends StatefulWidget {
  final CoachingRequestModel request;
  final String coachName;

  const _PendingRequestCard({
    required this.request,
    required this.coachName,
  });

  @override
  State<_PendingRequestCard> createState() => _PendingRequestCardState();
}

class _PendingRequestCardState extends State<_PendingRequestCard> {
  bool _cancelling = false;

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Request'),
        content: Text(
            'Cancel your pending request to ${widget.coachName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Keep'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cancel Request',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _cancelling = true);
    try {
      await CoachingRequestService().cancelRequest(widget.request.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFCD34D), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE68A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.hourglass_top_rounded,
                    size: 20, color: Color(0xFFD97706)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Request Pending',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Awaiting coach response',
                      style: TextStyle(
                          fontSize: 12, color: Color(0xFFB45309)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFFCD34D)),
          const SizedBox(height: 12),

          // ── Goal ────────────────────────────────────────────────────
          _DetailRow(
            label: 'Goal',
            value: widget.request.primaryGoal,
          ),
          const SizedBox(height: 6),
          _DetailRow(
            label: 'Frequency',
            value: widget.request.frequency,
          ),
          const SizedBox(height: 6),
          _DetailRow(
            label: 'Preferred Time',
            value: widget.request.preferredTime,
          ),

          const SizedBox(height: 16),

          // ── Cancel button ───────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _cancelling ? null : _cancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              icon: _cancelling
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Color(0xFFEF4444)),
              )
                  : const Icon(Icons.cancel_outlined,
                  color: Color(0xFFEF4444), size: 18),
              label: Text(
                _cancelling ? 'Cancelling...' : 'Cancel Request',
                style: const TextStyle(
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Status Card (accepted state)
// ─────────────────────────────────────────────────────────────────────────────
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final Color borderColor;
  final String title;
  final String subtitle;

  const _StatusCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: iconColor)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 13,
                        color: iconColor.withOpacity(0.8))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small detail row inside pending card
// ─────────────────────────────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF92400E)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF78350F)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Unchanged helper widgets (kept identical to original)
// ─────────────────────────────────────────────────────────────────────────────
class _SpecialtyChip extends StatelessWidget {
  final String label;
  const _SpecialtyChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5F7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _InfoCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2533),
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String price;
  final String duration;

  const _PriceRow({
    required this.icon,
    required this.label,
    required this.price,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF1A2533))),
          ),
          Text(duration,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF9EABB8))),
          const SizedBox(width: 12),
          Text(
            price,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}