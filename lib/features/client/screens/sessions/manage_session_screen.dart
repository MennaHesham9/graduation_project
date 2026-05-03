import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../booking/models/booking_model.dart';
import '../../../booking/providers/booking_provider.dart';
import '../../../booking/services/availability_service.dart';
import '../../../booking/services/booking_service.dart';

class ManageSessionScreen extends StatefulWidget {
  final BookingModel session;
  const ManageSessionScreen({super.key, required this.session});

  @override
  State<ManageSessionScreen> createState() => _ManageSessionScreenState();
}

class _ManageSessionScreenState extends State<ManageSessionScreen> {
  final AvailabilityService _availService = AvailabilityService();
  final BookingService _bookingService = BookingService();

  // Reschedule state
  DateTime? _rescheduleDate;
  String? _rescheduleSlot;
  List<String> _availableSlots = [];
  bool _loadingSlots = false;
  final _reasonCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRescheduleSlots(DateTime date) async {
    setState(() => _loadingSlots = true);
    try {
      final booked = await _bookingService.fetchBookedSlots(
          widget.session.coachId, date);
      final available = await _availService.getAvailableSlotsForDate(
        coachId: widget.session.coachId,
        date: date,
        alreadyBookedSlots: booked,
      );
      if (mounted) setState(() => _availableSlots = available);
    } catch (_) {
      if (mounted) setState(() => _availableSlots = []);
    }
    if (mounted) setState(() => _loadingSlots = false);
  }

  Future<void> _pickRescheduleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(hours: 6)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked == null) return;
    setState(() {
      _rescheduleDate = picked;
      _rescheduleSlot = null;
    });
    await _loadRescheduleSlots(picked);
  }

  Future<void> _submitReschedule() async {
    if (_rescheduleDate == null || _rescheduleSlot == null) return;
    final parts = _rescheduleSlot!.split(':');
    final newSlotUtc = DateTime.utc(_rescheduleDate!.year,
        _rescheduleDate!.month, _rescheduleDate!.day,
        int.parse(parts[0]), int.parse(parts[1]));

    final client = context.read<AuthProvider>().user;
    final provider = context.read<BookingProvider>();

    final ok = await provider.requestReschedule(
      sessionId: widget.session.id,
      newSlotUtc: newSlotUtc,
      reason: _reasonCtrl.text.trim().isEmpty
          ? 'Rescheduled by client'
          : _reasonCtrl.text.trim(),
      clientId: client?.uid ?? '',
      coachId: widget.session.coachId,
      coachName: widget.session.coachName,
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session rescheduled!')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _cancel() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancel Session?'),
        content: Text(
          widget.session.canCancel
              ? 'Are you sure you want to cancel this session?'
              : 'Cancelling within 12 hours means no refund. Continue?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('No')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Yes, Cancel',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;

    final client = context.read<AuthProvider>().user;
    final provider = context.read<BookingProvider>();
    final ok = await provider.cancelSession(
      sessionId: widget.session.id,
      cancelledBy: 'client',
      reason: 'Cancelled by client',
      notifyUid: widget.session.coachId,
      notifyName: client?.fullName ?? 'Client',
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session cancelled.')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _acceptCoachProposal(DateTime chosenSlot) async {
    final client = context.read<AuthProvider>().user;
    final provider = context.read<BookingProvider>();
    final ok = await provider.acceptCoachReschedule(
      sessionId: widget.session.id,
      chosenSlotUtc: chosenSlot,
      coachId: widget.session.coachId,
      clientName: client?.fullName ?? '',
    );
    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reschedule accepted!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final localTime = session.scheduledAtUtc.toLocal();
    final provider = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Manage Session',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Session Info Card ────────────────────────────────────────
          _InfoCard(session: session, localTime: localTime),
          const SizedBox(height: 16),

          // ── Coach Reschedule Proposal Banner ─────────────────────────
          if (session.rescheduleRequestPending &&
              session.coachProposedSlots.isNotEmpty)
            _CoachProposalBanner(
              session: session,
              onAccept: _acceptCoachProposal,
            ),

          // ── Reschedule Section ───────────────────────────────────────
          if (session.canReschedule) ...[
            const SizedBox(height: 8),
            const Text('Request Reschedule',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _RescheduleSection(
              date: _rescheduleDate,
              slot: _rescheduleSlot,
              slots: _availableSlots,
              loadingSlots: _loadingSlots,
              reasonCtrl: _reasonCtrl,
              onPickDate: _pickRescheduleDate,
              onPickSlot: (s) => setState(() => _rescheduleSlot = s),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: (_rescheduleSlot != null && !provider.isLoading)
                    ? _submitReschedule
                    : null,
                child: provider.isLoading
                    ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                    : const Text('Submit Reschedule',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                session.rescheduleCount >= 2
                    ? 'You have used all 2 reschedules for this session.'
                    : 'Reschedule window has passed (< 6h before session).',
                style: const TextStyle(color: Colors.orange),
              ),
            ),

          const SizedBox(height: 24),

          // ── Cancel Button ────────────────────────────────────────────
          if (session.isActive)
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _cancel,
              icon: const Icon(Icons.cancel_outlined),
              label: Text(session.canCancel
                  ? 'Cancel Session'
                  : 'Cancel Session (No Refund)'),
            ),

          if (provider.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(provider.error!,
                  style: const TextStyle(color: Colors.red)),
            ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final BookingModel session;
  final DateTime localTime;
  const _InfoCard({required this.session, required this.localTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          _Row('Coach', session.coachName),
          _Row('Date',
              DateFormat('EEEE, MMM d, yyyy').format(localTime)),
          _Row('Time', DateFormat('h:mm a').format(localTime)),
          _Row('Duration', '${session.durationMinutes} min'),
          _Row('Type',
              session.type == SessionType.video ? 'Video' : 'Audio'),
          if (session.planType == PlanType.package &&
              session.sessionIndexInPackage != null)
            _Row('Package',
                'Session ${session.sessionIndexInPackage} of ${session.packageSize}'),
          _Row('Status', session.status.name.toUpperCase()),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 13))),
        Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontWeight: FontWeight.w500))),
      ],
    ),
  );
}

