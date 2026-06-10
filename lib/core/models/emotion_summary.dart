// lib/core/models/emotion_summary.dart

import '../services/emotion_analyzer.dart';

/// Aggregated emotion data for one completed session.
///
/// Produced by [EmotionSummary.fromReadings] at the end of the call and
/// stored under `sessions/{sessionId}` in Firestore.
/// Displayed to the coach only by [EmotionSummaryScreen].
class EmotionSummary {
  /// Raw counts per emotion label, e.g. {'happy': 12, 'calm': 30}.
  final Map<String, int> emotionCounts;

  /// The emotion label that appeared most frequently.
  final String dominantEmotion;

  /// Total number of [EmotionReading]s collected during the session.
  final int totalReadings;

  final DateTime generatedAt;

  /// Coach notes added via [EmotionSummaryScreen]. May be null/empty.
  final String coachNotes;

  EmotionSummary({
    required this.emotionCounts,
    required this.dominantEmotion,
    required this.totalReadings,
    required this.generatedAt,
    this.coachNotes = '',
  });

  factory EmotionSummary.fromReadings(List<EmotionReading> readings) {
    if (readings.isEmpty) {
      return EmotionSummary(
        emotionCounts: {},
        dominantEmotion: 'neutral',
        totalReadings: 0,
        generatedAt: DateTime.now(),
      );
    }

    final counts = <String, int>{};
    for (final r in readings) {
      counts[r.emotion.name] = (counts[r.emotion.name] ?? 0) + 1;
    }

    final dominant =
        counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    return EmotionSummary(
      emotionCounts: counts,
      dominantEmotion: dominant,
      totalReadings: readings.length,
      generatedAt: DateTime.now(),
    );
  }

  /// Percentage [0.0–1.0] of session time in each emotion.
  Map<String, double> get emotionPercentages {
    if (totalReadings == 0) return {};
    return emotionCounts.map(
          (emotion, count) => MapEntry(emotion, count / totalReadings),
    );
  }

  Map<String, dynamic> toMap() => {
    'emotionCounts': emotionCounts,
    'dominantEmotion': dominantEmotion,
    'totalReadings': totalReadings,
    'generatedAt': generatedAt.toUtc().toIso8601String(),
    'coachNotes': coachNotes,
  };

  factory EmotionSummary.fromMap(Map<String, dynamic> map) {
    return EmotionSummary(
      emotionCounts: Map<String, int>.from(map['emotionCounts'] ?? {}),
      dominantEmotion: map['dominantEmotion'] as String? ?? 'neutral',
      totalReadings: map['totalReadings'] as int? ?? 0,
      generatedAt: map['generatedAt'] != null
          ? DateTime.parse(map['generatedAt'] as String)
          : DateTime.now(),
      coachNotes: map['coachNotes'] as String? ?? '',
    );
  }

  /// Returns a copy with the given fields replaced.
  EmotionSummary copyWith({String? coachNotes}) => EmotionSummary(
    emotionCounts: emotionCounts,
    dominantEmotion: dominantEmotion,
    totalReadings: totalReadings,
    generatedAt: generatedAt,
    coachNotes: coachNotes ?? this.coachNotes,
  );
}
