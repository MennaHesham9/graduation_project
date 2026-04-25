import 'package:flutter/foundation.dart';
import '../models/dashboard_data.dart';
import '../services/dashboard_service.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardService _service;

  DashboardProvider({DashboardService? service})
      : _service = service ?? DashboardService();

  bool _isLoading = false;
  DashboardData? _data;
  String? _error;

  bool get isLoading => _isLoading;
  DashboardData? get data => _data;
  String? get error => _error;

  Future<void> load() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _service.fetchDashboard();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}