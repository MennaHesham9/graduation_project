// lib/features/client/dashboard/providers/dashboard_provider.dart
//
// FIX (setState() called during build):
//   load() previously called notifyListeners() synchronously in a path that
//   could be triggered from initState() → _load() while the widget tree was
//   still being built. This caused the "setState() or markNeedsBuild() called
//   during build" assertion.
//
//   Fix: Guard the first notifyListeners() call in load() with
//   WidgetsBinding.instance.addPostFrameCallback so that if the provider is
//   notified while the tree is mid-build, the notification is deferred to
//   the next frame. The _isLoading flag is still set immediately so subsequent
//   calls are properly debounced.

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service;

  DashboardProvider({DashboardService? service})
      : _service = service ?? DashboardService();

  bool _isLoading = false;
  bool _isStatsLoading = false;
  DashboardData? _data;
  ClientStats? _clientStats;
  String? _error;
  String? _statsError;

  bool get isLoading => _isLoading;
  bool get isStatsLoading => _isStatsLoading;
  DashboardData? get data => _data;
  ClientStats? get clientStats => _clientStats;
  String? get error => _error;
  String? get statsError => _statsError;

  // ── Safe notify helper ─────────────────────────────────────────────────────
  // Defers notifyListeners() to the post-frame callback if called during a
  // build phase, which prevents the "setState() called during build" error
  // when load() is invoked from initState().
  void _safeNotify() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.transientCallbacks) {
      // We are inside a frame — defer notification to after the frame.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }

  // ── Load dashboard (called with clientId) ──────────────────────────────────
  Future<void> load({String? clientId}) async {
    if (_isLoading) return;
    if (clientId == null) return;

    _isLoading = true;
    _error = null;
    // FIX: use _safeNotify() instead of notifyListeners() so this is safe to
    // call from initState() without triggering the build-phase assertion.
    _safeNotify();

    try {
      _data = await _service.fetchDashboard(clientId: clientId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners(); // safe here — we are past the build phase
    }
  }

  // ── Load profile stats counters (sessions, goals, tasks done) ─────────────
  Future<void> loadClientStats({required String clientId}) async {
    if (_isStatsLoading) return;
    _isStatsLoading = true;
    _statsError = null;
    _safeNotify();

    try {
      _clientStats = await _service.fetchClientStats(clientId: clientId);
    } catch (e) {
      _statsError = e.toString();
    } finally {
      _isStatsLoading = false;
      notifyListeners();
    }
  }
}
