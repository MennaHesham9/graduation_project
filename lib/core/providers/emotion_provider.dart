// lib/core/providers/emotion_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/agora_service.dart';
import '../services/emotion_detection_service.dart';
import '../services/emotion_analyzer.dart';
import '../models/emotion_summary.dart';

class EmotionProvider extends ChangeNotifier {
  EmotionDetectionService? _service;

  EmotionReading? currentEmotion;
  EmotionSummary? sessionSummary;

  bool isRunning = false;
  bool isLoading = false;
  String? error;

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

  void activateFrameCapture() {
    _service?.activateFrameCapture();
  }

  /// Stops frame processing, builds the [EmotionSummary] from all collected
  /// readings, and persists it to Firestore under the booking document.
  ///
  /// FIX: collection changed from 'sessions' → 'bookings' to match the rest
  /// of the app, and set+merge is used so the write is safe even if the
  /// emotionSummary field doesn't exist yet.
  Future<void> stopAndSave(String bookingId) async {
    isRunning = false;
    final readings = _service?.allReadings ?? [];
    sessionSummary = EmotionSummary.fromReadings(readings);

    try {
      await FirebaseFirestore.instance
          .collection('bookings')   // ← FIXED: was 'sessions'
          .doc(bookingId)
          .set(
            {'emotionSummary': sessionSummary!.toMap()},
            SetOptions(merge: true),
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
