// lib/core/services/agora_service.dart

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:agora_token_generator/agora_token_generator.dart';
import 'dart:typed_data';

const String agoraAppId = 'dd4c1367c7c14070be2c9e8964f249e6';

// ⚠️ For graduation project only — do NOT commit to a public GitHub repo.
// In production, move token generation to a Firebase Cloud Function.
const String agoraAppCertificate = '359b6b8e0b554d2092ef00a8442a0813';

class AgoraService {
  RtcEngine? _engine;
  bool _isMicMuted = false;
  bool _isCameraOff = false;

  Function(int uid)? onRemoteUserJoined;
  Function(int uid)? onRemoteUserLeft;
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

  Future<void> joinChannel(String channelName) async {
    // Generate a token locally using App ID + App Certificate
    final token = RtcTokenBuilder.buildTokenWithUid(
      appId: agoraAppId,
      appCertificate: agoraAppCertificate,
      channelName: channelName,
      uid: 0,                  // 0 = Agora auto-assigns UID
      tokenExpireSeconds: 3600, // token valid for 1 hour
    );

    await _engine!.joinChannel(
      token: token,
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
    await _engine?.leaveChannel();
    await _engine?.release();
    _engine = null;
  }
}