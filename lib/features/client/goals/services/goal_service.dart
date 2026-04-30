// lib/features/client/goals/services/goal_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get _col => _db.collection('goals');

  // ── Stream all goals for a client ─────────────────────────────────────────
  Stream<List<GoalModel>> streamClientGoals(String clientId) {
    return _col
        .where('clientId', isEqualTo: clientId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => GoalModel.fromMap(d.id, d.data() as Map<String, dynamic>))
        .toList());
  }

  // ── Create a goal ─────────────────────────────────────────────────────────
  Future<String> createGoal(GoalModel goal) async {
    final ref = await _col.add(goal.toMap());
    return ref.id;
  }

  // ── Toggle a single action step ───────────────────────────────────────────
  Future<void> toggleActionStep({
    required String goalId,
    required List<ActionStep> updatedSteps,
  }) async {
    await _col.doc(goalId).update({
      'actionSteps': updatedSteps.map((s) => s.toMap()).toList(),
    });
  }

  // ── Delete a goal ─────────────────────────────────────────────────────────
  Future<void> deleteGoal(String goalId) async {
    await _col.doc(goalId).delete();
  }
}