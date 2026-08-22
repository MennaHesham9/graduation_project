// lib/features/tasks/providers/task_provider.dart
//
// Single provider used by both the Coach and Client.
// Exposes filtered lists, streak, compliance, and loading state.

import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';
import '../utils/task_logic.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _service;

  TaskProvider({TaskService? service})
      : _service = service ?? TaskService();

  // ── State ─────────────────────────────────────────────────────────────────

  bool _isLoading = false;
  String? _error;

  // Raw templates from Firestore
  List<TaskModel> _allTasks = [];

  // Per-task completion keys cache: taskId → Set<dateKey>
  final Map<String, Set<String>> _completionsCache = {};

  // Subscriptions
  StreamSubscription<List<TaskModel>>? _tasksSub;
  final Map<String, StreamSubscription<Set<String>>> _completionSubs = {};

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TaskModel> get allTasks => _allTasks;

  // ── Filtered views ────────────────────────────────────────────────────────

  /// tasks due today that are NOT yet completed (client "Pending" tab).
  List<TaskModel> get pendingTodayTasks => _allTasks
      .where((t) =>
  isTaskDueToday(t) && !_isCompletedToday(t.id))
      .toList();

  /// tasks that have been completed at some point (client "Completed" tab).
  /// Shows tasks completed today first.
  List<TaskModel> get completedTasks => _allTasks
      .where((t) => _isCompletedToday(t.id))
      .toList();

  /// All tasks regardless of due status (coach view).
  List<TaskModel> get coachViewTasks => _allTasks;

  bool _isCompletedToday(String taskId) {
    final keys = _completionsCache[taskId] ?? {};
    return keys.contains(todayCompletionKey());
  }

  // ── Stream: Client tasks ──────────────────────────────────────────────────

  void listenToClientTasks(String clientId) {
    _tasksSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _tasksSub = _service.streamClientTasks(clientId).listen(
          (tasks) {
        _allTasks = tasks;
        _isLoading = false;
        _subscribeToCompletions(tasks);
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Stream: Coach → specific client tasks ────────────────────────────────

  void listenToCoachClientTasks(
      {required String coachId, required String clientId}) {
    _tasksSub?.cancel();
    _isLoading = true;
    notifyListeners();

    _tasksSub = _service
        .streamCoachClientTasks(coachId: coachId, clientId: clientId)
        .listen(
          (tasks) {
        _allTasks = tasks;
        _isLoading = false;
        _subscribeToCompletions(tasks);
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void _subscribeToCompletions(List<TaskModel> tasks) {
    // Cancel subs for tasks no longer in the list
    final currentIds = tasks.map((t) => t.id).toSet();
    final toRemove =
    _completionSubs.keys.where((id) => !currentIds.contains(id)).toList();
    for (final id in toRemove) {
      _completionSubs[id]?.cancel();
      _completionSubs.remove(id);
      _completionsCache.remove(id);
    }

    // Subscribe for new tasks
    for (final task in tasks) {
      if (!_completionSubs.containsKey(task.id)) {
        _completionSubs[task.id] =
            _service.streamCompletionKeys(task.id).listen((keys) {
              _completionsCache[task.id] = keys;
              notifyListeners();
            });
      }
    }
  }

  // ── Assign task (coach) ───────────────────────────────────────────────────

  Future<String?> assignTask({
    required TaskModel task,
    /// Pass in the coach's existing active tasks to check for overlap
    List<TaskModel> existingClientTasks = const [],
  }) async {
    // Overlap guard
    if (hasScheduleOverlap(task, existingClientTasks)) {
      return null; // caller shows the warning dialog
    }

    _isLoading = true;
    notifyListeners();

    try {
      final id = await _service.assignTask(task);
      _isLoading = false;
      notifyListeners();
      return id;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // ── Complete task (client) ────────────────────────────────────────────────

  Future<bool> completeTask({
    required String taskId,
    required String clientId,
    String? clientNote,
  }) async {
    try {
      await _service.completeTaskInstance(
        taskId: taskId,
        clientId: clientId,
        clientNote: clientNote,
      );
      // Optimistic local update
      final prev = _completionsCache[taskId] ?? {};
      _completionsCache[taskId] = {...prev, todayCompletionKey()};
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ── Streak for a task ─────────────────────────────────────────────────────

  int streakFor(String taskId, TaskModel task) {
    final keys = _completionsCache[taskId] ?? {};
    return calculateStreak(task, keys);
  }

  // ── Compliance for a task ─────────────────────────────────────────────────

  double complianceFor(String taskId, TaskModel task) {
    final keys = _completionsCache[taskId] ?? {};
    return complianceRate(task, keys);
  }

  String complianceLabelFor(String taskId, TaskModel task) {
    final keys = _completionsCache[taskId] ?? {};
    return complianceLabel(task, keys);
  }

  // ── Overlap check (coach assign screen) ───────────────────────────────────

  Future<bool> wouldOverlap(
      {required TaskModel newTask, required String clientId}) async {
    final existing = await _service.fetchActiveTasksForClient(
        coachId: newTask.coachId, clientId: clientId);
    return hasScheduleOverlap(newTask, existing);
  }

  // ── Delete task ───────────────────────────────────────────────────────────

  Future<void> deleteTask(String taskId) async {
    await _service.deleteTask(taskId, deleteCompletions: true);
    _allTasks.removeWhere((t) => t.id == taskId);
    _completionsCache.remove(taskId);
    _completionSubs[taskId]?.cancel();
    _completionSubs.remove(taskId);
    notifyListeners();
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _tasksSub?.cancel();
    for (final sub in _completionSubs.values) {
      sub.cancel();
    }
    super.dispose();
  }
}