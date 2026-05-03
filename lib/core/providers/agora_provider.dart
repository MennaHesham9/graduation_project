// lib/core/providers/agora_provider.dart
//
// ── FIXES ────────────────────────────────────────────────────────────────────
//
// FIX 1 (Shared-instance / "both sides stuck waiting"):
//   AgoraProvider was registered ONCE in main.dart's MultiProvider, so the
//   coach screen and client screen shared the exact same instance. When the
//   client called initAndJoin(), it overwrote the coach's remoteUid and vice
//   versa. The provider is now NO LONGER registered in main.dart — instead
//   each video-session screen creates its own instance via
//   ChangeNotifierProvider at the top of its widget tree. See the updated
//   VideoSessionScreen and ClientVideoSessionScreen for how this is done.
//
// FIX 2 (remoteUid not exposed to EmotionDetectionService):
//   EmotionDetectionService needs the remote UID so it can register
//   onRenderVideoFrame (the client's incoming stream) instead of
//   onCaptureVideoFrame (the coach's outgoing stream). The provider now
//   exposes remoteUid publicly and passes it to startDetection().
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import '../services/agora_service.dart';

/// State management layer for the Agora video call.
///
/// ⚠️  Do NOT register this in main.dart's MultiProvider.
/// Instead, wrap each video-session screen in its own ChangeNotifierProvider:
///
/// ```dart
/// ChangeNotifierProvider(
///   create: (_) => AgoraProvider(),
///   child: VideoSessionScreen(...),
/// )
/// ```
///
/// This ensures the coach and client each get an independent engine + state.
class AgoraProvider extends ChangeNotifier {
  final AgoraService _service = AgoraService();

  bool isInCall = false;
  bool isLoading = false;

  /// True once the remote peer has joined the Agora channel.
  bool remoteUserConnected = false;

  /// UID assigned by Agora to the remote user. Required by [AgoraVideoView]
  /// and by [EmotionDetectionService] to subscribe to the correct video stream.
  int? remoteUid;

  String? error;

  AgoraService get service => _service;

  bool get isMicMuted => _service.isMicMuted;
  bool get isCameraOff => _service.isCameraOff;

  /// Initialises the Agora engine and joins the session channel.
  ///
  /// [channelName] must match on both sides: `'session_${bookingId}'`
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