// lib/features/tasks/utils/task_logic.dart
//
// Pure functions — no Firebase, no Flutter deps.
// All "today" comparisons use the DEVICE LOCAL date so timezone is automatic
// (dates are stored UTC, DateTime.toLocal() is called when reading them).

import '../models/task_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// 1. Is this task due today?
// ─────────────────────────────────────────────────────────────────────────────

/// Returns true if [task] should appear in the client's task list today.
///
/// Logic per repetition type:
/// • once   → visible if today is within [startDate, endDate] (endDate required)
/// • daily  → visible every day within [startDate, endDate?]
/// • weekly → visible if today is exactly 7n days from startDate (and in range)
/// • custom → visible if today's weekday is in [selectedDays] (and in range)
bool isTaskDueToday(TaskModel task) {
  final now = DateTime.now();
  final today = _dateOnly(now);

  // Convert stored UTC dates to local for comparison
  final start = _dateOnly(task.startDate.toLocal());
  final end = task.endDate != null ? _dateOnly(task.endDate!.toLocal()) : null;

  // Must have started
  if (today.isBefore(start)) return false;

  // Must not be past end date (if one exists)
  if (end != null && today.isAfter(end)) return false;

  switch (task.repetition) {
    case RepetitionType.once:
    // Visible only on startDate itself (or until end date if coach set one)
      return true; // already passed range check above

    case RepetitionType.daily:
      return true; // every day in range

    case RepetitionType.weekly:
    // Due every 7 days counting from startDate
      final daysSinceStart = today.difference(start).inDays;
      return daysSinceStart % 7 == 0;

    case RepetitionType.custom:
    // Coach picked specific weekdays (1=Mon … 7=Sun, matching DateTime.weekday)
      return task.selectedDays.contains(today.weekday);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Completion key for today
// ─────────────────────────────────────────────────────────────────────────────

/// Returns the Firestore document ID to use for today's completion.
/// Format: "YYYY-MM-DD" in the device's LOCAL timezone.
String todayCompletionKey() {
  final now = DateTime.now();
  return _dateKey(now);
}

/// Returns the date key for any given local [date].
String dateKeyFor(DateTime date) => _dateKey(date);

// ─────────────────────────────────────────────────────────────────────────────
// 3. Streak counter
// ─────────────────────────────────────────────────────────────────────────────

/// Given a set of completion date keys (e.g. {"2026-04-26","2026-04-27","2026-04-28"})
/// and the task's repetition type, returns the current consecutive streak.
///
/// For RepetitionType.daily  → counts consecutive days ending today.
/// For RepetitionType.weekly → counts consecutive 7-day windows.
/// For once / custom         → returns total completions (streak concept not applicable).
int calculateStreak(TaskModel task, Set<String> completedKeys) {
  if (completedKeys.isEmpty) return 0;

  switch (task.repetition) {
    case RepetitionType.daily:
      return _dailyStreak(completedKeys);

    case RepetitionType.weekly:
      return _weeklyStreak(task, completedKeys);

    case RepetitionType.once:
    case RepetitionType.custom:
      return completedKeys.length;
  }
}

int _dailyStreak(Set<String> keys) {
  var streak = 0;
  var cursor = DateTime.now();

  while (true) {
    final key = _dateKey(cursor);
    if (keys.contains(key)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }
  return streak;
}

int _weeklyStreak(TaskModel task, Set<String> keys) {
  final start = _dateOnly(task.startDate.toLocal());
  var streak = 0;
  var windowStart = start;
  final today = _dateOnly(DateTime.now());

  while (!windowStart.isAfter(today)) {
    final windowEnd = windowStart.add(const Duration(days: 6));
    // Check if any completion falls in this 7-day window
    final hasCompletion = keys.any((k) {
      final d = DateTime.parse(k);
      return !d.isBefore(windowStart) && !d.isAfter(windowEnd);
    });

    if (hasCompletion) {
      streak++;
    } else if (windowEnd.isBefore(today)) {
      // Missed a past window — streak resets
      streak = 0;
    }
    windowStart = windowStart.add(const Duration(days: 7));
  }
  return streak;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Compliance rate (coach view)
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a value 0.0–1.0 representing what fraction of expected occurrences
/// have been completed so far.
///
/// Example: daily task for 7 days, client completed 5 → 0.71
double complianceRate(TaskModel task, Set<String> completedKeys) {
  final expected = expectedOccurrences(task);
  if (expected == 0) return 0.0;
  return (completedKeys.length / expected).clamp(0.0, 1.0);
}

/// Returns a human-readable compliance string for the coach UI.
/// e.g. "5 / 7 (71%)"
String complianceLabel(TaskModel task, Set<String> completedKeys) {
  final expected = expectedOccurrences(task);
  final completed = completedKeys.length.clamp(0, expected);
  final pct = expected > 0 ? ((completed / expected) * 100).round() : 0;
  return '$completed / $expected ($pct%)';
}

/// How many times should this task have occurred between startDate and today?
int expectedOccurrences(TaskModel task) {
  final start = _dateOnly(task.startDate.toLocal());
  final today = _dateOnly(DateTime.now());

  if (today.isBefore(start)) return 0;

  final end = task.endDate != null
      ? _dateOnly(task.endDate!.toLocal())
      : today;

  final effectiveEnd = end.isAfter(today) ? today : end;
  if (effectiveEnd.isBefore(start)) return 0;

  switch (task.repetition) {
    case RepetitionType.once:
      return 1;

    case RepetitionType.daily:
      return effectiveEnd.difference(start).inDays + 1;

    case RepetitionType.weekly:
      return (effectiveEnd.difference(start).inDays ~/ 7) + 1;

    case RepetitionType.custom:
    // Count days in range that match selectedDays weekdays
      var count = 0;
      var cursor = start;
      while (!cursor.isAfter(effectiveEnd)) {
        if (task.selectedDays.contains(cursor.weekday)) count++;
        cursor = cursor.add(const Duration(days: 1));
      }
      return count;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Overlapping task check
// ─────────────────────────────────────────────────────────────────────────────

/// Returns true if [newTask]'s schedule overlaps with any task in [existing]
/// on the same days.  Used to warn the coach before assigning.
bool hasScheduleOverlap(TaskModel newTask, List<TaskModel> existing) {
  for (final t in existing) {
    if (_tasksOverlap(newTask, t)) return true;
  }
  return false;
}

bool _tasksOverlap(TaskModel a, TaskModel b) {
  // Date range overlap check
  final aStart = _dateOnly(a.startDate.toLocal());
  final aEnd = a.endDate != null
      ? _dateOnly(a.endDate!.toLocal())
      : aStart.add(const Duration(days: 365));
  final bStart = _dateOnly(b.startDate.toLocal());
  final bEnd = b.endDate != null
      ? _dateOnly(b.endDate!.toLocal())
      : bStart.add(const Duration(days: 365));

  // No date range overlap → no conflict
  if (aEnd.isBefore(bStart) || bEnd.isBefore(aStart)) return false;

  // Now check if they share any weekday
  final aDays = _activeDays(a);
  final bDays = _activeDays(b);
  return aDays.any((d) => bDays.contains(d));
}

Set<int> _activeDays(TaskModel task) {
  switch (task.repetition) {
    case RepetitionType.once:
      return {task.startDate.toLocal().weekday};
    case RepetitionType.daily:
      return {1, 2, 3, 4, 5, 6, 7};
    case RepetitionType.weekly:
      return {task.startDate.toLocal().weekday};
    case RepetitionType.custom:
      return task.selectedDays.toSet();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Helpers
// ─────────────────────────────────────────────────────────────────────────────

DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

String _dateKey(DateTime dt) {
  final local = dt.toLocal();
  return '${local.year}-'
      '${local.month.toString().padLeft(2, '0')}-'
      '${local.day.toString().padLeft(2, '0')}';
}