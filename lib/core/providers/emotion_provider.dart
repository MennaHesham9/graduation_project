// lib/core/providers/emotion_provider.dart
//
// FIX (Bug 2 + Bug 4):
//   - startDetection() now receives the RtcEngine from AgoraService so the
//     EmotionDetectionService can register a VideoFrameObserver instead of
//     opening a competing CameraController.
//   - stopAndSave() calls notifyListeners() before awaiting dispose() so the
//     EmotionSummaryScreen sees sessionSummary immediately — not after a
//     potential delay from releasing native resources.

import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/emotion_detection_service.dart';
import '../services/emotion_analyzer.dart';
import '../models/emotion_summary.dart';

/// State management layer for emotion detection during a coaching session.
///
/// Registered in [main.dart] MultiProvider.
/// Consumed by [VideoSessionScreen] (live badge) and [EmotionSummaryScreen].
///
/// IMPORTANT: Always check the *client's* [allowSessionAnalysis] flag before
/// calling [startDetection]. [VideoSessionScreen] does this check — do not
/// bypass it.
class EmotionProvider extends ChangeNotifier {
  final EmotionDetectionService _service = EmotionDetectionService();

  /// The most recent reading — drives the live emotion badge in the UI.
  EmotionReading? currentEmotion;

  /// Set by [stopAndSave] after the session ends.
  EmotionSummary? sessionSummary;

  bool isRunning = false;
  bool isLoading = false;
  String? error;

  /// Opens the ML Kit detector and registers an Agora VideoFrameObserver on
  /// [engine] — no second camera stream is opened.
  ///
  /// [engine] must already be initialised (i.e. [AgoraProvider.initAndJoin]
  /// must have completed successfully before this is called).
  ///
  /// Safe to call only when the client's [allowSessionAnalysis] is true.
  Future<void> startDetection(RtcEngine engine) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _service.initialize(engine);

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

  /// Stops the frame observer, builds the [EmotionSummary] from all collected
  /// readings, and persists it to Firestore under the booking document.
  ///
  /// Called by [VideoSessionScreen._endSession] before navigating away.
  Future<void> stopAndSave(String bookingId) async {
    isRunning = false;
    sessionSummary = EmotionSummary.fromReadings(_service.allReadings);

    // FIX (Bug 4): notify *before* the async dispose so the summary screen
    // receives the data immediately and doesn't get stuck on a loading spinner.
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'emotionSummary': sessionSummary!.toMap()});
    } catch (e) {
      // Non-fatal: summary is still available in memory for the summary screen.
      error = 'Could not save emotion summary: $e';
      notifyListeners();
    }

    await _service.dispose();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}