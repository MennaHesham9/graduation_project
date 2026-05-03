// lib/core/services/emotion_detection_service.dart

import 'dart:io' show Platform;
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'emotion_analyzer.dart';

/// Owns the device camera and ML Kit face detector.
///
/// Lifecycle:
///   1. [initialize] — opens the front camera, inits the detector, starts
///      the image stream.
///   2. Frames flow: camera → [_processFrame] → [EmotionAnalyzer.analyze]
///      → [onEmotionDetected] callback → [EmotionProvider].
///   3. [dispose] — stops the stream and releases native resources.
///
/// One frame is processed every ~500 ms to balance accuracy and battery.
class EmotionDetectionService {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  bool _isProcessing = false;

  /// All readings collected since [initialize] was called.
  /// Read by [EmotionProvider.stopAndSave] to build the [EmotionSummary].
  final List<EmotionReading> sessionReadings = [];

  /// [EmotionProvider] sets this to update its own state on each reading.
  Function(EmotionReading)? onEmotionDetected;

  Future<void> initialize() async {
    final cameras = await availableCameras();

    // Prefer front camera — the coach's device analyses the client's face,
    // which arrives via Agora in the front camera preview on the coach side.
    final frontCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
      // nv21 is required by ML Kit on Android; bgra8888 on iOS.
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await _cameraController!.initialize();

    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,  // smileProb + eyeOpenProb
        enableLandmarks: false,      // not needed, saves compute
        enableTracking: true,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    await _cameraController!.startImageStream(_processFrame);
  }

  void _processFrame(CameraImage image) async {
    // Guard: skip frame if the previous one is still being processed.
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertToInputImage(image);
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
      // Throttle to ~2 readings per second. Increase to 800 ms if battery
      // drain is reported on older devices.
      await Future.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;
    }
  }

  InputImage? _convertToInputImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final rotation =
    InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final plane = image.planes.first;
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  /// Unmodifiable view of all readings — safe to pass to [EmotionSummary].
  List<EmotionReading> get allReadings => List.unmodifiable(sessionReadings);

  Future<void> dispose() async {
    await _cameraController?.stopImageStream();
    await _cameraController?.dispose();
    await _faceDetector?.close();
    _cameraController = null;
    _faceDetector = null;
  }
}