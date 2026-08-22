// lib/core/providers/emotion_provider.dart
//
// ── FIXES ────────────────────────────────────────────────────────────────────
//
// FIX 1 (Emotion summary saved to wrong Firestore collection):
//   The previous version wrote to 'bookings/{bookingId}' but the app uses
//   the 'sessions' collection. Changed the collection reference from
//   'bookings' → 'sessions' to match BookingService and Firestore rules.
//
// FIX 2 (notifyListeners before async dispose):
//   stopAndSave() notifies before awaiting dispose() so EmotionSummaryScreen
//   receives sessionSummary immediately. Preserved from previous version.
//
// FIX 3 (Emotion analyzing coach's face, not client's):
//   startDetection() requires [clientRemoteUid] and passes it to
//   EmotionDetectionService so it filters onRenderVideoFrame to the client's
//   remote stream only. Preserved from previous version.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/emotion_detection_service.dart';
import '../services/emotion_analyzer.dart';
import '../models/emotion_summary.dart';

/// State management layer for emotion detection during a coaching session.
///
/// ⚠️  This provider is scoped inside VideoSessionScreen's widget tree
/// (created alongside AgoraProvider). Do NOT register it in main.dart.
///
/// Call order:
///   1. AgoraProvider.initAndJoin() → engine + channel joined
///   2. Wait for AgoraProvider.remoteUserConnected == true → remoteUid known
///   3. EmotionProvider.startDetection(engine, clientRemoteUid)
class EmotionProvider extends ChangeNotifier {
  final EmotionDetectionService _service = EmotionDetectionService();

  /// Most recent reading — drives the live emotion badge.
  EmotionReading? currentEmotion;

  /// Set by [stopAndSave] after the session ends.
  EmotionSummary? sessionSummary;

  bool isRunning = false;
  bool isLoading = false;
  String? error;

  /// Starts ML Kit face detection on the CLIENT's remote video stream.
  ///
  /// [engine]          — already-initialised RtcEngine (from AgoraProvider).
  /// [clientRemoteUid] — Agora UID of the client (AgoraProvider.remoteUid).
  ///                     Required so detection targets the client's stream,
  ///                     NOT the coach's local camera.
  ///
  /// Only call this when:
  ///   • clientAllowsAnalysis == true (checked in VideoSessionScreen)
  ///   • AgoraProvider.remoteUserConnected == true (uid is valid)
  Future<void> startDetection(RtcEngine engine, int clientRemoteUid) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _service.initialize(engine, clientRemoteUid);

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

  /// Stops detection, builds the EmotionSummary, and persists to Firestore.
  ///
  /// FIX 1: Writes to 'sessions/{sessionId}' — the correct collection used
  /// throughout the app (BookingService uses _db.collection('sessions')).
  /// The previous version incorrectly wrote to 'bookings/{bookingId}' which
  /// does not exist and is not covered by Firestore security rules.
  ///
  /// Called by VideoSessionScreen._endSession() before navigation.
  Future<void> stopAndSave(String sessionId) async {
    isRunning = false;
    sessionSummary = EmotionSummary.fromReadings(_service.allReadings);

    // Notify before async dispose so EmotionSummaryScreen gets data immediately.
    notifyListeners();

    try {
      // FIX 1: 'sessions' not 'bookings'
      await FirebaseFirestore.instance
          .collection('sessions')
          .doc(sessionId)
          .update({'emotionSummary': sessionSummary!.toMap()});
    } catch (e) {
      // Non-fatal: summary is still available in memory for EmotionSummaryScreen.
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
