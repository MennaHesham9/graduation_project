// lib/core/services/emotion_detection_service.dart

import 'dart:typed_data';
import 'dart:ui';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'agora_service.dart';
import 'emotion_analyzer.dart';

/// Owns the ML Kit face detector and wires it to Agora's remote video frames.
///
/// Lifecycle:
///   1. [initialize] — warms up ML Kit detector. Does NOT start frame capture.
///   2. [activateFrameCapture] — called once the remote client joins the Agora
///      channel. Registers [AgoraService.onFrameCaptured] so frames flow into
///      [_processFrame]. Separating these two steps is critical: registering
///      the observer before the remote user joins delivers zero frames.
///   3. Frames flow: Agora remote video → [_processFrame] → [EmotionAnalyzer]
///      → [onEmotionDetected] callback → [EmotionProvider].
///   4. [dispose] — unregisters the frame hook and releases ML Kit resources.
///
/// One frame is processed every ~500 ms to balance accuracy and battery.
class EmotionDetectionService {
  final AgoraService _agoraService;
  FaceDetector? _faceDetector;
  bool _isProcessing = false;

  /// All readings collected since [activateFrameCapture] was called.
  final List<EmotionReading> sessionReadings = [];

  /// [EmotionProvider] sets this to update its state on each reading.
  Function(EmotionReading)? onEmotionDetected;

  EmotionDetectionService(this._agoraService);

  /// Warms up the ML Kit detector. Fast — no camera or Agora interaction.
  Future<void> initialize() async {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,  // smileProb + eyeOpenProb
        enableLandmarks: false,
        enableTracking: true,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.fast,
      ),
    );
  }

  /// Registers the Agora frame observer and starts processing.
  /// MUST be called only after the remote user has joined the channel —
  /// otherwise the observer fires zero times and the summary stays empty.
  void activateFrameCapture() {
    _agoraService.onFrameCaptured = _processFrame;
    _agoraService.enableFrameCapture();
  }

  void _processFrame(Uint8List bytes, int width, int height) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertToInputImage(bytes, width, height);
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
    } catch (_) {
      // Swallow frame-level errors (e.g. bad buffer, transient ML Kit error).
      // A single bad frame must never crash the session.
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;
    }
  }

  /// Converts the raw Agora frame into an [InputImage] for ML Kit.
  ///
  /// **Format rationale**
  /// Agora's `onRenderVideoFrame` delivers *rendered* (post-processed) frames
  /// in RGBA — not the YUV format used by the local camera pipeline.
  /// The full pixel data lands in `frame.yBuffer` as `width × height × 4` bytes.
  ///
  /// ML Kit's equivalent format is [InputImageFormat.bgra8888], which expects:
  ///   • 4 bytes per pixel  →  `bytesPerRow = width * 4`
  ///   • no separate UV planes
  ///
  /// The old code used `nv21` with `bytesPerRow = width` (1 byte per pixel),
  /// which mismatched both the channel count and the stride, causing:
  ///   "ByteBuffer size and format don't match"
  InputImage? _convertToInputImage(Uint8List bytes, int width, int height) {
    // Validate before handing to ML Kit — a mismatched buffer throws a
    // PlatformException; we'd rather drop the frame silently.
    final expectedBytes = width * height * 4; // RGBA: 4 channels × 1 byte
    if (bytes.lengthInBytes != expectedBytes) return null;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: InputImageRotation.rotation0deg,
        format: InputImageFormat.bgra8888, // RGBA rendered frame from Agora
        bytesPerRow: width * 4,            // 4 bytes per pixel, not 1
      ),
    );
  }

  List<EmotionReading> get allReadings => List.unmodifiable(sessionReadings);

  Future<void> dispose() async {
    _agoraService.disableFrameCapture();
    _agoraService.onFrameCaptured = null;
    await _faceDetector?.close();
    _faceDetector = null;
  }
}
