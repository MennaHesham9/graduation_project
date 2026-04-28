// lib/features/tasks/models/task_model.dart
//
// TaskTemplate document — ONE document per assigned task, regardless of how
// many times it repeats.  Individual completions live in the sub-collection
// tasks/{taskId}/completions/{YYYY-MM-DD}.

import 'package:cloud_firestore/cloud_firestore.dart';

// ── Repetition type ───────────────────────────────────────────────────────────

enum RepetitionType { once, daily, weekly, custom }

extension RepetitionTypeX on RepetitionType {
  String get label {
    switch (this) {
      case RepetitionType.once:
        return 'Once';
      case RepetitionType.daily:
        return 'Daily';
      case RepetitionType.weekly:
        return 'Weekly';
      case RepetitionType.custom:
        return 'Custom';
    }
  }

  static RepetitionType fromString(String s) {
    switch (s.toLowerCase()) {
      case 'daily':
        return RepetitionType.daily;
      case 'weekly':
        return RepetitionType.weekly;
      case 'custom':
        return RepetitionType.custom;
      default:
        return RepetitionType.once;
    }
  }
}

// ── Priority ──────────────────────────────────────────────────────────────────

enum TaskPriority { low, medium, high }

extension TaskPriorityX on TaskPriority {
  String get label {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
    }
  }

  static TaskPriority fromString(String s) {
    switch (s.toLowerCase()) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }
}

// ── Effort ────────────────────────────────────────────────────────────────────

enum TaskEffort { five, fifteen, thirty, sixty }

extension TaskEffortX on TaskEffort {
  String get label {
    switch (this) {
      case TaskEffort.five:
        return '5 min';
      case TaskEffort.fifteen:
        return '15 min';
      case TaskEffort.thirty:
        return '30 min';
      case TaskEffort.sixty:
        return '60 min';
    }
  }

  static TaskEffort fromString(String s) {
    switch (s) {
      case '5 min':
        return TaskEffort.five;
      case '30 min':
        return TaskEffort.thirty;
      case '60 min':
        return TaskEffort.sixty;
      default:
        return TaskEffort.fifteen;
    }
  }
}

// ── TaskModel (the Template document) ────────────────────────────────────────

class TaskModel {
  final String id;

  // Parties
  final String coachId;
  final String clientId;
  final String coachName;
  final String clientName;

  // Content
  final String title;
  final String description;
  final String? attachmentUrl;
  final String? resourceLink;
  final String? privateCoachNote;

  // Schedule — all dates stored as UTC, displayed as local
  final RepetitionType repetition;

  /// For RepetitionType.custom: list of weekday ints (1=Mon … 7=Sun).
  final List<int> selectedDays;

  final DateTime startDate; // UTC
  final DateTime? endDate; // UTC — null means "no end date"

  // Meta
  final TaskPriority priority;
  final TaskEffort effort;
  final bool remindersEnabled;
  final String? reminderTime; // "08:00"
  final bool visibleToClient;

  // Firestore timestamps
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.coachId,
    required this.clientId,
    required this.coachName,
    required this.clientName,
    required this.title,
    this.description = '',
    this.attachmentUrl,
    this.resourceLink,
    this.privateCoachNote,
    required this.repetition,
    this.selectedDays = const [],
    required this.startDate,
    this.endDate,
    this.priority = TaskPriority.medium,
    this.effort = TaskEffort.fifteen,
    this.remindersEnabled = true,
    this.reminderTime,
    this.visibleToClient = true,
    required this.createdAt,
  });

  // ── Firestore → TaskModel ─────────────────────────────────────────────────

  factory TaskModel.fromMap(String id, Map<String, dynamic> m) {
    DateTime _ts(dynamic v) {
      if (v is Timestamp) return v.toDate().toUtc();
      if (v is String) return DateTime.parse(v).toUtc();
      return DateTime.now().toUtc();
    }

    return TaskModel(
      id: id,
      coachId: m['coachId'] as String? ?? '',
      clientId: m['clientId'] as String? ?? '',
      coachName: m['coachName'] as String? ?? '',
      clientName: m['clientName'] as String? ?? '',
      title: m['title'] as String? ?? '',
      description: m['description'] as String? ?? '',
      attachmentUrl: m['attachmentUrl'] as String?,
      resourceLink: m['resourceLink'] as String?,
      privateCoachNote: m['privateCoachNote'] as String?,
      repetition:
      RepetitionTypeX.fromString(m['repetition'] as String? ?? 'once'),
      selectedDays:
      (m['selectedDays'] as List?)?.map((e) => e as int).toList() ?? [],
      startDate: _ts(m['startDate']),
      endDate: m['endDate'] != null ? _ts(m['endDate']) : null,
      priority: TaskPriorityX.fromString(m['priority'] as String? ?? 'medium'),
      effort: TaskEffortX.fromString(m['effort'] as String? ?? '15 min'),
      remindersEnabled: m['remindersEnabled'] as bool? ?? true,
      reminderTime: m['reminderTime'] as String?,
      visibleToClient: m['visibleToClient'] as bool? ?? true,
      createdAt: _ts(m['createdAt']),
    );
  }

  // ── TaskModel → Firestore ─────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
    'coachId': coachId,
    'clientId': clientId,
    'coachName': coachName,
    'clientName': clientName,
    'title': title,
    'description': description,
    if (attachmentUrl != null) 'attachmentUrl': attachmentUrl,
    if (resourceLink != null) 'resourceLink': resourceLink,
    if (privateCoachNote != null) 'privateCoachNote': privateCoachNote,
    'repetition': repetition.label.toLowerCase(),
    'selectedDays': selectedDays,
    'startDate': Timestamp.fromDate(startDate),
    'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'priority': priority.label.toLowerCase(),
    'effort': effort.label,
    'remindersEnabled': remindersEnabled,
    if (reminderTime != null) 'reminderTime': reminderTime,
    'visibleToClient': visibleToClient,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

// ── TaskCompletion (sub-collection document) ──────────────────────────────────
//
// Path: tasks/{taskId}/completions/{YYYY-MM-DD}
// Document ID = the local date string on which the client completed the task.

class TaskCompletion {
  final String dateKey; // "2026-04-28"
  final String taskId;
  final String clientId;
  final String? clientNote;
  final DateTime completedAt; // UTC

  const TaskCompletion({
    required this.dateKey,
    required this.taskId,
    required this.clientId,
    this.clientNote,
    required this.completedAt,
  });

  factory TaskCompletion.fromMap(String dateKey, Map<String, dynamic> m) {
    DateTime _ts(dynamic v) {
      if (v is Timestamp) return v.toDate().toUtc();
      if (v is String) return DateTime.parse(v).toUtc();
      return DateTime.now().toUtc();
    }

    return TaskCompletion(
      dateKey: dateKey,
      taskId: m['taskId'] as String? ?? '',
      clientId: m['clientId'] as String? ?? '',
      clientNote: m['clientNote'] as String?,
      completedAt: _ts(m['completedAt']),
    );
  }

  Map<String, dynamic> toMap() => {
    'taskId': taskId,
    'clientId': clientId,
    if (clientNote != null) 'clientNote': clientNote,
    'completedAt': Timestamp.fromDate(completedAt),
    'status': 'completed',
  };
}