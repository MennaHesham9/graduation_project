// lib/core/providers/emotion_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/agora_service.dart';
import '../services/emotion_detection_service.dart';
import '../services/emotion_analyzer.dart';
import '../models/emotion_summary.dart';

/// State management layer for emotion detection during a coaching session.
///
/// Registered in [main.dart] MultiProvider.
/// Consumed by [VideoSessionScreen] (live badge) and [EmotionSummaryScreen].
///
/// IMPORTANT: Always check the client's [allowSessionAnalysis] before calling
/// [startDetection]. Pass [agoraService] from [AgoraProvider.service] so
/// detection taps into the existing Agora frame pipeline rather than opening
/// a competing CameraController.
class EmotionProvider extends ChangeNotifier {
  EmotionDetectionService? _service;

  /// The most recent reading — drives the live emotion badge in the UI.
  EmotionReading? currentEmotion;

  /// Set by [stopAndSave] after the session ends.
  EmotionSummary? sessionSummary;

  bool isRunning = false;
  bool isLoading = false;
  String? error;

  /// Opens the ML Kit detector and begins processing remote video frames
  /// delivered by Agora (via [AgoraService.onFrameCaptured]).
  ///
  /// [agoraService] must already be initialised (i.e. [AgoraProvider.initAndJoin]
  /// has been called) before this method is invoked.
  ///
  /// Only call this if the client has opted in (allowSessionAnalysis == true).
  Future<void> startDetection(AgoraService agoraService) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _service = EmotionDetectionService(agoraService);
      await _service!.initialize();

      _service!.onEmotionDetected = (reading) {
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

  /// Stops frame processing, builds the [EmotionSummary] from all collected
  /// readings, and persists it to Firestore under the booking document.
  ///
  /// Called by [VideoSessionScreen._endSession] before navigating away.
  /// Safe to call even if [startDetection] was never called (summary will be
  /// empty, which is correct when the client opted out).
  Future<void> stopAndSave(String bookingId) async {
    isRunning = false;
    final readings = _service?.allReadings ?? [];
    sessionSummary = EmotionSummary.fromReadings(readings);

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'emotionSummary': sessionSummary!.toMap()});
    } catch (e) {
      // Non-fatal: summary is still available in memory for the summary screen.
      error = 'Could not save emotion summary: $e';
    }

    await _service?.dispose();
    _service = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _service?.dispose();
    super.dispose();
  }
}
