// lib/features/client/dashboard/providers/dashboard_provider.dart

import 'package:flutter/foundation.dart';
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

  // ── Load dashboard (called with clientId) ──────────────────────────────────
  Future<void> load({String? clientId}) async {
    if (_isLoading) return;
    if (clientId == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _service.fetchDashboard(clientId: clientId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Load profile stats counters (sessions, goals, tasks done) ─────────────
  Future<void> loadClientStats({required String clientId}) async {
    if (_isStatsLoading) return;
    _isStatsLoading = true;
    _statsError = null;
    notifyListeners();

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
