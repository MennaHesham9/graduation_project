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
class EmotionProvider extends ChangeNotifier {
  EmotionDetectionService? _service;

  /// The most recent reading — drives the live emotion badge in the UI.
  EmotionReading? currentEmotion;

  /// Set by [stopAndSave] after the session ends.
  EmotionSummary? sessionSummary;

  bool isRunning = false;
  bool isLoading = false;
  String? error;

  /// Initialises ML Kit and wires the frame callback, but does NOT yet enable
  /// Agora frame capture. Call [activateFrameCapture] once the remote user has
  /// joined and real video frames are actually flowing.
  ///
  /// Split into two steps so the detector is ready the instant the first frame
  /// arrives, with no cold-start delay.
  Future<void> startDetection(AgoraService agoraService) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      _service = EmotionDetectionService(agoraService);
      await _service!.initialize(); // warms up ML Kit; does NOT start frames yet

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

  /// Enables Agora frame capture. Call this only after the remote client has
  /// joined the channel (i.e. inside [AgoraProvider.onRemoteUserConnected]).
  /// Calling it before the client joins registers the observer but delivers
  /// zero frames, producing an empty summary.
  void activateFrameCapture() {
    _service?.activateFrameCapture();
  }

  /// Stops frame processing, builds the [EmotionSummary] from all collected
  /// readings, and persists it to Firestore under the booking document.
  ///
  /// Uses set+merge instead of update so it works even when the emotionSummary
  /// field doesn't exist yet on the booking document.
  Future<void> stopAndSave(String bookingId) async {
    isRunning = false;
    final readings = _service?.allReadings ?? [];
    sessionSummary = EmotionSummary.fromReadings(readings);

    try {
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(bookingId)
          .set(
            {'emotionSummary': sessionSummary!.toMap()},
            SetOptions(merge: true), // safe whether the field exists or not
          );
    } catch (e) {
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
