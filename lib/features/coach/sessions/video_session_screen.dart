// lib/features/coach/sessions/video_session_screen.dart
//
// ── FIXES ────────────────────────────────────────────────────────────────────
//
// FIX 1 (Shared-provider / both sides stuck "waiting"):
//   AgoraProvider and EmotionProvider are NO LONGER global. Each session
//   screen creates its own instances via ChangeNotifierProvider scoped to the
//   screen. The static factory VideoSessionScreen.route() wraps the screen in
//   the correct providers — use this to navigate.
//
// FIX 2 (Emotion analyzes coach's face instead of client's):
//   startDetection() is now called INSIDE the onRemoteUserJoined callback
//   (via a listener on AgoraProvider), guaranteeing that:
//     a) the client's UID is known, and
//     b) the remote video stream is flowing before ML Kit tries to read it.
//   The clientRemoteUid is passed to EmotionProvider.startDetection() so
//   EmotionDetectionService registers onRenderVideoFrame for that UID only.
//
// FIX 3 (RtcConnection channelId was empty string):
//   Already fixed in the previous version. Preserved: _RemoteVideo passes
//   widget.channelName to RtcConnection(channelId: channelName).
//
// FIX 4 (clientAllowsAnalysis read from coach's own UserModel):
//   The flag is accepted as a constructor parameter from the caller —
//   it must come from the booking's client data, NOT AuthProvider.user.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/agora_provider.dart';
import '../../../core/providers/emotion_provider.dart';
import '../../../core/services/emotion_analyzer.dart';
import 'emotion_summary_screen.dart';

class VideoSessionScreen extends StatefulWidget {
  final String bookingId;
  final String channelName;

  /// Must come from the CLIENT's Firestore document or the booking record —
  /// NOT from AuthProvider.user (which is the coach).
  final bool clientAllowsAnalysis;

  const VideoSessionScreen({
    super.key,
    required this.bookingId,
    required this.channelName,
    required this.clientAllowsAnalysis,
  });

  /// ── Convenience factory ──────────────────────────────────────────────────
  /// Always navigate using this route so the screen gets its own scoped
  /// AgoraProvider and EmotionProvider instances.
  ///
  /// ```dart
  /// Navigator.push(context, VideoSessionScreen.route(
  ///   bookingId: booking.id,
  ///   channelName: 'session_${booking.id}',
  ///   clientAllowsAnalysis: booking.clientAllowsAnalysis,
  /// ));
  /// ```
  static Route<void> route({
    required String bookingId,
    required String channelName,
    required bool clientAllowsAnalysis,
  }) {
    return MaterialPageRoute(
      builder: (_) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AgoraProvider()),
          ChangeNotifierProvider(create: (_) => EmotionProvider()),
        ],
        child: VideoSessionScreen(
          bookingId: bookingId,
          channelName: channelName,
          clientAllowsAnalysis: clientAllowsAnalysis,
        ),
      ),
    );
  }

  @override
  State<VideoSessionScreen> createState() => _VideoSessionScreenState();
}

class _VideoSessionScreenState extends State<VideoSessionScreen> {
  /// Tracks whether we have already started emotion detection this session.
  /// Prevents duplicate calls if the remote user briefly disconnects and
  /// reconnects.
  bool _detectionStarted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. Request permissions.
      await [Permission.camera, Permission.microphone].request();
      if (!mounted) return;

      final agora = context.read<AgoraProvider>();

      // 2. FIX 2: Listen for the remote user joining so we can start detection
      //    only after the client's UID is known and their stream is flowing.
      agora.addListener(_onAgoraStateChanged);

