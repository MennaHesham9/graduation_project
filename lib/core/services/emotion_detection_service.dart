// lib/core/services/emotion_detection_service.dart

import 'dart:typed_data';
import 'dart:ui' show Size; // ← FIX 3: Size lives in dart:ui, not in flutter/material

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/foundation.dart';

import 'emotion_analyzer.dart';

/// Owns the ML Kit face detector and taps into the Agora engine's local
/// video frames — without opening a competing [CameraController].
///
/// Lifecycle:
///   1. [initialize] — inits the detector and registers the Agora frame observer
///      via [RtcEngine.getMediaEngine().registerVideoFrameObserver()].
///   2. Frames flow: Agora engine → [_onCaptureVideoFrame] → [EmotionAnalyzer.analyze]
///      → [onEmotionDetected] callback → [EmotionProvider].
///   3. [dispose] — unregisters the observer and releases ML Kit resources.
///
/// One frame is processed every ~500 ms to balance accuracy and battery.
class EmotionDetectionService {
  FaceDetector? _faceDetector;
  RtcEngine? _engine;
  VideoFrameObserver? _frameObserver; // stored so we can pass it to unregister
  bool _isProcessing = false;

  /// All readings collected since [initialize] was called.
  /// Read by [EmotionProvider.stopAndSave] to build the [EmotionSummary].
  final List<EmotionReading> sessionReadings = [];

  /// [EmotionProvider] sets this to update its own state on each reading.
  Function(EmotionReading)? onEmotionDetected;

  /// Must be called with the already-initialised [RtcEngine] from [AgoraService].
  /// This avoids any attempt to open a second camera stream.
  Future<void> initialize(RtcEngine engine) async {
    _engine = engine;

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // smileProb + eyeOpenProb
        enableLandmarks: false,     // not needed, saves compute
        enableTracking: true,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    // FIX 1: In Agora v6 the frame observer belongs to MediaEngine, not RtcEngine.
    // Use _engine.getMediaEngine().registerVideoFrameObserver() instead of
    // _engine.registerVideoFrameObserver().
    _frameObserver = VideoFrameObserver(
      onCaptureVideoFrame: (sourceType, videoFrame) {
        _processFrame(videoFrame);
      },
    );
    _engine!.getMediaEngine().registerVideoFrameObserver(_frameObserver!);
  }

  void _processFrame(VideoFrame frame) async {
    // Throttle: skip if previous frame is still being analysed.
    if (_isProcessing) return;

    // We need actual pixel data — bail early if the frame is empty.
    final yBuffer = frame.yBuffer;
    if (yBuffer == null || yBuffer.isEmpty) return;

    _isProcessing = true;

    try {
      final inputImage = _convertToInputImage(frame);
      if (inputImage == null) return;

      final faces = await _faceDetector!.processImage(inputImage);
      if (faces.isEmpty) return; // No face visible — skip, don't log neutral

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

    // Build NV21 byte array (Y plane + interleaved VU) — required by ML Kit
    // on Android. On iOS, Agora delivers BGRA which ML Kit also accepts via
    // InputImageFormat.bgra8888; the NV21 path still works via the byte array
    // constructor so we use one code-path for both platforms.
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
      // Fallback: Y-plane only (grayscale — face detection still works)
      bytes = Uint8List.fromList(yBuffer);
    }

    // FIX 3: Size is imported from dart:ui (see top of file).
    // Previously missing import caused "The method 'Size' isn't defined" error.
    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        // Agora front-camera frames on Android are rotated 270°.
        rotation: InputImageRotation.rotation270deg,
        format: InputImageFormat.nv21,
        bytesPerRow: frame.yStride ?? width,
      ),
    );
  }

  /// Unmodifiable view of all readings — safe to pass to [EmotionSummary].
  List<EmotionReading> get allReadings => List.unmodifiable(sessionReadings);

  Future<void> dispose() async {
    // FIX 2: In Agora v6 unregisterVideoFrameObserver also belongs to
    // MediaEngine. Use _engine.getMediaEngine().unregisterVideoFrameObserver()
    // instead of _engine.unregisterVideoFrameObserver().
    if (_frameObserver != null) {
      _engine?.getMediaEngine().unregisterVideoFrameObserver(_frameObserver!);
      _frameObserver = null;
    }
    await _faceDetector?.close();
    _faceDetector = null;
    _engine = null;
  }
}