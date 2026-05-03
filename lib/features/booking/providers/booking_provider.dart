// lib/features/booking/providers/booking_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../models/package_model.dart';
import '../services/booking_service.dart';

enum BookingStep { selectPlan, selectSlots, payment, confirmed }

class BookingProvider extends ChangeNotifier {
  final BookingService _service;

  BookingProvider({BookingService? service})
      : _service = service ?? BookingService();

  // ── Streams ───────────────────────────────────────────────────────────────
  StreamSubscription<List<BookingModel>>? _upcomingSub;
  StreamSubscription<List<BookingModel>>? _pastSub;
  StreamSubscription<List<BookingModel>>? _rescheduleReqSub;

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String? _error;

  List<BookingModel> _upcomingSessions = [];
  List<BookingModel> _pastSessions = [];
  List<BookingModel> _pendingReschedules = [];
  List<PackageModel> _activePackages = [];

  // ── Booking flow state (ephemeral, per-booking-wizard) ────────────────────
  BookingStep _currentStep = BookingStep.selectPlan;
  String? _selectedPlanType;      // "single_audio" | "single_video" | "package_audio" | "package_video"
  List<DateTime> _selectedSlots = [];
  List<String> _lockIds = [];
  String? _activeSessionId;

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<BookingModel> get upcomingSessions => _upcomingSessions;
  List<BookingModel> get pastSessions => _pastSessions;
  List<BookingModel> get pendingReschedules => _pendingReschedules;
  List<PackageModel> get activePackages => _activePackages;
  BookingStep get currentStep => _currentStep;
  String? get selectedPlanType => _selectedPlanType;
  List<DateTime> get selectedSlots => _selectedSlots;
  bool get isPackagePlan => _selectedPlanType?.startsWith('package') ?? false;
  int get requiredSlots => isPackagePlan ? _packageSizeOverride : 1;
  bool get slotsComplete => _selectedSlots.length == requiredSlots;

  // ── Stream: Client ────────────────────────────────────────────────────────
  void listenToClientSessions(String clientId) {
    _upcomingSub?.cancel();
    _pastSub?.cancel();
    _rescheduleReqSub?.cancel();

    _upcomingSub = _service
        .streamClientUpcomingSessions(clientId)
        .listen((sessions) {
      _upcomingSessions = sessions;
      notifyListeners();
    });

    _pastSub = _service.streamClientPastSessions(clientId).listen((sessions) {
      _pastSessions = sessions;
      notifyListeners();
    });

    _rescheduleReqSub = _service
        .streamClientRescheduleRequests(clientId)
        .listen((sessions) {
      _pendingReschedules = sessions;
      notifyListeners();
    });
  }

  // ── Booking wizard ────────────────────────────────────────────────────────
  int _packageSizeOverride = 4;
  void selectPlan(String planType, {int? packageSize}) {
    _selectedPlanType = planType;
    _selectedSlots = [];
    _packageSizeOverride = packageSize ?? 4;
    _currentStep = BookingStep.selectSlots;
    notifyListeners();
  }

  void toggleSlot(DateTime slotUtc) {
    if (_selectedSlots.contains(slotUtc)) {
      _selectedSlots.remove(slotUtc);
    } else {
      if (_selectedSlots.length < requiredSlots) {
        _selectedSlots.add(slotUtc);
      }
    }
    notifyListeners();
  }

  Future<bool> lockSelectedSlots({
    required String coachId,
    required String clientId,
  }) async {
    if (!slotsComplete) return false;
    _isLoading = true;
    notifyListeners();

    final sessionType =
    _selectedPlanType!.contains('video') ? 'video' : 'audio';

    try {
      _lockIds = [];
      for (final slot in _selectedSlots) {
        final lockId = await _service.lockSlot(
          coachId: coachId,
          clientId: clientId,
          slotUtc: slot,
          sessionType: sessionType,
        );
        _lockIds.add(lockId);
      }
      _currentStep = BookingStep.payment;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
      await _releaseAllLocks();
      return false;
    }
  }

