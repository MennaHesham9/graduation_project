// lib/core/providers/emotion_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/emotion_detection_service.dart';
import '../services/emotion_analyzer.dart';
import '../models/emotion_summary.dart';

/// State management layer for emotion detection during a coaching session.
///
/// Registered in [main.dart] MultiProvider.
/// Consumed by [VideoSessionScreen] (live badge) and [EmotionSummaryScreen].
///
/// IMPORTANT: Always check [UserModel.allowSessionAnalysis] before calling
/// [startDetection]. [VideoSessionScreen] does this check — do not bypass it.
class EmotionProvider extends ChangeNotifier {
  final EmotionDetectionService _service = EmotionDetectionService();

  /// The most recent reading — drives the live emotion badge in the UI.
  EmotionReading? currentEmotion;

  /// Set by [stopAndSave] after the session ends.
  EmotionSummary? sessionSummary;

  bool isRunning = false;
  bool isLoading = false;
  String? error;

  /// Opens the camera and ML Kit detector, then begins streaming readings.
  /// Safe to call only if [UserModel.allowSessionAnalysis] is true.
  Future<void> startDetection() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _service.initialize();

      _service.onEmotionDetected = (reading) {
        currentEmotion = reading;
        notifyListeners();
      };

      isRunning = true;
    } catch (e) {
      error = 'Could not start emotion detection: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Stops the camera stream, builds the [EmotionSummary] from all collected
  /// readings, and persists it to Firestore under the booking document.
  ///
  /// Called by [VideoSessionScreen._endSession] before navigating away.
  Future<void> stopAndSave(String bookingId) async {
    isRunning = false;
    sessionSummary = EmotionSummary.fromReadings(_service.allReadings);

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'emotionSummary': sessionSummary!.toMap()});
    } catch (e) {
      // Non-fatal: summary is still available in memory for the summary screen
      error = 'Could not save emotion summary: $e';
    }

    await _service.dispose();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}