      // 3. Join the channel.
      await agora.initAndJoin(widget.channelName);
    });
  }

  /// Called whenever AgoraProvider notifies. Starts emotion detection as soon
  /// as the client (remote user) has joined and their UID is available.
  void _onAgoraStateChanged() {
    if (!mounted) return;
    final agora = context.read<AgoraProvider>();

    if (agora.remoteUserConnected &&
        agora.remoteUid != null &&
        agora.service.engine != null &&
        widget.clientAllowsAnalysis &&
        !_detectionStarted) {
      _detectionStarted = true;
      // Start on the next microtask to avoid calling setState inside a listener.
      Future.microtask(() async {
        if (!mounted) return;
        await context.read<EmotionProvider>().startDetection(
          agora.service.engine!,
          agora.remoteUid!, // FIX 2: client's remote UID, not local camera
        );
      });
    }
  }

  @override
  void dispose() {
    // Remove the listener before the widget is torn down.
    try {
      context.read<AgoraProvider>().removeListener(_onAgoraStateChanged);
    } catch (_) {}
    super.dispose();
  }

  Future<void> _endSession() async {
    try {
      context.read<AgoraProvider>().removeListener(_onAgoraStateChanged);
    } catch (_) {}

    await context.read<EmotionProvider>().stopAndSave(widget.bookingId);
    await context.read<AgoraProvider>().endCall();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<EmotionProvider>(),
          child: EmotionSummaryScreen(bookingId: widget.bookingId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Consumer2<AgoraProvider, EmotionProvider>(
        builder: (context, agora, emotion, _) {
          if (agora.isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    'Connecting...',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (agora.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.redAccent, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      agora.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Go Back',
                          style: TextStyle(color: Color(0xFF2F8F9D))),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              // ── Client's video feed — full screen ──────────────────────
              _RemoteVideo(agora: agora, channelName: widget.channelName),

              // ── Coach's own preview — top-right ────────────────────────
              if (agora.service.engine != null)
                Positioned(
                  top: 60,
                  right: 16,
                  child: _LocalPreview(agora: agora),
                ),

              // ── Live emotion badge — top-left ──────────────────────────
              Positioned(
                top: 60,
                left: 16,
                child: _EmotionBadge(emotion: emotion),
              ),

              // ── Session controls — bottom ──────────────────────────────
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: _SessionControls(
                  agora: agora,
                  onEndCall: _endSession,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Remote video ──────────────────────────────────────────────────────────────

class _RemoteVideo extends StatelessWidget {
  final AgoraProvider agora;
  final String channelName;

  const _RemoteVideo({required this.agora, required this.channelName});

  @override
  Widget build(BuildContext context) {
    if (!agora.remoteUserConnected ||
        agora.remoteUid == null ||
        agora.service.engine == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Waiting for client to join...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: agora.service.engine!,
        canvas: VideoCanvas(uid: agora.remoteUid),
        // FIX 3: Use actual channelName, not empty string.
        connection: RtcConnection(channelId: channelName),
      ),
    );
  }
}

// ── Local preview (coach) ─────────────────────────────────────────────────────

class _LocalPreview extends StatelessWidget {
  final AgoraProvider agora;
  const _LocalPreview({required this.agora});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 100,
        height: 140,
        child: AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: agora.service.engine!,
            canvas: const VideoCanvas(uid: 0), // 0 = local user
          ),
        ),
      ),
    );
  }
}

// ── Live emotion badge ────────────────────────────────────────────────────────

class _EmotionBadge extends StatelessWidget {
  final EmotionProvider emotion;
  const _EmotionBadge({required this.emotion});

  @override
  Widget build(BuildContext context) {
    final reading = emotion.currentEmotion;
    if (reading == null) return const SizedBox.shrink();

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(reading.emotion),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _badgeColor(reading.emotion).withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emoji(reading.emotion),
                style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              reading.emotion.name.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _badgeColor(DetectedEmotion e) {
    switch (e) {
      case DetectedEmotion.happy:
        return Colors.green.shade600;
      case DetectedEmotion.calm:
        return const Color(0xFF2F8F9D);
      case DetectedEmotion.tense:
        return Colors.orange.shade700;
      case DetectedEmotion.distracted:
        return Colors.grey.shade600;
      case DetectedEmotion.sad:
        return Colors.blue.shade700;
      case DetectedEmotion.neutral:
        return Colors.grey.shade500;
    }
  }

  String _emoji(DetectedEmotion e) {
    switch (e) {
      case DetectedEmotion.happy:
        return '😊';
      case DetectedEmotion.calm:
        return '😌';
      case DetectedEmotion.tense:
        return '😟';
      case DetectedEmotion.distracted:
        return '👀';
      case DetectedEmotion.sad:
        return '😔';
      case DetectedEmotion.neutral:
        return '😐';
    }
  }
}

// ── Session controls ──────────────────────────────────────────────────────────

class _SessionControls extends StatelessWidget {
  final AgoraProvider agora;
  final VoidCallback onEndCall;
  const _SessionControls({required this.agora, required this.onEndCall});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ControlButton(
          icon: agora.isMicMuted ? Icons.mic_off : Icons.mic,
          color: agora.isMicMuted ? Colors.red : Colors.white,
          onTap: () => context.read<AgoraProvider>().toggleMic(),
        ),
        const SizedBox(width: 24),
        _ControlButton(
          icon: Icons.call_end,
          color: Colors.white,
          background: Colors.red,
          onTap: onEndCall,
          size: 64,
        ),
        const SizedBox(width: 24),
        _ControlButton(
          icon: agora.isCameraOff ? Icons.videocam_off : Icons.videocam,
          color: agora.isCameraOff ? Colors.red : Colors.white,
          onTap: () => context.read<AgoraProvider>().toggleCamera(),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;
  final double size;

  const _ControlButton({
    required this.icon,
    required this.color,
    required this.onTap,
    this.background = const Color(0x66000000),
    this.size = 52,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: size * 0.45),
      ),
    );
  }
}