import 'package:flutter/material.dart';
import '../../../core/models/user_model.dart';
import '../services/coach_service.dart';

class CoachesProvider extends ChangeNotifier {
  final _service = CoachService();

  List<UserModel> _allCoaches = [];
  List<UserModel> _filtered = [];
  bool isLoading = false;
  String? error;

  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<UserModel> get coaches => _filtered;

  Future<void> fetchCoaches() async {
  isLoading = true;
  error = null;
  notifyListeners();

  try {
    _allCoaches = await _service.fetchCoaches();
    _applyFilters();
  } catch (e) {
  error = 'Failed to load coaches. Please try again.';
  }

  isLoading = false;
  notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filtered = _allCoaches.where((coach) {
    // Search filter
    final matchesSearch = _searchQuery.isEmpty ||
    (coach.fullName?.toLowerCase().contains(_searchQuery) ?? false) ||
    (coach.professionalTitle?.toLowerCase().contains(_searchQuery) ?? false) ||
    (coach.coachingCategory?.toLowerCase().contains(_searchQuery) ?? false);

// Category filter
    final matchesCategory = _selectedCategory == 'All' ||
    (coach.coachingCategories?.any((cat) =>
    cat.toLowerCase().contains(_selectedCategory.toLowerCase())) ??
    false) ||
    (coach.coachingCategory?.toLowerCase()
      .contains(_selectedCategory.toLowerCase()) ?? false);

    return matchesSearch && matchesCategory;
    }).toList();
  }
}