// lib/core/services/emotion_detection_service.dart
//
// ── FIXES ────────────────────────────────────────────────────────────────────
//
// FIX 1 (Wrong video stream — root cause of emotion analyzing coach's face):
//   Uses onRenderVideoFrame (remote decoded stream) not onCaptureVideoFrame
//   (local camera). Filters by _clientRemoteUid. Preserved from previous.
//
// FIX 2 (0 readings despite connection):
//   The Agora Flutter SDK v6 onRenderVideoFrame signature changed across
//   patch releases. The callback parameters are:
//     (String channelId, int uid, VideoFrame videoFrame)
//   not (int uid, int connectionId, VideoFrame). Updated to match v6 API.
//   Also wrapped registration in a try/catch with a logged fallback so
//   initialization errors surface instead of silently producing 0 readings.
//
// FIX 3 (Frame rotation — faces not detected):
//   Remote frames from Agora on Android are typically delivered in
//   rotation0deg but can be rotation90deg on some devices depending on
//   the sender's camera orientation. Added an adaptive retry: if no face
//   is found with rotation0, the next frame attempts rotation90.
//
// FIX 4 (Agora v6 MediaEngine API):
//   Registration goes through engine.getMediaEngine(). Preserved.
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

import 'emotion_analyzer.dart';

/// Analyzes the CLIENT's face from the Agora remote video stream using ML Kit.
///
/// Lifecycle:
///   1. Wait for the client to join (AgoraProvider.remoteUserConnected == true).
///   2. Call [initialize] with the already-initialised RtcEngine and the
///      client's remote UID.
///   3. Frames flow: Agora → [onRenderVideoFrame for remoteUid] →
///      [_processFrame] → [EmotionAnalyzer.analyze] → [onEmotionDetected].
///   4. Call [dispose] to unregister the observer and release ML Kit.
class EmotionDetectionService {
  FaceDetector? _faceDetector;
  RtcEngine? _engine;
  VideoFrameObserver? _frameObserver;
  bool _isProcessing = false;

  /// The remote UID of the CLIENT whose face we are analysing.
  int? _clientRemoteUid;

  /// FIX 3: Adaptive rotation — cycle through rotations if no face is found.
  InputImageRotation _rotation = InputImageRotation.rotation0deg;
  int _consecutiveNoFace = 0;
  static const int _rotationSwitchThreshold = 10;

  /// All readings collected since [initialize] was called.
  final List<EmotionReading> sessionReadings = [];

  /// Wired by [EmotionProvider] to update live badge state.
  Function(EmotionReading)? onEmotionDetected;

  /// Initialise ML Kit and register the Agora frame observer.
  ///
  /// [engine]          — already-initialised RtcEngine from AgoraService.
  /// [clientRemoteUid] — Agora UID of the CLIENT (from AgoraProvider.remoteUid).
  ///
  /// Must be called AFTER AgoraProvider.remoteUserConnected == true.
  Future<void> initialize(RtcEngine engine, int clientRemoteUid) async {
    _engine = engine;
    _clientRemoteUid = clientRemoteUid;

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // smileProb + eyeOpenProb
        enableLandmarks: false,
        enableTracking: true,
        minFaceSize: 0.10, // slightly lower threshold for remote compressed video
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    // FIX 2: Correct Agora Flutter SDK v6 callback signature.
    // onRenderVideoFrame receives (channelId, uid, videoFrame) — NOT
    // (uid, connectionId, videoFrame) as previously coded. The UID is the
    // second parameter so we compare it against _clientRemoteUid.
    _frameObserver = VideoFrameObserver(
      onRenderVideoFrame: (String channelId, int uid, VideoFrame videoFrame) {
        // Only analyse the client's incoming stream.
        if (uid == _clientRemoteUid) {
          _processFrame(videoFrame);
        }
      },
    );

    try {
      _engine!.getMediaEngine().registerVideoFrameObserver(_frameObserver!);
      debugPrint('[EmotionDetection] Frame observer registered for UID $_clientRemoteUid');
    } catch (e) {
      debugPrint('[EmotionDetection] Failed to register frame observer: $e');
      rethrow;
    }
  }