class _CoachProposalBanner extends StatelessWidget {
  final BookingModel session;
  final void Function(DateTime) onAccept;
  const _CoachProposalBanner(
      {required this.session, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Coach Proposed New Times',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue)),
          const SizedBox(height: 8),
          ...session.coachProposedSlots.map((slot) {
            final local = slot.toLocal();
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(DateFormat('EEE, MMM d · h:mm a').format(local)),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue),
                onPressed: () => onAccept(slot),
                child: const Text('Accept',
                    style: TextStyle(color: Colors.white)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _RescheduleSection extends StatelessWidget {
  final DateTime? date;
  final String? slot;
  final List<String> slots;
  final bool loadingSlots;
  final TextEditingController reasonCtrl;
  final VoidCallback onPickDate;
  final void Function(String) onPickSlot;

  const _RescheduleSection({
    required this.date,
    required this.slot,
    required this.slots,
    required this.loadingSlots,
    required this.reasonCtrl,
    required this.onPickDate,
    required this.onPickSlot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OutlinedButton.icon(
            onPressed: onPickDate,
            icon: const Icon(Icons.calendar_month_outlined),
            label: Text(date == null
                ? 'Pick a new date'
                : DateFormat('EEE, MMM d').format(date!)),
          ),
          if (date != null) ...[
            const SizedBox(height: 12),
            if (loadingSlots)
              const Center(
                  child: CircularProgressIndicator())
            else if (slots.isEmpty)
              const Text('No available slots on this day.',
                  style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: slots
                    .map((s) => ChoiceChip(
                  label: Text(s),
                  selected: slot == s,
                  onSelected: (_) => onPickSlot(s),
                  selectedColor:
                  const Color(0xFF4A90D9),
                  labelStyle: TextStyle(
                      color: slot == s
                          ? Colors.white
                          : Colors.black87),
                ))
                    .toList(),
              ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: reasonCtrl,
            decoration: InputDecoration(
              hintText: 'Reason (optional)',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
            maxLines: 2,
          ),
        ],
      ),
    );
  }
}