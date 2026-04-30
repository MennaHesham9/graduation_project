// lib/features/client/goals/models/goal_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ActionStep {
  final String id;
  final String text;
  final bool isDone;

  const ActionStep({
    required this.id,
    required this.text,
    this.isDone = false,
  });

  ActionStep copyWith({bool? isDone}) =>
      ActionStep(id: id, text: text, isDone: isDone ?? this.isDone);

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'isDone': isDone,
  };

  factory ActionStep.fromMap(Map<String, dynamic> m) => ActionStep(
    id: m['id'] as String? ?? '',
    text: m['text'] as String? ?? '',
    isDone: m['isDone'] as bool? ?? false,
  );
}

class GoalModel {
  final String id;
  final String clientId;
  final String title;
  final String description;
  final String category;
  final DateTime? startDate;
  final DateTime? targetDate;
  final List<ActionStep> actionSteps;
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.category,
    this.startDate,
    this.targetDate,
    required this.actionSteps,
    required this.createdAt,
  });

  // ── Computed ───────────────────────────────────────────────────────────────
  double get progress {
    if (actionSteps.isEmpty) return 0.0;
    final done = actionSteps.where((s) => s.isDone).length;
    return done / actionSteps.length;
  }

  int get completedSteps => actionSteps.where((s) => s.isDone).length;
  int get totalSteps => actionSteps.length;

  // ── Firestore ↔ Model ──────────────────────────────────────────────────────
  factory GoalModel.fromMap(String id, Map<String, dynamic> m) => GoalModel(
    id: id,
    clientId: m['clientId'] as String? ?? '',
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    category: m['category'] as String? ?? '',
    startDate: m['startDate'] != null
        ? (m['startDate'] as Timestamp).toDate()
        : null,
    targetDate: m['targetDate'] != null
        ? (m['targetDate'] as Timestamp).toDate()
        : null,
    actionSteps: (m['actionSteps'] as List? ?? [])
        .map((e) => ActionStep.fromMap(e as Map<String, dynamic>))
        .toList(),
    createdAt: m['createdAt'] != null
        ? (m['createdAt'] as Timestamp).toDate()
        : DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'clientId': clientId,
    'title': title,
    'description': description,
    'category': category,
    if (startDate != null) 'startDate': Timestamp.fromDate(startDate!),
    if (targetDate != null) 'targetDate': Timestamp.fromDate(targetDate!),
    'actionSteps': actionSteps.map((s) => s.toMap()).toList(),
    'createdAt': Timestamp.fromDate(createdAt),
  };

  GoalModel copyWith({List<ActionStep>? actionSteps}) => GoalModel(
    id: id,
    clientId: clientId,
    title: title,
    description: description,
    category: category,
    startDate: startDate,
    targetDate: targetDate,
    actionSteps: actionSteps ?? this.actionSteps,
    createdAt: createdAt,
  );
}