  Future<bool> confirmBooking({
    required String clientId,
    required String clientName,
    required String coachId,
    required String coachName,
    required double price,
    required String currency,
    required int durationMinutes,
    required String clientTimezone,
    required String paymentRef,
  }) async {
    _isLoading = true;
    notifyListeners();

    final sessionType =
    _selectedPlanType!.contains('video') ? 'video' : 'audio';

    try {
      if (isPackagePlan) {
        _activeSessionId = await _service.confirmPackage(
          clientId: clientId,
          clientName: clientName,
          coachId: coachId,
          coachName: coachName,
          slotsUtc: _selectedSlots,
          sessionType: sessionType,
          totalPrice: price,
          currency: currency,
          durationMinutes: durationMinutes,
          clientTimezone: clientTimezone,
          lockIds: _lockIds,
          paymentRef: paymentRef,
        );
      } else {
        _activeSessionId = await _service.confirmSingleSession(
          clientId: clientId,
          clientName: clientName,
          coachId: coachId,
          coachName: coachName,
          slotUtc: _selectedSlots.first,
          sessionType: sessionType,
          price: price,
          currency: currency,
          durationMinutes: durationMinutes,
          clientTimezone: clientTimezone,
          lockId: _lockIds.first,
          paymentRef: paymentRef,
        );
      }

      _currentStep = BookingStep.confirmed;
      _lockIds = [];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
      await _releaseAllLocks(); // payment failed → release all locks
      return false;
    }
  }

  void resetBookingWizard() {
    _currentStep = BookingStep.selectPlan;
    _selectedPlanType = null;
    _selectedSlots = [];
    _lockIds = [];
    _activeSessionId = null;
    _error = null;
    notifyListeners();
  }

  // ── Reschedule ────────────────────────────────────────────────────────────

  Future<bool> requestReschedule({
    required String sessionId,
    required DateTime newSlotUtc,
    required String reason,
    required String clientId,
    required String coachId,
    required String coachName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.clientRequestReschedule(
        sessionId: sessionId,
        newSlotUtc: newSlotUtc,
        reason: reason,
        clientId: clientId,
        coachId: coachId,
        coachName: coachName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> acceptCoachReschedule({
    required String sessionId,
    required DateTime chosenSlotUtc,
    required String coachId,
    required String clientName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.clientAcceptCoachProposal(
        sessionId: sessionId,
        chosenSlotUtc: chosenSlotUtc,
        coachId: coachId,
        clientName: clientName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  Future<bool> cancelSession({
    required String sessionId,
    required String cancelledBy,
    required String reason,
    required String notifyUid,
    required String notifyName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.cancelSession(
        sessionId: sessionId,
        cancelledBy: cancelledBy,
        reason: reason,
        notifyUid: notifyUid,
        notifyName: notifyName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ── Private ───────────────────────────────────────────────────────────────

  Future<void> _releaseAllLocks() async {
    for (final lockId in _lockIds) {
      try {
        await _service.releaseLock(lockId);
      } catch (_) {}
    }
    _lockIds = [];
  }

  String _friendlyError(String raw) {
    if (raw.contains('slot_locked')) return 'This time slot is temporarily held. Please try another.';
    if (raw.contains('double_booking')) return 'This slot is already booked. Please choose another time.';
    if (raw.contains('reschedule_limit')) return 'You have reached the maximum of 2 reschedules.';
    if (raw.contains('reschedule_deadline')) return 'Cannot reschedule within 6 hours of your session.';
    return 'Something went wrong. Please try again.';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _upcomingSub?.cancel();
    _pastSub?.cancel();
    _rescheduleReqSub?.cancel();
    super.dispose();
  }
  // ADD to BookingProvider in booking_provider.dart:
  Future<bool> proposeCoachReschedule({
    required String sessionId,
    required List<DateTime> proposedSlotsUtc,
    required String clientId,
    required String coachName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _service.coachProposeReschedule(
        sessionId: sessionId,
        proposedSlotsUtc: proposedSlotsUtc,
        clientId: clientId,
        coachName: coachName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = _friendlyError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}