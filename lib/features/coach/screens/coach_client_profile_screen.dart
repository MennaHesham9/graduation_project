// lib/features/coach/screens/coach_client_profile_screen.dart
//
// Fully dynamic version:
//  • Fetches client UserModel from Firestore (photo, country, timezone, etc.)
//  • Streams client Goals (real progress stats)
//  • Streams upcoming + past sessions with this client (real session stats)
//  • Progress Overview card is driven by real goal data
//  • Stats Row (Progress / Active Goals / Tasks Done) is real
//  • "Progress Overview" card header taps → GoalsDashboardScreen (read-only view)
//  • Upcoming session row taps → ManageSessionScreen
//  • Tasks panel and Questionnaire panel are already live (unchanged)

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/user_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../booking/models/booking_model.dart';
import '../../booking/providers/booking_provider.dart';
import '../../booking/services/availability_service.dart';
import '../../booking/services/booking_service.dart';
import '../../client/goals/models/goal_model.dart';
import '../../client/goals/providers/goal_provider.dart';
import '../../client/goals/screens/goals_dashboard_screen.dart';
import '../../client/models/coaching_request_model.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/screens/assign_task_screen.dart';
import '../sessions/video_session_screen.dart';
import '../../../core/providers/agora_provider.dart';
import '../../../core/providers/emotion_provider.dart';
import '../widgets/coach_client_tasks_panel.dart';
import '../widgets/coach_questionnaire_panel.dart';
import 'clients/manage_session_screen.dart';


class CoachClientProfileScreen extends StatefulWidget {
  final CoachingRequestModel client;

  const CoachClientProfileScreen({super.key, required this.client});

  @override
  State<CoachClientProfileScreen> createState() =>
      _CoachClientProfileScreenState();
}

class _CoachClientProfileScreenState extends State<CoachClientProfileScreen> {
  int _selectedStatus = 0;

  // ── Async data ─────────────────────────────────────────────────────────────
  UserModel? _clientUser;
  bool _loadingUser = true;

  // Session streams
  final BookingService _bookingService = BookingService();
  List<BookingModel> _upcomingSessions = [];
  List<BookingModel> _pastSessions = [];
  StreamSubscription<List<BookingModel>>? _upcomingSub;
  StreamSubscription<List<BookingModel>>? _pastSub;

  @override
  void initState() {
    super.initState();
    _loadClientUser();
    _subscribeToSessions();
  }

  @override
  void dispose() {
    _upcomingSub?.cancel();
    _pastSub?.cancel();
    super.dispose();
  }

  // ── Load client UserModel ──────────────────────────────────────────────────
  Future<void> _loadClientUser() async {
    final user =
    await AuthService().getUserById(widget.client.clientId);
    if (mounted) {
      setState(() {
        _clientUser = user;
        _loadingUser = false;
      });
    }
  }

  // ── Stream sessions ────────────────────────────────────────────────────────
  void _subscribeToSessions() {
    final coachId = widget.client.coachId;
    final clientId = widget.client.clientId;

    _upcomingSub = _bookingService
        .streamClientUpcomingSessions(clientId)
        .listen((sessions) {
      if (mounted) {
        setState(() {
          // Filter to only sessions with THIS coach
          _upcomingSessions =
              sessions.where((s) => s.coachId == coachId).toList();
        });
      }
    });

    _pastSub = _bookingService
        .streamClientPastSessions(clientId)
        .listen((sessions) {
      if (mounted) {
        setState(() {
          _pastSessions =
              sessions.where((s) => s.coachId == coachId).toList();
        });
      }
    });
  }

