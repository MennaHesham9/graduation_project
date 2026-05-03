// lib/core/services/emotion_detection_service.dart
//
// ── FIXES ────────────────────────────────────────────────────────────────────
//
// FIX 1 (Wrong video stream — root cause of emotion analyzing coach's face):
//   The old code used onCaptureVideoFrame, which delivers the LOCAL camera
//   frames — i.e. the COACH's own face. We need the CLIENT's face, which
//   arrives as a REMOTE rendered frame.
//
//   Fix: Use onRenderVideoFrame instead of onCaptureVideoFrame.
//   onRenderVideoFrame fires for each decoded remote frame and provides the
//   remote UID, so we can filter specifically for the client's UID.
//
//   initialize() now requires the remote UID (int remoteUid) in addition to
//   the RtcEngine. Pass agora.remoteUid after the client has joined.
//
// FIX 2 (Agora v6 MediaEngine API):
//   VideoFrameObserver registration/unregistration must go through
//   engine.getMediaEngine(), not directly on RtcEngine. Already correct in
//   the previous version — preserved here.
//
// FIX 3 (dart:ui Size import):
//   Size is from dart:ui, not package:flutter/material.dart. Already correct
//   in the previous version — preserved here.
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
  /// Set once in [initialize] and used to filter onRenderVideoFrame events.
  int? _clientRemoteUid;

  /// All readings collected since [initialize] was called.
  final List<EmotionReading> sessionReadings = [];

  /// Wired by [EmotionProvider] to update live badge state.
  Function(EmotionReading)? onEmotionDetected;

  /// Initialise ML Kit and register the Agora frame observer.
  ///
  /// [engine]        — already-initialised RtcEngine from AgoraService.
  /// [clientRemoteUid] — the Agora UID assigned to the CLIENT (from
  ///                   AgoraProvider.remoteUid). This is required so we
  ///                   analyse the client's incoming stream, NOT the coach's
  ///                   local camera.
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
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    // FIX 1: Use onRenderVideoFrame to capture the REMOTE (client) stream.
    //   - onCaptureVideoFrame = local camera (coach's face) ← WRONG
    //   - onRenderVideoFrame  = decoded remote frame per UID ← CORRECT
    //
    // The callback receives (uid, videoFrame). We filter by _clientRemoteUid
    // so we only process frames from the client, ignoring any other participants.
    _frameObserver = VideoFrameObserver(
      onRenderVideoFrame: (uid, connectionId, videoFrame) {
        // Only analyse the client's stream.
        if (uid == _clientRemoteUid) {
          _processFrame(videoFrame);
        }
      },
    );

    // Registration goes through MediaEngine in Agora v6.
    _engine!.getMediaEngine().registerVideoFrameObserver(_frameObserver!);
  }

  void _processFrame(VideoFrame frame) async {
    if (_isProcessing) return;

    final yBuffer = frame.yBuffer;
    if (yBuffer == null || yBuffer.isEmpty) return;

    _isProcessing = true;

    try {
      final inputImage = _convertToInputImage(frame);
      if (inputImage == null) return;

      final faces = await _faceDetector!.processImage(inputImage);
      if (faces.isEmpty) return;

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
    } catch (e) {
      debugPrint('[EmotionDetection] frame processing error: $e');
    } finally {
      // Throttle to ~2 readings per second.
      await Future.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;
    }
  }

  InputImage? _convertToInputImage(VideoFrame frame) {
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
        // Remote frames from Agora are typically upright (0°).
        // If faces are not detected, try rotation270deg.
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.nv21,
        bytesPerRow: frame.yStride ?? width,
      ),
    );
  }

  List<EmotionReading> get allReadings => List.unmodifiable(sessionReadings);

  Future<void> dispose() async {
    if (_frameObserver != null) {
      _engine?.getMediaEngine().unregisterVideoFrameObserver(_frameObserver!);
      _frameObserver = null;
    }
    await _faceDetector?.close();
    _faceDetector = null;
    _engine = null;
    _clientRemoteUid = null;
  }
}