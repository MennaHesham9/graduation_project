// lib/core/providers/emotion_provider.dart

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/emotion_detection_service.dart';
import '../services/emotion_analyzer.dart';
import '../models/emotion_summary.dart';

class EmotionProvider extends ChangeNotifier {
  final EmotionDetectionService _service = EmotionDetectionService();

  EmotionReading? currentEmotion;
  EmotionSummary? sessionSummary;
  bool isRunning = false;
  bool isLoading = false;
  String? error;

  /// Start detection by tapping into the already-running Agora engine.
  ///
  /// [engine]    — from AgoraProvider.service.engine
  /// [remoteUid] — from AgoraProvider.remoteUid (the client's Agora UID)
  ///
  /// IMPORTANT: call this only AFTER the remote user has joined
  /// (AgoraProvider.remoteUserConnected == true) so remoteUid is valid.
  Future<void> startDetection(RtcEngine engine, int remoteUid) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      // FIX: wire callback BEFORE initialize so no frames are missed
      _service.onEmotionDetected = (reading) {
        currentEmotion = reading;
        notifyListeners();
      };

      // FIX: pass Agora engine + client UID — analyses remote frames,
      // not the coach's own camera
      await _service.initialize(engine, remoteUid);
      isRunning = true;
    } catch (e) {
      error = 'Could not start emotion detection: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> stopAndSave(String bookingId) async {
    isRunning = false;
    sessionSummary = EmotionSummary.fromReadings(_service.allReadings);

    try {
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({'emotionSummary': sessionSummary!.toMap()});
    } catch (e) {
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