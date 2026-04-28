// lib/features/tasks/services/task_service.dart
//
// All Firestore operations for the task system.
// Free-plan friendly: one TaskTemplate doc + lightweight completion sub-docs.
//
// Collection structure:
//   tasks/{taskId}                        ← TaskModel
//   tasks/{taskId}/completions/{dateKey}  ← TaskCompletion

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task_model.dart';
import '../utils/task_logic.dart';

class TaskService {
  final FirebaseFirestore _db;

  TaskService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  // ── Collection refs ───────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _tasks =>
      _db.collection('tasks');

  CollectionReference<Map<String, dynamic>> _completions(String taskId) =>
      _tasks.doc(taskId).collection('completions');

  // ─────────────────────────────────────────────────────────────────────────
  // COACH: Assign a new task
  // ─────────────────────────────────────────────────────────────────────────

  /// Creates a single TaskTemplate document.
  /// Returns the new task's Firestore ID.
  Future<String> assignTask(TaskModel task) async {
    final ref = _tasks.doc(); // auto-ID
    final withId = TaskModel(
      id: ref.id,
      coachId: task.coachId,
      clientId: task.clientId,
      coachName: task.coachName,
      clientName: task.clientName,
      title: task.title,
      description: task.description,
      attachmentUrl: task.attachmentUrl,
      resourceLink: task.resourceLink,
      privateCoachNote: task.privateCoachNote,
      repetition: task.repetition,
      selectedDays: task.selectedDays,
      startDate: task.startDate,
      endDate: task.endDate,
      priority: task.priority,
      effort: task.effort,
      remindersEnabled: task.remindersEnabled,
      reminderTime: task.reminderTime,
      visibleToClient: task.visibleToClient,
      createdAt: DateTime.now().toUtc(),
    );
    await ref.set(withId.toMap());
    return ref.id;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CLIENT: Stream tasks assigned to a client
  // ─────────────────────────────────────────────────────────────────────────

  /// Streams ALL task templates for [clientId].
  /// The client UI applies isTaskDueToday() locally to filter the list.
  /// This avoids composite indexes on the free plan.
  Stream<List<TaskModel>> streamClientTasks(String clientId) {
    return _tasks
        .where('clientId', isEqualTo: clientId)
        .where('visibleToClient', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => TaskModel.fromMap(d.id, d.data()))
        .toList());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COACH: Stream tasks assigned by coach to a specific client
  // ─────────────────────────────────────────────────────────────────────────

  Stream<List<TaskModel>> streamCoachClientTasks(
      {required String coachId, required String clientId}) {
    return _tasks
        .where('coachId', isEqualTo: coachId)
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => TaskModel.fromMap(d.id, d.data()))
        .toList());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // CLIENT: Complete a task occurrence (one Firestore write per completion)
  // ─────────────────────────────────────────────────────────────────────────

  /// Marks today's occurrence of [taskId] as completed.
  /// Uses today's local date as the document ID so we never duplicate.
  /// Passing [clientNote] is optional (task details screen note field).
  Future<void> completeTaskInstance({
    required String taskId,
    required String clientId,
    String? clientNote,
  }) async {
    final dateKey = todayCompletionKey();
    final completion = TaskCompletion(
      dateKey: dateKey,
      taskId: taskId,
      clientId: clientId,
      clientNote: clientNote,
      completedAt: DateTime.now().toUtc(),
    );

    // set() is idempotent — safe if tapped twice
    await _completions(taskId).doc(dateKey).set(completion.toMap());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Check if today's occurrence is already completed (local cache + Firestore)
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns true if the client already completed [taskId] today.
  Future<bool> isTodayCompleted(String taskId) async {
    final dateKey = todayCompletionKey();
    final doc = await _completions(taskId).doc(dateKey).get();
    return doc.exists;
  }

  /// Stream version — UI updates automatically.
  Stream<bool> streamIsTodayCompleted(String taskId) {
    final dateKey = todayCompletionKey();
    return _completions(taskId).doc(dateKey).snapshots().map((s) => s.exists);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Fetch all completion keys for a task (for streak / compliance)
  // ─────────────────────────────────────────────────────────────────────────

  Future<Set<String>> fetchCompletionKeys(String taskId) async {
    final snap = await _completions(taskId).get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Stream<Set<String>> streamCompletionKeys(String taskId) {
    return _completions(taskId)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COACH: Overlapping task guard
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns all ACTIVE tasks for [clientId] assigned by [coachId].
  /// Used before assigning a new task to check for schedule overlap.
  Future<List<TaskModel>> fetchActiveTasksForClient(
      {required String coachId, required String clientId}) async {
    final snap = await _tasks
        .where('coachId', isEqualTo: coachId)
        .where('clientId', isEqualTo: clientId)
        .get();

    final now = DateTime.now().toUtc();
    return snap.docs
        .map((d) => TaskModel.fromMap(d.id, d.data()))
        .where((t) =>
    t.endDate == null || t.endDate!.isAfter(now)) // still active
        .toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COACH: Compliance rate for a specific task
  // ─────────────────────────────────────────────────────────────────────────

  Future<double> getComplianceRate(TaskModel task) async {
    final keys = await fetchCompletionKeys(task.id);
    return complianceRate(task, keys);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // COACH: Delete a task template (and all its completions)
  // ─────────────────────────────────────────────────────────────────────────

  /// Deletes the template.  Sub-collection completions are NOT auto-deleted
  /// by Firestore on free plan — pass [deleteCompletions: true] to also
  /// delete them (uses a batch, max 500 completions).
  Future<void> deleteTask(String taskId,
      {bool deleteCompletions = false}) async {
    if (deleteCompletions) {
      final completionSnap = await _completions(taskId).get();
      final batch = _db.batch();
      for (final doc in completionSnap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_tasks.doc(taskId));
      await batch.commit();
    } else {
      await _tasks.doc(taskId).delete();
    }
  }
}