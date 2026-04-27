import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../client/models/coaching_request_model.dart';

class CoachClientProfileScreen extends StatefulWidget {
  final CoachingRequestModel client; // ← add this

  const CoachClientProfileScreen({super.key, required this.client}); // ← add this

  @override
  State<CoachClientProfileScreen> createState() =>
      _CoachClientProfileScreenState();
}

class _CoachClientProfileScreenState extends State<CoachClientProfileScreen> {
  int _selectedStatus = 0;

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Helper: initials from full name ──
  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // ── Helper: "Mar 18" format ──
  String _formatDate(DateTime dt) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(-0.95, -1.0),
          end: Alignment(0.95, 1.0),
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFEFF6FF),
            Color(0xFFFDF2F8),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        children: [
          _buildHeroHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              children: [
                _buildStatsRow(),
                const SizedBox(height: 20),
                _buildClientStatusCard(),
                const SizedBox(height: 20),
                _buildClientInfoCard(),       // ← NEW: real request data
                const SizedBox(height: 20),
                _buildProgressOverviewCard(context),
                const SizedBox(height: 20),
                _buildEmotionalPatternsCard(),
                const SizedBox(height: 20),
                _buildSessionNotesCard(context),
                const SizedBox(height: 20),
                _buildTasksAssignedCard(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Hero Header ─────────────────────────────────────────────────────────────

  Widget _buildHeroHeader(BuildContext context) {
    // Use MediaQuery to get top padding (status bar) dynamically
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 12, // dynamic instead of hardcoded 48
        left: 24,
        right: 24,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-0.75, -1.0),
          end: Alignment(0.75, 1.0),
          colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 25,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top nav row
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Client Profile',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Avatar + info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with initials (real data) — slightly smaller on small screens
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 50,
                      offset: const Offset(0, 25),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Container(
                    color: Colors.white.withOpacity(0.25),
                    child: Center(
                      child: Text(
                        _initials(widget.client.clientName), // ← real initials
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name + sessions + buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.client.clientName, // ← real name
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Since ${_formatDate(widget.client.createdAt)}', // ← real date
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 8),

                    // Message + Call buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                _snack(context, 'Opening message...'),
                            child: Container(
                              height: 34,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.chat_bubble_outline_rounded,
                                      size: 15, color: Colors.white),
                                  SizedBox(width: 5),
                                  Text('Message',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _snack(context, 'Calling...'),
                          child: Container(
                            height: 34,
                            width: 72,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.phone_outlined,
                                    size: 15, color: Colors.white),
                                SizedBox(width: 5),
                                Text('Call',
                                    style: TextStyle(
                                        fontSize: 13, color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Assign Task button
                    GestureDetector(
                      onTap: () => _showAssignTaskSheet(context),
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 6,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_task_rounded,
                                size: 18, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text('Assign Task',
                                style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.primary)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(value: '75%', label: 'Progress'),
        const SizedBox(width: 12),
        _buildStatCard(value: '3', label: 'Active Goals'),
        const SizedBox(width: 12),
        _buildStatCard(value: '8', label: 'Tasks Done'),
      ],
    );
  }

  Widget _buildStatCard({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
        child: Column(
          children: [
            Text(value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF101828))),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF4A5565))),
          ],
        ),
      ),
    );
  }

  // ─── Client Info Card (real request data) ────────────────────────────────────

  Widget _buildClientInfoCard() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            title: 'Coaching Request Details',
            icon: Icons.assignment_outlined,
          ),
          const SizedBox(height: 16),

          // Primary Goal
          _infoRow(Icons.flag_outlined, 'Primary Goal',
              widget.client.primaryGoal),
          const SizedBox(height: 12),

          // Challenges
          _infoRow(Icons.psychology_outlined, 'Current Challenges',
              widget.client.currentChallenges),
          const SizedBox(height: 12),

          // Frequency
          _infoRow(Icons.repeat_outlined, 'Frequency',
              widget.client.frequency),
          const SizedBox(height: 12),

          // Preferred Time
          _infoRow(Icons.access_time_outlined, 'Preferred Time',
              widget.client.preferredTime),

          // Additional Notes (only if present)
          if (widget.client.additionalNotes?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notes_outlined,
                        size: 15, color: Colors.grey.shade400),
                    const SizedBox(width: 8),
                    const Text('Notes',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E))),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FFFE),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFFEFF6FF), width: 1),
                  ),
                  child: Text(
                    '"${widget.client.additionalNotes!}"',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      fontStyle: FontStyle.italic,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: Colors.grey.shade400),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E))),
        Expanded(
          child: Text(value,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF4B5563))),
        ),
      ],
    );
  }

  // ─── Client Status Card ───────────────────────────────────────────────────────

  Widget _buildClientStatusCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 21, 21, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E8FF)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10)),
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Client Status',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF101828))),
          const SizedBox(height: 16),
          Container(
            height: 56,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildStatusTab(0, 'Current Client'),
                _buildStatusTab(1, 'Past Client'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF00C950).withOpacity(0.51),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _selectedStatus == 0
                      ? 'This client is actively receiving coaching'
                      : 'This client is no longer active',
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF4A5565)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTab(int index, String label) {
    final isSelected = _selectedStatus == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedStatus = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 48,
          decoration: isSelected
              ? BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C950), Color(0xFF00BC7D)],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 10)),
                    BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 4)),
                  ],
                )
              : BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isSelected) ...[
                const Icon(Icons.circle, size: 10, color: Colors.white),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : const Color(0xFF4A5565)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Progress Overview ────────────────────────────────────────────────────────

  Widget _buildProgressOverviewCard(BuildContext context) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            title: 'Progress Overview',
            icon: Icons.bar_chart_rounded,
            onTap: () =>
                _snack(context, 'Full progress report coming soon'),
          ),
          const SizedBox(height: 16),
          _buildProgressBar(
            label: 'Communication Skills',
            percent: 0.75,
            valueText: '75%',
            valueColor: const Color(0xFF155DFC),
            barGradient: const LinearGradient(
                colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)]),
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            label: 'Self-Confidence',
            percent: 0.60,
            valueText: '60%',
            valueColor: AppColors.primary,
            barGradient: const LinearGradient(
                colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)]),
          ),
          const SizedBox(height: 12),
          _buildProgressBar(
            label: 'Career Transition',
            percent: 0.40,
            valueText: '40%',
            valueColor: const Color(0xFF00A63E),
            barGradient: const LinearGradient(
                colors: [Color(0xFF00C950), Color(0xFF00BC7D)]),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required double percent,
    required String valueText,
    required Color valueColor,
    required LinearGradient barGradient,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF4A5565))),
            Text(valueText,
                style: TextStyle(fontSize: 14, color: valueColor)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: Stack(
            children: [
              Container(
                  height: 8,
                  width: double.infinity,
                  color: const Color(0xFFE5E7EB)),
              FractionallySizedBox(
                widthFactor: percent,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: barGradient,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Emotional Patterns ───────────────────────────────────────────────────────

  Widget _buildEmotionalPatternsCard() {
    const moods = [
      _MoodEntry(emoji: '😊', day: 'Mon'),
      _MoodEntry(emoji: '🙂', day: 'Tue'),
      _MoodEntry(emoji: '😐', day: 'Wed'),
      _MoodEntry(emoji: '😊', day: 'Thu'),
      _MoodEntry(emoji: '😊', day: 'Fri'),
    ];

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
              title: 'Emotional Patterns',
              icon: Icons.favorite_outline_rounded),
          const SizedBox(height: 16),
          Row(
            children: moods
                .map((m) => Expanded(
                      child: Column(
                        children: [
                          Text(m.emoji,
                              style: const TextStyle(fontSize: 24),
                              textAlign: TextAlign.center),
                          const SizedBox(height: 4),
                          Text(m.day,
                              style: const TextStyle(
                                  fontSize: 12, color: Color(0xFF4A5565)),
                              textAlign: TextAlign.center),
                        ],
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          const Text('Average mood: Good (4.2/5)',
              style: TextStyle(fontSize: 14, color: Color(0xFF4A5565))),
        ],
      ),
    );
  }

  // ─── Session Notes ────────────────────────────────────────────────────────────

  Widget _buildSessionNotesCard(BuildContext context) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            title: 'Session Notes',
            icon: Icons.notes_rounded,
            onTap: () => _snack(context, 'All notes coming soon'),
          ),
          const SizedBox(height: 16),
          _buildNoteEntry(
            date: 'Dec 3, 2025',
            session: 'Session #12',
            text:
                'Discussed work-life balance strategies. Client showing great progress with boundary setting.',
            borderColor: const Color(0xFF2B7FFF),
            bgColor: const Color(0xFFEFF6FF),
          ),
          const SizedBox(height: 12),
          _buildNoteEntry(
            date: 'Nov 30, 2025',
            session: 'Session #11',
            text:
                'Completed career transition assessment. Identified key action items for next month.',
            borderColor: const Color(0xFFAD46FF),
            bgColor: const Color(0xFFFAF5FF),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteEntry({
    required String date,
    required String session,
    required String text,
    required Color borderColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(date,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6A7282))),
              Text(session,
                  style: const TextStyle(
                      fontSize: 12, color: Color(0xFF6A7282))),
            ],
          ),
          const SizedBox(height: 4),
          Text(text,
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF364153), height: 1.43)),
        ],
      ),
    );
  }

  // ─── Tasks Assigned ───────────────────────────────────────────────────────────

  Widget _buildTasksAssignedCard(BuildContext context) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            title: 'Tasks Assigned',
            icon: Icons.checklist_rounded,
            onTap: () => _showAssignTaskSheet(context),
          ),
          const SizedBox(height: 16),
          _buildTaskRow(
            label: 'Daily meditation practice',
            status: 'Completed',
            statusColor: const Color(0xFF00A63E),
            bgColor: const Color(0xFFF0FDF4),
          ),
          const SizedBox(height: 8),
          _buildTaskRow(
            label: 'Communication exercise',
            status: 'In Progress',
            statusColor: const Color(0xFF155DFC),
            bgColor: const Color(0xFFEFF6FF),
          ),
          const SizedBox(height: 8),
          _buildTaskRow(
            label: 'Career assessment worksheet',
            status: 'Not Started',
            statusColor: const Color(0xFF4A5565),
            bgColor: const Color(0xFFF9FAFB),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskRow({
    required String label,
    required String status,
    required Color statusColor,
    required Color bgColor,
  }) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: Color(0xFF364153)),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Text(status,
              style: TextStyle(fontSize: 12, color: statusColor)),
        ],
      ),
    );
  }

  // ─── Assign Task Sheet ────────────────────────────────────────────────────────

  void _showAssignTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AssignTaskSheet(clientName: widget.client.clientName), // ← real name
    );
  }

  // ─── Shared helpers ───────────────────────────────────────────────────────────

  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 10)),
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _cardHeader({
    required String title,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Color(0xFF101828))),
        GestureDetector(
          onTap: onTap,
          child: Icon(icon, size: 20, color: const Color(0xFF6A7282)),
        ),
      ],
    );
  }
}

