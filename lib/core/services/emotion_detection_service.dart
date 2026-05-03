// lib/core/services/emotion_detection_service.dart

import 'dart:typed_data';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'agora_service.dart';
import 'emotion_analyzer.dart';

/// Owns the ML Kit face detector and wires it to Agora's remote video frames.
///
/// Lifecycle:
///   1. [initialize] — inits the detector and registers [AgoraService.onFrameCaptured]
///      so remote frames flow into [_processFrame].
///   2. Frames flow: Agora remote video → [_processFrame] → [EmotionAnalyzer.analyze]
///      → [onEmotionDetected] callback → [EmotionProvider].
///   3. [dispose] — unregisters the frame hook and releases ML Kit resources.
///
/// One frame is processed every ~500 ms to balance accuracy and battery.
///
/// KEY DESIGN DECISION: We deliberately do NOT open a CameraController here.
/// Opening a second CameraController while Agora owns the front camera causes
/// a hardware conflict that silently drops all frames — which is exactly why
/// the summary was always empty in the previous implementation. Instead we tap
/// directly into Agora's already-decoded remote frame pipeline.
class EmotionDetectionService {
  final AgoraService _agoraService;
  FaceDetector? _faceDetector;
  bool _isProcessing = false;

  /// All readings collected since [initialize] was called.
  /// Read by [EmotionProvider.stopAndSave] to build the [EmotionSummary].
  final List<EmotionReading> sessionReadings = [];

  /// [EmotionProvider] sets this to update its own state on each reading.
  Function(EmotionReading)? onEmotionDetected;

  EmotionDetectionService(this._agoraService);

  Future<void> initialize() async {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,  // smileProb + eyeOpenProb
        enableLandmarks: false,      // not needed, saves compute
        enableTracking: true,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    // Wire into Agora's frame pipeline — no separate camera needed.
    _agoraService.onFrameCaptured = _processFrame;
    _agoraService.enableFrameCapture();
  }

  void _processFrame(Uint8List bytes, int width, int height) async {
    // Guard: skip frame if the previous one is still being processed.
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertToInputImage(bytes, width, height);
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
    } finally {
      // Throttle to ~2 readings per second.
      await Future.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;
    }
  }

  InputImage? _convertToInputImage(Uint8List bytes, int width, int height) {
    // Agora delivers frames as NV21 (Android) or BGRA (iOS) depending on
    // platform. We use InputImageFormat.nv21 as the default; if you observe
    // misclassified emotions on iOS, switch to bgra8888 conditionally.
    const format = InputImageFormat.nv21;
    final bytesPerRow = width; // NV21 Y-plane row stride == width

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: format,
        bytesPerRow: bytesPerRow,
      ),
    );
  }

  /// Unmodifiable view of all readings — safe to pass to [EmotionSummary].
  List<EmotionReading> get allReadings => List.unmodifiable(sessionReadings);

  Future<void> dispose() async {
    _agoraService.disableFrameCapture();
    _agoraService.onFrameCaptured = null;
    await _faceDetector?.close();
    _faceDetector = null;
  }
}