  // ── Reschedule bottom sheet ────────────────────────────────────────────────
  Future<void> _proposeReschedule(
      BuildContext context, BookingModel session) async {
    final provider = context.read<BookingProvider>();
    final availService = AvailabilityService();
    final bookingService = BookingService();

    DateTime? pickedDate;
    List<String> availableSlots = [];
    String? pickedSlot;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              left: 20,
              right: 20,
              top: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Propose New Time',
                  style:
                  TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (d == null) return;
                  final booked = await bookingService.fetchBookedSlots(
                      session.coachId, d);
                  final slots =
                  await availService.getAvailableSlotsForDate(
                    coachId: session.coachId,
                    date: d,
                    alreadyBookedSlots: booked,
                  );
                  setModal(() {
                    pickedDate = d;
                    availableSlots = slots;
                    pickedSlot = null;
                  });
                },
                icon: const Icon(Icons.calendar_month),
                label: Text(pickedDate == null
                    ? 'Pick a date'
                    : DateFormat('EEE, MMM d').format(pickedDate!)),
              ),
              if (availableSlots.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSlots
                      .map((s) => ChoiceChip(
                    label: Text(s),
                    selected: pickedSlot == s,
                    onSelected: (_) => setModal(() => pickedSlot = s),
                    selectedColor: const Color(0xFF4A90D9),
                    labelStyle: TextStyle(
                        color: pickedSlot == s
                            ? Colors.white
                            : Colors.black87),
                  ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9)),
                  onPressed: pickedSlot == null
                      ? null
                      : () async {
                    final parts = pickedSlot!.split(':');
                    final slotUtc = DateTime.utc(
                        pickedDate!.year,
                        pickedDate!.month,
                        pickedDate!.day,
                        int.parse(parts[0]),
                        int.parse(parts[1]));
                    await provider.proposeCoachReschedule(
                      sessionId: session.id,
                      proposedSlotsUtc: [slotUtc],
                      clientId: session.clientId,
                      coachName: session.coachName,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Reschedule proposed!')),
                      );
                    }
                  },
                  child: const Text('Send Proposal',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  void _openAssignTask(BuildContext context) async {
    final coach = context.read<AuthProvider>().user!;
    final taskProvider = context.read<TaskProvider>();

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: taskProvider,
          child: AssignTaskScreen(
            clientId: widget.client.clientId,
            clientName: widget.client.clientName,
            clientGoal: widget.client.primaryGoal,
          ),
        ),
      ),
    );

    if (result == true && mounted) {
      taskProvider.listenToCoachClientTasks(
        coachId: coach.uid,
        clientId: widget.client.clientId,
      );
    }
  }

  // ── Navigate to client's Goals dashboard (read-only for coach) ────────────
  void _openClientGoals(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider(
          create: (_) => GoalProvider()
            ..listenToGoals(widget.client.clientId),
          child: const GoalsDashboardScreen(),
        ),
      ),
    );
  }

  // ── Navigate to ManageSessionScreen for a specific booking ───────────────
  void _openManageSession(BuildContext context, BookingModel session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ManageSessionScreen(session: session),
      ),
    );
  }

  // ── Navigate to VideoSessionScreen ─────────────────────────────────────────
  void _joinSession(BuildContext context, BookingModel session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => AgoraProvider()),
            ChangeNotifierProvider(create: (_) => EmotionProvider()),
          ],
          child: VideoSessionScreen(
            bookingId: session.id,
            channelName: 'session_${session.id}',
            clientId: session.clientId,
          ),
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()
          ..listenToGoals(widget.client.clientId)),
      ],
      child: Scaffold(
        body: Container(
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
                child: Consumer<GoalProvider>(
                  builder: (context, goalProvider, _) {
                    return ListView(
                      padding:
                      const EdgeInsets.fromLTRB(24, 20, 24, 32),
                      children: [
                        _buildStatsRow(goalProvider),
                        const SizedBox(height: 20),
                        _buildClientStatusCard(),
                        const SizedBox(height: 20),
                        _buildClientInfoCard(),
                        const SizedBox(height: 20),
                        _buildProgressOverviewCard(context, goalProvider),
                        const SizedBox(height: 20),
                        _buildUpcomingSessionsCard(context),
                        const SizedBox(height: 20),
                        _buildEmotionalPatternsCard(),
                        const SizedBox(height: 20),
                        CoachClientTasksPanel(client: widget.client),
                        const SizedBox(height: 20),
                        CoachQuestionnairePanel(client: widget.client),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Hero Header ──────────────────────────────────────────────────────────
  Widget _buildHeroHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // Use real photo if client has shared it and UserModel is loaded
    final hasPhoto = _clientUser?.showPhotoToCoach == true &&
        (_clientUser?.photoUrl?.isNotEmpty ?? false);

    return Container(
      padding: EdgeInsets.only(
        top: topPadding + 12,
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
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 25,
            offset: const Offset(0, 20),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.maybePop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
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
              // Avatar (real photo or initials)
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 50,
                      offset: const Offset(0, 25),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: hasPhoto
                      ? _buildBase64Avatar(_clientUser!.photoUrl!)
                      : Container(
                    color: Colors.white.withValues(alpha: 0.25),
                    child: Center(
                      child: Text(
                        _initials(widget.client.clientName),
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

              // Name + metadata + action buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.client.clientName,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Real country / timezone if available
                    if (_clientUser?.country != null ||
                        _clientUser?.timezone != null)
                      Text(
                        [
                          _clientUser?.country,
                          _clientUser?.timezone,
                        ]
                            .where((s) => s != null && s.isNotEmpty)
                            .join(' · '),
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    Text(
                      'Since ${_formatDate(widget.client.createdAt)}',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.9)),
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
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 15,
                                      color: Colors.white),
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
                              color: Colors.white.withValues(alpha: 0.2),
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
                                        fontSize: 13,
                                        color: Colors.white)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Assign Task button
                    GestureDetector(
                      onTap: () => _openAssignTask(context),
                      child: Container(
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
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

  /// Renders a base64-encoded photo string as a full avatar image.
  Widget _buildBase64Avatar(String photoUrl) {
    try {
      // Strip data URI prefix if present
      final base64Str = photoUrl.contains(',')
          ? photoUrl.split(',').last
          : photoUrl;
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, fit: BoxFit.cover);
    } catch (_) {
      return Container(
        color: Colors.white.withValues(alpha: 0.25),
        child: Center(
          child: Text(
            _initials(widget.client.clientName),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }

  // ─── Stats Row — real data from goals + sessions ──────────────────────────
  Widget _buildStatsRow(GoalProvider goalProvider) {
    final goals = goalProvider.goals;
    final totalSteps =
    goals.fold<int>(0, (sum, g) => sum + g.totalSteps);
    final doneSteps =
    goals.fold<int>(0, (sum, g) => sum + g.completedSteps);
    final progressPct =
    totalSteps == 0 ? 0 : ((doneSteps / totalSteps) * 100).round();

    final completedSessionCount = _pastSessions
        .where((s) => s.status == SessionStatus.completed)
        .length;

    return Row(
      children: [
        _buildStatCard(
            value: goalProvider.isLoading ? '…' : '$progressPct%',
            label: 'Progress'),
        const SizedBox(width: 12),
        _buildStatCard(
            value: goalProvider.isLoading
                ? '…'
                : '${goals.length}',
            label: 'Active Goals'),
        const SizedBox(width: 12),
        _buildStatCard(
            value: '$completedSessionCount',
            label: 'Sessions Done'),
      ],
    );
  }

  Widget _buildStatCard({required String value, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 10)),
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 4)),
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

  // ─── Client Info Card — real request data ─────────────────────────────────
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
          _infoRow(Icons.flag_outlined, 'Primary Goal',
              widget.client.primaryGoal),
          const SizedBox(height: 12),
          _infoRow(Icons.psychology_outlined, 'Current Challenges',
              widget.client.currentChallenges),
          const SizedBox(height: 12),
          _infoRow(
              Icons.repeat_outlined, 'Frequency', widget.client.frequency),
          const SizedBox(height: 12),
          _infoRow(Icons.access_time_outlined, 'Preferred Time',
              widget.client.preferredTime),
          // Real fields from UserModel
          if (_clientUser?.country != null) ...[
            const SizedBox(height: 12),
            _infoRow(Icons.location_on_outlined, 'Country',
                _clientUser!.country!),
          ],
          if (_clientUser?.language != null) ...[
            const SizedBox(height: 12),
            _infoRow(
                Icons.language_outlined, 'Language', _clientUser!.language!),
          ],
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
              style:
              const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
        ),
      ],
    );
  }

  // ─── Client Status Card ───────────────────────────────────────────────────
  Widget _buildClientStatusCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(21, 21, 21, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E8FF)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 10)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
                  color: const Color(0xFF00C950).withValues(alpha: 0.51),
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
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 10)),
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
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

  // ─── Progress Overview — real goal data, tappable ─────────────────────────
  Widget _buildProgressOverviewCard(
      BuildContext context, GoalProvider goalProvider) {
    final goals = goalProvider.goals;

    // Build per-goal progress bars (max 3 shown)
    final displayed = goals.take(3).toList();

    // Gradient palette for bars
    const gradients = [
      LinearGradient(colors: [Color(0xFF2B7FFF), Color(0xFF00B8DB)]),
      LinearGradient(
          colors: [Color(0xFF2F8F9D), Color(0xFF20A8BC)]),
      LinearGradient(
          colors: [Color(0xFF00C950), Color(0xFF00BC7D)]),
    ];
    const valueColors = [
      Color(0xFF155DFC),
      AppColors.primary,
      Color(0xFF00A63E),
    ];

    return GestureDetector(
      onTap: () => _openClientGoals(context),
      child: _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(
              title: 'Progress Overview',
              icon: Icons.bar_chart_rounded,
              onTap: () => _openClientGoals(context),
              trailingLabel: 'View All',
            ),
            const SizedBox(height: 16),
            if (goalProvider.isLoading)
              const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ))
            else if (goals.isEmpty)
              const Text(
                'No goals set yet.',
                style: TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
              )
            else
              ...List.generate(displayed.length, (i) {
                final goal = displayed[i];
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: i < displayed.length - 1 ? 12 : 0),
                  child: _buildProgressBar(
                    label: goal.title,
                    percent: goal.progress,
                    valueText: '${(goal.progress * 100).round()}%',
                    valueColor: valueColors[i % valueColors.length],
                    barGradient: gradients[i % gradients.length],
                  ),
                );
              }),
            if (goals.length > 3) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '+${goals.length - 3} more goals',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primary),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 10, color: AppColors.primary),
                ],
              ),
            ],
          ],
        ),
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
            Expanded(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF4A5565))),
            ),
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
                widthFactor: percent.clamp(0.0, 1.0),
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

  // ─── Upcoming Sessions Card — real data, each row tappable ────────────────
  Widget _buildUpcomingSessionsCard(BuildContext context) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(
            title: 'Upcoming Sessions',
            icon: Icons.calendar_today_outlined,
          ),
          const SizedBox(height: 16),
          if (_upcomingSessions.isEmpty)
            const Text(
              'No upcoming sessions scheduled.',
              style: TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
            )
          else
            ...(_upcomingSessions.take(3).toList()).asMap().entries.map(
                  (entry) {
                final i = entry.key;
                final session = entry.value;
                final local = session.scheduledAtUtc.toLocal();
                final dateStr = DateFormat('EEE, MMM d').format(local);
                final timeStr = DateFormat('h:mm a').format(local);
                final typeIcon = session.type == SessionType.video
                    ? Icons.videocam_outlined
                    : Icons.headset_mic_outlined;

                return GestureDetector(
                  onTap: () => _openManageSession(context, session),
                  child: Container(
                    margin: EdgeInsets.only(
                        bottom: i < _upcomingSessions.take(3).length - 1
                            ? 10
                            : 0),
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: session.isJoinable
                          ? const Color(0xFFECFEFF)
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: session.isJoinable
                              ? const Color(0xFF2F8F9D)
                              : const Color(0xFFBFDBFE),
                          width: session.isJoinable ? 1.5 : 1),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(typeIcon,
                                  size: 18, color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$dateStr · $timeStr',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF101828)),
                                  ),
                                  Text(
                                    '${session.durationMinutes} min · '
                                        '${session.type == SessionType.video ? 'Video' : 'Audio'}'
                                        '${session.planType == PlanType.package ? ' (Package)' : ''}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF4A5565)),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded,
                                size: 18, color: Color(0xFF9CA3AF)),
                          ],
                        ),
                        // ── Join Now button — only for joinable video sessions ──
                        if (session.isJoinable &&
                            session.type == SessionType.video) ...[
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: GestureDetector(
                              onTap: () => _joinSession(context, session),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 9),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2F8F9D),
                                      Color(0xFF20A8BC)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0xFF2F8F9D)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3)),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.videocam_rounded,
                                        color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text('Join Now',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                        // ── Audio session joinable hint ─────────────────────
                        if (session.isJoinable &&
                            session.type == SessionType.audio) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: const [
                              Icon(Icons.headset_mic_outlined,
                                  size: 14, color: Color(0xFF6B7280)),
                              SizedBox(width: 5),
                              Text('Session in progress — use phone',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280))),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          if (_upcomingSessions.length > 3) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '+${_upcomingSessions.length - 3} more sessions',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.primary),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 10, color: AppColors.primary),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─── Emotional Patterns (mood tracking, placeholder until real data) ──────
  Widget _buildEmotionalPatternsCard() {
    // Only show if client has mood tracking enabled
    final moodEnabled = _clientUser?.allowMoodTracking ?? true;

    if (!moodEnabled) {
      return _glassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _cardHeader(
                title: 'Emotional Patterns',
                icon: Icons.favorite_outline_rounded),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.lock_outline_rounded,
                    size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                const Text(
                  'Client has disabled mood tracking.',
                  style:
                  TextStyle(fontSize: 14, color: Color(0xFF4A5565)),
                ),
              ],
            ),
          ],
        ),
      );
    }

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

  // ─── Shared helpers ───────────────────────────────────────────────────────
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 15,
              offset: const Offset(0, 10)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
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
    String? trailingLabel,
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
          child: Row(
            children: [
              if (trailingLabel != null) ...[
                Text(trailingLabel,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.primary)),
                const SizedBox(width: 4),
              ],
              Icon(icon, size: 20, color: const Color(0xFF6A7282)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Data model ───────────────────────────────────────────────────────────────
class _MoodEntry {
  final String emoji;
  final String day;
  const _MoodEntry({required this.emoji, required this.day});
}