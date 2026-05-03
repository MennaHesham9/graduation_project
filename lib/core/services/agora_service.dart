// lib/core/services/agora_service.dart

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'dart:typed_data';

// ⚠️  Replace with your App ID from console.agora.io
// In production: generate tokens server-side via a Firebase Cloud Function
// and NEVER ship the raw App ID in a release build.
const String agoraAppId = 'dd4c1367c7c14070be2c9e8964f249e6';

class AgoraService {
  RtcEngine? _engine;
  bool _isMicMuted = false;
  bool _isCameraOff = false;

  // Callbacks wired by AgoraProvider
  Function(int uid)? onRemoteUserJoined;
  Function(int uid)? onRemoteUserLeft;

  /// Set by [EmotionDetectionService] when emotion analysis is active.
  /// Called on every remote video frame (~15 fps) with raw RGBA bytes
  /// (width × height × 4). [EmotionDetectionService] throttles internally to ~2 fps.
  Function(Uint8List bytes, int width, int height)? onFrameCaptured;

  Future<void> initialize() async {
    _engine = createAgoraRtcEngine();

    await _engine!.initialize(const RtcEngineContext(appId: agoraAppId));
    await _engine!.enableVideo();
    await _engine!.startPreview();

    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 480),
        frameRate: 15,
        bitrate: 0,
      ),
    );

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onUserJoined: (connection, uid, elapsed) {
          onRemoteUserJoined?.call(uid);
        },
        onUserOffline: (connection, uid, reason) {
          onRemoteUserLeft?.call(uid);
        },
      ),
    );
  }

  /// Registers the video frame observer via the MediaEngine so
  /// [onFrameCaptured] fires for every rendered remote frame.
  ///
  /// Call this AFTER [initialize] and only when emotion analysis is active.
  ///
  /// NOTE: In agora_rtc_engine v6 the observer is registered on the
  /// MediaEngine object, not on RtcEngine directly. The position parameter
  /// uses [VideoModulePosition] (not VideoObserverPosition).
  // Stored so the same instance can be passed to unregisterVideoFrameObserver.
  VideoFrameObserver? _frameObserver;

  void enableFrameCapture() {
    _frameObserver = VideoFrameObserver(
      onRenderVideoFrame: (channelId, uid, frame) {
        // uid == 0 is the local preview; we want the remote client's frames.
        if (uid != 0 && onFrameCaptured != null) {
          final bytes = frame.yBuffer;
          if (bytes != null) {
            onFrameCaptured!(bytes, frame.width ?? 640, frame.height ?? 480);
          }
        }
      },
    );
    // registerVideoFrameObserver takes only the observer — no position arg.
    _engine?.getMediaEngine().registerVideoFrameObserver(_frameObserver!);
  }

  /// Stops frame delivery. Called by [EmotionDetectionService.dispose].
  void disableFrameCapture() {
    if (_frameObserver != null) {
      // unregisterVideoFrameObserver requires the original observer instance.
      _engine?.getMediaEngine().unregisterVideoFrameObserver(_frameObserver!);
      _frameObserver = null;
    }
  }

  Future<void> joinChannel(String channelName) async {
    await _engine!.joinChannel(
      token: '',
      channelId: channelName,
      uid: 0,
      options: const ChannelMediaOptions(
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );
  }

  Future<void> leaveChannel() async {
    await _engine?.leaveChannel();
  }

  Future<void> toggleMic() async {
    _isMicMuted = !_isMicMuted;
    await _engine!.muteLocalAudioStream(_isMicMuted);
  }

  Future<void> toggleCamera() async {
    _isCameraOff = !_isCameraOff;
    await _engine!.muteLocalVideoStream(_isCameraOff);
  }

  Future<void> switchCamera() async {
    await _engine!.switchCamera();
  }

  bool get isMicMuted => _isMicMuted;
  bool get isCameraOff => _isCameraOff;

  RtcEngine? get engine => _engine;

  Future<void> dispose() async {
    disableFrameCapture();
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }
}
