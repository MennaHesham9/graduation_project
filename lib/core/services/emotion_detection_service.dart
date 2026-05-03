// lib/core/services/emotion_detection_service.dart

import 'dart:typed_data';
import 'dart:ui';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'emotion_analyzer.dart';

/// Owns the ML Kit face detector and receives frames from the Agora remote
/// video stream (the client's face as seen by the coach).
///
/// Agora 6.x API note:
///   Frames are registered via engine.getMediaEngine().registerVideoFrameObserver()
///   NOT via engine.registerVideoFrameObserver() — that method does not exist in 6.x.
class EmotionDetectionService {
  FaceDetector? _faceDetector;
  bool _isProcessing = false;
  int? _remoteUid;
  RtcEngine? _engine;
  VideoFrameObserver? _frameObserver;

  final List<EmotionReading> sessionReadings = [];
  Function(EmotionReading)? onEmotionDetected;

  Future<void> initialize(RtcEngine engine, int remoteUid) async {
    _engine = engine;
    _remoteUid = remoteUid;

    // Init ML Kit FIRST so it is ready when frames arrive
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: false,
        enableTracking: true,
        minFaceSize: 0.15,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

    // Agora 6.x: must go through getMediaEngine(), not directly on RtcEngine
    _frameObserver = VideoFrameObserver(
      onRenderVideoFrame: (channelId, uid, frame) {
        if (uid != _remoteUid) return;
        _processFrame(frame);
      },
    );

    engine.getMediaEngine().registerVideoFrameObserver(_frameObserver!);
  }

  void _processFrame(VideoFrame frame) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final inputImage = _convertAgoraFrame(frame);
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
      // Skip bad frames silently
    } finally {
      await Future.delayed(const Duration(milliseconds: 500));
      _isProcessing = false;
    }
  }

  InputImage? _convertAgoraFrame(VideoFrame frame) {
    try {
      final bytes = frame.uBuffer;
      if (bytes == null || bytes.isEmpty) return null;

      return InputImage.fromBytes(
        bytes: Uint8List.fromList(bytes),
        metadata: InputImageMetadata(
          size: Size(
            frame.width?.toDouble() ?? 640,
            frame.height?.toDouble() ?? 480,
          ),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: (frame.width ?? 640) * 4,
        ),
      );
    } catch (_) {
      return null;
    }
  }

  List<EmotionReading> get allReadings => List.unmodifiable(sessionReadings);

  Future<void> dispose() async {
    if (_frameObserver != null) {
      // Agora 6.x: unregister via getMediaEngine()
      _engine?.getMediaEngine().unregisterVideoFrameObserver(_frameObserver!);
      _frameObserver = null;
    }
    await _faceDetector?.close();
    _faceDetector = null;
    _engine = null;
    _remoteUid = null;
  }
}