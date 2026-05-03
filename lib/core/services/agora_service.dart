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

  // Unused in current build — kept as the Interface A hook for Engineer 2
  // if you later want frame delivery through AgoraService instead of a
  // separate CameraController in EmotionDetectionService.
  Function(Uint8List bytes, int width, int height)? onFrameCaptured;

  Future<void> initialize() async {
    _engine = createAgoraRtcEngine();

    await _engine!.initialize(const RtcEngineContext(appId: agoraAppId));
    await _engine!.enableVideo();
    await _engine!.startPreview();

    await _engine!.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 480),
        frameRate: 15,   // conserves battery; sufficient for coaching sessions
        bitrate: 0,      // auto
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

  /// Called by [AgoraProvider.initAndJoin]. channelName should be
  /// 'session_\${bookingId}' so coach and client share the same channel.
  Future<void> joinChannel(String channelName) async {
    await _engine!.joinChannel(
      token: '',           // empty = Testing mode; swap for a real token in prod
      channelId: channelName,
      uid: 0,              // 0 → Agora assigns UID automatically
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

  /// Exposed so [VideoSessionScreen] can build [AgoraVideoView] widgets.
  RtcEngine? get engine => _engine;

  Future<void> dispose() async {
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }
}