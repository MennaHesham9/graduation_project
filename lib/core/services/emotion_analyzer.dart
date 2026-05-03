// lib/core/services/emotion_analyzer.dart

/// The six emotions MindWell surfaces to coaches.
enum DetectedEmotion { happy, calm, tense, distracted, sad, neutral }

/// A single snapshot of the client's detected emotion.
/// Produced by [EmotionAnalyzer.analyze] and consumed by [EmotionProvider].
class EmotionReading {
  final DetectedEmotion emotion;
  final DateTime timestamp;

  /// Confidence score in [0.0, 1.0] — how strongly the raw signals support
  /// the classified emotion. Used in [EmotionSummary] but not shown in the UI.
  final double confidence;

  EmotionReading({
    required this.emotion,
    required this.timestamp,
    required this.confidence,
  });

  Map<String, dynamic> toMap() => {
    'emotion': emotion.name,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'confidence': confidence,
  };
}

/// Pure mapping layer: raw ML Kit numbers → [EmotionReading].
///
/// **All tuning lives here.** If emotions are misclassified during QA,
/// adjust only the threshold constants at the top of [analyze].
/// Nothing else in the codebase needs to change.
class EmotionAnalyzer {
  // ── ML Kit output semantics ──────────────────────────────────────────────
  // smileProb      : 0.0 (no smile) → 1.0 (big smile)
  // eyeOpenProb    : 0.0 (closed)   → 1.0 (wide open)
  // headEulerY     : rotation left/right in degrees (negative = left)
  // headEulerZ     : tilt in degrees
  // ────────────────────────────────────────────────────────────────────────

  static EmotionReading analyze({
    required double smileProb,
    required double leftEyeOpenProb,
    required double rightEyeOpenProb,
    required double headEulerY,
    required double headEulerZ,
  }) {
    final avgEyeOpen = (leftEyeOpenProb + rightEyeOpenProb) / 2;
    final isLookingAway = headEulerY.abs() > 25; // > 25° = clearly turned away
    final isTilted = headEulerZ.abs() > 20;      // > 20° = significant head tilt

    // HAPPY ─ smiling, eyes open, facing camera
    if (smileProb > 0.7 && avgEyeOpen > 0.6 && !isLookingAway) {
      return EmotionReading(
        emotion: DetectedEmotion.happy,
        timestamp: DateTime.now(),
        confidence: smileProb,
      );
    }

    // DISTRACTED ─ head turned or tilted significantly
    if (isLookingAway || isTilted) {
      return EmotionReading(
        emotion: DetectedEmotion.distracted,
        timestamp: DateTime.now(),
        confidence: (headEulerY.abs() / 90).clamp(0.0, 1.0),
      );
    }

    // TENSE ─ eyes wide open, not smiling, facing camera
    if (avgEyeOpen > 0.85 && smileProb < 0.2) {
      return EmotionReading(
        emotion: DetectedEmotion.tense,
        timestamp: DateTime.now(),
        confidence: avgEyeOpen,
      );
    }

    // SAD ─ eyes partly closed, not smiling
    if (avgEyeOpen < 0.4 && smileProb < 0.2) {
      return EmotionReading(
        emotion: DetectedEmotion.sad,
        timestamp: DateTime.now(),
        confidence: 1 - avgEyeOpen,
      );
    }

    // CALM ─ eyes normally open, no strong smile
    if (avgEyeOpen > 0.5 && smileProb < 0.5) {
      return EmotionReading(
        emotion: DetectedEmotion.calm,
        timestamp: DateTime.now(),
        confidence: 0.7,
      );
    }

    return EmotionReading(
      emotion: DetectedEmotion.neutral,
      timestamp: DateTime.now(),
      confidence: 0.5,
    );
  }
}