// ─── Assign Task Sheet ────────────────────────────────────────────────────────

class _AssignTaskSheet extends StatefulWidget {
  final String clientName; // ← real name passed in

  const _AssignTaskSheet({required this.clientName});

  @override
  State<_AssignTaskSheet> createState() => _AssignTaskSheetState();
}

class _AssignTaskSheetState extends State<_AssignTaskSheet> {
  final _taskController = TextEditingController();
  String _selectedFrequency = 'Daily';
  static const _frequencies = ['Daily', 'Weekly', 'One-time'];

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Assign Task',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF101828))),
            const SizedBox(height: 4),
            Text(
              'Assign a new task to ${widget.clientName}', // ← real name
              style: const TextStyle(fontSize: 13, color: Color(0xFF6A7282)),
            ),
            const SizedBox(height: 20),
            const Text('Task Title',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF101828))),
            const SizedBox(height: 8),
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'e.g. Daily journaling',
                hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Frequency',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF101828))),
            const SizedBox(height: 8),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedFrequency,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      size: 20, color: Color(0xFF6A7282)),
                  style: const TextStyle(
                      fontSize: 15, color: Color(0xFF101828)),
                  dropdownColor: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  items: _frequencies
                      .map((f) => DropdownMenuItem(
                          value: f, child: Text(f)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null)
                      setState(() => _selectedFrequency = v);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Task assigned successfully'),
                      backgroundColor: AppColors.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Assign Task',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────

class _MoodEntry {
  final String emoji;
  final String day;
  const _MoodEntry({required this.emoji, required this.day});
}