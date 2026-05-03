// lib/core/providers/agora_provider.dart

import 'package:flutter/foundation.dart';
import '../services/agora_service.dart';

/// State management layer for the Agora video call.
///
/// Registered in [main.dart] MultiProvider.
/// Consumed by [VideoSessionScreen].
class AgoraProvider extends ChangeNotifier {
  final AgoraService _service = AgoraService();

  bool isInCall = false;
  bool isLoading = false;

  /// True once the remote user (client) has joined the Agora channel.
  bool remoteUserConnected = false;

  /// UID assigned by Agora to the remote user. Required by [AgoraVideoView].
  int? remoteUid;

  String? error;

  /// Exposed so [VideoSessionScreen] / [EmotionDetectionService] can access
  /// the underlying engine and register frame observers.
  AgoraService get service => _service;

  bool get isMicMuted => _service.isMicMuted;
  bool get isCameraOff => _service.isCameraOff;

  /// Fired by [VideoSessionScreen] when it wants to know the moment the
  /// remote user (client) joins — used to start emotion frame capture only
  /// after real frames are actually flowing.
  VoidCallback? onRemoteUserConnected;

  Future<void> initAndJoin(String channelName) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await _service.initialize();

      _service.onRemoteUserJoined = (uid) {
        remoteUserConnected = true;
        remoteUid = uid;
        notifyListeners();
        // Notify VideoSessionScreen so it can enable frame capture now that
        // real remote frames are flowing.
        onRemoteUserConnected?.call();
      };
      _service.onRemoteUserLeft = (uid) {
        remoteUserConnected = false;
        remoteUid = null;
        notifyListeners();
      };

      await _service.joinChannel(channelName);
      isInCall = true;
    } catch (e) {
      error = 'Failed to join session: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> endCall() async {
    onRemoteUserConnected = null;
    await _service.leaveChannel();
    isInCall = false;
    remoteUserConnected = false;
    remoteUid = null;
    notifyListeners();
  }

  Future<void> toggleMic() async {
    await _service.toggleMic();
    notifyListeners();
  }

  Future<void> toggleCamera() async {
    await _service.toggleCamera();
    notifyListeners();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }
}