  void _processFrame(VideoFrame frame) async {
    if (_isProcessing) return;

    final yBuffer = frame.yBuffer;
    if (yBuffer == null || yBuffer.isEmpty) return;

    _isProcessing = true;

    try {
      final inputImage = _convertToInputImage(frame, _rotation);
      if (inputImage == null) {
        // Throttle and release.
        await Future.delayed(const Duration(milliseconds: 500));
        _isProcessing = false;
        return;
      }

      final faces = await _faceDetector!.processImage(inputImage);

      // FIX 3: If no face found, increment counter and maybe rotate.
      if (faces.isEmpty) {
        _consecutiveNoFace++;
        if (_consecutiveNoFace >= _rotationSwitchThreshold) {
          _consecutiveNoFace = 0;
          _rotation = _nextRotation(_rotation);
          debugPrint('[EmotionDetection] No face found, trying rotation: $_rotation');
        }
        await Future.delayed(const Duration(milliseconds: 500));
        _isProcessing = false;
        return;
      }

      // Face found — reset rotation adaptation counter.
      _consecutiveNoFace = 0;

      final face = faces.first;
      final reading = EmotionAnalyzer.analyze(
        smileProb: face.smilingProbability ?? 0.0,
        leftEyeOpenProb: face.leftEyeOpenProbability ?? 0.5,
        rightEyeOpenProb: face.rightEyeOpenProbability ?? 0.5,
        headEulerY: face.headEulerAngleY ?? 0.0,
        headEulerZ: face.headEulerAngleZ ?? 0.0,
      );

      sessionReadings.add(reading);
      onEmotionDetected?.call(reading);
      debugPrint('[EmotionDetection] Reading: ${reading.emotion.name} (${sessionReadings.length} total)');
    } catch (e) {
      debugPrint('[EmotionDetection] Frame processing error: $e');
    } finally {
      // Throttle to ~2 readings per second.
      await Future.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;
    }
  }

  InputImage? _convertToInputImage(VideoFrame frame, InputImageRotation rotation) {
    final yBuffer = frame.yBuffer;
    final uBuffer = frame.uBuffer;
    final vBuffer = frame.vBuffer;

    if (yBuffer == null) return null;

    final width = frame.width ?? 0;
    final height = frame.height ?? 0;
    if (width == 0 || height == 0) return null;

    Uint8List bytes;
    if (uBuffer != null && vBuffer != null) {
      // Full YUV420: interleave U and V into NV21 (VU order)
      final vuInterleaved = Uint8List(uBuffer.length + vBuffer.length);
      for (int i = 0; i < uBuffer.length; i++) {
        vuInterleaved[i * 2] = vBuffer[i];
        vuInterleaved[i * 2 + 1] = uBuffer[i];
      }
      bytes = Uint8List(yBuffer.length + vuInterleaved.length);
      bytes.setAll(0, yBuffer);
      bytes.setAll(yBuffer.length, vuInterleaved);
    } else {
      bytes = Uint8List.fromList(yBuffer);
    }

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: frame.yStride ?? width,
      ),
    );
  }

  /// Cycles through the four possible rotations for adaptive detection.
  InputImageRotation _nextRotation(InputImageRotation current) {
    switch (current) {
      case InputImageRotation.rotation0deg:
        return InputImageRotation.rotation90deg;
      case InputImageRotation.rotation90deg:
        return InputImageRotation.rotation270deg;
      case InputImageRotation.rotation270deg:
        return InputImageRotation.rotation180deg;
      case InputImageRotation.rotation180deg:
        return InputImageRotation.rotation0deg;
    }
  }

  List<EmotionReading> get allReadings => List.unmodifiable(sessionReadings);

  Future<void> dispose() async {
    if (_frameObserver != null) {
      try {
        _engine?.getMediaEngine().unregisterVideoFrameObserver(_frameObserver!);
      } catch (e) {
        debugPrint('[EmotionDetection] Error unregistering observer: $e');
      }
      _frameObserver = null;
    }
    await _faceDetector?.close();
    _faceDetector = null;
    _engine = null;
    _clientRemoteUid = null;
  }
}
