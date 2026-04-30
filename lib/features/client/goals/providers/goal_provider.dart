// lib/features/client/goals/providers/goal_provider.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/goal_model.dart';
import '../services/goal_service.dart';

class GoalProvider extends ChangeNotifier {
  final GoalService _service = GoalService();

  List<GoalModel> _goals = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<GoalModel>>? _sub;

  List<GoalModel> get goals => _goals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Start listening to goals for a client ─────────────────────────────────
  void listenToGoals(String clientId) {
    _sub?.cancel();
    _isLoading = true;
    notifyListeners();

    _sub = _service.streamClientGoals(clientId).listen(
          (goals) {
        _goals = goals;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Failed to load goals.';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Create a new goal ──────────────────────────────────────────────────────
  Future<bool> createGoal(GoalModel goal) async {
    try {
      await _service.createGoal(goal);
      return true;
    } catch (e) {
      _error = 'Failed to save goal.';
      notifyListeners();
      return false;
    }
  }

  // ── Toggle action step completion ──────────────────────────────────────────
  Future<void> toggleStep({
    required String goalId,
    required int stepIndex,
  }) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final goal = _goals[goalIndex];
    final updatedSteps = List<ActionStep>.from(goal.actionSteps);
    updatedSteps[stepIndex] =
        updatedSteps[stepIndex].copyWith(isDone: !updatedSteps[stepIndex].isDone);

    // Optimistic update
    _goals[goalIndex] = goal.copyWith(actionSteps: updatedSteps);
    notifyListeners();

    try {
      await _service.toggleActionStep(
        goalId: goalId,
        updatedSteps: updatedSteps,
      );
    } catch (e) {
      // Revert on failure
      _goals[goalIndex] = goal;
      _error = 'Failed to update step.';
      notifyListeners();
    }
  }

  // ── Delete a goal ──────────────────────────────────────────────────────────
  Future<void> deleteGoal(String goalId) async {
    try {
      await _service.deleteGoal(goalId);
    } catch (e) {
      _error = 'Failed to delete goal.';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}